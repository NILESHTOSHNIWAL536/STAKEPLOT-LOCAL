import { Request, Response, NextFunction } from 'express';
import { StatusCodes } from 'http-status-codes';
import { Schema } from 'joi';

/**
 * Schema object example:
 * {
 *   body: Joi.object({...}),
 *   params: Joi.object({...}),
 *   query: Joi.object({...}),
 *   headers: Joi.object({...}),
 * }
 */
type ValidationSchemas = Partial<{
  body: Schema;
  params: Schema;
  query: Schema;
  headers: Schema;
}>;

const validateRequest = (schemas: ValidationSchemas = {}) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const errors: string[] = [];

    // ✅ iterate over each possible location
    (['body', 'params', 'query', 'headers'] as const).forEach((key) => {
      const schema = schemas[key];

      if (schema) {
        const { error, value } = schema.validate(req[key], {
          abortEarly: false,
        });

        if (error) {
          errors.push(...error.details.map((err) => err.message));
        } else {
          // ✅ Replace with validated & sanitized values
          (req as any)[key] = value;
        }
      }
    });

    if (errors.length) {
      res.status(StatusCodes.BAD_REQUEST).json({
        success: false,
        errors,
      });
      return;
    }

    next();
  };
};

export default validateRequest;
