import express from 'express';
import { TransactionController } from '../controllers';
import { AuthMiddlewares } from '../../src2/middlewares';

const router = express.Router();
router.use(express.json());

router.post('/add', AuthMiddlewares.protect, TransactionController.enterTransaction);
router.post('/updateGroupTransactions/:id', AuthMiddlewares.protect, TransactionController.updateGroupTransaction);

router.get('/groupedTransactions', AuthMiddlewares.protect, TransactionController.groupTransactions);
router.get('/all', AuthMiddlewares.protect, TransactionController.getAllTransactions);
router.get('/budgetHistory/:budgetId', AuthMiddlewares.protect, TransactionController.getBudgetHistory);
router.get('/:roomId', AuthMiddlewares.protect, TransactionController.getRoomHistory);

router.patch('/headsup-moneymap', AuthMiddlewares.protect, TransactionController.updateMoneymapHeadsUp);

router.delete('/:id', AuthMiddlewares.protect, TransactionController.deleteSpecificTransaction);

export default router;
    