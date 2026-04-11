import { Response } from "express";
import { ApiResponse } from "../utils/api.response";
import { PartnerService } from "../service/partner.service";

const partnerService = new PartnerService();

export class PartnerController {
  async createPartner(req: any, res: Response): Promise<void> {
    const { org_id, user_id } = req.user;
    const { company_name, description, contact_email, contact_phone, logo_url, website } = req.body;

    if (!company_name) {
      return ApiResponse.error(res, 400, "Company name is required");
    }

    const response = await partnerService.createPartner(org_id, user_id, {
      company_name,
      description,
      contact_email,
      contact_phone,
      logo_url,
      website,
    });

    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(res, response.data, response.status, null, response.message);
  }

  async getAllPartners(req: any, res: Response): Promise<void> {
    const { org_id } = req.user;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const search = req.query.search as string;

    const response = await partnerService.getAllPartners(org_id, page, limit, search);

    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    const total = response.total || 0;
    const totalPages = Math.ceil(total / limit);

    return ApiResponse.result(res, response.data, response.status, null, response.message, {
      previousPage: page > 1 ? page - 1 : null,
      nextPage: page < totalPages ? page + 1 : null,
      currentPage: page,
      totalItems: total,
      totalPages,
    });
  }

  async getPartnerById(req: any, res: Response): Promise<void> {
    const id = parseInt(req.params.id);
    const response = await partnerService.getPartnerById(id);

    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(res, response.data, response.status, null, response.message);
  }

  async updatePartner(req: any, res: Response): Promise<void> {
    const { user_id } = req.user;
    const id = parseInt(req.params.id);
    const updateData = req.body;

    const response = await partnerService.updatePartner(id, user_id, updateData);

    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(res, response.data, response.status, null, response.message);
  }

  async getDashboardStats(req: any, res: Response): Promise<void> {
    const { partner_id } = req.user;

    if (!partner_id) {
      return ApiResponse.error(res, 403, "Partner ID not found for this user");
    }

    const response = await partnerService.getDashboardStats(partner_id);

    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(res, response.data, response.status, null, response.message);
  }

  async getPartnerContracts(req: any, res: Response): Promise<void> {
    const { partner_id } = req.user;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;

    if (!partner_id) {
      return ApiResponse.error(res, 403, "Partner ID not found for this user");
    }

    const response = await partnerService.getPartnerContracts(partner_id, page, limit);

    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    const total = response.total || 0;
    const totalPages = Math.ceil(total / limit);

    return ApiResponse.result(res, response.data, response.status, null, response.message, {
      previousPage: page > 1 ? page - 1 : null,
      nextPage: page < totalPages ? page + 1 : null,
      currentPage: page,
      totalItems: total,
      totalPages,
    });
  }

  async getPartnerReports(req: any, res: Response): Promise<void> {
    const { partner_id } = req.user;

    if (!partner_id) {
      return ApiResponse.error(res, 403, "Partner ID not found for this user");
    }

    const response = await partnerService.getPartnerReports(partner_id);

    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(res, response.data, response.status, null, response.message);
  }

  async getPartnerProfile(req: any, res: Response): Promise<void> {
    const { partner_id } = req.user;

    if (!partner_id) {
      return ApiResponse.error(res, 403, "Partner ID not found for this user");
    }

    const response = await partnerService.getPartnerById(partner_id);

    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(res, response.data, response.status, null, response.message);
  }

  async updatePartnerProfile(req: any, res: Response): Promise<void> {
    const { partner_id, user_id } = req.user;

    if (!partner_id) {
      return ApiResponse.error(res, 403, "Partner ID not found for this user");
    }

    const updateData = req.body;
    const response = await partnerService.updatePartner(partner_id, user_id, updateData);

    if (response.status >= 400) {
      return ApiResponse.error(res, response.status, response.message);
    }

    return ApiResponse.result(res, response.data, response.status, null, response.message);
  }
}
