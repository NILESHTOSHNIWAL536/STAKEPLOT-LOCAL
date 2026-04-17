import { Router } from 'express';
import CollectionController from '../controllers/collection-controller';
import { protect } from '../middlewares/auth-middleware';

const router = Router();

router.use(protect);

router.patch('/:id/updateCollections', CollectionController.updateCollection);
router.post('/', CollectionController.createCollection);

router.get('/', CollectionController.getUserCollections);

// ====================================
// INVITATION ENDPOINTS (User routes)
// Must be before /:id to avoid being swallowed by the dynamic segment
// ====================================

// Get pending invitations for current user
router.get('/invitations/pending', CollectionController.getPendingInvitations);

// Accept invitation
router.post('/invitations/:invitationId/accept', CollectionController.acceptInvitation);

// Reject invitation
router.post('/invitations/:invitationId/reject', CollectionController.rejectInvitation);

// ====================================
// COLLECTION ROUTES (dynamic :id)
// ====================================
router.get('/:id', CollectionController.getCollectionById);

router.delete('/:id', CollectionController.deleteCollection);

// Send invitations to add members
router.post('/:id/members', CollectionController.addMembers);

// Get invitations for a collection
router.get('/:id/invitations', CollectionController.getCollectionInvitations);

// Cancel specific invitation
router.delete('/:id/invitations/:invitationId', CollectionController.cancelInvitation);

router.get('/:id/available-transactions', CollectionController.getAvailableTransactions);

router.get('/:id/splits', CollectionController.getCollectionSplits);

router.post('/:id/transactions', CollectionController.addTransaction);

router.put('/:id/splits/:splitId', CollectionController.updateSplit);

// Payer (X) records that they paid their share in a split to the creditor
router.post('/:id/splits/:splitId/pay', CollectionController.recordPayment);

// Receiver (Y) confirms/clears that a debtor paid them for a split
router.post('/:id/splits/:splitId/clear', CollectionController.clearPayment);

router.get('/:id/balances', CollectionController.getBalances);


router.patch('/:id/closeCollection', CollectionController.closeCollection);

// Bulk set spending limits for multiple members (owner only)
// NOTE: must come BEFORE /:id/members/:memberId to avoid route shadowing
router.patch('/:id/members/limits', CollectionController.setMemberLimits);

router.patch('/:id/members/:memberId', CollectionController.updateCollectionMember);

// Exit collection by member (delete member from collection)
router.delete('/:id/exit', CollectionController.exitCollection);

router.get('/:id/all-transactions', CollectionController.getAllTransactions);

export default router;
