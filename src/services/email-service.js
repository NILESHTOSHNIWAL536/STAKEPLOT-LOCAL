const { google } = require('googleapis');
const { EmailRepository } = require('../repositories');

const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;
const REDIRECT_URI = '';

const oauth2Client = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);

async function handleGoogleEmailAuth(userId, idToken) {
  // 1. Exchange idToken for tokens
  const { tokens } = await oauth2Client.getToken(idToken);
  oauth2Client.setCredentials(tokens);

  // 2. Get Gmail user info
  const oauth2 = google.oauth2({ auth: oauth2Client, version: 'v2' });
  const { data } = await oauth2.userinfo.get();
  const email = data.email;

  if (tokens.refresh_token) {
    await EmailRepository.upsertGoogleToken(userId, email, tokens.refresh_token);
  }

  return {
    googleAccessToken: tokens.access_token, // short-lived Gmail API token
    googleRefreshToken: tokens.refresh_token, // store securely
  };
}

module.exports = {
  handleGoogleEmailAuth,
};
