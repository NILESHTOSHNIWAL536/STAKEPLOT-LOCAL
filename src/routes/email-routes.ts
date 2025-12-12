// const express = require('express');
// const { protect } = require('../middlewares/auth');
// const EmailController = require('../controllers/email-controller');
// const router = express.Router();
// router.use(express.json());

// router.use(protect);

// // generate access token and store it in the googleToken document
// router.post('/generate-token', EmailController.generateAccessToken);

// // read emails from user's gmail account based on the bank id provided
// router.post('/scrape/', EmailController.scrapeEmailsByBankId);

// // get all the scraped emails from the emailScrape collection
// router.get('/', EmailController.getScrapedEmails);

// // get all the unlinked credit cards from the user's creditCard collection
// router.get('/get-unLinked-cards', EmailController.getUnlinkedCreditCards);

// // remove the access token from the googleToken document
// router.delete('/remove-access', EmailController.removeAccessToken);

// module.exports = router;
import express, { Router } from 'express';
import { protect } from '../middlewares/auth';
import * as EmailController from '../controllers/email-controller';

const router: Router = express.Router();

router.use(express.json());

// All routes below require auth
router.use(protect);

// generate access token and store it in the googleToken document
router.post('/generate-token', EmailController.generateAccessToken);

// read emails from user's gmail account based on the bank id provided
router.post('/scrape/', EmailController.scrapeEmailsByBankId);

// get all the scraped emails from the emailScrape collection
router.get('/', EmailController.getScrapedEmails);

// get all the unlinked credit cards from the user's creditCard collection
router.get('/get-unLinked-cards', EmailController.getUnlinkedCreditCards);

// remove the access token from the googleToken document
router.delete('/remove-access', EmailController.removeAccessToken);

export default router;
