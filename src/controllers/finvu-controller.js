const axios = require('axios');
const apiClient = require('../utils/helpers/apiClient');
const { Finvu, FipsMetric } = require('../models/index');
const { getDeviceIdsByUserId } = require('../utils/helpers/getDeviceIds');
const { SendNotificationToDeviceSpecific } = require('../services/notification-service');
const { User, FailedTransaction, ConsentHandleId } = require('../models/index');
const generateToken = require('../utils/helpers/generate-finvu-token');
const getISTTimestamp = require('../utils/helpers/get-IST-timeStamp');
const redisClient = require('../config/redis-config');
const logger = require('../utils/common/logger');
const finvuMap = new Map();
const { DateTime } = require('luxon');
const mongoose = require('mongoose');
// const WebSocketService = require('../services/websocket-service');
const { updateNextFetchByUserId } = require('../utils/helpers/update-existing-accounts');

/**
 * Helper to publish WebSocket events via Redis Pub/Sub
 */
async function publishSocketEvent(userId, event, data) {
  await redisClient.publish('bank_events', JSON.stringify({ userId, event, data }));
}

const baseUrl = process.env.FINVU_URL;
const headers = {
  rid: process.env.FINVU_RID,
  ts: process.env.FINVU_TS,
  channelId: process.env.FINVU_CHANNEL_ID,
};

async function deleteConsentHandleById(handleId) {
  try {
    const result = await ConsentHandleId.findOneAndDelete({ handleId });
    return '';
  } catch (error) {
    console.error('Error deleting consent handle:', error);
    return '';
  }
}

async function storeOrUpdateConsentHandle({ custId, handleId, userId }) {
  try {
    const result = await ConsentHandleId.findOneAndUpdate(
      { handleId }, // find by handleId
      {
        custId,
        handleId,
        userId,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // reset expiry
      },
      {
        new: true,
        upsert: true, // create if not exists
        setDefaultsOnInsert: true,
      }
    );
    return result;
  } catch (error) {
    console.error('Error in storeOrUpdateConsentHandle:', error);
    return '';
  }
}

async function loginAndGetHandleId(req, res) {
  try {
    const Id = req.user._id;
    const custId = req.body.custId;
    logger.debug(`custId: ${custId}`);

    // Step 1: Login to Auto-Transactions and get the token
    const token = await generateToken();
    logger.debug(`token from login ${token}`);

    // Step 2: Request Consent Handle ID
    const consentResponse = await apiClient.post(`${baseUrl}/ConsentRequestPlus`, token, {
      header: headers,
      body: {
        custId: custId,
        consentDescription: process.env.FINVU_CONSENT_DESCRIPTION,
        templateName: process.env.FINVU_TEMPLATE_NAME,
        userSessionId: process.env.FINVU_USER_SESSION_ID,
        redirectUrl: 'https://google.co.in',
        ConsentDetails: {},
        // aaId: process.env.FINVU_AA_ID,
        // "pan": "GDJHF8509I",
      },
    });

    if (consentResponse.status !== 200 && consentResponse.status !== 201) {
      return res.status(400).json({ message: 'Failed to get Consent Handle ID' });
    }
    const consentHandleId = consentResponse.data.body.ConsentHandle;
    logger.debug(`consentHandleId: ${consentHandleId} `);

    await storeOrUpdateConsentHandle({
      custId,
      handleId: consentHandleId,
      userId: Id,
    });

    //step-4: update the mobile for the User in the DB
    const updateMobile = await User.findOneAndUpdate({ _id: Id }, { $addToSet: { phone: req.body.number } }, { new: true });
    if (!updateMobile)
      return res.status(400).json({
        message: 'Failed to update mobile number, already the number is registered',
      });

    return res.json({ consentHandleId });
  } catch (error) {
    logger.error(`Error in loginAndGetHandleId: ${error}`);
    res.status(500).json({ error: error.message });
  }
}

// Function to fetch the transactions
async function fetchTransactions(req, res) {
  try {
    const { handleId, custId } = req.body;
    const userId = req.user._id;
    const token = await redisClient.get('auth_token');

    if (!handleId || !custId) return res.status(400).json({ message: 'Missing required parameters' });

    // Step 1: Fetch Consent Status
    let maxAtemptsForconsentResponse = 2;
    let attemptForConsentResponse = 0;
    let consentId = null;
    // Poll for consent status every 8 seconds
    while (!consentId && attemptForConsentResponse < maxAtemptsForconsentResponse) {
      logger.debug('entered into the while loop for consent status');
      const consentResponse = await fetchConsentStatus(token, handleId, custId);
      if (consentResponse.consentStatus == 'ACCEPTED') {
        consentId = consentResponse.consentId;
        break;
      }
      attemptForConsentResponse++;
      logger.debug(`Attempt ${attemptForConsentResponse}: consentResponse not received, retrying in 10 seconds...`);
      await new Promise((resolve) => setTimeout(resolve, 8000));
    }

    if (consentId == null) {
      const newObjectId = new mongoose.Types.ObjectId(userId);
      // const deviceIds = await getDeviceIdsByUserId(newObjectId);
      // await SendNotificationToDeviceSpecific(
      //   userId,
      //   `we couldn't able to fetch your bank details, try again later`,
      //   deviceIds,
      //   "/home"
      // );

      // webSocket message to the user
      // WebSocketService.sendMessage(custId, 'registerUser', {
      //   message: 'There is a problem with you bank server. Please try again later.',
      //   data: { number_id: custId, data: 'error' },
      // });

      await publishSocketEvent(custId, 'registerUser', {
        message: 'There is a problem with you bank server. Please try again later.',
        data: { number_id: custId, data: 'error' },
      });

      return res.status(400).json({ message: 'Consent ID not received' });
    }

    // Step 2: Fetch Consent Details
    const { from, to } = await fetchConsentDetails(token, consentId);
    const newFrom = DateTime.fromISO(from, { zone: 'utc' }).plus({ days: 1 });
    const formattedNewFrom = newFrom.setZone('utc', { keepLocalTime: false }).toFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZZ");

    const TO = getISTTimestamp();
    logger.debug(`to: ${TO}`);

    // step 3: Fetch the sessionId
    let maxAttempts = 5;
    let attempt = 0;
    let sessionId = null;
    // Poll for sessionId every 10 seconds
    while (!sessionId && attempt < maxAttempts) {
      sessionId = await initiateFIRequest(token, handleId, custId, consentId, formattedNewFrom, TO, userId);

      if (sessionId) {
        logger.debug(`Session ID received: ${sessionId}`);
        break;
      }

      attempt++;
      logger.debug(`Attempt ${attempt}: sessionId not received, retrying in 1 minute...`);
      await new Promise((resolve) => setTimeout(resolve, 10000)); // Wait for 10secs
    }

    // step 4: Check the status of the FI Request
    const checkStatus = await checkFIRequestStatus(token, consentId, sessionId, handleId, custId);

    const body = {
      sessionId,
      formattedNewFrom,
      to,
      custId,
      consentId,
      handleId,
    };
    req.body = { ...req.body, ...body };

    try {
      // Add Finvu Data to the DB
      await addFinvuData(req, res, userId);

      let maxAtemptsForStatus = 5;
      let atemptForStatus = 0;
      let checkStatus = null;
      // Poll for FIRequest every 10 seconds
      while (!checkStatus && atemptForStatus < maxAtemptsForStatus) {
        logger.debug('entered into the while loop for fiRequest status');
        checkStatus = await checkFIRequestStatus(token, consentId, sessionId, handleId, custId);
        if (checkStatus.fiRequestStatus == 'READY') {
          break;
        }
        atemptForStatus++;
        logger.debug(`Attempt ${atemptForStatus}: consentResponse not received, retrying in 10 seconds...`);
        await new Promise((resolve) => setTimeout(resolve, 10000));
      }
      logger.debug(`checkStatus: ${checkStatus}`);
    } catch (error) {
      logger.error(`error from fetchTransactions: ${error}`);
      res.status(200).json(body);
    }
  } catch (error) {
    console.error('Error fetching data:', error.response ? error.response.data : error.message);
    // res.status(500).json({ message: "Error fetching data", error: error.message });
  }
}

async function getStatus(req, res) {
  try {
    const id = req.params.id;

    // Fetch token from redis
    const token = await redisClient.get('auth_token');
    if (!token) {
      return res.status(401).json({ error: 'Auth token not found' });
    }

    // Find latest Finvu record by ID
    const findData = await ConsentHandleId.findOne({ _id: new mongoose.Types.ObjectId(id) }).sort({ createdAt: -1 });
    if (!findData) {
      return res.status(404).json({ error: 'Finvu record not found' });
    }

    // Extract values from DB record
    const { handleId, custId } = findData;
    // Call status API
    const data = await fetchConsentStatus(token, handleId, custId);

    return res.status(200).json({ data });
  } catch (error) {
    console.error('Error in getStatus:', error);
    return res.status(500).json({ error: error.message });
  }
}

// Fetch Consent Status from the server
async function fetchConsentStatus(token, handleId, custId) {
  try {
    const response = await axios.get(`${baseUrl}/ConsentStatus/${handleId}/${custId}`, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
    });
    logger.debug(`from fetchConsentStatus: ${response.data.body.consentStatus}`);
    return response.data.body;
  } catch (error) {
    logger.debug(`error from the fetchConsentStatus: ${error}`);
    throw new Error('Failed to fetch consent status');
  }
}

async function getFipsLatestMetricsAll(req, res) {
  try {
    const data = await fetchAndStoreFipsMetrics();
    return res.status(200).json({ data });
  } catch (error) {
    return res.status(400).json({ error: error });
  }
}

async function getFipsDetails(req, res) {
  try {
    const { fipIds } = req.body;
    if (!Array.isArray(fipIds) || fipIds.length === 0) {
      return res.status(400).json({ error: 'fipIds must be a non-empty array' });
    }
    // const sanitizedIds = fipIds
    // .filter(id => mongoose.Types.ObjectId.isValid(id))
    // .map(id => new mongoose.Types.ObjectId(id));

    const data = await FipsMetric.find({
      fip_id: { $in: fipIds },
      event_name: { $regex: /FIFetchResponse/, $options: 'i' },
    }).sort({ timestamp: -1 });
    console.log(data);
    var json = res.status(200).json({ data });
    return json;
  } catch (error) {
    console.error('getFipsDetails error:', error);
    return res.status(400).json({ error: error.message });
  }
}

// Fetch Consent Details based on consentId
async function fetchConsentDetails(token, consentId) {
  try {
    const response = await axios.get(`${baseUrl}/Consent/${consentId}`, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
    });
    const from = response.data.body.ConsentDetail.FIDataRange.from;
    const to = response.data.body.ConsentDetail.FIDataRange.to;

    return { from, to };
  } catch (error) {
    logger.debug(`error from the fetchConsentDetails: ${error}`);
    throw new Error('Failed to fetch consent details');
  }
}

// Initiate FI Request and get sessionId
async function initiateFIRequest(token, handleId, custId, consentId, from, to, userId) {
  try {
    const response = await axios.post(
      `${baseUrl}/FIRequest`,
      {
        header: headers,
        body: {
          custId,
          consentId,
          consentHandleId: handleId,
          dateTimeRangeFrom: from,
          dateTimeRangeTo: to,
        },
      },
      {
        headers: {
          'Content-Type': 'application/json',
          Authorization: token,
        },
      }
    );
    logger.debug(`response came from the server sessionId ${response.data.body.sessionId}`);
    return response.data.body.sessionId;
  } catch (error) {
    logger.error(`error response from inititateRequest: ${error}`);
    SendNotificationMessage(userId);
    throw new Error('Failed to initiate FI Request');
  }
}

async function SendNotificationMessage(userId) {
  const newObjectId = new mongoose.Types.ObjectId(userId);
  const deviceIds = await getDeviceIdsByUserId(newObjectId);

  await User.findByIdAndUpdate(userId, { fetchInProgress: false }, { new: true, runValidators: true });

  // await SendNotificationToDeviceSpecific(
  //   userId,
  //   `we couldn't able to fetch your bank details, please try again later.It might be due to an bank server issue.`,
  //   deviceIds,
  //   "/home"
  // );

  // WebSocketService.sendMessage(userId, 'addUserToSocket', {
  //   type: 'fetchedApiCall',
  //   data: {
  //     message: "we couldn't able to fetch your bank details, please try again later.It might be due to an bank server issue.",
  //     failed: true,
  //   },
  // });
  await publishSocketEvent(userId, 'addUserToSocket', {
    type: 'fetchedApiCall',
    data: {
      message: "we couldn't able to fetch your bank details, please try again later.It might be due to an bank server issue.",
      failed: true,
    },
  });
}

//  Check the Data request status
// async function checkConsentStatus(token, consentHandleId, custId, consentId, sessionId) {
//   try {
//     const response = await axios.get(`${baseUrl}/${consentHandleId}/${custId}/${consentId}/${sessionId}`, {
//       headers: {
//         "Content-Type": "application/json",
//         Authorization: token,
//       },
//     });
//     logger.debug(`response from checkConsentStatus: ${response.body.fiRequestStatus}`);
//     return response.data.body;
//   } catch (error) {
//     throw new Error("Failed to check Consent Status");
//   }
// }

// Check the status of the FI Request
async function checkFIRequestStatus(token, consentId, sessionId, handleId, custId) {
  const urlPath = `${baseUrl}/FIStatus/${consentId}/${sessionId}/${handleId}/${custId}`;
  try {
    const response = await axios.get(`${urlPath}`, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
    });

    logger.debug(`response from checkFIRRequestStatus: ${JSON.stringify(response.data.body)}`);
    return response.data.body;
  } catch (error) {
    logger.debug(`error from the checkFIRequestStatus: ${error}`);
    throw new Error('Failed to check FI Request Status');
  }
}

async function fetchFinalData(token, custId, consentId, sessionId) {
  try {
    const response = await axios.get(`${baseUrl}/FIFetch/${custId}/${consentId}/${sessionId}`, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
    });
    return response.data.body;
  } catch (error) {
    if (error.response) {
      console.error('Response error:', {
        data: error.response.data,
        status: error.response.status,
        headers: error.response.headers,
      });
    } else if (error.request) {
      // The request was made, but no response was received
      logger.error(`No response received: ${error.request}`);
    } else {
      // Something happened in setting up the request that triggered an Error
      logger.error(`Request setup error: ${error.message}`);
    }
    logger.error(`Config: ${error.config}, ${error}`);
    throw new Error('Failed to fetch final data');
  }
}

async function addFinvuData(req, res, userId) {
  try {
    const { sessionId, custId, consentId, handleId } = req.body;
    const userIdFormatted = new mongoose.Types.ObjectId(userId);

    const newFinvu = new Finvu({
      sessionId,
      custId,
      consentId,
      handleId,
      userId: userIdFormatted,
    });
    const response = await newFinvu.save().catch((err) => {
      logger.error(`Error while saving Finvu: ${err.message}`);
    });

    res.status(201).json({ message: 'Data added successfully', finvu: response });
  } catch (error) {
    res.status(500).json({ message: 'Error adding data', error: error.message });
  }
}

async function fetchTransactionsWeekly(req, res) {
  const { custId, userId, consentId, handleId, FROM, isCron } = req.body;
  try {
    let { token } = req.body;
    if (!isCron) {
      token = await generateToken();
      if (token == 'error') {
        SendNotificationMessage(userId);
        if (isCron != undefined && !isCron) return;
        throw new Error('Failed to initiate FI Request');
      }
    }

    const TO = getISTTimestamp();
    logger.debug(`from: ${FROM}`);
    logger.debug(`to: ${TO}`);

    const sessionId = await initiateFIRequest(token, handleId, custId, consentId, FROM, TO, userId);
    logger.debug(`sessionId: ${sessionId}`);

    const body = { sessionId, custId, consentId, handleId };
    req.body = { ...req.body, ...body };

    try {
      const response = await addFinvuData(req, res, userId);
      logger.debug(`response after adding finvu data: ${response}`);
    } catch (error) {
      SendNotificationMessage(userId);
      logger.debug(`Error adding Finvu data: ${error}`);
    }
  } catch (error) {
    if (isCron != undefined && !isCron) addFailedTransactions(req.body);
    await SendNotificationMessage(userId);
    logger.debug(`Error adding fetchWeekly: ${error}`);
    if (isCron != undefined && !isCron) return;
    throw new Error('Failed to initiate FI Request');
  }
}

async function fetchAndStoreFipsMetrics() {
  try {
    const token = await generateToken();
    const response = await axios.get(`${baseUrl}/fips/latest-metrics-all`, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
    });

    const { timestamp, header, data } = response.data;
    const metrics = data.map((row) => {
      const entry = { timestamp };
      header.forEach((key, i) => {
        entry[key] = row[i];
      });
      return entry;
    });

    await FipsMetric.collection.drop();
    await FipsMetric.insertMany(metrics);

    return metrics;
  } catch (e) {}
}

async function addFailedTransactions(result) {
  try {
    await FailedTransaction.findOneAndUpdate(
      { consendHandleId: result.handleId }, // Find condition
      {
        $set: {
          custId: result.custId,
          consentId: result.consentId,
          userId: result.userId,
          FROM: result.FROM,
          retryCount: 0,
          bankName: result.bankName,
          accountId: result.accountId,
          fipId: result.fipId,
          fetchCount: result.fetchCount,
          createdAt: new Date(),
        },
      },
      { upsert: true, new: true } // Create if not found, return the updated doc
    );
    await updateNextFetchByUserId(result.accountId);
  } catch (e) {
    console.log(e);
  }
}

module.exports = {
  finvuMap,
  loginAndGetHandleId,
  fetchTransactions,
  fetchFinalData,
  addFinvuData,
  checkFIRequestStatus,
  fetchTransactionsWeekly,
  getFipsLatestMetricsAll,
  fetchAndStoreFipsMetrics,
  getFipsDetails,
  deleteConsentHandleById,
  getStatus,
};
