/* services/wealthscape-service.ts
 * Wrappers for all Wealthscape PFM API calls.
 * Base URL: /pfm/api/v2
 */

import axios from 'axios';
import logger from '@/utils/common/logger';
import generateWealthscapeToken from '@/utils/helpers/generate-wealthscape-token';

const BASE_URL = process.env.WEALTHSCAPE_BASE_URL as string;

function authHeaders(token: string) {
  return {
    'Content-Type': 'application/json',
    Authorization: token,
  };
}

// ─────────────────────────────────────────────
// Step 2 — Subscribe a user
// POST /pfm/api/v2/user-subscriptions
// ─────────────────────────────────────────────
export async function subscribeUser(
  uniqueIdentifier: string,
  mobileNumber: string,
  token?: string
): Promise<string> {
  const authToken = token || (await generateWealthscapeToken());

  const response = await axios.post(
    `${BASE_URL}/pfm/api/v2/user-subscriptions`,
    { uniqueIdentifier, mobileNumber, subscriptionStatus: 'YES' },
    { headers: authHeaders(authToken) }
  );

  // API returns plain text "SUCCESS"
  return response.data as string;
}

// ─────────────────────────────────────────────
// Step 3 — Generate user token
// POST /pfm/api/v2/user-token
// ─────────────────────────────────────────────
export async function generateUserToken(
  uniqueIdentifier: string,
  mobileNumber: string,
  token?: string
): Promise<string> {
  const authToken = token || (await generateWealthscapeToken());

  const response = await axios.post(
    `${BASE_URL}/pfm/api/v2/user-token`,
    { uniqueIdentifier, mobileNumber, subscriptionStatus: 'YES' },
    { headers: authHeaders(authToken) }
  );

  return response.data.token as string;
}

// ─────────────────────────────────────────────
// Step 4 — Submit consent request (single)
// POST /pfm/api/v2/submit-consent-request-plus
// ─────────────────────────────────────────────
export interface WealthscapeConsentRequestBody {
  uniqueIdentifier: string;
  aaCustId: string;
  templateName: string;
  userSessionId?: string;
  redirectUrl?: string;
  pan?: string;
}

export interface WealthscapeConsentResponse {
  encryptedRequest: string;
  requestDate: string;
  encryptedFiuId: string;
  ConsentHandle: string;
  url: string;
}

export async function submitConsentRequest(
  body: WealthscapeConsentRequestBody,
  token?: string
): Promise<WealthscapeConsentResponse> {
  const authToken = token || (await generateWealthscapeToken());

  const payload = {
    uniqueIdentifier: body.uniqueIdentifier,
    aaCustId: body.aaCustId,
    templateName: body.templateName || process.env.WEALTHSCAPE_TEMPLATE_NAME || 'BANK_STATEMENT_PERIODIC',
    userSessionId: body.userSessionId || `session-${Date.now()}`,
    redirectUrl: body.redirectUrl || process.env.WEALTHSCAPE_REDIRECT_URL || 'https://google.co.in',
    ...(body.pan && { pan: body.pan }),
  };

  const response = await axios.post(
    `${BASE_URL}/pfm/api/v2/submit-consent-request-plus`,
    payload,
    { headers: authHeaders(authToken) }
  );

  return response.data as WealthscapeConsentResponse;
}

// ─────────────────────────────────────────────
// Submit multi-consent request
// POST /pfm/api/v2/submit-multi-consent-request
// ─────────────────────────────────────────────
export async function submitMultiConsentRequest(
  body: Record<string, any>,
  token?: string
): Promise<any> {
  const authToken = token || (await generateWealthscapeToken());

  const response = await axios.post(
    `${BASE_URL}/pfm/api/v2/submit-multi-consent-request`,
    body,
    { headers: authHeaders(authToken) }
  );

  return response.data;
}

// ─────────────────────────────────────────────
// Get linked accounts for a user
// This API is used to obtain accountId before raw data fetch.
// The actual endpoint comes from Postman collection.
// ─────────────────────────────────────────────
export async function getLinkedAccounts(
  uniqueIdentifier: string,
  token?: string
): Promise<any[]> {
  const authToken = token || (await generateWealthscapeToken());

  try {
    const response = await axios.post(
      `${BASE_URL}/pfm/api/v2/user-linked-accounts`, { uniqueIdentifier },
      { headers: authHeaders(authToken) }
    );
    return response.data?.accounts || response.data || [];
  } catch (error: any) {
    logger.warn(`getLinkedAccounts error: ${error.message}`);
    return [];
  }
}

// ─────────────────────────────────────────────
// Raw data fetch
// POST /pfm/api/v2/account/data
// ─────────────────────────────────────────────
export interface WealthscapeAccountDataRequest {
  uniqueIdentifier: string;
  accountId: string;
  fromDate: string; // "YYYY-MM-DD"
  toDate: string;   // "YYYY-MM-DD"
}

export async function fetchAccountData(
  params: WealthscapeAccountDataRequest,
  token?: string
): Promise<any> {
  const authToken = token || (await generateWealthscapeToken());

  const response = await axios.post(
    `${BASE_URL}/pfm/api/v2/account/data`,
    params,
    { headers: authHeaders(authToken) }
  );

  return response.data;
}
