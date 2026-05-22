import mongoose from 'mongoose';
import AppError from '../utils/errors/app-error';
import { StatusCodes } from 'http-status-codes';

export interface DeviceInfo {
  deviceId?: string;
  device?: string;
  brand?: string;
  model?: string;
  os?: string;
}

export default class InputValidator {
  static sanitizeString(input: unknown, maxLength = 255): string {
    if (typeof input !== 'string') return '';
    return input.trim().substring(0, maxLength);
  }

  static validateObjectId(id: string): mongoose.Types.ObjectId {
    if (!mongoose.Types.ObjectId.isValid(id)) {
      throw new AppError('Invalid ObjectId format', StatusCodes.BAD_REQUEST);
    }
    return new mongoose.Types.ObjectId(id);
  }

  static validateEmail(email: unknown): string {
    const sanitized = this.sanitizeString(email).trim().toLowerCase();
    const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

    if (!emailRegex.test(sanitized)) {
      throw new AppError('Invalid email format', StatusCodes.BAD_REQUEST);
    }
    return sanitized;
  }

  static sanitizeQueryObject<T = any>(obj: T): T {
    if (obj === null || typeof obj !== 'object') return obj;

    const sanitized: any = {};

    for (const [key, value] of Object.entries(obj)) {
      // Block dangerous MongoDB operator keys
      if (key.startsWith('$') || key.includes('.')) {
        throw new Error('Invalid query parameter');
      }

      sanitized[key] = typeof value === 'object' ? this.sanitizeQueryObject(value) : typeof value === 'string' ? this.sanitizeString(value) : value;
    }
    return sanitized;
  }

  static validateDeviceInfo(obj: any): DeviceInfo | null {
    if (obj == null || typeof obj !== 'object') return null;

    const allowedKeys: (keyof DeviceInfo)[] = ['deviceId', 'device', 'brand', 'model', 'os'];

    const sanitized: DeviceInfo = {};
    const safeRegex = /^[A-Za-z0-9 _\-]{1,64}$/;

    for (const key of allowedKeys) {
      if (Object.prototype.hasOwnProperty.call(obj, key)) {
        const val = obj[key];

        if (typeof val !== 'string') {
          throw new AppError(`Invalid type for ${key}`, StatusCodes.BAD_REQUEST);
        }

        const trimmed = val.trim();

        if (!safeRegex.test(trimmed) || trimmed.length === 0) {
          throw new Error(`Invalid characters or empty value in ${key}`);
        }

        sanitized[key] = trimmed;
      }
    }

    return sanitized;
  }
}
