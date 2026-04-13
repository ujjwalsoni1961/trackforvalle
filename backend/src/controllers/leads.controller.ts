import { Request, Response } from "express";
import { CustomerService } from "../service/customer.service";
import { ApiResponse } from "../utils/api.response";
import { parse } from "csv-parse";
import httpStatusCodes from "http-status-codes";
import * as XLSX from "xlsx";
import { readFileSync, unlinkSync, createReadStream } from "fs";
import { LeadImportDto, UpdateLeadDto } from "../interfaces/common.interface";
import { validate } from "class-validator";
import { GeminiService } from "../service/gemini.service";

const customerService = new CustomerService();
const geminiService = new GeminiService();

export class LeadsController {
  async parseExcelWithAI(req: any, res: Response): Promise<void> {
    try {
      if (!req.file) {
        return ApiResponse.error(res, 400, "No file uploaded");
      }

      const filePath = req.file.path;
      const fileBuffer = readFileSync(filePath);
      const workbook = XLSX.read(fileBuffer, { type: "buffer", cellDates: true, raw: false, dateNF: "yyyy-mm-dd" });
      const sheetName = workbook.SheetNames[0];
      const worksheet = workbook.Sheets[sheetName];
      const rawRows: any[][] = XLSX.utils.sheet_to_json(worksheet, { header: 1, blankrows: false, raw: false, dateNF: "yyyy-mm-dd" });

      // Clean up temp file
      try { unlinkSync(filePath); } catch (e) { /* ignore */ }

      if (!rawRows || rawRows.length < 2) {
        return ApiResponse.error(res, 400, "File is empty or has no data rows");
      }

      const result = await geminiService.parseExcelData(rawRows);

      return ApiResponse.result(
        res,
        result,
        200,
        null,
        `Parsed ${result.leads.length} leads using AI`
      );
    } catch (error: any) {
      console.error("Parse Excel with AI error:", error);
      return ApiResponse.error(res, 500, error.message || "Failed to parse Excel file");
    }
  }

  async createLeads(req: any, res: Response): Promise<void> {
    const data: LeadImportDto = req.body;
    const userId = parseInt(req.user.user_id);
    const org_id = parseInt(req.user.org_id); // Validate input
    const validation = new LeadImportDto();
    Object.assign(validation, data);
    const response = await customerService.createCustomer(data, userId, org_id);
    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(
      res,
      response.data ?? null,
      response.status,
      null,
      response.message
    );
  }

  async updateLead(req: any, res: Response): Promise<void> {
    const customerId = parseInt(req.params.id);
    const data: Partial<UpdateLeadDto> = req.body;
    const userId = parseInt(req.user.user_id);
    const org_id = parseInt(req.user.org_id);

    const role = req.user.role;

    const response = await customerService.updateCustomer(
      customerId,
      data,
      userId,
      org_id,
      role
    );
    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(
      res,
      response.data ?? null,
      response.status,
      null,
      response.message
    );
  }
  async updateStatus(req: any, res: Response): Promise<void> {
    const customerId = parseInt(req.params.id);
    const data: Partial<UpdateLeadDto> = req.body;
    const userId = parseInt(req.user.user_id);
    const org_id = parseInt(req.user.org_id);

    const role = req.user.role;

    const response = await customerService.updateCustomer(
      customerId,
      data,
      userId,
      org_id,
      role
    );
    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message, null);
    }

    return ApiResponse.result(
      res,
      response.data ?? null,
      response.status,
      null,
      response.message
    );
  }

  async deleteLead(req: any, res: Response): Promise<void> {
    const customerId = parseInt(req.params.id);
    const userId = parseInt(req.user.user_id);

    const response = await customerService.deleteCustomer(customerId, userId);
    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(res, {}, response.status, null, response.message);
  }

  async deleteBulkLead(req: any, res: Response): Promise<void> {
    const userId = parseInt(req.user.user_id);
    const { lead_ids } = req.body;
    const response = await customerService.deleteBulkCustomer(lead_ids, userId);
    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(res, {}, response.status, null, response.message);
  }
  async getLeadById(req: any, res: Response): Promise<void> {
    const customerId = parseInt(req.params.id);
    const userId = parseInt(req.user.user_id);
    const role = req.user.role;

    const response = await customerService.getCustomerById(
      customerId,
      userId,
      role
    );
    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message, null);
    }

    return ApiResponse.result(
      res,
      response.data,
      response.status,
      null,
      response.message
    );
  }

  async getAllLeads(req: any, res: Response): Promise<void> {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;
    const source = req.query.source as string;
    const search = req.query.search as string;
    const managerId = req.query.managerId
      ? parseInt(req.query.managerId)
      : undefined;
    const salesmanId = req.query.salesmanId
      ? parseInt(req.query.salesmanId)
      : undefined;
    const partnerId = req.query.partnerId
      ? parseInt(req.query.partnerId)
      : undefined;
    const territoryId = req.query.territoryId as string | undefined;
    const leadSet = req.query.leadSet as string | undefined;
    const filters = {
      page,
      limit,
      skip,
      search,
      source,
      managerId,
      salesmanId,
      partnerId,
      territoryId,
      leadSet,
    };
    const userId = parseInt(req.user.user_id);
    const response = await customerService.getAllCustomers(filters, userId);
    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(
      res,
      {
        leads: response.data,
        pagination: {
          page,
          limit,
          total: response.total ?? 0,
          totalPages: Math.ceil((response.total ?? 0) / limit),
        },
      },
      response.status,
      null,
      response.message
    );
  }

  async bulkAssignLeads(req: any, res: Response): Promise<void> {
    const { lead_ids, rep_id } = req.body;
    const userId = parseInt(req.user.user_id);

    const response = await customerService.bulkAssignCustomers(
      lead_ids,
      rep_id,
      userId
    );
    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(
      res,
      response.data ?? null,
      response.status,
      null,
      response.message
    );
  }

  async assignLeads(req: any, res: Response): Promise<void> {
    const customerId = parseInt(req.params.id);
    const repId = parseInt(req.body.rep_id);
    const userId = parseInt(req.user.user_id);

    const response = await customerService.assignCustomer(
      customerId,
      repId,
      userId
    );
    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(
      res,
      response.data,
      response.status,
      null,
      response.message
    );
  }

  async getLeadSets(req: any, res: Response): Promise<void> {
    try {
      const response = await customerService.getDistinctLeadSets();
      if (response.status >= 400) {
        return ApiResponse.error(res, response.status, response.message);
      }
      return ApiResponse.result(
        res,
        response.data ?? [],
        response.status,
        null,
        response.message
      );
    } catch (error: any) {
      return ApiResponse.error(
        res,
        httpStatusCodes.INTERNAL_SERVER_ERROR,
        `Failed to get lead sets: ${error.message}`
      );
    }
  }

  async importLeads(req: any, res: Response): Promise<void> {
    try {
      let data: LeadImportDto[] = req.body.leads;
      const lead_set: string | undefined = req.body.lead_set;
      const { user_id, org_id } = req.user;
      const response = await customerService.importCustomers(
        data,
        user_id,
        org_id,
        500,
        lead_set
      );
      if (response.status >= 400) {
        return ApiResponse.error(
          res,
          response.status,
          response.message,
          response.errors
        );
      }

      return ApiResponse.result(
        res,
        response.data ?? null,
        response.status,
        null,
        response.message
      );
    } catch (error: any) {
      return ApiResponse.error(
        res,
        httpStatusCodes.INTERNAL_SERVER_ERROR,
        `Failed to import customers: ${error.message}`
      );
    } finally {
      if (req.file?.path) {
        try {
          unlinkSync(req.file.path);
        } catch (err) {
          console.error("Failed to delete uploaded file:", err);
        }
      }
    }
  }
}
