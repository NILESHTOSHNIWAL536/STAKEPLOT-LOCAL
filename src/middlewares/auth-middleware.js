const { User } = require("../models");
const jwt = require("jsonwebtoken");
const AppError = require("../utils/errors/app-error");
const { StatusCodes } = require("http-status-codes");
// const { OAuth2Client } = require("google-auth-library");
const { ErrorResponse } = require("../utils/common");
const { ServerConfig } = require("../config");
const { UserService } = require("../services");
// const client = new OAuth2Client(ServerConfig.GOOGLE_APP_CLIENTID);
const axios = require("axios");
const { Session } = require("../models");

const verifyGoogleToken = async (token) => {
  const response = await axios.get(`https://oauth2.googleapis.com/tokeninfo?access_token=${token}`);
  if (response.status !== 200) {
    throw new Error("Invalid Google token");
  }
  return response.data;
};

const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      ErrorResponse.error = "JsonWebTokenError";
      return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
    }

    const [tokenType, token] = authHeader.split(" ");

    if (tokenType === "Bearer") {
      try {
        const decoded = jwt.verify(token, ServerConfig.JWT_SECRET);
        const user = await User.findOne({ _id: decoded.id }).select("-password");

        if (!user) throw new AppError("User Not found", StatusCodes.UNAUTHORIZED);

        // Check if token is active in the session database
        const session = await Session.findOne({ userId: user._id });
        if (!session) {
          ErrorResponse.error = "JsonWebTokenError";
          return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
        }

        req.user = user;
        req.user.token = token;
        return next();
      } catch {
        ErrorResponse.error = "JsonWebTokenError";
        return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      }
    } else if (tokenType === "Google") {
      try {
        const payload = await verifyGoogleToken(token);
        let user = await User.findOne({ googleId: payload.sub }).select("-password");

        if (!user) {
          user = await UserService.createUser({
            googleId: payload.sub,
            email: payload.email,
            password: payload.sub,
          });
        }

        // Check if the Google token session is active
        const session = await Session.findOne({ userId: user._id });
        if (!session) {
          throw new AppError("Google session expired. Please log in again.", StatusCodes.UNAUTHORIZED);
        }

        req.user = user;
        req.user.token = token;
        return next();
      } catch {
        ErrorResponse.error = "GToken might be expired or wrong";
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
      }
    } else {
      throw new AppError("Invalid token type", StatusCodes.BAD_REQUEST);
    }
  } catch {
    ErrorResponse.error = "AuthenticationError";
    return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
  }
};

module.exports = { protect };
