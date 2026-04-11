import express from "express";
import { verifyToken } from "../middleware/auth.middleware";
import { PartnerController } from "../controllers/partner.controller";

const router = express.Router();
const partnerController = new PartnerController();

// Admin-only routes
router.get("/", verifyToken, (req, res) => partnerController.getAllPartners(req, res));
router.post("/", verifyToken, (req, res) => partnerController.createPartner(req, res));

// Partner self-service routes
router.get("/dashboard", verifyToken, (req, res) => partnerController.getDashboardStats(req, res));
router.get("/signed-contracts", verifyToken, (req, res) => partnerController.getPartnerSignedContracts(req, res));
router.get("/contracts", verifyToken, (req, res) => partnerController.getPartnerContracts(req, res));
router.post("/contracts", verifyToken, (req, res) => partnerController.createContractTemplate(req, res));
router.get("/reports", verifyToken, (req, res) => partnerController.getPartnerReports(req, res));
router.get("/profile", verifyToken, (req, res) => partnerController.getPartnerProfile(req, res));
router.put("/profile", verifyToken, (req, res) => partnerController.updatePartnerProfile(req, res));

// Admin routes with partner ID
router.get("/:id", verifyToken, (req, res) => partnerController.getPartnerById(req, res));
router.put("/:id", verifyToken, (req, res) => partnerController.updatePartner(req, res));

export default router;
