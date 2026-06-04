import { Request, Response, NextFunction, RequestHandler } from 'express';
import { StatusCodes } from 'http-status-codes';
import { SuccessResponse } from '../utils/api-response';
import EmailScrapingService from '../services/email-service';

interface AuthenticatedRequest extends Request {
  user: {
    _id: string;
    token?: string;
    [key: string]: any;
  };
}

const generateAccessTokenImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const { idToken, bankId } = req.body as { idToken: string; bankId: string };
    const result = await EmailScrapingService.generateAccessToken(user._id, idToken, bankId);
    res.status(StatusCodes.OK).json({ ...SuccessResponse, data: result });
  } catch (error:any) {
    // next(error);
    try {
      const parsed = JSON.parse(error.message);

      res.status(error.statusCode || 500).json({
        success: false,
        ...parsed,
      });

    } catch {
      next(error);
    }
  }
};

const scrapeEmailsByBankIdImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const { bankIds, email } = req.body as { bankIds: string[]; email: string };
    const response = await EmailScrapingService.scrapeEmailsByBankId(user._id, bankIds, email);

    res.status(StatusCodes.CREATED).json({ ...SuccessResponse, data: response });
  } catch (error) {
    console.error('Error in scrapeEmailsByBankIdImpl:', error);
    next(error);
  }
};

const saveStatementPasswordImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const { bankId, password, email, accountHint } = req.body as {
      bankId: string;
      password: string;
      email?: string;
      accountHint?: string;
    };
    const response = await EmailScrapingService.saveStatementPassword(user._id, {
      bankId,
      password,
      email,
      accountHint,
    });

    res.status(StatusCodes.OK).json({ ...SuccessResponse, data: response });
  } catch (error) {
    next(error);
  }
};

const getScrapedEmailsImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const response = await EmailScrapingService.getScrapedEmails(user._id);

    res.status(StatusCodes.CREATED).json({ ...SuccessResponse, data: response });
  } catch (error) {
    next(error);
  }
};

const getUnlinkedCreditCardsImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const response = await EmailScrapingService.getUnlinkedCreditCards(user._id);

    res.status(StatusCodes.OK).json({ ...SuccessResponse, data: response });
  } catch (error) {
    next(error);
  }
};

const removeAccessTokenImpl = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { user } = req as AuthenticatedRequest;
    const { email } = (req.body || {}) as { email?: string };
    const response = await EmailScrapingService.removeAccessToken(user._id, email);

    res.status(StatusCodes.OK).json({ ...SuccessResponse, data: response });
  } catch (error) {
    next(error);
  }
};

export const generateAccessToken: RequestHandler = (req, res, next) => {
  void generateAccessTokenImpl(req, res, next);
};

export const scrapeEmailsByBankId: RequestHandler = (req, res, next) => {
  void scrapeEmailsByBankIdImpl(req, res, next);
};

export const saveStatementPassword: RequestHandler = (req, res, next) => {
  void saveStatementPasswordImpl(req, res, next);
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

export const addBankMapping = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, bankId } = req.body;
    const { user } = req as AuthenticatedRequest;

    const result = await EmailScrapingService.addBankMapping(
      email,
      bankId,
      user._id
    );

    res.status(StatusCodes.OK).json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};
