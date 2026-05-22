import { Router } from 'express';
import ReferralController from '@/controllers/referral-controller';
import { protect } from '@/middlewares/auth-middleware';
import validateRequest from '@/middlewares/validateRequest';
import {
  applyReferralCodeSchema,
  createReferralCodeSchema,
  validateReferralCodeSchema,
} from '@/validators/referral-validators';

const router = Router();

router.use(protect);

router.get('/share-code', ReferralController.getShareReferralCode);
router.post('/create', validateRequest(createReferralCodeSchema), ReferralController.createReferralCode);
router.post('/validate', validateRequest(validateReferralCodeSchema), ReferralController.validateReferralCode);
router.post('/apply', validateRequest(applyReferralCodeSchema), ReferralController.applyReferralCode);

export default router;
