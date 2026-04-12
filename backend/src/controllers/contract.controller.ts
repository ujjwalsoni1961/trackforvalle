import { Response } from "express";
import { ContractTemplateService } from "../service/contract.service";
import { ApiResponse } from "../utils/api.response";
import { getDataSource } from "../config/data-source";
import { Contract } from "../models/Contracts.entity";
import { ContractPDF } from "../models/ContractPdf.entity";
import { Visit } from "../models/Visits.entity";
import { getBrowser } from "../utils/chromium";
import { generateStyledContractHTML } from "../utils/styled-html-generator";

export class ContractTemplateController {
  constructor() {
    this.getContractHTML = this.getContractHTML.bind(this);
    this.getContractByLead = this.getContractByLead.bind(this);
  }
  async create(req: any, res: Response): Promise<void> {
    const { title, content, assigned_manager_ids, assigned_sales_rep_ids, status, dropdown_fields, partner_id } =
      req.body;

    // Support both old field name (assigned_manager_ids) and new (assigned_sales_rep_ids) for backwards compatibility
    const repIds = assigned_sales_rep_ids || assigned_manager_ids || [];

    const newTemplate = await ContractTemplateService.createContractTemplate({
      title,
      content,
      status,
      assigned_sales_rep_ids: repIds,
      dropdown_fields,
      ...(partner_id && { partner_id }),
    });
    if (newTemplate.status >= 400) {
      ApiResponse.error(res, newTemplate.status, newTemplate.message);
    }
    ApiResponse.result(
      res,
      newTemplate.data,
      newTemplate.status,
      null,
      newTemplate.message
    );
  }
  async list(req: any, res: Response): Promise<void> {
    const newTemplate = await ContractTemplateService.listContractTemplates();
    if (newTemplate.status >= 400) {
      return ApiResponse.error(res, newTemplate.status, newTemplate.message);
    }
    return ApiResponse.result(
      res,
      newTemplate.data,
      newTemplate.status,
      null,
      newTemplate.message
    );
  }
  async getAllContracts(req: any, res: Response): Promise<void> {
    const salesRepId = req.query.salesRepId
      ? Number(req.query.salesRepId)
      : req.query.managerId
        ? Number(req.query.managerId)
        : undefined;
    const status = req.query.status as string;
    const search = req.query.search as string;
    const sortBy = req.query.sortBy as "signedCount" | "title" | "date";

    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;

    const result = await ContractTemplateService.getAllContracts({
      salesRepId,
      status,
      search,
      sortBy,
      skip,
      limit,
      page,
    });

    if (result.status >= 400) {
      return ApiResponse.error(res, result.status, result.message);
    }

    return ApiResponse.result(
      res,
      {
        contracts: result.data,
        pagination: {
          page,
          limit,
          total: result.total,
          totalPages: Math.ceil((result.total || 0) / limit),
        },
      },
      result.status,
      null,
      result.message
    );
  }

  async getTemplatesForRep(req: any, res: Response) {
    const repId = req.user.user_id;
    const templates = await ContractTemplateService.getTemplatesForSalesRep(
      repId
    );
    if (templates.status >= 400) {
      ApiResponse.error(res, templates.status, templates.message);
    }
    ApiResponse.result(
      res,
      templates.data,
      templates.status,
      null,
      templates.message
    );
  }
  async getContractHTML(req: any, res: Response): Promise<void> {
    try {
      const { contractId } = req.params;
      const { download } = req.query;
      const shouldDownload = download === "true";
      const dataSource = await getDataSource();
      const contractRepo = dataSource.getRepository(Contract);

      // Find the contract with its rendered HTML and images
      const contract = await contractRepo.findOne({
        where: { id: parseInt(contractId) },
        relations: { images: true, pdf: true },
      });

      if (!contract) {
        res.status(404).json({
          data: null,
          message: "Contract not found",
          status: 404,
        });
        return;
      }

      if (!contract?.rendered_html) {
        res.status(404).json({
          data: null,
          message: "HTML content not found for this contract",
          status: 404,
        });
        return;
      }

      // Generate styled HTML
      const signatureUrl = contract?.images?.[0]?.image_url || null;
      const styledHtml = generateStyledContractHTML(
        contract?.rendered_html || "",
        signatureUrl || ""
      );

      // If download is requested, generate and return PDF
      if (shouldDownload) {
        try {
          // Check if PDF already exists in database
          if (contract.pdf && contract.pdf.pdf_data) {
            const fileName = `contract_${contractId}_${Date.now()}.pdf`;
            res.setHeader("Content-Type", "application/pdf");
            res.setHeader(
              "Content-Disposition",
              `attachment; filename="${fileName}"`
            );
            res.setHeader(
              "Content-Length",
              contract.pdf.pdf_data.length.toString()
            );
            res.send(contract.pdf.pdf_data);
            return;
          }

          // Generate PDF from HTML
          const pdfBuffer = await this.generatePdfFromHtml(styledHtml);
          const fileName = `contract_${contractId}_${Date.now()}.pdf`;

          // Set headers for PDF download
          res.setHeader("Content-Type", "application/pdf");
          res.setHeader(
            "Content-Disposition",
            `attachment; filename="${fileName}"`
          );
          res.setHeader("Content-Length", pdfBuffer.length.toString());

          res.send(pdfBuffer);
          return;
        } catch (pdfError) {
          console.error("Error generating PDF:", pdfError);
          res.status(500).json({
            data: null,
            message: "Error generating PDF",
            status: 500,
          });
          return;
        }
      }

      // Set headers for HTML response
      res.setHeader("Content-Type", "text/html; charset=utf-8");
      res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
      res.setHeader("Pragma", "no-cache");
      res.setHeader("Expires", "0");

      // Return the styled HTML
      res.status(200).send(styledHtml);
    } catch (error) {
      console.error("Error retrieving contract:", error);
      res.status(500).json({
        data: null,
        message: "Error retrieving the contract",
        status: 500,
      });
      return;
    }
  }
  async reassignContractTemplate(req: any, res: Response): Promise<void> {
    try {
      const { templateId } = req.params;
      const { assigned_sales_rep_ids, assigned_manager_ids } = req.body;

      // Support both old and new field names
      const repIds = assigned_sales_rep_ids || assigned_manager_ids;

      if (
        !templateId ||
        !repIds ||
        !Array.isArray(repIds)
      ) {
        return ApiResponse.error(
          res,
          400,
          "Template ID and assigned_sales_rep_ids array are required"
        );
      }

      if (repIds.length === 0) {
        return ApiResponse.error(
          res,
          400,
          "At least one sales rep ID must be provided"
        );
      }

      const result = await ContractTemplateService.reassignContractTemplate(
        parseInt(templateId),
        repIds
      );

      if (result.status >= 400) {
        return ApiResponse.error(res, result.status, result.message);
      }

      return ApiResponse.result(
        res,
        result.data,
        result.status,
        null,
        result.message
      );
    } catch (error) {
      console.error("Error reassigning contract template:", error);
      return ApiResponse.error(res, 500, "Internal server error");
    }
  }

  async updateContractTemplate(req: any, res: Response): Promise<void> {
    try {
      const { templateId } = req.params;
      const updates = req.body;

      if (!templateId) {
        return ApiResponse.error(res, 400, "Template ID is required");
      }

      // Map old field name to new
      if (updates.assigned_manager_ids && !updates.assigned_sales_rep_ids) {
        updates.assigned_sales_rep_ids = updates.assigned_manager_ids;
        delete updates.assigned_manager_ids;
      }

      const result = await ContractTemplateService.updateContractTemplate(
        parseInt(templateId),
        updates
      );

      if (result.status >= 400) {
        return ApiResponse.error(res, result.status, result.message);
      }

      return ApiResponse.result(
        res,
        result.data,
        result.status,
        null,
        result.message
      );
    } catch (error) {
      console.error("Error updating contract template:", error);
      return ApiResponse.error(res, 500, "Internal server error");
    }
  }

  async getTemplateById(req: any, res: Response): Promise<void> {
    try {
      const { templateId } = req.params;

      if (!templateId) {
        return ApiResponse.error(res, 400, "Template ID is required");
      }

      const result = await ContractTemplateService.getContractTemplateById(
        parseInt(templateId)
      );

      if (result.status >= 400) {
        return ApiResponse.error(res, result.status, result.message);
      }

      return ApiResponse.result(
        res,
        result.data,
        result.status,
        null,
        result.message
      );
    } catch (error) {
      console.error("Error fetching contract template:", error);
      return ApiResponse.error(res, 500, "Internal server error");
    }
  }

  async deleteContractTemplate(req: any, res: Response): Promise<void> {
    try {
      const { templateId } = req.params;

      if (!templateId) {
        return ApiResponse.error(res, 400, "Template ID is required");
      }

      const templateIdNum = parseInt(templateId);
      if (isNaN(templateIdNum)) {
        return ApiResponse.error(res, 400, "Invalid template ID format");
      }

      const result = await ContractTemplateService.deleteContractTemplate(
        templateIdNum
      );

      if (result.status >= 400) {
        return ApiResponse.error(res, result.status, result.message);
      }

      return ApiResponse.result(
        res,
        result.data,
        result.status,
        null,
        result.message
      );
    } catch (error) {
      console.error("Error deleting contract:", error);
      return ApiResponse.error(res, 500, "Internal server error");
    }
  }

  async getContractByLead(req: any, res: Response): Promise<void> {
    try {
      const { leadId } = req.params;
      const dataSource = await getDataSource();

      // Find visit(s) for this lead that have a contract
      const visitRepo = dataSource.getRepository(Visit);
      const visits = await visitRepo.find({
        where: { lead_id: parseInt(leadId) },
        relations: {
          contract: {
            template: true,
            images: true,
            pdf: true,
          },
        },
        order: { created_at: "DESC" },
      });

      // Filter visits that have a contract
      const contractVisits = visits.filter((v) => v.contract);

      if (contractVisits.length === 0) {
        res.status(404).json({
          success: false,
          data: null,
          message: "No contracts found for this lead",
        });
        return;
      }

      // Return the most recent contract with visit info
      const latestVisit = contractVisits[0];
      const contract = latestVisit.contract;

      res.status(200).json({
        success: true,
        data: {
          contract_id: contract.id,
          template_title: contract.template?.title || "Contract",
          signed_at: contract.signed_at,
          rendered_html: contract.rendered_html,
          signature_url: contract.images?.[0]?.image_url || null,
          has_pdf: !!contract.pdf,
          visit_id: latestVisit.visit_id,
          metadata: contract.metadata,
        },
        message: "Contract found",
      });
    } catch (error) {
      console.error("Error fetching contract by lead:", error);
      res.status(500).json({
        success: false,
        data: null,
        message: "Error fetching contract",
      });
    }
  }

  private async generatePdfFromHtml(html: string): Promise<Buffer> {
    let browser = null;

    try {
      browser = await getBrowser();
      const page = await browser.newPage();

      // Set viewport for consistent rendering
      await page.setViewport({
        width: 1024,
        height: 768,
        deviceScaleFactor: 2,
      });

      // Set content and wait for load
      await page.setContent(html, {
        waitUntil: "networkidle0",
        timeout: 30000,
      });

      // Wait for images to load
      await page.evaluate(() => {
        return Promise.all(
          Array.from(document.images)
            .filter((img) => !img.complete)
            .map(
              (img) =>
                new Promise((resolve) => {
                  img.onload = img.onerror = resolve;
                })
            )
        );
      });

      // Generate PDF
      const pdfBuffer = await page.pdf({
        format: "a4",
        margin: {
          top: "20mm",
          right: "15mm",
          bottom: "20mm",
          left: "15mm",
        },
        printBackground: true,
        preferCSSPageSize: false,
      });

      await page.close();
      return pdfBuffer;
    } catch (error) {
      console.error("Error generating PDF:", error);
      throw new Error("Failed to generate PDF");
    } finally {
      if (browser) {
        await browser.close();
      }
    }
  }
}
