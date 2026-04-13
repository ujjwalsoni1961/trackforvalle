import { Response } from "express";
import { ContractTemplateService } from "../service/contract.service";
import { ApiResponse } from "../utils/api.response";
import { getDataSource } from "../config/data-source";
import { Contract } from "../models/Contracts.entity";
import { ContractPDF } from "../models/ContractPdf.entity";
import { ContractImage } from "../models/ContractImage.entity";
import { ContractTemplate } from "../models/ContractTemplate.entity";
import { Visit } from "../models/Visits.entity";
import { getBrowser } from "../utils/chromium";
import { generateStyledContractHTML } from "../utils/styled-html-generator";
import { PDFDocument, rgb, StandardFonts } from "pdf-lib";
import { getSupabaseServiceClient } from "../config/supabase";
import { sendEmail } from "../service/email.service";
import { Leads } from "../models/Leads.entity";
import { LeadStatus } from "../enum/leadStatus";

export class ContractTemplateController {
  constructor() {
    this.getContractHTML = this.getContractHTML.bind(this);
    this.getContractByLead = this.getContractByLead.bind(this);
    this.signContract = this.signContract.bind(this);
    this.uploadPdf = this.uploadPdf.bind(this);
  }
  async create(req: any, res: Response): Promise<void> {
    const { title, content, assigned_manager_ids, assigned_sales_rep_ids, status, dropdown_fields, partner_id, template_type, pdf_url, field_positions, field_positions_canvas_width, field_positions_canvas_height } =
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
      ...(template_type && { template_type }),
      ...(pdf_url && { pdf_url }),
      ...(field_positions && { field_positions }),
      ...(field_positions_canvas_width && { field_positions_canvas_width }),
      ...(field_positions_canvas_height && { field_positions_canvas_height }),
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

      // If PDF already stored in contract_pdfs, serve it directly (covers custom-signed PDF contracts)
      if (contract.pdf && contract.pdf.pdf_data) {
        const fileName = `contract_${contractId}_${Date.now()}.pdf`;
        res.setHeader("Content-Type", "application/pdf");
        if (shouldDownload) {
          res.setHeader(
            "Content-Disposition",
            `attachment; filename="${fileName}"`
          );
        } else {
          res.setHeader(
            "Content-Disposition",
            `inline; filename="${fileName}"`
          );
        }
        res.setHeader(
          "Content-Length",
          contract.pdf.pdf_data.length.toString()
        );
        res.send(contract.pdf.pdf_data);
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
      const leadIdNum = parseInt(leadId);
      const dataSource = await getDataSource();
      const contractRepo = dataSource.getRepository(Contract);

      // Strategy 1: Find contracts linked directly by lead_id on contracts table
      const directContracts = await contractRepo.find({
        where: { lead_id: leadIdNum },
        relations: {
          template: true,
          images: true,
          pdf: true,
        },
        order: { signed_at: "DESC" },
      });

      // Strategy 2: Find contracts linked through visits
      const visitRepo = dataSource.getRepository(Visit);
      const visits = await visitRepo.find({
        where: { lead_id: leadIdNum },
        relations: {
          contract: {
            template: true,
            images: true,
            pdf: true,
          },
        },
        order: { created_at: "DESC" },
      });
      const visitContracts = visits
        .filter((v) => v.contract)
        .map((v) => v.contract);

      // Merge and deduplicate by contract id
      const contractMap = new Map<number, Contract>();
      for (const c of directContracts) {
        contractMap.set(c.id, c);
      }
      for (const c of visitContracts) {
        if (!contractMap.has(c.id)) {
          contractMap.set(c.id, c);
        }
      }

      const allContracts = Array.from(contractMap.values());

      if (allContracts.length === 0) {
        res.status(404).json({
          success: false,
          data: null,
          message: "No contracts found for this lead",
        });
        return;
      }

      // Sort by signed_at descending, return the most recent
      allContracts.sort(
        (a, b) =>
          new Date(b.signed_at).getTime() - new Date(a.signed_at).getTime()
      );
      const contract = allContracts[0];

      // Find visit_id if available
      const matchingVisit = visits.find(
        (v) => v.contract && v.contract.id === contract.id
      );

      res.status(200).json({
        success: true,
        data: {
          contract_id: contract.id,
          template_title: contract.template?.title || "Contract",
          signed_at: contract.signed_at,
          rendered_html: contract.rendered_html,
          signature_url: contract.images?.[0]?.image_url || null,
          has_pdf: !!contract.pdf,
          visit_id: matchingVisit?.visit_id || contract.visit_id || null,
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

  async signContract(req: any, res: Response): Promise<void> {
    try {
      const { template_id, lead_id, field_values, signature } = req.body;

      if (!template_id || !signature) {
        ApiResponse.error(res, 400, "template_id and signature are required");
        return;
      }

      const dataSource = await getDataSource();
      const templateRepo = dataSource.getRepository(ContractTemplate);
      const contractRepo = dataSource.getRepository(Contract);
      const contractPdfRepo = dataSource.getRepository(ContractPDF);

      // Fetch the template with partner relation
      const template = await templateRepo.findOne({
        where: { id: template_id },
        relations: ["partner"],
      });

      if (!template) {
        ApiResponse.error(res, 404, "Contract template not found");
        return;
      }

      // Extract base64 data from data URL
      const base64Match = signature.match(/^data:image\/png;base64,(.+)$/);
      if (!base64Match) {
        ApiResponse.error(res, 400, "Invalid signature format. Expected data:image/png;base64,...");
        return;
      }
      const sigBase64 = base64Match[1];
      const sigBuffer = Buffer.from(sigBase64, "base64");

      // Upload signature to Supabase
      const supabase = getSupabaseServiceClient();
      const sigName = `signatures/${Date.now()}_signature.png`;
      const { error: uploadError } = await supabase.storage
        .from("contract-signature-images")
        .upload(sigName, sigBuffer, { contentType: "image/png" });

      if (uploadError) {
        console.error("Signature upload failed:", uploadError);
        ApiResponse.error(res, 500, "Failed to upload signature");
        return;
      }

      const {
        data: { publicUrl: signatureUrl },
      } = supabase.storage.from("contract-signature-images").getPublicUrl(sigName);

      // Generate PDF based on template type
      let pdfBytes: Uint8Array;

      if (template.template_type === "pdf_upload" && template.pdf_url) {
        // Download original PDF
        const pdfResponse = await fetch(template.pdf_url);
        if (!pdfResponse.ok) {
          ApiResponse.error(res, 500, "Failed to download template PDF");
          return;
        }
        const originalPdfBytes = new Uint8Array(await pdfResponse.arrayBuffer());
        const pdfDoc = await PDFDocument.load(originalPdfBytes);
        const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
        const sigImage = await pdfDoc.embedPng(sigBuffer);
        const pages = pdfDoc.getPages();

        // Overlay field values and signature
        const fieldPositions = template.field_positions || [];

        // Compute scale factor: admin placed fields on a CSS-scaled canvas.
        // The canvas internal dimensions match PDF at scale=1.0, but the CSS
        // display may be different (w-full h-auto). If canvas display width
        // was stored, use it to scale coordinates to actual PDF dimensions.
        const canvasWidth = (template as any).field_positions_canvas_width;
        const firstPage = pages[0];
        const pdfPageWidth = firstPage ? firstPage.getWidth() : 612;
        const pdfPageHeight = firstPage ? firstPage.getHeight() : 792;
        // Scale factor: if canvasWidth is stored, compute ratio; otherwise assume 1:1
        const scaleFactor = canvasWidth && canvasWidth > 0 ? pdfPageWidth / canvasWidth : 1;
        console.log(`PDF overlay: canvasWidth=${canvasWidth}, pdfPageWidth=${pdfPageWidth}, scaleFactor=${scaleFactor}`);

        for (const field of fieldPositions) {
          const pageIndex = (field.page || 1) - 1;
          if (pageIndex < 0 || pageIndex >= pages.length) continue;
          const page = pages[pageIndex];
          const pageHeight = page.getHeight();

          // Scale field coordinates from CSS display space to actual PDF space
          const fieldX = field.x * scaleFactor;
          const fieldY = field.y * scaleFactor;
          const fieldW = field.width * scaleFactor;
          const fieldH = field.height * scaleFactor;

          // Convert coordinates: y = pageHeight - fieldY - fieldH (top-left to bottom-left)
          const drawY = pageHeight - fieldY - fieldH;

          if (field.type === "signature") {
            // Draw signature image - NO borders, NO red boxes
            page.drawImage(sigImage, {
              x: fieldX,
              y: drawY,
              width: fieldW,
              height: fieldH,
            });
          } else {
            // Draw text field value — match by label (lowercased) since Flutter sends keys that way
            const fieldKey = (field.label || field.name || field.id || '').toLowerCase();
            const value = field_values?.[fieldKey] || (field.name ? field_values?.[field.name] : '') || (field.label ? field_values?.[field.label] : '') || (field.id ? field_values?.[field.id] : '') || "";
            if (value) {
              const fontSize = Math.min(fieldH * 0.7, 14);
              page.drawText(String(value), {
                x: fieldX + 2,
                y: drawY + fieldH * 0.25,
                size: fontSize,
                font,
                color: rgb(0, 0, 0),
              });
            }
          }
        }

        pdfBytes = await pdfDoc.save();
      } else {
        // richtext template: generate PDF from HTML content
        const pdfDoc = await PDFDocument.create();
        const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
        const boldFont = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
        const sigImage = await pdfDoc.embedPng(sigBuffer);

        // Replace placeholders in HTML content with field values
        let htmlContent = template.content || "";
        if (field_values) {
          for (const [key, value] of Object.entries(field_values)) {
            const placeholder = new RegExp(`\\{\\{\\s*${key}\\s*\\}\\}`, "g");
            htmlContent = htmlContent.replace(placeholder, String(value));
          }
        }

        // Strip HTML tags and parse basic structure
        const lines = this.parseHtmlToLines(htmlContent);

        const pageWidth = 595.28; // A4
        const pageHeight = 841.89;
        const margin = 50;
        const maxWidth = pageWidth - margin * 2;
        let currentY = pageHeight - margin;
        let page = pdfDoc.addPage([pageWidth, pageHeight]);

        for (const line of lines) {
          const fontSize = line.isHeader ? 16 : 11;
          const currentFont = line.isHeader ? boldFont : font;
          const lineHeight = fontSize * 1.4;

          // Word wrap
          const words = line.text.split(" ");
          let currentLine = "";

          for (const word of words) {
            const testLine = currentLine ? `${currentLine} ${word}` : word;
            const textWidth = currentFont.widthOfTextAtSize(testLine, fontSize);

            if (textWidth > maxWidth && currentLine) {
              // Check if we need a new page
              if (currentY - lineHeight < margin) {
                page = pdfDoc.addPage([pageWidth, pageHeight]);
                currentY = pageHeight - margin;
              }

              page.drawText(currentLine, {
                x: margin,
                y: currentY,
                size: fontSize,
                font: currentFont,
                color: rgb(0, 0, 0),
              });
              currentY -= lineHeight;
              currentLine = word;
            } else {
              currentLine = testLine;
            }
          }

          // Draw remaining text
          if (currentLine) {
            if (currentY - lineHeight < margin) {
              page = pdfDoc.addPage([pageWidth, pageHeight]);
              currentY = pageHeight - margin;
            }

            page.drawText(currentLine, {
              x: margin,
              y: currentY,
              size: fontSize,
              font: currentFont,
              color: rgb(0, 0, 0),
            });
            currentY -= lineHeight;
          }

          // Add extra spacing after headers
          if (line.isHeader) {
            currentY -= 5;
          }
        }

        // Add signature at the end
        const sigDisplayWidth = 150;
        const sigDisplayHeight = (sigImage.height / sigImage.width) * sigDisplayWidth;

        if (currentY - sigDisplayHeight - 40 < margin) {
          page = pdfDoc.addPage([pageWidth, pageHeight]);
          currentY = pageHeight - margin;
        }

        currentY -= 20;
        page.drawText("Signature:", {
          x: margin,
          y: currentY,
          size: 11,
          font: boldFont,
          color: rgb(0, 0, 0),
        });
        currentY -= sigDisplayHeight + 5;

        // Draw signature image - NO borders, NO rectangles
        page.drawImage(sigImage, {
          x: margin,
          y: currentY,
          width: sigDisplayWidth,
          height: sigDisplayHeight,
        });

        pdfBytes = await pdfDoc.save();
      }

      // Find the most recent visit for this lead to link the contract
      let visitId: number | null = null;
      if (lead_id) {
        try {
          const visitRepo = dataSource.getRepository(Visit);
          const openVisit = await visitRepo.findOne({
            where: { lead_id: lead_id },
            order: { created_at: "DESC" },
          });
          if (openVisit) {
            visitId = openVisit.visit_id;
          }
        } catch (visitErr) {
          console.error("Could not find visit for lead:", visitErr);
        }

        // Update lead status to Signed
        try {
          const leadsRepo = dataSource.getRepository(Leads);
          await leadsRepo.update({ lead_id: lead_id }, { status: LeadStatus.Signed });
        } catch (statusErr) {
          console.error("Failed to update lead status:", statusErr);
        }
      }

      // Save contract record
      const contract = contractRepo.create({
        contract_template_id: template_id,
        lead_id: lead_id || null,
        visit_id: visitId,
        field_values: field_values || {},
        signature_url: signatureUrl,
        rendered_html: template.content || "",
        signed_at: new Date(),
        metadata: {
          template_type: template.template_type,
          source: "custom_signing",
        },
      });

      const savedContract = await contractRepo.save(contract);

      // Save PDF to contract_pdfs table
      const contractPdf = contractPdfRepo.create({
        contract_id: savedContract.id,
        pdf_data: Buffer.from(pdfBytes),
      });
      await contractPdfRepo.save(contractPdf);

      // Email signed PDF to admin and partner
      const pdfBufferForEmail = Buffer.from(pdfBytes);
      const adminEmail = "ujjwalsoni1961@gmail.com";
      const templateName = template.title || "Contract";
      const emailBody = `
        <h2>Contract Signed</h2>
        <p><strong>Template:</strong> ${templateName}</p>
        <p><strong>Contract ID:</strong> ${savedContract.id}</p>
        ${lead_id ? `<p><strong>Lead ID:</strong> ${lead_id}</p>` : ""}
        <p><strong>Date:</strong> ${new Date().toISOString()}</p>
        <p>The signed contract PDF is attached to this email.</p>
      `;

      const attachments = [
        {
          filename: `signed_contract_${savedContract.id}.pdf`,
          content: pdfBufferForEmail,
          contentType: "application/pdf",
        },
      ];

      // Send to admin
      try {
        await sendEmail({
          to: adminEmail,
          subject: `Contract Signed: ${templateName}`,
          body: emailBody,
          attachments,
        });
      } catch (emailErr) {
        console.error("Failed to send email to admin:", emailErr);
      }

      // Send to partner if linked
      if (template.partner?.contact_email) {
        try {
          await sendEmail({
            to: template.partner.contact_email,
            subject: `Contract Signed: ${templateName}`,
            body: emailBody,
            attachments,
          });
        } catch (emailErr) {
          console.error("Failed to send email to partner:", emailErr);
        }
      }

      ApiResponse.result(
        res,
        { contract_id: savedContract.id, visit_id: visitId || 0 },
        201,
        null,
        "Contract signed successfully"
      );
    } catch (error: any) {
      console.error("Error signing contract:", error?.message || error, error?.stack);
      const errMsg = error?.message || "Failed to sign contract";
      ApiResponse.error(res, 500, `Failed to sign contract: ${errMsg}`);
    }
  }

  async uploadPdf(req: any, res: Response): Promise<void> {
    try {
      if (!req.file) {
        ApiResponse.error(res, 400, "No PDF file uploaded");
        return;
      }

      const fileUrl = (req.file as any).location;
      if (!fileUrl) {
        ApiResponse.error(res, 500, "File upload failed - no URL returned");
        return;
      }

      ApiResponse.result(
        res,
        { url: fileUrl },
        200,
        null,
        "PDF uploaded successfully"
      );
    } catch (error) {
      console.error("Error uploading PDF:", error);
      ApiResponse.error(res, 500, "Failed to upload PDF");
    }
  }

  private parseHtmlToLines(html: string): Array<{ text: string; isHeader: boolean }> {
    const lines: Array<{ text: string; isHeader: boolean }> = [];

    // Split by common block-level tags
    const blocks = html.split(/<\/?(p|div|br|h[1-6]|li|ul|ol|tr|table|blockquote)[^>]*>/gi);

    for (const block of blocks) {
      // Check if this was a header tag
      const headerMatch = block.match(/^(h[1-6])$/i);

      // Strip remaining HTML tags
      let text = block.replace(/<[^>]+>/g, "").trim();

      // Decode HTML entities
      text = text
        .replace(/&amp;/g, "&")
        .replace(/&lt;/g, "<")
        .replace(/&gt;/g, ">")
        .replace(/&quot;/g, '"')
        .replace(/&#39;/g, "'")
        .replace(/&nbsp;/g, " ");

      if (text) {
        lines.push({ text, isHeader: !!headerMatch });
      }
    }

    return lines;
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
