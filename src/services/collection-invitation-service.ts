import mongoose from 'mongoose';
import CollectionInvitation, { ICollectionInvitation } from '../models/collections/collection-invitation.model';
import Collection from '../models/collections/collection.model';
import CollectionMember from '../models/collections/collection-member.model';
import Notification from '../models/notification-model';
import AppError from '../utils/errors/app-error';
import { StatusCodes } from 'http-status-codes';
import UserService from './user-service';
import { redisClient } from '../config';
import { Types } from 'mongoose';

const MAX_COLLECTIONS_PER_USER = 10;

/**
 * Send invitations to multiple friends for a collection
 */
export const sendInvitations = async (
  collectionId: string,
  invitedByUserId: string,
  friends: Array<{ friendId: string; role?: 'VIEW' | 'CONTRIBUTE' }>
): Promise<ICollectionInvitation[]> => {
  // Verify collection exists and user has permission
  const collection = await Collection.findById(collectionId);
  if (!collection) {
    throw new AppError('Collection not found', StatusCodes.NOT_FOUND);
  }

  if (collection.type == 'PERSONAL') {
    throw new AppError('personal collection cannot have members', StatusCodes.FORBIDDEN);
  }

  const authorMember = await CollectionMember.findOne({ collectionId, userId: invitedByUserId });
  if (!authorMember || authorMember.role !== 'CONTRIBUTE') {
    throw new AppError('Only collection contributors can send invitations', StatusCodes.FORBIDDEN);
  }

  const invitations: ICollectionInvitation[] = [];
  const invitingUser = await UserService.hydrateUsers([invitedByUserId]);

  for (const friend of friends) {
    const { friendId, role = 'VIEW' } = friend;

    // Validate role
    if (role !== 'VIEW' && role !== 'CONTRIBUTE') {
      throw new AppError(`Invalid role: ${role}`, StatusCodes.BAD_REQUEST);
    }

    // Check if user exists
    const friendData = await UserService.hydrateUsers([friendId]);
    if (!friendData || friendData.length === 0) {
      throw new AppError(`User ${friendId} not found`, StatusCodes.NOT_FOUND);
    }

    const friendCollectionCount = await CollectionMember.aggregate([
      { $match: { userId: friendId } },
      {
        $lookup: {
          from: 'collections',
          localField: 'collectionId',
          foreignField: '_id',
          as: 'collectionData',
        },
      },
      { $unwind: '$collectionData' },
      { $match: { 'collectionData.status': 'ACTIVE' } },
      { $count: 'count' },
    ]);

    const memberCount = friendCollectionCount.length > 0 ? friendCollectionCount[0].count : 0;

    if (memberCount >= MAX_COLLECTIONS_PER_USER) {
      throw new AppError(`User ${friendId} has reached the maximum allowed collections (2)`, StatusCodes.BAD_REQUEST);
    }

    // Check if user is already a member
    const existingMember = await CollectionMember.findOne({
      collectionId,
      userId: friendId,
    });
    if (existingMember) {
      throw new AppError(`User ${friendId} is already a member of this collection`, StatusCodes.BAD_REQUEST);
    }

    // Check if invitation already exists and is pending
    const existingInvitation = await CollectionInvitation.findOne({
      collectionId,
      invitedUserId: friendId,
      status: 'PENDING',
    });
    if (existingInvitation) {
      throw new AppError(`Pending invitation already exists for user ${friendId}`, StatusCodes.BAD_REQUEST);
    }

    // Create invitation with 30-day expiry
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    const invitation = new CollectionInvitation({
      collectionId,
      invitedByUserId,
      invitedUserId: friendId,
      invitedEmail: friendData[0]?.email || '',
      role,
      status: 'PENDING',
      expiresAt,
    });

    await invitation.save();
    invitations.push(invitation);

    // Create notification in database
    const notification = new Notification({
      userId: friendId,
      notificationMessage: {
        type: 'COLLECTION_INVITATION',
        invitationId: invitation._id.toString(),
        collectionId: collectionId,
        collectionName: collection.name,
        invitedByUser: {
          _id: invitingUser[0]?._id || invitedByUserId,
          name: invitingUser[0]?.name || 'Unknown',
          email: invitingUser[0]?.email || '',
        },
        action: 'INVITED',
        expiresAt,
        roleOffered: role,
      },
      acknowledged: false,
    });
    await notification.save();

    // Publish real-time event via WebSocket
    await publishSocketEvent(friendId, 'collection:invitation_received', {
      invitationId: invitation._id.toString(),
      collectionId,
      collectionName: collection.name,
      invitedBy: {
        _id: invitingUser[0]?._id || invitedByUserId,
        name: invitingUser[0]?.name || 'Unknown',
      },
      expiresAt,
      role,
    });
  }

  return invitations;
};

/**
 * Get all pending invitations for a user
 */
export const getPendingInvitations = async (userId: string): Promise<{ invitations: any[] }> => {
  const invitations = await CollectionInvitation.find({
    invitedUserId: userId,
    status: 'PENDING',
    expiresAt: { $gt: new Date() },
  })
    .populate('collectionId')
    .sort({ createdAt: -1 })
    .lean();

  // Hydrate user data
  const userIds = new Set<string>();
  invitations.forEach((inv: any) => {
    userIds.add(inv.invitedByUserId.toString());
  });

  const userData = await UserService.hydrateUsers(Array.from(userIds));
  const userMap = new Map();
  userData.forEach((u: any) => userMap.set(u._id.toString(), u));

  const hydratedInvitations = invitations.map((inv: any) => ({
    ...inv,
    invitedBy: userMap.get(inv.invitedByUserId.toString()) || { _id: inv.invitedByUserId },
    collection: inv.collectionId,
  }));

  return {
    invitations: hydratedInvitations,
  };
};

/**
 * Accept an invitation
 */
export const acceptInvitation = async (invitationId: string, userId: string): Promise<{ invitation: ICollectionInvitation; member: any }> => {
  const invitation = await CollectionInvitation.findById(invitationId);

  if (!invitation) {
    throw new AppError('Invitation not found', StatusCodes.NOT_FOUND);
  }

  // Verify this invitation is for the current user
  if (invitation.invitedUserId.toString() !== userId) {
    throw new AppError('This invitation is not for you', StatusCodes.FORBIDDEN);
  }

  // Check invitation status
  if (invitation.status !== 'PENDING') {
    throw new AppError(`This invitation has already been ${invitation.status.toLowerCase()}`, StatusCodes.BAD_REQUEST);
  }

  // Check if invitation has expired
  if (invitation.expiresAt < new Date()) {
    invitation.status = 'EXPIRED';
    await invitation.save();
    throw new AppError('This invitation has expired', StatusCodes.BAD_REQUEST);
  }

  // Check if user is already a member
  const existingMember = await CollectionMember.findOne({
    collectionId: invitation.collectionId,
    userId,
  });
  if (existingMember) {
    throw new AppError('You are already a member of this collection', StatusCodes.BAD_REQUEST);
  }

  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    // Update invitation status
    invitation.status = 'ACCEPTED';
    invitation.acceptedAt = new Date();
    await invitation.save({ session });

    // Create collection member
    const newMember = new CollectionMember({
      collectionId: invitation.collectionId,
      userId,
      role: invitation.role,
      joinedAt: new Date(),
    });
    await newMember.save({ session });

    // Get collection and accepting user data
    const collection = await Collection.findById(invitation.collectionId).session(session);
    const acceptingUserData = await UserService.hydrateUsers([userId]);
    const collectionOwnerData = await UserService.hydrateUsers([invitation.invitedByUserId]);

    // Create notification for collection owner
    const notificationForOwner = new Notification({
      userId: invitation.invitedByUserId,
      notificationMessage: {
        type: 'COLLECTION_INVITATION',
        invitationId: invitation._id.toString(),
        collectionId: invitation.collectionId.toString(),
        collectionName: collection?.name || 'Unknown',
        action: 'ACCEPTED',
        acceptedBy: {
          _id: userId,
          name: acceptingUserData[0]?.name || 'Unknown',
        },
      },
      acknowledged: false,
    });
    await notificationForOwner.save({ session });

    // Publish event to collection owner and members
    await publishSocketEvent(invitation.invitedByUserId, 'collection:member_joined', {
      collectionId: invitation.collectionId.toString(),
      collectionName: collection?.name || 'Unknown',
      newMember: {
        _id: userId,
        name: acceptingUserData[0]?.name || 'Unknown',
        role: invitation.role,
      },
    });

    // Also notify other members of the collection
    const otherMembers = await CollectionMember.find({
      collectionId: invitation.collectionId,
      userId: { $ne: userId },
    })
      .select('userId')
      .session(session)
      .lean();

    for (const member of otherMembers) {
      await publishSocketEvent(member.userId, 'collection:member_joined', {
        collectionId: invitation.collectionId.toString(),
        newMember: {
          _id: userId,
          name: acceptingUserData[0]?.name || 'Unknown',
          role: invitation.role,
        },
      });
    }

    await session.commitTransaction();
    session.endSession();

    return {
      invitation,
      member: newMember.toObject(),
    };
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    throw error;
  }
};

/**
 * Reject an invitation
 */
export const rejectInvitation = async (invitationId: string, userId: string): Promise<ICollectionInvitation> => {
  const invitation = await CollectionInvitation.findById(invitationId);

  if (!invitation) {
    throw new AppError('Invitation not found', StatusCodes.NOT_FOUND);
  }

  // Verify this invitation is for the current user
  if (invitation.invitedUserId.toString() !== userId) {
    throw new AppError('This invitation is not for you', StatusCodes.FORBIDDEN);
  }

  // Check invitation status
  if (invitation.status !== 'PENDING') {
    throw new AppError(`This invitation has already been ${invitation.status.toLowerCase()}`, StatusCodes.BAD_REQUEST);
  }

  invitation.status = 'REJECTED';
  invitation.rejectedAt = new Date();
  await invitation.save();

  // Create notification for collection owner
  const collection = await Collection.findById(invitation.collectionId);
  const rejectingUserData = await UserService.hydrateUsers([userId]);

  const notification = new Notification({
    userId: invitation.invitedByUserId,
    notificationMessage: {
      type: 'COLLECTION_INVITATION',
      invitationId: invitation._id.toString(),
      collectionId: invitation.collectionId.toString(),
      collectionName: collection?.name || 'Unknown',
      action: 'REJECTED',
      rejectedBy: {
        _id: userId,
        name: rejectingUserData[0]?.name || 'Unknown',
      },
    },
    acknowledged: false,
  });
  await notification.save();

  // Publish event
  await publishSocketEvent(invitation.invitedByUserId, 'collection:invitation_rejected', {
    collectionId: invitation.collectionId.toString(),
    collectionName: collection?.name || 'Unknown',
    rejectedBy: {
      _id: userId,
      name: rejectingUserData[0]?.name || 'Unknown',
    },
  });

  return invitation;
};

/**
 * Cancel an invitation (owner/sender only)
 */
export const cancelInvitation = async (invitationId: string, userId: string): Promise<void> => {
  const invitation = await CollectionInvitation.findById(invitationId);

  if (!invitation) {
    throw new AppError('Invitation not found', StatusCodes.NOT_FOUND);
  }

  // Verify user is the one who sent the invitation
  if (invitation.invitedByUserId.toString() !== userId) {
    throw new AppError('Only the invitation sender can cancel it', StatusCodes.FORBIDDEN);
  }

  // Check invitation status
  if (invitation.status !== 'PENDING') {
    throw new AppError(`Cannot cancel a ${invitation.status.toLowerCase()} invitation`, StatusCodes.BAD_REQUEST);
  }

  // Delete the invitation
  await CollectionInvitation.findByIdAndDelete(invitationId);

  // Notify the invited user that invitation was cancelled
  const collection = await Collection.findById(invitation.collectionId);
  const cancellingUserData = await UserService.hydrateUsers([userId]);

  const notification = new Notification({
    userId: invitation.invitedUserId,
    notificationMessage: {
      type: 'COLLECTION_INVITATION',
      invitationId: invitationId,
      collectionId: invitation.collectionId.toString(),
      collectionName: collection?.name || 'Unknown',
      action: 'CANCELLED',
      cancelledBy: {
        _id: userId,
        name: cancellingUserData[0]?.name || 'Unknown',
      },
    },
    acknowledged: false,
  });
  await notification.save();

  // Publish event
  await publishSocketEvent(invitation.invitedUserId, 'collection:invitation_cancelled', {
    invitationId,
    collectionId: invitation.collectionId.toString(),
    cancelledBy: {
      _id: userId,
      name: cancellingUserData[0]?.name || 'Unknown',
    },
  });
};

/**
 * Get invitations for a collection (view pending/accepted/rejected)
 */
export const getCollectionInvitations = async (collectionId: string, userId: string, status?: 'PENDING' | 'ACCEPTED' | 'REJECTED' | 'EXPIRED'): Promise<any[]> => {
  // Verify user has access to collection
  const member = await CollectionMember.findOne({ collectionId, userId });
  if (!member || member.role !== 'CONTRIBUTE') {
    throw new AppError('Only collection contributors can view invitations', StatusCodes.FORBIDDEN);
  }

  const query: any = { collectionId };
  if (status) {
    query.status = status;
  }

  const invitations = await CollectionInvitation.find(query).lean();

  // Hydrate user data
  const userIds = new Set<string>();
  invitations.forEach((inv: any) => {
    userIds.add(inv.invitedUserId.toString());
    userIds.add(inv.invitedByUserId.toString());
  });

  const userData = await UserService.hydrateUsers(Array.from(userIds));
  const userMap = new Map();
  userData.forEach((u: any) => userMap.set(u._id.toString(), u));

  return invitations.map((inv: any) => ({
    ...inv,
    invitedUser: userMap.get(inv.invitedUserId.toString()) || { _id: inv.invitedUserId },
    invitedBy: userMap.get(inv.invitedByUserId.toString()) || { _id: inv.invitedByUserId },
  }));
};

/**
 * Check invitation status for a user and collection
 */
export const checkInvitationStatus = async (collectionId: string, userId: string): Promise<ICollectionInvitation | null> => {
  return await CollectionInvitation.findOne({
    collectionId,
    invitedUserId: userId,
    status: 'PENDING',
  });
};

/**
 * Cleanup expired invitations (cron job)
 */
export const cleanupExpiredInvitations = async (): Promise<number> => {
  const result = await CollectionInvitation.updateMany(
    {
      status: 'PENDING',
      expiresAt: { $lt: new Date() },
    },
    { status: 'EXPIRED' }
  );

  // Optionally, you can delete them instead
  // await CollectionInvitation.deleteMany({ status: 'EXPIRED' });

  return result.modifiedCount || 0;
};

/**
 * Helper: Publish socket event via Redis
 */
async function publishSocketEvent(userId: string | Types.ObjectId, event: string, data: any): Promise<void> {
  try {
    await redisClient.publish(
      'bank_events',
      JSON.stringify({
        userId,
        event,
        data,
        timestamp: new Date().toISOString(),
      })
    );
  } catch (error) {
    console.error('Error publishing socket event:', error);
    // Log but don't throw - WebSocket events are non-critical
  }
}

export default {
  sendInvitations,
  getPendingInvitations,
  acceptInvitation,
  rejectInvitation,
  cancelInvitation,
  getCollectionInvitations,
  checkInvitationStatus,
  cleanupExpiredInvitations,
};
