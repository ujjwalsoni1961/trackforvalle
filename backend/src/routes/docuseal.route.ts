import express, { Request, Response } from "express";
import jwt from "jsonwebtoken";
import { verifyToken } from "../middleware/auth.middleware";
import * as docusealService from "../service/docuseal.service";
import { getDataSource } from "../config/data-source";
import { ContractTemplate } from "../models/ContractTemplate.entity";
import { Contract } from "../models/Contracts.entity";
import { sendEmail } from "../service/email.service";
import { ApiResponse } from "../utils/api.response";

const router = express.Router();

// ─── Authenticated routes ───

// Generate JWT for embedded DocuSeal builder
router.post("/builder-token", verifyToken, async (req: Request, res: Response): Promise<any> => {
  try {
    const { template_id, document_urls, name } = req.body;
    const apiKey = process.env.DOCUSEAL_API_KEY;
    if (!apiKey) {
      return ApiResponse.error(res, 500, "DOCUSEAL_API_KEY is not configured");
    }

    const payload: Record<string, any> = {
      user_email: process.env.DOCUSEAL_ADMIN_EMAIL || "ujjwalsoni1961@gmail.com",
    };

    if (template_id) {
      payload.template_id = template_id;
    }
    if (document_urls) {
      payload.document_urls = document_urls;
    }
    if (name) {
      payload.name = name;
    }

    const token = jwt.sign(payload, apiKey);
    return ApiResponse.result(res, { token }, 200, null, "Builder token generated");
  } catch (error: any) {
    console.error("Error generating builder token:", error);
    return ApiResponse.error(res, 500, error.message || "Failed to generate builder token");
  }
});

router.get("/templates", verifyToken, async (req: Request, res: Response): Promise<any> => {
  try {
    const templates = await docusealService.listTemplates();
    return ApiResponse.result(res, templates, 200, null, "DocuSeal templates fetched");
  } catch (error: any) {
    console.error("Error fetching DocuSeal templates:", error);
    return ApiResponse.error(res, 500, error.message || "Failed to fetch DocuSeal templates");
  }
});

router.get("/templates/:id", verifyToken, async (req: Request, res: Response): Promise<any> => {
  try {
    const template = await docusealService.getTemplate(Number(req.params.id));
    return ApiResponse.result(res, template, 200, null, "DocuSeal template fetched");
  } catch (error: any) {
    console.error("Error fetching DocuSeal template:", error);
    return ApiResponse.error(res, 500, error.message || "Failed to fetch DocuSeal template");
  }
});

router.post("/submissions", verifyToken, async (req: Request, res: Response): Promise<any> => {
  try {
    const { template_id, submitters, metadata } = req.body;
    if (!template_id || !submitters || !Array.isArray(submitters)) {
      return ApiResponse.error(res, 400, "template_id and submitters array are required");
    }
    const submission = await docusealService.createSubmission(template_id, submitters, metadata);
    // Return the submitters array directly so frontends can access embed_src
    const submittersList = Array.isArray(submission) ? submission : (submission.submitters || [submission]);
    return ApiResponse.result(res, submittersList, 201, null, "DocuSeal submission created");
  } catch (error: any) {
    console.error("Error creating DocuSeal submission:", error);
    return ApiResponse.error(res, 500, error.message || "Failed to create submission");
  }
});

router.get("/submissions", verifyToken, async (req: Request, res: Response): Promise<any> => {
  try {
    const params: any = {};
    if (req.query.template_id) params.template_id = Number(req.query.template_id);
    if (req.query.limit) params.limit = Number(req.query.limit);
    if (req.query.after) params.after = Number(req.query.after);
    const submissions = await docusealService.listSubmissions(params);
    return ApiResponse.result(res, submissions, 200, null, "DocuSeal submissions fetched");
  } catch (error: any) {
    console.error("Error fetching DocuSeal submissions:", error);
    return ApiResponse.error(res, 500, error.message || "Failed to fetch submissions");
  }
});

router.get("/submissions/:id", verifyToken, async (req: Request, res: Response): Promise<any> => {
  try {
    const submission = await docusealService.getSubmissionDocuments(Number(req.params.id));
    return ApiResponse.result(res, submission, 200, null, "DocuSeal submission fetched");
  } catch (error: any) {
    console.error("Error fetching DocuSeal submission:", error);
    return ApiResponse.error(res, 500, error.message || "Failed to fetch submission");
  }
});

// ─── Webhook (NO auth middleware) ───

router.post("/webhook", async (req: Request, res: Response): Promise<any> => {
  try {
    const payload = req.body;
    console.log("DocuSeal webhook received:", JSON.stringify(payload, null, 2));

    const eventType = payload.event_type || payload.event;

    if (eventType !== "form.completed") {
      console.log(`Ignoring DocuSeal webhook event: ${eventType}`);
      return res.status(200).json({ status: "ignored", event: eventType });
    }

    const submissionData = payload.data || payload;
    const submissionId = submissionData.submission_id || submissionData.id;

    if (!submissionId) {
      console.error("No submission ID in webhook payload");
      return res.status(200).json({ status: "no_submission_id" });
    }

    // Fetch full submission details from DocuSeal
    let submission: any;
    try {
      submission = await docusealService.getSubmission(submissionId);
    } catch (fetchErr) {
      console.error("Failed to fetch submission from DocuSeal:", fetchErr);
      return res.status(200).json({ status: "fetch_failed" });
    }

    // Find the signed document URL
    const documents = submission.documents || submission.submission_documents || [];
    const submitters = submission.submitters || [];
    let pdfUrl: string | null = null;
    let pdfBuffer: Buffer | null = null;

    // Check submitters for documents
    for (const submitter of submitters) {
      if (submitter.documents && submitter.documents.length > 0) {
        pdfUrl = submitter.documents[0].url;
        break;
      }
    }

    // Fallback to top-level documents
    if (!pdfUrl && documents.length > 0) {
      pdfUrl = documents[0].url;
    }

    if (pdfUrl) {
      try {
        pdfBuffer = await docusealService.downloadDocument(pdfUrl);
        console.log(`Downloaded signed PDF: ${pdfBuffer.length} bytes`);
      } catch (dlErr) {
        console.error("Failed to download signed PDF:", dlErr);
      }
    }

    // Look up the contract template by docuseal_template_id
    const dataSource = await getDataSource();
    const templateRepo = dataSource.getRepository(ContractTemplate);
    const contractRepo = dataSource.getRepository(Contract);

    const templateId = submission.template?.id || submissionData.template_id;
    let contractTemplate: ContractTemplate | null = null;
    if (templateId) {
      contractTemplate = await templateRepo.findOne({
        where: { docuseal_template_id: templateId },
        relations: ["partner"],
      });
    }

    // Store contract record
    const contract = contractRepo.create({
      contract_template_id: contractTemplate?.id || 0,
      visit_id: submission.metadata?.visit_id || submissionData.metadata?.visit_id || 0,
      rendered_html: `DocuSeal Submission #${submissionId}`,
      metadata: {
        docuseal_submission_id: submissionId,
        docuseal_template_id: templateId,
        submitters: submitters.map((s: any) => ({
          email: s.email,
          name: s.name,
          status: s.status,
          completed_at: s.completed_at,
        })),
        documents: documents.map((d: any) => ({ url: d.url, filename: d.filename })),
        source: "docuseal",
      },
      signed_at: new Date(),
    });

    try {
      await contractRepo.save(contract);
      console.log(`Contract record saved with id: ${contract.id}`);
    } catch (saveErr) {
      console.error("Failed to save contract record:", saveErr);
    }

    // Send email notifications
    const adminEmail = process.env.ADMIN_EMAIL || "ujjwalsoni1961@gmail.com";
    const submitterNames = submitters.map((s: any) => s.name || s.email).join(", ");
    const templateName = submission.template?.name || contractTemplate?.title || "Contract";

    const emailBody = `
      <h2>Contract Signed via DocuSeal</h2>
      <p><strong>Template:</strong> ${templateName}</p>
      <p><strong>Submission ID:</strong> ${submissionId}</p>
      <p><strong>Signed by:</strong> ${submitterNames}</p>
      <p><strong>Date:</strong> ${new Date().toISOString()}</p>
      ${pdfUrl ? `<p><strong>Document URL:</strong> <a href="${pdfUrl}">${pdfUrl}</a></p>` : ""}
      <p>The signed contract PDF is attached to this email.</p>
    `;

    const attachments = pdfBuffer
      ? [{ filename: `signed_contract_${submissionId}.pdf`, content: pdfBuffer, contentType: "application/pdf" }]
      : [];

    // Send to admin
    try {
      await sendEmail({
        to: adminEmail,
        subject: `Contract Signed: ${templateName} - ${submitterNames}`,
        body: emailBody,
        attachments,
      });
      console.log(`Email sent to admin: ${adminEmail}`);
    } catch (emailErr) {
      console.error("Failed to send email to admin:", emailErr);
    }

    // Send to partner if linked
    if (contractTemplate?.partner?.contact_email) {
      try {
        await sendEmail({
          to: contractTemplate.partner.contact_email,
          subject: `Contract Signed: ${templateName} - ${submitterNames}`,
          body: emailBody,
          attachments,
        });
        console.log(`Email sent to partner: ${contractTemplate.partner.contact_email}`);
      } catch (emailErr) {
        console.error("Failed to send email to partner:", emailErr);
      }
    }

    return res.status(200).json({ status: "processed", contract_id: contract.id });
  } catch (error: any) {
    console.error("DocuSeal webhook error:", error);
    return res.status(200).json({ status: "error", message: error.message });
  }
});

export default router;
