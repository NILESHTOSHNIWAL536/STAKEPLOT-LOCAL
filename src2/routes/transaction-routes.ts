const express = require("express");
const { TransactionController } = require("../controllers");
import { AuthMiddlewares } from "../../src2/middlewares";
const router = express.Router();
router.use(express.json());

router.post("/add", AuthMiddlewares.protect, TransactionController.enterTransaction);

router.get("/groupedTransactions", AuthMiddlewares.protect, TransactionController.groupTransactions);
router.get("/all", AuthMiddlewares.protect, TransactionController.getAllTransactions);
// router.get("/history", AuthMiddlewares.protect, TransactionController.transactionHistory);
router.get("/budgetHistory/:budgetId", AuthMiddlewares.protect, TransactionController.getBudgetHistory);
router.get("/:roomId", AuthMiddlewares.protect, TransactionController.getRoomHistory);

router.delete("/:id", AuthMiddlewares.protect, TransactionController.deleteSpecificTransaction);
router.post("/updateGroupTransactions/:id", AuthMiddlewares.protect, TransactionController.updateGroupTransaction);
router.patch("/headsup-moneymap", AuthMiddlewares.protect, TransactionController.updateMoneymapHeadsUp);

module.exports = router;