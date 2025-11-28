const { Finvu } = require('../models/index');
const logger = require('../utils/common/logger');
const redisClient = require('../config/redis-config');
const mongoose = require('mongoose');
const generateToken = require('../utils/helpers/generate-finvu-token');
const { getDeviceIdsByUserId } = require('../utils/helpers/getDeviceIds');
const { SendNotificationToDeviceSpecific } = require('../services/notification-service');
const { FinvuController } = require('../controllers/index');
const { NotificationRepository } = require('../respositories');
const transactionController = require('../controllers/transaction-automation/transaction-controller');
const { User, FailedTransaction, BankLogo } = require('../models');
const { deleteConsentHandleById } = require('../controllers/finvu-controller');
const axios = require('axios');

// Initialize notification repository
const notificationRepository = new NotificationRepository();

/**
 * Helper to publish WebSocket events via Redis Pub/Sub
 */
async function publishSocketEvent(userId, event, data) {
  await redisClient.publish('bank_events', JSON.stringify({ userId, event, data }));
}

async function getAll(req, res) {
  try {
    const allFinvus = await Finvu.find();
    for (const item of allFinvus) {
      try {
        await axios.post('https://stakeplot.in/fi/notification/callback/v1/finvu/FI/Prod/Notification', {
          dataSessionId: item.sessionId,
        });
      } catch (err) {
        logger.error(`❌ Error calling webhook for sessionId: ${item.sessionId} - ${err.message}`);
      }
    }
    res.status(200).json({ message: 'All sessions processed' });
  } catch (e) {
    logger.error(`Error in getAll: ${e.message}`);
    res.status(500).json({ message: 'Error processing all sessions', error: e.message });
  }
}

async function processFinvuSession(dataSessionId) {
  let finvuData;
  try {
    finvuData = await Finvu.findOne({ sessionId: dataSessionId });
    if (!finvuData) {
      logger.warn(`No data found for sessionId: ${dataSessionId}`);
      return;
    }

    logger.debug(`Processing sessionId: ${dataSessionId}`);

    let token = await redisClient.get('auth_token');
    if (!token) {
      token = await generateToken();
      logger.debug(`New token created: ${token}`);
    }

    const finalData = await FinvuController.fetchFinalData(token, finvuData.custId, finvuData.consentId, finvuData.sessionId);

    if (finalData !== 'Account data not found.') {
      await transactionController.createUserDetails(finalData, finvuData.handleId, finvuData.userId);

      let totalTransactions = 0;
      let name = finalData?.[0]?.fipName || 'Bank';
      let bankId = finalData?.[0]?.fipId || '';

      finalData.forEach((data) => {
        data.fiObjects.forEach((obj) => {
          totalTransactions += obj.Transactions?.Transaction?.length || 0;
        });
      });

      const bankLogo = await BankLogo.findOne({ name: bankId });
      const notificationMessage = {
        type: 'FetchedData',
        message: `${name} Data has been successfully fetched`,
        avatarType: bankLogo,
        logo: bankLogo,
      };

      await notificationRepository.createNotification({
        userId: finvuData.userId,
        notificationMessage,
      });

      // ✅ Publish message to main-backend via Redis
      await publishSocketEvent(finvuData.custId, 'registerUser', {
        message: 'Your bank account data has been successfully fetched.',
        data: { number_id: finvuData.custId, data: finalData },
      });

      await publishSocketEvent(finvuData.userId, 'addUserToSocket', {
        type: 'fetchedApiCall',
        data: {
          message: `${name} fetched successfully! ${totalTransactions} new transactions.`,
          failed: false,
        },
      });
    } else {
      await publishSocketEvent(finvuData.custId, 'registerUser', {
        message: 'Sorry, we are unable to fetch your bank details. Please try again later.',
        data: { number_id: finvuData.custId, data: 'account-data-not-found' },
      });

      await publishSocketEvent(finvuData.userId, 'addUserToSocket', {
        type: 'fetchedApiCall',
        data: {
          message: 'No transactions were found at the moment, try again later',
          failed: true,
        },
      });
    }
  } catch (error) {
    logger.error(`Error processing session ${dataSessionId}: ${error.message}`);
    if (finvuData?.userId) {
      await publishSocketEvent(finvuData.userId, 'addUserToSocket', {
        type: 'fetchedApiCall',
        data: {
          message: "We couldn't fetch your bank details, please try again later. It might be due to a bank server issue.",
          failed: true,
        },
      });
    }
  }
}

async function webHook(req, res) {
  let finvuData;
  try {
    const { dataSessionId } = req.body;
    finvuData = await Finvu.findOne({ sessionId: dataSessionId });
    if (!finvuData) return res.status(404).json({ message: 'No data found for this sessionId' });

    logger.debug(`Webhook received for sessionId: ${dataSessionId}`);

    let token = await redisClient.get('auth_token');
    if (!token) {
      token = await generateToken();
      logger.debug(`token created for webhook: ${token}`);
    }

    const finalData = await FinvuController.fetchFinalData(token, finvuData.custId, finvuData.consentId, finvuData.sessionId);

    if (finalData !== 'Account data not found.') {
      await Finvu.findOneAndUpdate({ sessionId: finvuData.sessionId }, { $set: { data: finalData } }, { new: true });

      if (finvuData.isUpdate) {
        await transactionController.updateBankDetails(finalData, finvuData.handleId, finvuData.userId);
      } else {
        await transactionController.createBankDetails(finalData, finvuData.handleId, finvuData.userId);
      }

      await deleteConsentHandleById(finvuData.handleId);
      await FailedTransaction.deleteMany({ consendHandleId: finvuData.handleId });

      let totalTransactions = 0;
      let name = finalData?.[0]?.fipName || 'Bank';
      let bankId = finalData?.[0]?.fipId || '';
      finalData.forEach((data) => {
        data.fiObjects.forEach((obj) => {
          totalTransactions += obj.Transactions?.Transaction?.length || 0;
        });
      });

      const bankLogo = await BankLogo.findOne({ name: bankId });
      const notificationMessage = {
        type: 'FetchedData',
        message: `${name} Data has been successfully fetched`,
        avatarType: bankLogo?.logoUrl || 'default',
        logo: bankLogo?.logoUrl || 'default',
      };
      await notificationRepository.createNotification({
        userId: finvuData.userId,
        notificationMessage,
      });

      // ✅ Publish WebSocket events to main-backend
      await publishSocketEvent(finvuData.custId, 'registerUser', {
        message: 'Your bank account data has been successfully fetched.',
        data: { number_id: finvuData.custId, data: finalData },
      });

      await publishSocketEvent(finvuData.userId, 'addUserToSocket', {
        type: 'fetchedApiCall',
        data: {
          message: `${name} fetched successfully! ${totalTransactions} new transactions.`,
          failed: false,
        },
      });
    } else {
      await publishSocketEvent(finvuData.custId, 'registerUser', {
        message: 'Sorry, we are unable to fetch your bank details. Please try again later.',
        data: { number_id: finvuData.custId, data: 'account-data-not-found' },
      });

      await publishSocketEvent(finvuData.userId, 'addUserToSocket', {
        type: 'fetchedApiCall',
        data: {
          message: 'No transactions were found at the moment, try again later',
          failed: true,
        },
      });
    }

    res.status(200).json({ message: 'Data fetched successfully' });
  } catch (error) {
    logger.error(`Webhook error: ${error.message}`);
    res.status(500).json({ message: 'Error fetching data', error: error.message });
  }
}

module.exports = { webHook, getAll, processFinvuSession };
