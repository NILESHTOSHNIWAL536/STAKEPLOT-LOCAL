const mongoose = require('mongoose');
const AppError = require('../utils/errors/app-error');
const { StatusCodes } = require('http-status-codes');
// const { StatusCode } = require('@aws-sdk/client-cloudwatch');

class InputValidator {
  static sanitizeString(input, maxLength = 255) {
    if (typeof input !== 'string') return '';
    return input.trim().substring(0, maxLength);
  }

  static validateObjectId(id) {
    if (!mongoose.Types.ObjectId.isValid(id)) throw new AppError('Invalid ObjectId format',StatusCodes.BAD_REQUEST);
    return new mongoose.Types.ObjectId(id);
  }

  static validateEmail(email) {
    const sanitized = this.sanitizeString(email).trim().toLowerCase();
    const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
    if (!emailRegex.test(sanitized)) throw new AppError('Invalid email format',StatusCodes.BAD_REQUEST);
    return sanitized;
  }

  static sanitizeQueryObject(obj) {
    if (obj === null || typeof obj !== 'object') return obj;

    const sanitized = {};
    for (const [key, value] of Object.entries(obj)) {
      // Block keys that start with MongoDB operators
      if (key.startsWith('$') || key.includes('.')) {
        throw new Error('Invalid query parameter');
      }

      sanitized[key] = typeof value === 'object' ? this.sanitizeQueryObject(value) : typeof value === 'string' ? this.sanitizeString(value) : value;
    }
    return sanitized;
  }

  // SPECIAL CHECK FOR DEVICE INFO OBJECT
  static validateDeviceInfo(obj) {
    if (obj == null || typeof obj !== 'object') return null;

    // Only allow these keys
    const allowedKeys = ['deviceId', 'device', 'brand', 'model', 'os'];
    const sanitized = {};

    for (const key of allowedKeys) {
      if (Object.prototype.hasOwnProperty.call(obj, key)) {
        const val = obj[key];

        // allow only strings
        if (typeof val !== 'string') throw new App(`Invalid type for ${key}`);

        // basic whitelist: allow letters, numbers, hyphen, underscore and space, limit length
        const safeRegex = /^[A-Za-z0-9 _\-]{1,64}$/;
        if (!safeRegex.test(val.trim()) || val.trim().length === 0) {
          throw new Error(`Invalid characters or empty value in ${key}`);
        }

        sanitized[key] = val.trim();
      }
    }

    return sanitized;
  }
}

module.exports = InputValidator;
