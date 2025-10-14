const express = require('express');
const { protect } = require('../middlewares/auth');
const EmailController = require('../controllers/email-controller');
const router = express.Router();
router.use(express.json());

router.use(protect);

router.post('/store', EmailController.storeEmailScraping);

router.post('/google-gmail-auth', EmailController.googleEmailAuthToken);

router.get('/', EmailController.getUserEmailScrapings);

// *************** MOVE THIS CREDIT CARD ROUTE TO CONFIG FILE LATER ********************************
router.get('/get-banks', creditCardController.getAllBanks);

// read emails from user's gmail account based on the bank id provided
router.get('/readEmail/:bankId', EmailController.getEmailsByBankId);

// remove the access token from the googleToken document
router.delete('/remove-access', EmailController.removeAccessEmailToken);

module.exports = router;
