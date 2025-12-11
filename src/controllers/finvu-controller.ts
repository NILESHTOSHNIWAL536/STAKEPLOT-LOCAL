import axios, { AxiosResponse } from 'axios';
import { Request, Response } from 'express';
import apiClient from '../utils/helpers/apiClient';
import { Finvu, FipsMetric, User, FailedTransaction, ConsentHandleId } from '../models';
import { getDeviceIdsByUserId } from '../utils/helpers/getDeviceIds';
import { SendNotificationToDeviceSpecific } from '../services/notification-service';
import generateToken from '../utils/helpers/generate-finvu-token';
import getISTTimestamp from '../utils/helpers/get-IST-timeStamp';
import redisClient from '../config/redis-config';
import logger from '../utils/common/logger';
import { DateTime } from 'luxon';
import mongoose from 'mongoose';
import { Types } from 'mongoose';

interface LoginRequestBody {
  custId: string;
  number: string;
}

interface FetchTransactionBody {
  handleId: string;
  custId: string;
}

interface WeeklyFetchBody {
  custId: string;
  userId: string;
  consentId: string;
  handleId: string;
  FROM: string;
  token?: string;
  isCron?: boolean;
  bankName?: string;
  accountId?: string;
  fipId?: string;
  fetchCount?: number;
}

interface ConsentStatusResponse {
  consentStatus: string;
  consentId?: string;
}

interface FIStatusResponse {
  fiRequestStatus: string;
}

// Redis-based WebSocket publish helper
async function publishSocketEvent(userId: string | Types.ObjectId, event: string, data: any) {
  await redisClient.publish('bank_events', JSON.stringify({ userId, event, data }));
}

const baseUrl = process.env.FINVU_URL!;
const headers = {
  rid: process.env.FINVU_RID!,
  ts: process.env.FINVU_TS!,
  channelId: process.env.FINVU_CHANNEL_ID!,
};

// =======================================
// Consent Handle Helpers
// =======================================

export async function deleteConsentHandleById(handleId: string) {
  try {
    await ConsentHandleId.findOneAndDelete({ handleId });
    return '';
  } catch (error) {
    console.error('Error deleting consent handle:', error);
    return '';
  }
}

export async function storeOrUpdateConsentHandle({ custId, handleId, userId }: { custId: string; handleId: string; userId: string | Types.ObjectId }) {
  try {
    return await ConsentHandleId.findOneAndUpdate(
      { handleId },
      {
        custId,
        handleId,
        userId,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
      },
      { new: true, upsert: true }
    );
  } catch (error) {
    console.error('Error in storeOrUpdateConsentHandle:', error);
    return '';
  }
}

// =======================================
// Login + Consent Handle Flow
// =======================================

export async function loginAndGetHandleId(req: Request, res: Response) {
  try {
    const userId = req.user._id;
    const { custId, number } = req.body as LoginRequestBody;

    const token = await generateToken();

    const consentResponse = await apiClient.post(`${baseUrl}/ConsentRequestPlus`, token, {
      header: headers,
      body: {
        custId,
        consentDescription: process.env.FINVU_CONSENT_DESCRIPTION,
        templateName: process.env.FINVU_TEMPLATE_NAME,
        userSessionId: process.env.FINVU_USER_SESSION_ID,
        redirectUrl: 'https://google.co.in',
        ConsentDetails: {},
      },
    });

    if (![200, 201].includes(consentResponse.status)) {
      return res.status(400).json({ message: 'Failed to get Consent Handle ID' });
    }

    const consentHandleId = consentResponse.data.body.ConsentHandle;
    await storeOrUpdateConsentHandle({ custId, handleId: consentHandleId, userId });

    // Update user phone
    const updateMobile = await User.findOneAndUpdate({ _id: userId }, { $addToSet: { phone: number } }, { new: true });

    if (!updateMobile) {
      return res.status(400).json({
        message: 'Failed to update mobile number, already registered',
      });
    }

    return res.json({ consentHandleId });
  } catch (error: any) {
    logger.error(`Error in loginAndGetHandleId: ${error}`);
    res.status(500).json({ error: error.message });
  }
}

// =======================================
// Fetch Transactions Flow
// =======================================

export async function fetchTransactions(req: Request, res: Response) {
  try {
    const { handleId, custId } = req.body as FetchTransactionBody;
    const userId = req.user!._id;

    const token = await redisClient.get('auth_token');
    if (!token) return res.status(401).json({ message: 'Auth token missing' });

    // -----------------------------
    // Step 1: Poll Consent Status
    // -----------------------------
    let consentId: string | null = null;

    for (let attempt = 0; attempt < 2; attempt++) {
      const status = await fetchConsentStatus(token, handleId, custId);
      if (status.consentStatus === 'ACCEPTED') {
        consentId = status.consentId!;
        break;
      }
      await delay(8000);
    }

    if (!consentId) {
      await publishSocketEvent(custId, 'registerUser', {
        message: 'Bank server error. Try again later.',
        data: { number_id: custId, data: 'error' },
      });

      return res.status(400).json({ message: 'Consent ID not received' });
    }

    // -----------------------------
    // Step 2: Fetch Consent Details
    // -----------------------------
    const { from, to } = await fetchConsentDetails(token, consentId);

    const newFrom = DateTime.fromISO(from, { zone: 'utc' }).plus({ days: 1 }).toFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZZ");

    const TO = getISTTimestamp();

    // -----------------------------
    // Step 3: Poll FI Request
    // -----------------------------
    let sessionId: string | null = null;

    for (let attempt = 0; attempt < 5; attempt++) {
      sessionId = await initiateFIRequest(token, handleId, custId, consentId, newFrom, TO, userId);

      if (sessionId) break;

      await delay(10000);
    }

    if (!sessionId) {
      sendFailedNotification(userId);
      return res.status(500).json({ message: 'FI request failed' });
    }

    // Cache for async processing
    const finvuData = { sessionId, custId, consentId, handleId, isUpdate: false, userId };
    await redisClient.setEx(`finvu:${sessionId}`, 600, JSON.stringify(finvuData));

    await addFinvuData(finvuData);

    return res.json({ message: 'FI Request started', sessionId });
  } catch (error: any) {
    console.error('Error fetching data:', error);
    res.status(500).json({ message: 'Error fetching data', error: error.message });
  }
}

// =======================================
// Status API
// =======================================

export async function getStatus(req: Request, res: Response) {
  try {
    const id = req.params.id;
    const token = await redisClient.get('auth_token');

    if (!token) return res.status(401).json({ error: 'Auth token missing' });

    const data = await ConsentHandleId.findOne({
      _id: new mongoose.Types.ObjectId(id),
    }).sort({ createdAt: -1 });

    if (!data) return res.status(404).json({ error: 'Finvu record not found' });

    const status = await fetchConsentStatus(token, data.handleId, data.custId);

    return res.status(200).json({ data: status });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
}

// =======================================
// Fetch Consent Status
// =======================================

export async function fetchConsentStatus(token: string, handleId: string, custId: string): Promise<ConsentStatusResponse> {
  try {
    const response: AxiosResponse = await axios.get(`${baseUrl}/ConsentStatus/${handleId}/${custId}`, {
      headers: { 'Content-Type': 'application/json', Authorization: token },
    });

    return response.data.body;
  } catch (error) {
    logger.debug(`error from fetchConsentStatus: ${error}`);
    throw new Error('Failed to fetch consent status');
  }
}

// =======================================
// Fetch Consent Details
// =======================================

export async function fetchConsentDetails(token: string, consentId: string) {
  try {
    const response = await axios.get(`${baseUrl}/Consent/${consentId}`, {
      headers: { 'Content-Type': 'application/json', Authorization: token },
    });

    const from = response.data.body.ConsentDetail.FIDataRange.from;
    const to = response.data.body.ConsentDetail.FIDataRange.to;

    return { from, to };
  } catch (error) {
    throw new Error('Failed to fetch consent details');
  }
}

// =======================================
// Initiate FI Request
// =======================================

export async function initiateFIRequest(token: string, handleId: string, custId: string, consentId: string, from: string, to: string, userId: string | Types.ObjectId): Promise<string | null> {
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
        headers: { 'Content-Type': 'application/json', Authorization: token },
      }
    );

    return response.data.body.sessionId;
  } catch (error) {
    sendFailedNotification(userId);
    logger.error(`FI Request error: ${error}`);
    return null;
  }
}

// =======================================
// Check FI Request Status
// =======================================

export async function checkFIRequestStatus(token: string, consentId: string, sessionId: string, handleId: string, custId: string): Promise<FIStatusResponse> {
  try {
    const response = await axios.get(`${baseUrl}/FIStatus/${consentId}/${sessionId}/${handleId}/${custId}`, {
      headers: { 'Content-Type': 'application/json', Authorization: token },
    });

    return response.data.body;
  } catch (error) {
    throw new Error('Failed to check FI Request status');
  }
}

// =======================================
// Fetch Final FI Data
// =======================================

export async function fetchFinalData(token: string, custId: string, consentId: string, sessionId: string) {
  try {
    const response = await axios.get(`${baseUrl}/FIFetch/${custId}/${consentId}/${sessionId}`, {
      headers: { 'Content-Type': 'application/json', Authorization: token },
    });

    return response.data.body;
  } catch (error: any) {
    console.error('Failed final FI fetch:', error.response?.data || error.message);
    throw new Error('Failed to fetch final data');
  }
}

// =======================================
// Save Finvu Data
// =======================================

export async function addFinvuData(data: any) {
  try {
    const newFinvu = new Finvu(data);
    await newFinvu.save();
  } catch (error: any) {
    logger.error(`Error adding Finvu: ${error.message}`);
  }
}

// =======================================
// Weekly Fetch
// =======================================

export async function fetchTransactionsWeekly(req: Request, res: Response) {
  const body = req.body as WeeklyFetchBody;

  try {
    const token = body.token || (await redisClient.get('auth_token'));

    const TO = getISTTimestamp();

    const sessionId = await initiateFIRequest(token!, body.handleId, body.custId, body.consentId, body.FROM, TO, body.userId);

    if (!sessionId) throw new Error('Failed to initiate FI Request');

    const finvuData = { ...body, sessionId, isUpdate: true };
    await redisClient.setEx(`finvu:${sessionId}`, 600, JSON.stringify(finvuData));
    await addFinvuData(finvuData);

    return res.json({ sessionId });
  } catch (error: any) {
    await sendFailedNotification(body.userId);
    return res.status(500).json({ error: error.message });
  }
}

// =======================================
// FIPS Metrics
// =======================================

export async function getFipsLatestMetricsAll(req: Request, res: Response) {
  try {
    const data = await fetchAndStoreFipsMetrics();
    return res.status(200).json({ data });
  } catch (error) {
    return res.status(400).json({ error });
  }
}

export async function fetchAndStoreFipsMetrics() {
  try {
    const token = await generateToken();
    const response = await axios.get(`${baseUrl}/fips/latest-metrics-all`, {
      headers: { 'Content-Type': 'application/json', Authorization: token },
    });

    const { timestamp, header, data } = response.data;

    const metrics = data.map((row: any[]) => {
      const entry: any = { timestamp };
      header.forEach((key: string, i: number) => (entry[key] = row[i]));
      return entry;
    });

    await FipsMetric.collection.drop();
    await FipsMetric.insertMany(metrics);

    return metrics;
  } catch (error) {
    logger.error('FIPS metrics error:', error);
    return [];
  }
}

export async function getFipsDetails(req: Request, res: Response) {
  try {
    const { fipIds } = req.body;
    if (!Array.isArray(fipIds) || fipIds.length === 0) {
      return res.status(400).json({ error: 'fipIds must be a non-empty array' });
    }

    const data = await FipsMetric.find({ fip_id: { $in: fipIds }, event_name: { $regex: /FIFetchResponse/, $options: 'i' } }).sort({ timestamp: -1 });

    const json = res.status(200).json({ data });
    return json;
  } catch (error: any) {
    console.error('getFipsDetails error:', error);
    return res.status(400).json({ error: error.message });
  }
}

// =======================================
// Helpers
// =======================================

async function sendFailedNotification(userId: string | Types.ObjectId) {
  // Update fetchInProgress to false
  await User.findByIdAndUpdate(userId, { fetchInProgress: false }, { new: true, runValidators: true });

  // WebSocket message to the user
  await publishSocketEvent(userId, 'addUserToSocket', {
    type: 'fetchedApiCall',
    data: {
      message: "we couldn't able to fetch your bank details, please try again later.It might be due to an bank server issue.",
      failed: true,
    },
  });
}

function delay(ms: number) {
  return new Promise((res) => setTimeout(res, ms));
}

export const finvuMap = new Map();
