const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
// const { avatars } = require("../utils/common/enums");

const accountSchema = new mongoose.Schema(
  {
    name: {
      type: String,
    },
    income: {
      type: Number,
      default: 0,
    },
    balance: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

const muteSchema = mongoose.Schema({
  muteType: {
    type: String,
    required: true,
  },
  id: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
  },
});

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
    },
    googleId: {
      type: String,
    },
    isGoogleUser: {
      type: Boolean,
      default: false,
    },
    isAppleUser: {
      type: Boolean,
      default: false,
    },
    appleUserId: {
      type: String,
    },
    interestedTags: {
      type: [String],
      default: [],
      trim: true,
    },
    maskedName: {
      type: String,
      default: "",
    },
    maskedConnections: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    maskedConnected: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    canMaskMessage: {
      type: Boolean,
      default: true,
    },
    email: {
      type: String,
      unique: true,
      trim: true,
      required: [true, "Please provide an email address"],
      match: [
        /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
        "Please enter a valid email",
      ],
    },
    dob: {
      type: Date,
    },
    password: {
      type: String,
      minLength: [6, "Password must be atleast 6 characters"],
    },
    phone: {
      type: [String],
      default: [],
      trim: true,
    },
    currency: {
      type: String,
      default: "INR",
    },
    friendsList: [
      {
        type: Object,
      },
    ],
    coins: {
      type: Number,
      default: 10,
    },
    accounts: {
      type: [accountSchema],
      validate: [
        {
          validator: function (v) {
            return v.length <= 4;
          },
          message: "Number of accounts cannot exceed 4",
        },
      ],
    },
    saved: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "PostBase",
      },
    ],
    myDiscussions: [
      {
        type: Object,
      },
    ],
    aboutMe: {
      type: String,
      default: "Hello",
    },
    roomsAssociated: [
      {
        type: Object,
        default: {},
      },
    ],
    reportedPosts: [
      {
        type: Object,
      },
    ],
    avatarType: {
      type: String,
      default: "",
    },
    avatarBackGround: {
      type: String,
      default: "#FA7070",
    },
    muted: {
      type: [muteSchema],
    },
    likedProducts: [
      {
        type: mongoose.Schema.Types.ObjectId,
      },
    ],
    likedPosts: [
      {
        type: String,
      },
    ],
    likedComments: [
      {
        type: String,
      },
    ],
    expense: {
      type: Number,
      default: 0,
    },
    score: {
      type: Number,
      default: 0,
    },
    firstTimeLogin: {
      type: Boolean,
      default: true,
    },
    isBankAccountLinked: {
      type: Boolean,
      default: false,
    },
    fetchInProgress: {
      type: Boolean,
      default: false,
    },
    cupertino_pin: {
      type: String,
      default: 0,
    },
    cupertinoAttemptCount: {
      type: Number,
      default: 0,
    },
    selectedBank: {
      type: String,
      default: "",
    },
    googleRefreshToken: {
      type: String,
      default: "",
    },
    banks: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Bank",
      },
    ],
    CreditCardLinkedBanks: [
      {
        type: String,
      },
    ],
  },
  {
    timestamps: true,
  }
);

userSchema.pre("save", async function (next) {
  try {
    if (!this.isModified("password") && !this.isModified("cupertino_pin"))
      return next();

    if (this.isModified("password") && this.password) {
      const salt = await bcrypt.genSalt(10);
      this.password = await bcrypt.hash(this.password, salt);
    }

    if (
      this.isModified("cupertino_pin") &&
      this.cupertino_pin &&
      this.cupertino_pin !== 0
    ) {
      const salt = await bcrypt.genSalt(10);
      this.cupertino_pin = await bcrypt.hash(this.cupertino_pin, salt);
    }

    next();
  } catch (error) {
    next(error);
  }
});

const User = mongoose.model("User", userSchema);
module.exports = {User, userSchema};

