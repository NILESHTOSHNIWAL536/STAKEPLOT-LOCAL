import express from 'express';
import { AuthMiddlewares } from '../middlewares';
import { ReserveController } from '../controllers/reserve-controller';
import reserveMatchService from '../services/reserve-match.service';

const router = express.Router();

router.post('/suggest', AuthMiddlewares.protect, ReserveController.suggest);

router.post('/', AuthMiddlewares.protect, ReserveController.createReserve);

router.get('/', AuthMiddlewares.protect, ReserveController.getReserves);

router.patch('/:rid/share', AuthMiddlewares.protect, ReserveController.toggleShare);

router.get('/share/feed', AuthMiddlewares.protect, async (req, res) => {
  try {
    const page = parseInt((req.query.page as string) || '1', 10);
    const limit = parseInt((req.query.limit as string) || '10', 10);
    const data = await reserveMatchService.getSharedReservesFeed(req.user!._id, page, limit);
    return res.json({ success: true, data });
  } catch (err: any) {
    return res.status(500).json({ success: false, message: err?.message || 'Failed to load reserve shares' });
  }
});

router.get('/:rid', AuthMiddlewares.protect, ReserveController.getReserveById);

router.delete('/:rid', AuthMiddlewares.protect, ReserveController.deleteReserve);

export default router;
