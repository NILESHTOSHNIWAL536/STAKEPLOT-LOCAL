/* controllers/wealthscape-controller.ts
 * HTTP handlers for the Wealthscape PFM integration.
 */

import { Request, Response } from 'express';
import { Types } from 'mongoose';
import logger from '@/utils/common/logger';
import redisClient from '@/config/redis-config';
import generateWealthscapeToken from '@/utils/helpers/generate-wealthscape-token';
import * as WealthscapeService from '@/services/wealthscape-service';
import WealthscapeSession from '@/models/wealthscape-session';
import WealthscapeAccountData from '@/models/wealthscape-account-data';

// ─────────────────────────────────────────────
// POST /api/wealthscape/initConsent
// Orchestrates: subscribe → user-token → consent
// ─────────────────────────────────────────────
export async function initConsent(req: Request, res: Response) {
  try {
    const userId = req.user._id;
    const { uniqueIdentifier, mobileNumber, aaCustId, pan, templateName, redirectUrl, userSessionId } = req.body;

    if (!uniqueIdentifier || !mobileNumber || !aaCustId) {
      return res.status(400).json({ message: 'uniqueIdentifier, mobileNumber and aaCustId are required' });
    }

    // Step 1 — Get channel token (cached in Redis)
    const channelToken = await generateWealthscapeToken();

    // Step 2 — Subscribe user
    await WealthscapeService.subscribeUser(uniqueIdentifier, mobileNumber, channelToken);

    // Step 3 — Generate user token
    const userToken = await WealthscapeService.generateUserToken(uniqueIdentifier, mobileNumber, channelToken);

    // Step 4 — Submit consent request
    const consentResponse = await WealthscapeService.submitConsentRequest(
      { uniqueIdentifier, aaCustId, templateName, userSessionId, redirectUrl, pan },
      channelToken
    );

    // Persist session
    await WealthscapeSession.findOneAndUpdate(
      { userId, uniqueIdentifier },
      {
        userId,
        uniqueIdentifier,
        mobileNumber,
        aaCustId,
        pan,
        templateName: templateName || process.env.WEALTHSCAPE_TEMPLATE_NAME,
        userSessionId,
        redirectUrl,
        consentHandle: consentResponse.ConsentHandle,
        url: consentResponse.url,
        subscribed: true,
        userToken,
        consentStatus: 'PENDING',
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
      { new: true, upsert: true }
    );

    return res.status(200).json({
      message: 'Consent initiated. Redirect user to the URL.',
      consentHandle: consentResponse.ConsentHandle,
      consentRedirectUrl: consentResponse.url,
    });
  } catch (error: any) {
    logger.error(`Wealthscape initConsent error: ${error.message}`);
    return res.status(500).json({ message: 'Failed to initiate consent', error: error.message });
  }
}

// ─────────────────────────────────────────────
// POST /api/wealthscape/multi-consent
// ─────────────────────────────────────────────
export async function initMultiConsent(req: Request, res: Response) {
  try {
    const channelToken = await generateWealthscapeToken();
    const result = await WealthscapeService.submitMultiConsentRequest(req.body, channelToken);
    return res.status(200).json({ data: result });
  } catch (error: any) {
    logger.error(`Wealthscape initMultiConsent error: ${error.message}`);
    return res.status(500).json({ message: 'Failed to submit multi-consent', error: error.message });
  }
}

// ─────────────────────────────────────────────
// GET /api/wealthscape/accounts/:uniqueIdentifier
// ─────────────────────────────────────────────
export async function getLinkedAccounts(req: Request, res: Response) {
  try {
    const { uniqueIdentifier } = req.params;
    if (!uniqueIdentifier) return res.status(400).json({ message: 'uniqueIdentifier is required' });

    const channelToken = await generateWealthscapeToken();
    const accounts = await WealthscapeService.getLinkedAccounts(uniqueIdentifier, channelToken);

    return res.status(200).json({ accounts });
  } catch (error: any) {
    logger.error(`Wealthscape getLinkedAccounts error: ${error.message}`);
    return res.status(500).json({ message: 'Failed to fetch linked accounts', error: error.message });
  }
}

// ─────────────────────────────────────────────
// POST /api/wealthscape/accountData
// Fetch + persist raw account data
// ─────────────────────────────────────────────
export async function fetchAndStoreAccountData(req: Request, res: Response) {
  try {
    const userId = req.user._id;
    const { uniqueIdentifier, accountId, fromDate, toDate } = req.body;

    if (!uniqueIdentifier || !accountId || !fromDate || !toDate) {
      return res.status(400).json({ message: 'uniqueIdentifier, accountId, fromDate and toDate are required' });
    }

    const channelToken = await generateWealthscapeToken();
    const rawData = await WealthscapeService.fetchAccountData(
      { uniqueIdentifier, accountId, fromDate, toDate },
      channelToken
    );

    // Persist / update
    const saved = await WealthscapeAccountData.findOneAndUpdate(
      { userId, accountId },
      {
        userId,
        uniqueIdentifier,
        accountId,
        fromDate,
        toDate,
        type: rawData?.type,
        version: rawData?.version,
        profile: rawData?.Profile || {},
        summary: rawData?.Summary || {},
        transactions: rawData?.Transactions?.Transaction || [],
        rawData,
        fetchedAt: new Date(),
      },
      { new: true, upsert: true }
    );

    return res.status(200).json({ message: 'Account data fetched and stored', data: saved });
  } catch (error: any) {
    logger.error(`Wealthscape fetchAndStoreAccountData error: ${error.message}`);
    return res.status(500).json({ message: 'Failed to fetch account data', error: error.message });
  }
}

// ─────────────────────────────────────────────
// GET /api/wealthscape/accountData/:uniqueIdentifier
// Retrieve stored account data
// ─────────────────────────────────────────────
export async function getStoredAccountData(req: Request, res: Response) {
  try {
    const userId = req.user._id;
    const { uniqueIdentifier } = req.params;

    const data = await WealthscapeAccountData.find({ userId, uniqueIdentifier }).sort({ fetchedAt: -1 });
    return res.status(200).json({ data });
  } catch (error: any) {
    logger.error(`Wealthscape getStoredAccountData error: ${error.message}`);
    return res.status(500).json({ message: 'Failed to get account data', error: error.message });
  }
}

// ─────────────────────────────────────────────
// GET /api/wealthscape/sessions
// List user's Wealthscape consent sessions
// ─────────────────────────────────────────────
export async function getUserSessions(req: Request, res: Response) {
  try {
    const userId = req.user._id;
    const sessions = await WealthscapeSession.find({ userId }).sort({ createdAt: -1 });
    return res.status(200).json({ sessions });
  } catch (error: any) {
    logger.error(`Wealthscape getUserSessions error: ${error.message}`);
    return res.status(500).json({ message: 'Failed to get sessions', error: error.message });
  }
}

// ─────────────────────────────────────────────
// Webhook: POST /Wealthscape/Notification
// Called by Wealthscape when consent is approved.
// ─────────────────────────────────────────────
export async function handleConsentNotification(req: Request, res: Response) {
  try {
    const { consentHandle, status, consentId } = req.body;

    if (!consentHandle) {
      return res.status(400).json({ message: 'consentHandle required' });
    }

    logger.debug(`Wealthscape consent notification: handle=${consentHandle}, status=${status}`);

    // Update session status
    await WealthscapeSession.findOneAndUpdate(
      { consentHandle },
      { consentStatus: status || 'ACTIVE' },
      { new: true }
    );

    // Publish to Redis for any socket listeners
    await redisClient.publish(
      'bank_events',
      JSON.stringify({
        event: 'wealthscape_consent',
        data: { consentHandle, status, consentId },
      })
    );

    return res.status(200).json({ message: 'Notification received' });
  } catch (error: any) {
    logger.error(`Wealthscape consent webhook error: ${error.message}`);
    return res.status(500).json({ message: 'Webhook processing failed', error: error.message });
  }
}

// ─────────────────────────────────────────────
// Webhook: POST /Wealthscape/DataReady
// Called by Wealthscape when data is ready.
// ─────────────────────────────────────────────
export async function handleDataReadyNotification(req: Request, res: Response) {
  try {
    const { consentHandle, status } = req.body;

    logger.debug(`Wealthscape data ready notification: handle=${consentHandle}, status=${status}`);

    await redisClient.publish(
      'bank_events',
      JSON.stringify({
        event: 'wealthscape_data_ready',
        data: { consentHandle, status },
      })
    );

    return res.status(200).json({ message: 'Data notification received' });
  } catch (error: any) {
    logger.error(`Wealthscape data webhook error: ${error.message}`);
    return res.status(500).json({ message: 'Webhook processing failed', error: error.message });
  }
}
