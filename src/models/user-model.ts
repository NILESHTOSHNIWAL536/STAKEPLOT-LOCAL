import mongoose, { Schema, Document, Types } from "mongoose";
import bcrypt from "bcrypt";

/* =======================
   Account Sub Schema
======================= */

export interface IAccount {
  name?: string;
  income: number;
  balance: number;
}

const accountSchema = new Schema<IAccount>(
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
  { _id: false }
);

/* =======================
   Mute Sub Schema
======================= */

export interface IMute {
  muteType: string;
  id: Types.ObjectId;
}

const muteSchema = new Schema<IMute>(
  {
    muteType: {
      type: String,
      required: true,
    },
    id: {
      type: Schema.Types.ObjectId,
      required: true,
    },
  },
  { _id: false }
);

/* =======================
   User Interface
======================= */

export interface IUser extends Document {
  name?: string;
  googleId?: string;
  isGoogleUser: boolean;
  isAppleUser: boolean;
  appleUserId?: string;

  interestedTags: string[];
  maskedName: string;
  maskedConnections: Types.ObjectId[];
  maskedConnected: Types.ObjectId[];
  canMaskMessage: boolean;

  email: string;
  dob?: Date;
  password?: string;

  phone: string[];
  currency: string;

  friendsList: Record<string, any>[];
  coins: number;

  accounts: IAccount[];

  saved: Types.ObjectId[];
  myDiscussions: Record<string, any>[];

  aboutMe: string;
  roomsAssociated: Record<string, any>[];
  reportedPosts: Record<string, any>[];

  avatarType: string;
  avatarBackGround: string;

  muted: IMute[];

  likedProducts: Types.ObjectId[];
  likedPosts: string[];
  likedComments: string[];

  expense: number;
  score: number;

  firstTimeLogin: boolean;
  isBankAccountLinked: boolean;
  fetchInProgress: boolean;

  cupertino_pin: string | number;
  cupertinoAttemptCount: number;

  selectedBank: string;
  googleRefreshToken: string;

  banks: Types.ObjectId[];
  CreditCardLinkedBanks: Types.ObjectId[];
}

/* =======================
   User Schema
======================= */

const userSchema = new Schema<IUser>(
  {
    name: { type: String },

    googleId: { type: String },

    isGoogleUser: {
      type: Boolean,
      default: false,
    },

    isAppleUser: {
      type: Boolean,
      default: false,
    },

    appleUserId: { type: String },

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
        type: Schema.Types.ObjectId,
        ref: "User",
      },
    ],

    maskedConnected: [
      {
        type: Schema.Types.ObjectId,
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

    dob: { type: Date },

    password: {
      type: String,
      minlength: 6,
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

    friendsList: [{ type: Object }],

    coins: {
      type: Number,
      default: 10,
    },

    accounts: {
      type: [accountSchema],
      validate: [
        {
          validator: function (v: IAccount[]) {
            return v.length <= 4;
          },
          message: "Number of accounts cannot exceed 4",
        },
      ],
    },

    saved: [
      {
        type: Schema.Types.ObjectId,
        ref: "PostBase",
      },
    ],

    myDiscussions: [{ type: Object }],

    aboutMe: {
      type: String,
      default: "Hello",
    },

    roomsAssociated: [{ type: Object, default: {} }],

    reportedPosts: [{ type: Object }],

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

    likedProducts: [{ type: Schema.Types.ObjectId }],

    likedPosts: [{ type: String }],

    likedComments: [{ type: String }],

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
        type: Schema.Types.ObjectId,
        ref: "Bank",
      },
    ],

    CreditCardLinkedBanks: [
      {
        type: Schema.Types.ObjectId,
        ref: "CreditCardBank",
      },
    ],
  },
  { timestamps: true }
);

/* =======================
   Pre-save Hook
======================= */

userSchema.pre<IUser>("save", async function (next) {
  try {
    if (!this.isModified("password") && !this.isModified("cupertino_pin")) {
      return next();
    }

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
      this.cupertino_pin = await bcrypt.hash(
        String(this.cupertino_pin),
        salt
      );
    }

    next();
  } catch (error) {
    next(error as any);
  }
});

/* =======================
   Export Model
======================= */

const User = mongoose.model<IUser>("User", userSchema);
export default User;
