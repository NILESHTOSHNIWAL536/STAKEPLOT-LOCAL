import mongoose from 'mongoose';

const strideEventSchema = new mongoose.Schema(
  {
    reason: { type: String, required: true },
    points: { type: Number, required: true },
    referenceId: { type: String },
    metadata: { type: mongoose.Schema.Types.Mixed, default: {} },
    createdAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const strideMilestoneSchema = new mongoose.Schema(
  {
    key: { type: String, required: true },
    awardedAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const stridesSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, required: true, unique: true, index: true },
    total: { type: Number, default: 0 },
    longestStreak: { type: Number, default: 0 },
    currentStreak: { type: Number, default: 0 },
    lastOpenDate: { type: String },
    streakStartedAt: { type: String },
    milestones: { type: [strideMilestoneSchema], default: [] },
    events: { type: [strideEventSchema], default: [] },
  },
  { timestamps: true }
);

stridesSchema.index({ total: -1 });

export default mongoose.model('Strides', stridesSchema);
