import { Request, Response } from 'express';
import logger from './common/logger';
import redisClient from '../config/redis-config';
import bankLogos from '../config/bankLogos';
import generateToken from '../utils/helpers/generate-finvu-token';
import { FinvuController, TransactionAutoController } from '../controllers';
import { NotificationRepository } from '../respositories';
import { FailedTransaction, Finvu } from '../models';

// ✅ Initialize notification repository
const notificationRepository = new NotificationRepository();

/* ============================
   Socket Publisher
============================ */

async function publishSocketEvent(userId: string, event: string, data: any): Promise<void> {
  await redisClient.publish('bank_events', JSON.stringify({ userId, event, data }));
}

/* ============================
   Webhook Handler
============================ */

async function webHook(req: Request, res: Response): Promise<Response> {
  const { dataSessionId } = req.body as { dataSessionId: string };
  const lockKey = `finvu-lock:${dataSessionId}`;

  let lockAcquired = false;

  try {
    // ✅ 1. Acquire lock (2 min TTL)
    const acquired = await redisClient.set(lockKey, '1', {
      NX: true,
      EX: 120,
    });

    if (!acquired) {
      return res.status(200).json({ message: 'Already processing' });
    }

    lockAcquired = true;

    // ✅ 2. Cache-first lookup
    const cached = await redisClient.get(`finvu:${dataSessionId}`);
    let finvuData: any = null;

    if (cached) {
      try {
        finvuData = JSON.parse(cached);
        await redisClient.del(`finvu:${dataSessionId}`);
      } catch (e) {
        logger.error('Redis JSON parse failed');
      }
    }

    // ✅ 3. DB fallback
    if (!finvuData) {
      finvuData = await Finvu.findOne({ sessionId: dataSessionId });
    }

    // ✅ 4. Hard guard
    if (!finvuData) {
      return res.status(404).json({ message: 'Invalid or expired sessionId' });
    }

    logger.debug(`Webhook received for sessionId: ${dataSessionId}`);

    // ✅ 5. Token reuse
    let token = await redisClient.get('auth_token');
    if (!token) {
      token = await generateToken();
      await redisClient.setEx('auth_token', 800, token); // prevent token storms
    }

    // ✅ 6. Fetch final data
    const finalData = await FinvuController.fetchFinalData(token, finvuData.custId, finvuData.consentId, finvuData.sessionId);

    if (finalData !== 'Account data not found.') {
      await Finvu.findOneAndUpdate({ sessionId: finvuData.sessionId }, { $set: { data: finalData } }, { new: true });

      if (finvuData.isUpdate) {
        await TransactionAutoController.updateBankDetails(finalData, finvuData.handleId, finvuData.userId);
      } else {
        await TransactionAutoController.createBankDetails(finalData, finvuData.handleId, finvuData.userId);
      }

      await FinvuController.deleteConsentHandleById(finvuData.handleId);
      await FailedTransaction.deleteMany({
        consendHandleId: finvuData.handleId,
      });

      // ✅ Notifications
      let totalTransactions = 0;
      const name = finalData?.[0]?.fipName || 'Bank';
      const bankId = finalData?.[0]?.fipId || '';

      finalData.forEach((data: any) => {
        data.fiObjects.forEach((obj: any) => {
          totalTransactions += obj.Transactions?.Transaction?.length || 0;
        });
      });

      const bankLogo = bankLogos[bankId] || 'https://cdn.finvu.in/finvulogos/bank_large_light.png';

      await notificationRepository.createNotification({
        userId: finvuData.userId,
        notificationMessage: {
          type: 'FetchedData',
          message: `${name} Data has been successfully fetched`,
          avatarType: bankLogo,
          logo: bankLogo,
        },
      });

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

      // ✅ 7. DB cleanup after success
      await Finvu.deleteOne({ sessionId: finvuData.sessionId });
    } else {
      await publishSocketEvent(finvuData.custId, 'registerUser', {
        message: 'Sorry, we are unable to fetch your bank details. Please try again later.',
        data: {
          number_id: finvuData.custId,
          data: 'account-data-not-found',
        },
      });

      await publishSocketEvent(finvuData.userId, 'addUserToSocket', {
        type: 'fetchedApiCall',
        data: {
          message: 'No transactions were found at the moment, try again later',
          failed: true,
        },
      });
    }

    return res.status(200).json({ message: 'Data fetched successfully' });
  } catch (error: any) {
    logger.error(`Webhook error: ${error.message}`);
    return res.status(500).json({
      message: 'Error fetching data',
      error: error.message,
    });
  } finally {
    // ✅ 8. Always release lock (safely)
    if (lockAcquired) {
      await redisClient.del(lockKey);
    }
  }
}

export default webHook;
