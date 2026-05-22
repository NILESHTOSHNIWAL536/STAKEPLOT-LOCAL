import mongoose, { Schema, Document } from 'mongoose';

export interface ICollectionInvitation extends Document {
  collectionId: mongoose.Types.ObjectId;
  invitedByUserId: mongoose.Types.ObjectId;
  invitedUserId: mongoose.Types.ObjectId;
  invitedEmail?: string;
  role: 'VIEW' | 'CONTRIBUTE';
  status: 'PENDING' | 'ACCEPTED' | 'REJECTED' | 'EXPIRED';
  expiresAt: Date;
  acceptedAt?: Date;
  rejectedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const collectionInvitationSchema = new Schema<ICollectionInvitation>(
  {
    collectionId: {
      type: Schema.Types.ObjectId,
      ref: 'Collection',
      required: true,
    },

    invitedByUserId: {
      type: Schema.Types.ObjectId,
      required: true,
    },

    invitedUserId: {
      type: Schema.Types.ObjectId,
      required: true,
    },

    invitedEmail: {
      type: String,
      default: '',
    },

    role: {
      type: String,
      enum: ['VIEW', 'CONTRIBUTE'],
      default: 'VIEW',
      required: true,
    },

    status: {
      type: String,
      enum: ['PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED'],
      default: 'PENDING',
      required: true,
    },

    expiresAt: {
      type: Date,
      required: true,
      default: () => new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
    },

    acceptedAt: {
      type: Date,
      default: null,
    },

    rejectedAt: {
      type: Date,
      default: null,
    },
  },
  { timestamps: true }
);

// Indexes for efficient querying
collectionInvitationSchema.index({ invitedUserId: 1, status: 1 }); // Get pending invitations for a user
collectionInvitationSchema.index({ collectionId: 1, status: 1 }); // Get invitations for a collection
collectionInvitationSchema.index({ expiresAt: 1 }); // Cleanup expired invitations
collectionInvitationSchema.index({ collectionId: 1, invitedUserId: 1 }, { unique: true, sparse: true }); // Prevent duplicate invitations

const CollectionInvitation = mongoose.model<ICollectionInvitation>(
  'CollectionInvitation',
  collectionInvitationSchema
);

export default CollectionInvitation;
