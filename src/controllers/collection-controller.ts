import { Request, Response, NextFunction } from 'express';
import { StatusCodes } from 'http-status-codes';
import { SuccessResponse } from '../utils/common';
import CollectionService from '../services/collection-service';
import CollectionInvitationService from '../services/collection-invitation-service';

export const createCollection = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { friends = [], ...collectionData } = req.body;
    const collection = await CollectionService.createCollection(userId, collectionData, friends);
    SuccessResponse.data = collection;
    SuccessResponse.message = 'Collection created successfully';
    res.status(StatusCodes.CREATED).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const getUserCollections = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const collections = await CollectionService.getUserCollections(userId);
    SuccessResponse.data = collections;
    SuccessResponse.message = 'Collections fetched successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const getCollectionById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;
    const collectionData = await CollectionService.getCollectionById(id, userId);
    SuccessResponse.data = collectionData;
    SuccessResponse.message = 'Collection fetched successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const addMembers = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authorId = req.user._id;
    const { id } = req.params;
    const { friends } = req.body;

    if (!Array.isArray(friends)) {
      SuccessResponse.message = 'friends must be an array';
      return res.status(StatusCodes.BAD_REQUEST).json(SuccessResponse);
    }

    // Send invitations instead of directly adding members
    const invitations = await CollectionInvitationService.sendInvitations(id, authorId, friends);
    SuccessResponse.data = invitations;
    SuccessResponse.message = 'Invitations sent successfully';
    res.status(StatusCodes.CREATED).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const addTransaction = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId } = req.params;
    const { transactionIds, splitType, customSplits } = req.body;
    const result = await CollectionService.addTransactions(collectionId, userId, transactionIds, splitType, customSplits);
    SuccessResponse.data = result;
    SuccessResponse.message = 'Transactions added to collection successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const updateSplit = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId, splitId } = req.params;
    const { customSplits } = req.body;
    const split = await CollectionService.updateSplit(collectionId, userId, splitId, customSplits);
    SuccessResponse.data = split;
    SuccessResponse.message = 'Split updated successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const deleteCollection = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;
    await CollectionService.deleteCollection(id, userId);
    SuccessResponse.data = {};
    SuccessResponse.message = 'Collection deleted successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const getAvailableTransactions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId } = req.params;
    const { page, limit } = req.query;

    const pageNum = parseInt(page as string) || 1;
    const limitNum = parseInt(limit as string) || 20;

    const result = await CollectionService.getAvailableTransactions(userId, collectionId, pageNum, limitNum);
    SuccessResponse.data = result;
    SuccessResponse.message = 'Available transactions fetched successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const getCollectionSplits = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId } = req.params;
    const splits = await CollectionService.getCollectionSplits(collectionId, userId);
    SuccessResponse.data = splits;
    SuccessResponse.message = 'Collection splits fetched successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const getBalances = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId } = req.params;
    const balances = await CollectionService.getBalances(collectionId, userId);
    SuccessResponse.data = balances;
    SuccessResponse.message = 'Balances calculated successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const updateCollection = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId } = req.params;
    const { name, description, expiryAt } = req.body;
    const collection = await CollectionService.updateCollection(collectionId, userId, { name, description, expiryAt });
    SuccessResponse.data = collection;
    SuccessResponse.message = 'Collection updated successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const closeCollection = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId } = req.params;
    const collection = await CollectionService.closeCollection(collectionId, userId);
    SuccessResponse.data = collection;
    SuccessResponse.message = 'Collection closed successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const getAllTransactions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId } = req.params;
    const { page, limit } = req.query;
    const pageNum = parseInt(page as string) || 1;
    const limitNum = parseInt(limit as string) || 20;
    const result = await CollectionService.getAllTransactions(collectionId, userId, pageNum, limitNum);
    SuccessResponse.data = result;
    SuccessResponse.message = 'Transactions fetched successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const updateCollectionMember = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId, memberId } = req.params;
    const { role, limitAmount } = req.body;

    const updatedMember = await CollectionService.updateCollectionMember(collectionId, userId, memberId, role, limitAmount);
    SuccessResponse.data = updatedMember;
    SuccessResponse.message = 'Collection member amount updated successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

// ============================================
// COLLECTION INVITATION ENDPOINTS
// ============================================

export const getPendingInvitations = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;

    const result = await CollectionInvitationService.getPendingInvitations(userId);
    SuccessResponse.data = result;
    SuccessResponse.message = 'Pending invitations fetched successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const acceptInvitation = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { invitationId } = req.params;

    const result = await CollectionInvitationService.acceptInvitation(invitationId, userId);
    SuccessResponse.data = result;
    SuccessResponse.message = 'Invitation accepted successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const rejectInvitation = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { invitationId } = req.params;

    const result = await CollectionInvitationService.rejectInvitation(invitationId, userId);
    SuccessResponse.data = result;
    SuccessResponse.message = 'Invitation rejected successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const cancelInvitation = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId, invitationId } = req.params;

    await CollectionInvitationService.cancelInvitation(invitationId, userId);
    SuccessResponse.data = {};
    SuccessResponse.message = 'Invitation cancelled successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const getCollectionInvitations = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const { id: collectionId } = req.params;
    const { status } = req.query;

    const invitations = await CollectionInvitationService.getCollectionInvitations(collectionId, userId, status as 'PENDING' | 'ACCEPTED' | 'REJECTED' | 'EXPIRED' | undefined);
    SuccessResponse.data = invitations;
    SuccessResponse.message = 'Collection invitations fetched successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export default {
  createCollection,
  getUserCollections,
  getCollectionById,
  addMembers,
  addTransaction,
  updateSplit,
  deleteCollection,
  getAvailableTransactions,
  getCollectionSplits,
  getBalances,
  updateCollection,
  closeCollection,
  getAllTransactions,
  updateCollectionMember,
  getPendingInvitations,
  acceptInvitation,
  rejectInvitation,
  cancelInvitation,
  getCollectionInvitations,
};
