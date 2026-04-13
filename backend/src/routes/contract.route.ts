import express from "express";
import { verifyToken } from "../middleware/auth.middleware";
import { ContractTemplateController } from "../controllers/contract.controller";
import { VisitController } from "../controllers/visits.controller";
import {
  uploadContractImage,
  uploadContractPdf,
  supabaseUploadMiddleware,
} from "../aws/aws.service";
import { STORAGE_BUCKETS } from "../config/supabase";

const router = express.Router();

let authController = new ContractTemplateController();
let visitController = new VisitController();
router.get(
  "/templates/sale-rep",
  verifyToken,
  authController.getTemplatesForRep
);
router.post("/templates", verifyToken, authController.create);
router.get("/templates", verifyToken, authController.list);
router.get("/", verifyToken, authController.getAllContracts);
router.post(
  "/submit",
  verifyToken,
  uploadContractImage.single("signature"),
  supabaseUploadMiddleware(STORAGE_BUCKETS.CONTRACT_SIGNATURES),
  visitController.submitVisitWithContract
);
router.post(
  "/submit-pdf",
  verifyToken,
  uploadContractPdf.single("contract_pdf"),
  supabaseUploadMiddleware(STORAGE_BUCKETS.CONTRACT_SIGNATURES, "contracts/pdf/"),
  visitController.submitContractPdf
);
router.post("/sign", verifyToken, authController.signContract);
router.post(
  "/templates/upload-pdf",
  verifyToken,
  uploadContractPdf.single("pdf"),
  supabaseUploadMiddleware(STORAGE_BUCKETS.CONTRACT_SIGNATURES, "template-pdfs/"),
  authController.uploadPdf
);
router.get("/by-lead/:leadId", verifyToken, authController.getContractByLead);
router.get("/:contractId/pdf", (req, res) =>
  authController.getContractHTML(req, res)
);

// Reassign contract template to sales reps
router.put(
  "/templates/:templateId",
  verifyToken,
  authController.reassignContractTemplate
);

// Update/Edit contract template
router.patch(
  "/templates/:templateId",
  verifyToken,
  authController.updateContractTemplate
);

// Get contract template by ID (including dropdown fields)
router.get(
  "/templates/:templateId",
  verifyToken,
  authController.getTemplateById
);

// Delete contract template
router.delete(
  "/templates/:templateId",
  verifyToken,
  (req, res) => authController.deleteContractTemplate(req, res)
);

export default router;
