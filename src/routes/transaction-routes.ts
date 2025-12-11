import express from 'express';
import { TransactionController } from '@/controllers';
import { AuthMiddlewares } from '../middlewares';

const router = express.Router();
router.use(express.json());

router.post('/add', AuthMiddlewares.protect, TransactionController.enterTransaction);
router.post('/updateGroupTransactions/:id', AuthMiddlewares.protect, TransactionController.updateGroupTransaction);

router.get('/all', AuthMiddlewares.protect, TransactionController.getAllTransactions);

router.delete('/:id', AuthMiddlewares.protect, TransactionController.deleteSpecificTransaction);

export default router;
