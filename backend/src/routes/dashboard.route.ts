import { DashboardController } from "../controllers/dashboard.controller";
import { verifyToken } from "../middleware/auth.middleware";
const dashboardController = new DashboardController();
import express from "express";
const router = express.Router();
router.get(
  "/",
  verifyToken,
  dashboardController.getDashboard
);
export default router;
