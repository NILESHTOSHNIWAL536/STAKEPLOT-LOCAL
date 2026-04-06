
import mongoose from "mongoose";

const reserveSchema = new mongoose.Schema(
  {
    categories: {
      type: [String],
      required: true,
    },

    amount: {
      type: Number,
      required: true,
    },

    // ✅ NEW
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
      required: true,
    },

    reminder_time: {
      type: String, // later we can convert to object
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

    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
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

export const Reserve = mongoose.model("Reserve", reserveSchema);