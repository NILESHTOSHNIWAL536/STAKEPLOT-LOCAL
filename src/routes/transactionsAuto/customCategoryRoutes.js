const express = require("express");
const router = express.Router();
const {CustomCategoryController} = require("../../../controllers/");
const { AuthMiddlewares } = require("../../../middlewares");

router.post("/custom-category",AuthMiddlewares.protect,CustomCategoryController.addCustomCategory);
router.get("/custom-category",AuthMiddlewares.protect,CustomCategoryController.getCustomCategories);

module.exports = router;
