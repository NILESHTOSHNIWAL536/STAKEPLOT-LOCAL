const logger = require('../utils/common/logger');
const redisClient = require('../config/redis-config');
const bankLogos = require('../config/bankLogos');
const generateToken = require('../utils/helpers/generate-finvu-token');
const { FinvuController, TransactionAutoController } = require('../controllers');
const { NotificationRepository } = require('../respositories');
const { FailedTransaction, BankLogo, Finvu } = require('../models');

// Initialize notification repository
const notificationRepository = new NotificationRepository();

async function publishSocketEvent(userId, event, data) {
  await redisClient.publish('bank_events', JSON.stringify({ userId, event, data }));
}

async function webHook(req, res) {
  try {
    const { dataSessionId } = req.body;
    const finvuData = await Finvu.findOne({ sessionId: dataSessionId });
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

      if (finvuData.isUpdate) await TransactionAutoController.updateBankDetails(finalData, finvuData.handleId, finvuData.userId);
      else await TransactionAutoController.createBankDetails(finalData, finvuData.handleId, finvuData.userId);

      // Delete calls, failed transactions after successful fetch
      await FinvuController.deleteConsentHandleById(finvuData.handleId);
      await FailedTransaction.deleteMany({ consendHandleId: finvuData.handleId });

      // calculate total transactions fetched from each bank for notification
      let totalTransactions = 0;
      const name = finalData?.[0]?.fipName || 'Bank';
      let bankId = finalData?.[0]?.fipId || '';
      finalData.forEach((data) => {
        data.fiObjects.forEach((obj) => {
          totalTransactions += obj.Transactions?.Transaction?.length || 0;
        });
      });

      const bankLogo = bankLogos[bankId] || 'https://cdn.finvu.in/finvulogos/bank_large_light.png';
      const notificationMessage = {
        type: 'FetchedData',
        message: `${name} Data has been successfully fetched`,
        avatarType: bankLogo,
        logo: bankLogo,
      };
      await notificationRepository.createNotification({ userId: finvuData.userId, notificationMessage });

      // Publish WebSocket events to main-backend
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

module.exports = webHook;
