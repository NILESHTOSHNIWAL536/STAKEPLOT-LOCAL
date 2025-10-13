const express = require('express');
const { protect } = require('../middlewares/auth');
const EmailController = require("../controllers/email-controller");
const router = express.Router();
router.use(express.json());

router.use(protect);

router.post('/store', gmailAuthMiddleware, EmailController.storeEmailScraping);

// *********************** MOVE THIS CREDIT CARD ROUTE TO CONFIG FILE LATER *************************
router.post('/add-multiple', gmailAuthMiddleware, creditCardController.addBanks);

router.post('/google-gmail-auth', gmailAuthMiddleware, EmailController.googleEmailAuthToken);

router.get('/', gmailAuthMiddleware, EmailController.getUserEmailScrapings);

// *************** MOVE THIS CREDIT CARD ROUTE TO CONFIG FILE LATER ********************************
router.get('/get-banks', gmailAuthMiddleware, creditCardController.getAllBanks);

// read emails from user's gmail account based on the bank id provided
router.get('/readEmail/:bankId', gmailAuthMiddleware, EmailController.getEmailsByBankId);

// remove the access token from the googleToken document
router.delete('/remove-access', gmailAuthMiddleware, EmailController.removeAccessEmailToken);

module.exports = router;
