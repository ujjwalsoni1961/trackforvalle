import { VisitController } from "../controllers/visits.controller";
import { verifyToken } from "../middleware/auth.middleware";
import { permissionMiddleware } from "../middleware/permission.middleware";
const visitController = new VisitController();
import express from "express";
import { upload, supabaseUploadMiddleware } from "../aws/aws.service";
import { STORAGE_BUCKETS } from "../config/supabase";

const router = express.Router();
router.post(
  "/plan",
  verifyToken,
  // permissionMiddleware("customer_import"),
  visitController.planVisit
);
router.post(
  "/log",
  verifyToken,
  upload.array("photos"),
  supabaseUploadMiddleware(STORAGE_BUCKETS.VISIT_LOGS),
  // permissionMiddleware("customer_import"),
  visitController.logVisit
);
router.get("/past-vists", verifyToken, visitController.getPastVisits);
router.get("/planned", verifyToken, visitController.getPlannedVisits);
router.get("/route/daily", verifyToken, visitController.getDailyRoute);
router.get("/route/refresh", verifyToken, visitController.refreshDailyRoute);
router.post("/route/update-location", verifyToken, visitController.updateRouteWithCurrentLocation);
export default router;
