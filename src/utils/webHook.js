const { Finvu } = require("../models/index");
const logger = require("../utils/common/logger");
const redisClient = require("../config/redis-config");
const mongoose = require("mongoose");
const generateToken = require("../utils/helpers/generate-finvu-token");
const { getDeviceIdsByUserId } = require("../utils/helpers/getDeviceIds");
const {
  SendNotificationToDeviceSpecific,
} = require("../services/notification-service");
const { FinvuController } = require("../controllers/index");
const { NotificationRepository } = require("../repositories/index");
const transactionController = require("../controllers/transaction-automation/transaction-controller");
const WebSocketService = require("../services/websocket-service");
const {User,FailedTransaction,BankLogo}=require("../models");
const {deleteConsentHandleById}=require("../controllers/finvu-controller");
const axios = require('axios');


// Initialize notification repository
const notificationRepository = new NotificationRepository();

async function getAll(req, res) {
  try {
    const allFinvus = await Finvu.find();
    for (const item of allFinvus)
    {
      // await processFinvuSession(item.sessionId);
      try {
        const response = await axios.post("https://stakeplot.in/fi/notification/callback/v1/finvu/FI/Prod/Notification", {
          dataSessionId: item.sessionId,
        });
      } catch (err) {
        console.error(`❌ Error calling webhook for sessionId: ${item.sessionId}`, err.message);
      }
    }

    res.status(200).json({ message: "All sessions processed" });
  } catch (e) {
    logger.error(`Error in getAll: ${e.message}`);
    res.status(500).json({ message: "Error processing all sessions", error: e.message });
  }
}



async function processFinvuSession(dataSessionId) {
  let finvuData;
  try {
    finvuData = await Finvu.findOne({ sessionId: dataSessionId });
    if (!finvuData) {
      logger.warn(`No data found for sessionId: ${dataSessionId}`);
      return;
    }

    logger.debug(`Processing sessionId: ${dataSessionId}`);

    let token = await redisClient.get("auth_token");
    if (!token) {
      token = await generateToken();
      logger.debug(`New token created: ${token}`);
    }

    const finalData = await FinvuController.fetchFinalData(token, finvuData.custId, finvuData.consentId, finvuData.sessionId);
    logger.debug(`Fetched finalData for session: ${dataSessionId}`);

    if (finalData !== "Account data not found.") {
      await transactionController.createUserDetails(finalData, finvuData.handleId, finvuData.userId);

      let totalTransactions = 0;
      let name = finalData?.[0]?.fipName || 'Bank';
      let bankId = finalData?.[0]?.fipId || '';

      finalData.forEach(data => {
        data.fiObjects.forEach(obj => {
          totalTransactions += obj.Transactions?.Transaction?.length || 0;
        });
      });

      const bankLogo = bank ? await BankLogo.findOne({ name: bankId }) : null;
 
      const notificationMessage = {
        type: "FetchedData",
        message: `${name} Data has been successfully fetched`,
        avatarType: bankLogo,
        logo: bankLogo,
      };

      await notificationRepository.createNotification({
        userId: finvuData.userId,
        notificationMessage: notificationMessage
      });

      WebSocketService.sendMessage(finvuData.custId, "registerUser", {
        message: "Your bank account data has been successfully fetched.",
        data: { number_id: "custId", data: finalData },
      });

      sendWebSocketMessage(finvuData.userId, `${name} Fetched successfully! There are ${totalTransactions} new transactions.`);
    } else {
      WebSocketService.sendMessage(finvuData.custId, "registerUser", {
        message: "Sorry, we are unable to fetch your bank details. Please try again later.",
        data: { number_id: "custId", data: "account-data-not-found" },
      });

      sendWebSocketMessage(finvuData.userId, "No transactions were found at the moment, try again later", true);
    }

  } catch (error) {
    logger.error(`Error processing session ${dataSessionId}: ${error.message}`);
    if (finvuData?.userId) {
      sendWebSocketMessage(finvuData.userId, "we couldn't able to fetch your bank details, please try again later. It might be due to a bank server issue.", true);
    }
  }
}



async function webHook(req, res){
  let finvuData;
  try {
    const { dataSessionId } = req.body;
    finvuData = await Finvu.findOne({ sessionId: dataSessionId });

    if (!finvuData)
      return res
        .status(404)
        .json({ message: "No data found for this sessionId" });
    logger.debug(`finvuData from the backend finvu: ${finvuData}`);

    // const token = await generateToken();
    let token;
    token = await redisClient.get("auth_token");
    if (!token) {
      token = await generateToken();
      logger.debug(`token created again for the call: ${token}`);
    }

    logger.debug(`token from the finvu: ${token}`);

    // Fetch the finalData with ID's
    const finalData = await FinvuController.fetchFinalData(
      token,
      finvuData.custId,
      finvuData.consentId,
      finvuData.sessionId
    );
    logger.debug(`finalData getFinvuBySession: ${finalData}`);

    //  const newObjectId = new mongoose.Types.ObjectId(finvuData.userId);
    //  const deviceIds = await getDeviceIdsByUserId(newObjectId);
    if (finalData !== "Account data not found.") {
      try {
        await Finvu.findOneAndUpdate({ sessionId: finvuData.sessionId }, { $set: { data: finalData } },{ new: true });
        await transactionController.createUserDetails(
          finalData,
          finvuData.handleId,
          finvuData.userId 
        );

        await deleteConsentHandleById(finvuData.handleId)


        //  await SendNotificationToDeviceSpecific(finvuData.userId, `Your bank account data has been successfully fetched.`, deviceIds, "/home");

        //  let length;
        let totalTransactions = 0;
        let name = "Bank";
        let bankId = "";
        if (finalData) {
          name = finalData[0].fipName;
          bankId = finalData[0].fipId;
          finalData.forEach((data) => {
            data.fiObjects.forEach((obj) => {
              const len = obj.Transactions?.Transaction?.length || 0;
              totalTransactions += len;
            });
          });
        }

       const bankLogo = await BankLogo.findOne({ name: bankId });
        const notificationMessage = {
          type: "FetchedData",
          message: `${name} Data has been successfully fetched`,
          avatarType: bankLogo.logoUrl,
          logo: bankLogo.logoUrl,
        };
        await notificationRepository.createNotification({
          userId: finvuData.userId,
          notificationMessage: notificationMessage,
        });

        const custId = finvuData.custId;
        try {
          WebSocketService.sendMessage(custId, "registerUser", {
            message: "Your bank account data has been successfully fetched.",
            data: { number_id: "custId", data: finalData },
          });
          sendWebSocketMessage(
            finvuData.userId,
            `${name} Fetched successfully! There are ${totalTransactions} new transactions.`
          );
          
          await FailedTransaction.deleteMany({ consendHandleId:  finvuData.handleId });

          // sendWebSocketMessage(finvuData.userId,`Your bank account data has been successfully fetched. ${length} new Transactions found`);
        } catch (e) {
          logger.error(`Error sending websocket message: ${e.message}`);
        }
      } catch (error) {
        logger.error(`Error updating data: ${error.message}`);
      }
    } else {
      // webSocket message to the user
      WebSocketService.sendMessage(finvuData.custId, "registerUser", {
        message: "Sorry, we are unable to fetch your bank details. Please try again later.",
        data: { number_id: "custId", data: "account-data-not-found" },
      });

      sendWebSocketMessage(
        finvuData.userId,
        "No transactions were found at the moment, try again later",
        true
      );
    }
    res.status(200).json({ message: "Data fetched successfully" });
  } catch (error) {
    // sendWebSocketMessage(
    //   finvuData.userId,
    //   "we couldn't able to fetch your bank details, please try again later.It might be due to an bank server issue.",
    //   true
    // );
    logger.error(`error from the notification: ${error}`);
    res.status(500).json({ message: "Error fetching data", error: error.message });
  }
}

async function sendWebSocketMessage(userId, msg, failed = false) {
  const newObjectId = new mongoose.Types.ObjectId(userId);
  await User.findByIdAndUpdate(
    userId,
    { fetchInProgress: false },
    { new: true, runValidators: true }
  );
  const deviceIds = await getDeviceIdsByUserId(newObjectId);
  await SendNotificationToDeviceSpecific(userId, msg, deviceIds, "/home");
  WebSocketService.sendMessage(userId, "addUserToSocket", {
    type: "fetchedApiCall",
    data: {
      message: msg,
      failed: failed,
    },
  });
}



  module.exports = { webHook,getAll };
