import express from "express";
import { AuthMiddlewares } from "../middlewares";
import { ReserveController } from "../controllers/reserve-controller";

const router = express.Router();

router.post("/", AuthMiddlewares.protect, ReserveController.createReserve);

router.get("/", AuthMiddlewares.protect, ReserveController.getReserves);

router.get("/:rid", AuthMiddlewares.protect, ReserveController.getReserveById);

router.delete("/:rid", AuthMiddlewares.protect, ReserveController.deleteReserve);

export default router;