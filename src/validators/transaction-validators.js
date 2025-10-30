const Joi = require("joi");
const mongoose = require("mongoose");

// mongoose objectId
const objectId = () =>
  Joi.string()
    .regex(/^[0-9a-fA-F]{24}$/)
    .message("Invalid MongoDB ObjectId");

// categorizeGroupedTransaction Schema
const categorizeGroupedTransaction = {
  params: Joi.object({
    groupId: objectId().required(),
  }),
  body: Joi.object({
    category: Joi.string().required(),
    subcategory: Joi.string().required(),
    removedTransactions: Joi.array().items(objectId()).optional(),
  }),
};

// verifyPendingTransaction schema
const verifyPendingTransaction = {
  params: Joi.object({
    transactionId: objectId().required(),
    isCorrect: Joi.string().required(),
  }),
};

// update a transaction schema
const updateTransaction = {
  params: Joi.object({
    transactionId: objectId().required(),
  }),

  body: Joi.object({
    manualTransaction: Joi.boolean(),
    category: Joi.string(),
    subcategory: Joi.string(),
    Hidden: Joi.boolean(),
    isBill: Joi.boolean(),
    isDebt: Joi.boolean(),
    isSplit: Joi.boolean(),
    needsReview: Joi.boolean(),
    isAutoPay: Joi.boolean(),
    isExcluded: Joi.boolean(),
    isBalanceOut: Joi.boolean(),
    autoPayId: Joi.string(),
    merchant: Joi.string(),
    expectedFrequency: Joi.string(),
    selectedCategory: Joi.object({
      category: Joi.string().required(),
      percentage: Joi.number().required(),
    }).optional(),
    predictedCategories: Joi.array()
      .items(
        Joi.object({
          category: Joi.string().required(),
          percentage: Joi.number().required(),
        })
      ).optional(),
  }).min(1), // make sure at least one field is sent
};

//getAllTransactions schema
const getAllTransactions = {
  params: Joi.object({
    page: Joi.number().integer().min(1).default(1),
  }),
};

// getSearchedTransactions shema
const getSearchedTransactions = {
  params: Joi.object({
    page: Joi.number().integer().min(1).default(1),
    search: Joi.string().required(),
    isBankAccount: Joi.string().required(),
  }),
};

//getAllTransactionsForAccount schema
const getAllTransactionsForAccount = {
  params: Joi.object({
    accountId: objectId().required(),
    page: Joi.number().integer().min(1).default(1),
  }),
};

//getTransactionsByDate schema
const getTransactionsByDate = {
  params: Joi.object({
    date: Joi.date()
      .iso() // enforce ISO format: YYYY-MM-DD or full ISO string
      .required(),
  }),
};

//getRecurringPayments schema
const getRecurringPayments = {
  params: Joi.object({
    isActive: Joi.boolean().required(),
  }),
};

//updateRecurringPayment or delete
const updateOrDeleteRecurringpayment = {
  params: Joi.object({
    id: objectId().required(),
  }),
  body: Joi.object({
    nextReminderAt: Joi.date().iso().optional(),
    isActive: Joi.boolean().optional(),
    isDaily: Joi.boolean().optional(),
  }),
};

const getLoanCalculation = {
  body: Joi.object({
    income: Joi.number().positive().required(),
    existingEmi: Joi.number().min(0).required(),

    creditScore: Joi.string()
      .pattern(/^(\d{3}\+\b|\<\d{3}\b|\d{3}-\d{3})$/) // matches "750+", "<600", "600-650"
      .required(),

    loanType: Joi.string()
      .valid("personal", "home", "car", "education", "business")
      .required(),

    expenses: Joi.object()
      .pattern(
        Joi.string(), // any string key
        Joi.number().min(0) // values must be numbers >= 0
      )
      .required(),
  }),
};

// getAllCustomTransactions schema
const getAllCustomTransactions = {
  params: Joi.object({
    accountId: objectId().required(),
    type: Joi.string().valid("month", "week", "custom", "year").required(),

    value: Joi.alternatives().conditional("type", [
      {
        is: "month",
        then: Joi.string()
          .pattern(/^\d{4}-(0[1-9]|1[0-2])$/) // YYYY-MM
          .required(),
      },
      {
        is: "week",
        then: Joi.string()
          .pattern(/^\d{4}-W(0[1-9]|[1-4][0-9]|5[0-3])$/) // YYYY-Www (ISO week)
          .required(),
      },
      {
        is: "custom",
        then: Joi.string()
          .pattern(/^\d{4}-\d{2}-\d{2},\d{4}-\d{2}-\d{2}$/) // YYYY-MM-DD,YYYY-MM-DD
          .required(),
      },
      {
        is: "year",
        then: Joi.string()
          .pattern(/^\d{4}$/) // YYYY
          .required(),
      },
    ]),
  }),
};

// getWholeTransactionsGraph schema
const getWholeTransactionsGraph = {
  params: Joi.object({
    type: Joi.string().valid("month", "week", "custom", "year").required(),

    value: Joi.alternatives().conditional("type", [
      {
        is: "month",
        then: Joi.string()
          .pattern(/^\d{4}-(0[1-9]|1[0-2])$/) // YYYY-MM
          .required(),
      },
      {
        is: "week",
        then: Joi.string()
          .pattern(/^\d{4}-W(0[1-9]|[1-4][0-9]|5[0-3])$/) // YYYY-Www (ISO week)
          .required(),
      },
      {
        is: "custom",
        then: Joi.string()
          .pattern(/^\d{4}-\d{2}-\d{2},\d{4}-\d{2}-\d{2}$/) // YYYY-MM-DD,YYYY-MM-DD
          .required(),
      },
      {
        is: "year",
        then: Joi.string()
          .pattern(/^\d{4}$/) // YYYY
          .required(),
      },
    ]),
  }),
};

//getMonthlyTransactionsHistory schema
const getMonthlyTransactionsHistory = {
  params: Joi.object({
    type: Joi.alternatives()
      .try(
        Joi.string().pattern(/^\d{4}$/), // YYYY
        Joi.string().pattern(/^\d{4}-(0[1-9]|1[0-2])$/) // YYYY-MM
      )
      .required(),

    accountId: objectId().required(),

    page: Joi.number().integer().min(1).default(1),
  }),
};

// getPreviousTransactions schema
const getPreviousTransactions = {
  params: Joi.object({
    accountId: objectId().required(),
    date: Joi.date()
      .iso() // enforce ISO format: YYYY-MM-DD or full ISO string
      .required(),
  }),
};

// deleteBankAccount schema
const deleteBankAccount = {
  params: Joi.object({
    accountId: objectId().required(),
    bankId: objectId().required(),
  }),
};

// delete transctions
const deleteTransactionsSchema = Joi.object({
  transactionIds: Joi.array()
    .items(
      Joi.string()
        .custom((value, helpers) => {
          if (!mongoose.Types.ObjectId.isValid(value)) {
            return helpers.error("any.invalid");
          }
          return value;
        }, "ObjectId validation")
        .required()
    )
    .min(1)
    .required()
    .messages({
      "array.base": "transactionIds must be an array",
      "array.min": "transactionIds cannot be empty",
      "any.required": "transactionIds are required",
      "any.invalid": "transactionIds must contain valid ObjectIds",
    }),
});

module.exports = {
  categorizeGroupedTransaction,
  verifyPendingTransaction,
  updateTransaction,
  getAllTransactions,
  getSearchedTransactions,
  getAllTransactionsForAccount,
  getTransactionsByDate,
  getRecurringPayments,
  updateOrDeleteRecurringpayment,
  getLoanCalculation,
  getAllCustomTransactions,
  getWholeTransactionsGraph,
  getMonthlyTransactionsHistory,
  getPreviousTransactions,
  deleteBankAccount,
  deleteTransactionsSchema,
};
