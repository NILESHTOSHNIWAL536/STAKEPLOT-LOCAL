import { Router } from 'express';
import CollectionController from '../controllers/collection-controller';
import { protect } from '../middlewares/auth-middleware';

const router = Router();

router.use(protect);

router.post('/', CollectionController.createCollection);
router.get('/', CollectionController.getUserCollections);
router.get('/:id', CollectionController.getCollectionById);
router.delete('/:id', CollectionController.deleteCollection);

router.post('/:id/members', CollectionController.addMembers);

router.get('/:id/available-transactions', CollectionController.getAvailableTransactions);
router.get('/:id/splits', CollectionController.getCollectionSplits);
router.post('/:id/transactions', CollectionController.addTransaction);

router.put('/:id/splits/:splitId', CollectionController.updateSplit);

router.get('/:id/balances', CollectionController.getBalances);

export default router;
