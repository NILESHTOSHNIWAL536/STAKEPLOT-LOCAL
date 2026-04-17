
import mongoose from "mongoose";

const RESERVE_CATEGORIES = [
  "travel",
  "food",
  "shopping",
  "groceries",
  "overall",
] as const;

const snapshotSchema = new mongoose.Schema(
  {
    date: { type: Date, required: true },
    spend: { type: Number, default: 0 },
    projectedTotal: { type: Number, default: 0 },
    percentUsed: { type: Number, default: 0 },
    remaining: { type: Number, default: 0 },
    remainingDays: { type: Number, default: 0 },
    recommendedDaily: { type: Number, default: 0 },
    recoveryTarget: { type: Number, default: 0 },
    alertSent: { type: Boolean, default: false },
    overspendNotified: { type: Boolean, default: false },
  },
  { _id: false }
);

const reserveSchema = new mongoose.Schema(
  {
    categories: {
      type: [String],
      enum: RESERVE_CATEGORIES,
      required: true,
    },

    amount: {
      type: Number,
      required: true,
    },

    suggested_limit: { type: Number },
    planned_daily: { type: Number },
    duration_days: { type: Number },
    daily_baseline: { type: Number },
    momentum: { type: Number },
    mtd_pressure: { type: Number },
    adjustment_factor: { type: Number },

    startDate: {
      type: Date,
      required: true,
    },

    endDate: {
      type: Date,
      required: true,
    },

    notify_at_percent: {
      type: Number,
      default: 90,
      min: 1,
      max: 100,
    },

    reminder_time: {
      type: String, // HH:mm in user's local preference
      required: true,
    },

    partner_reserve: {
      type: Boolean,
      default: false,
    },

    reserve_widget: {
      type: Boolean,
      default: false,
    },

    share_with_community: {
      type: Boolean,
      default: false,
    },

    achieved: {
      type: Boolean,
      default: false,
    },

    status: {
      type: String,
      enum: ["UPCOMING", "ACTIVE", "COMPLETED", "OVERSPENT"],
      default: "UPCOMING",
    },

    last_notified_percent: {
      type: Number,
      default: 0,
    },

    pre_alert_sent: {
      type: Boolean,
      default: false,
    },

    recovery_notified: {
      type: Boolean,
      default: false,
    },

    snapshots: {
      type: [snapshotSchema],
      default: [],
    },

    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

// 🔥 VALIDATION (IMPORTANT)
reserveSchema.pre("save", function (next) {
  if (this.startDate > this.endDate) {
    return next(new Error("startDate cannot be after endDate"));
  }

  const diff =
    (this.endDate.getTime() - this.startDate.getTime()) /
      (1000 * 60 * 60 * 24) +
    1;

  if (diff > 7) {
    return next(new Error("Max 7 days allowed"));
  }

  next();
});

reserveSchema.index({ userId: 1, startDate: 1 });

export const Reserve = mongoose.model("Reserve", reserveSchema);
export type ReserveDocument = mongoose.InferSchemaType<typeof reserveSchema> & mongoose.Document;
export type ReserveSnapshot = mongoose.InferSchemaType<typeof snapshotSchema>;
export const RESERVE_CATEGORY_ENUM = RESERVE_CATEGORIES;
