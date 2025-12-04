const express = require("express");
const {FinvuController} = require("../controllers");
const { AuthMiddlewares } = require("../../src2/middlewares");
const router = express.Router();
router.use(express.json());

router.post("/login", AuthMiddlewares.protect, FinvuController.loginAndGetHandleId);
router.post("/fetchData", AuthMiddlewares.protect, FinvuController.fetchTransactions);
router.post("/fetchWeekly", AuthMiddlewares.protect, FinvuController.fetchTransactionsWeekly);
router.get("/fipsmetric", FinvuController.getFipsLatestMetricsAll);
router.get("/status/:id", FinvuController.getStatus);
router.post("/fip-details/",AuthMiddlewares.protect, FinvuController.getFipsDetails);

module.exports = router;
