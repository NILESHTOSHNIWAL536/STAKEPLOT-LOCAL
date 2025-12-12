// const { StatusCodes } = require('http-status-codes');
// const { SuccessResponse, ErrorResponse } = require('../utils/api-response');
// const EmailScrapingService = require('../services/email-service');

// // Google authentication
// async function generateAccessToken(req, res) {
//   try {
//     const userId = req.user._id;
//     const { idToken } = req.body;
//     const result = await EmailScrapingService.generateAccessToken(userId, idToken);
//     SuccessResponse.data = result;
//     return res.status(StatusCodes.OK).json(SuccessResponse);
//   } catch (error) {
//     ErrorResponse.error = error.response.data.error || error;
//     return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
//   }
// }

// // Scrape emails based on bank id
// async function scrapeEmailsByBankId(req, res) {
//   try {
//     const userId =req.user._id;
//     const { bankIds } = req.body;
//     const response = await EmailScrapingService.scrapeEmailsByBankId(userId, bankIds);
//     SuccessResponse.data = response;
//     return res.status(StatusCodes.CREATED).json(SuccessResponse);
//   } catch (error) {
//     ErrorResponse.error = error;
//     return res.status(error.statusCode).json(ErrorResponse);
//   }
// }

// // Fetch all records for a user
// const getScrapedEmails = async (req, res) => {
//   try {
//     const userId = req.user._id;

//     const response = await EmailScrapingService.getScrapedEmails(userId);

//     SuccessResponse.data = response;
//     return res.status(StatusCodes.CREATED).json(SuccessResponse);
//   } catch (error) {
//     ErrorResponse.error = error;
//     return res.status(error.statusCode).json(ErrorResponse);
//   }
// };

// const getUnlinkedCreditCards = async (req, res) => {
//   try {
//     const userId = req.user._id;
//     const response = await EmailScrapingService.getUnlinkedCreditCards(userId);
//     SuccessResponse.data = response;
//     return res.status(StatusCodes.OK).json(SuccessResponse);
//   } catch (error) {
//     ErrorResponse.error = error;
//     return res.status(error.statusCode).json(ErrorResponse);
//   }
// };

// // Revoke Google access token
// const removeAccessToken = async (req, res) => {
//   try {
//     const userId = req.user._id;

//     const response = await EmailScrapingService.removeAccessToken(userId);

//     SuccessResponse.data = response;
//     return res.status(StatusCodes.OK).json(SuccessResponse);
//   } catch (error) {
//     ErrorResponse.error = error;
//     const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
//     return res.status(statusCode).json(ErrorResponse);
//   }
// };

// module.exports = {
//   generateAccessToken,
//   scrapeEmailsByBankId,
//   getScrapedEmails,
//   getUnlinkedCreditCards,
//   removeAccessToken,
// };
import { Request, Response, NextFunction, RequestHandler } from 'express';
import { StatusCodes } from 'http-status-codes';
import { SuccessResponse, ErrorResponse } from '../utils/api-response';
import EmailScrapingService from '../services/email-service';

// Local type just for casting inside functions
interface AuthenticatedRequest extends Request {
  user: {
    _id: string;
    token?: string;
    [key: string]: any;
  };
}

/**
 * Implementation helpers (async) – they do the real work
 * and can use AuthenticatedRequest for typing.
 */

const generateAccessTokenImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const userId = user._id;
    const { idToken } = req.body as { idToken: string };

    const result = await EmailScrapingService.generateAccessToken(userId, idToken);

    const responseBody = { ...SuccessResponse, data: result };
    res.status(StatusCodes.OK).json(responseBody);
  } catch (error: any) {
    const errMessage =
      error?.response?.data?.error || error?.message || 'Unauthorized';

    const responseBody = { ...ErrorResponse, error: errMessage };
    res.status(StatusCodes.UNAUTHORIZED).json(responseBody);
  }
};

const scrapeEmailsByBankIdImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const userId = user._id;
    const { bankIds } = req.body as { bankIds: string[] };

    const response = await EmailScrapingService.scrapeEmailsByBankId(userId, bankIds);

    const responseBody = { ...SuccessResponse, data: response };
    res.status(StatusCodes.CREATED).json(responseBody);
  } catch (error: any) {
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    const responseBody = { ...ErrorResponse, error };
    res.status(statusCode).json(responseBody);
  }
};

const getScrapedEmailsImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const userId = user._id;

    const response = await EmailScrapingService.getScrapedEmails(userId);

    const responseBody = { ...SuccessResponse, data: response };
    res.status(StatusCodes.CREATED).json(responseBody);
  } catch (error: any) {
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    const responseBody = { ...ErrorResponse, error };
    res.status(statusCode).json(responseBody);
  }
};

const getUnlinkedCreditCardsImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const userId = user._id;

    const response = await EmailScrapingService.getUnlinkedCreditCards(userId);

    const responseBody = { ...SuccessResponse, data: response };
    res.status(StatusCodes.OK).json(responseBody);
  } catch (error: any) {
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    const responseBody = { ...ErrorResponse, error };
    res.status(statusCode).json(responseBody);
  }
};

const removeAccessTokenImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const userId = user._id;

    const response = await EmailScrapingService.removeAccessToken(userId);

    const responseBody = { ...SuccessResponse, data: response };
    res.status(StatusCodes.OK).json(responseBody);
  } catch (error: any) {
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    const responseBody = { ...ErrorResponse, error };
    res.status(statusCode).json(responseBody);
  }
};

/**
 * Exported handlers – these are the ones you pass to router.get/post.
 * They are explicitly typed as RequestHandler so Express types are happy.
 */

export const generateAccessToken: RequestHandler = (req, res, next) => {
  void generateAccessTokenImpl(req, res, next);
};

export const scrapeEmailsByBankId: RequestHandler = (req, res, next) => {
  void scrapeEmailsByBankIdImpl(req, res, next);
};

export const getScrapedEmails: RequestHandler = (req, res, next) => {
  void getScrapedEmailsImpl(req, res, next);
};

export const getUnlinkedCreditCards: RequestHandler = (req, res, next) => {
  void getUnlinkedCreditCardsImpl(req, res, next);
};

export const removeAccessToken: RequestHandler = (req, res, next) => {
  void removeAccessTokenImpl(req, res, next);
};
