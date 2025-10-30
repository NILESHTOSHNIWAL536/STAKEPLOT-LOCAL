const { StatusCodes } = require("http-status-codes");

/**
 * schema object example:
 * {
 *   body: Joi.object({...}),
 *   params: Joi.object({...}),
 *   query: Joi.object({...}),
 *   headers: Joi.object({...}),
 * }
 */
const validateRequest = (schemas = {}) => {
  return (req, res, next) => {
    const errors = [];

    // iterate over each possible location
    ["body", "params", "query", "headers"].forEach((key) => {
      if (schemas[key]) {
        const { error, value } = schemas[key].validate(req[key], {
          abortEarly: false,
        });

        if (error) {
          errors.push(...error.details.map((err) => err.message));
        } else {
          // Replace with validated & sanitized values
          req[key] = value;
        }
      }
    });

    if (errors.length) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        success: false,
        errors,
      });
    }

    next();
  };
};

module.exports = validateRequest;
