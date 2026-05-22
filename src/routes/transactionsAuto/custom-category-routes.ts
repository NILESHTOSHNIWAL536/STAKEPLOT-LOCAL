import express from 'express';
import { AuthMiddlewares } from '../../middlewares';
import { CustomCategoryController } from '@/controllers';

const router = express.Router();
router.use(express.json());

router.post('/custom-category', AuthMiddlewares.protect, CustomCategoryController.addCustomCategory);
router.get('/custom-category', AuthMiddlewares.protect, CustomCategoryController.getCustomCategories);

export default router;
