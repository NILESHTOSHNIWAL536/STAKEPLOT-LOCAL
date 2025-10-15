const { StatusCodes } = require('http-status-codes');
const { SuccessResponse, ErrorResponse } = require('../utils/api-response');
const EmailScrapingService = require('../services/email-service');

// Google authentication
async function generateAccessToken(req, res) {
  try {
    const userId = req.user._id;
    const { idToken } = req.body;

    const result = await EmailScrapingService.generateAccessToken(userId, idToken);

    SuccessResponse.data = result;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    console.log(error);
    ErrorResponse.error = error.response.data.error || error;
    return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
  }
}

// Scrape emails based on bank id
async function scrapeEmailsByBankId(req, res) {
  try {
    const userId = req.user._id;
    const { bankId } = req.params;
    const response = await EmailScrapingService.scrapeEmailsByBankId(userId, bankId);
    SuccessResponse.data = response;
    return res.status(StatusCodes.CREATED).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    return res.status(error.statusCode).json(ErrorResponse);
  }
}

// Fetch all records for a user
const getScrapedEmails = async (req, res) => {
  try {
    const userId = req.user._id;

    const response = await EmailScrapingService.getScrapedEmails(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.CREATED).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    return res.status(error.statusCode).json(ErrorResponse);
  }
};

const getUnlinkedCreditCards = async (req, res) => {
  try {
    const userId = req.user._id;

    const response = await EmailScrapingService.getUnlinkedCreditCards(userId);
    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    return res.status(error.statusCode).json(ErrorResponse);
  }
};

// Revoke Google access token
const removeAccessToken = async (req, res) => {
  try {
    const userId = req.user._id;

    const response = await EmailScrapingService.removeAccessToken(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

module.exports = {
  generateAccessToken,
  scrapeEmailsByBankId,
  getScrapedEmails,
  getUnlinkedCreditCards,
  removeAccessToken,
};
