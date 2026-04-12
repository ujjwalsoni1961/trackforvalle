import httpStatusCodes from "http-status-codes";
import { getDataSource } from "../config/data-source";
import { Partner } from "../models/Partner.entity";
import { User } from "../models/User.entity";
import { Leads } from "../models/Leads.entity";
import { ContractTemplate } from "../models/ContractTemplate.entity";
import { Contract } from "../models/Contracts.entity";
import { Visit } from "../models/Visits.entity";
import { LeadStatus } from "../enum/leadStatus";
import { In, Not, IsNull } from "typeorm";
import { getFinnishTime } from "../utils/timezone";

export class PartnerService {
  async createPartner(
    org_id: number,
    user_id: number,
    data: Partial<Partner>
  ): Promise<{ status: number; data?: any; message: string }> {
    const dataSource = await getDataSource();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.startTransaction();

    try {
      const partner = queryRunner.manager.getRepository(Partner).create({
        ...data,
        org_id,
        created_by: String(user_id).trim(),
        updated_by: String(user_id).trim(),
        created_at: getFinnishTime(),
        updated_at: getFinnishTime(),
      });
      const saved = await queryRunner.manager.getRepository(Partner).save(partner);
      await queryRunner.commitTransaction();

      return {
        status: httpStatusCodes.CREATED,
        data: saved,
        message: "Partner created successfully",
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      return {
        status: httpStatusCodes.INTERNAL_SERVER_ERROR,
        message: "Error creating partner",
      };
    } finally {
      await queryRunner.release();
    }
  }

  async getAllPartners(
    org_id: number,
    page: number,
    limit: number,
    search?: string
  ): Promise<{ status: number; data?: any; message: string; total?: number }> {
    const dataSource = await getDataSource();

    try {
      const skip = (page - 1) * limit;
      let query = dataSource
        .getRepository(Partner)
        .createQueryBuilder("partner")
        .where("partner.org_id = :org_id", { org_id });

      if (search && search.trim() !== "") {
        const searchTerm = `%${search.trim().toLowerCase()}%`;
        query = query.andWhere(
          `(LOWER(partner.company_name) LIKE :searchTerm
           OR LOWER(partner.contact_email) LIKE :searchTerm)`,
          { searchTerm }
        );
      }

      const [partners, total] = await query
        .orderBy("partner.partner_id", "ASC")
        .skip(skip)
        .take(limit)
        .getManyAndCount();

      return {
        status: httpStatusCodes.OK,
        data: partners,
        total,
        message: "Partners fetched successfully",
      };
    } catch (error) {
      return {
        status: httpStatusCodes.INTERNAL_SERVER_ERROR,
        message: "Error fetching partners",
      };
    }
  }

  async getPartnerById(
    partner_id: number
  ): Promise<{ status: number; data?: any; message: string }> {
    const dataSource = await getDataSource();

    try {
      const partner = await dataSource.getRepository(Partner).findOne({
        where: { partner_id },
      });

      if (!partner) {
        return {
          status: httpStatusCodes.NOT_FOUND,
          message: "Partner not found",
        };
      }

      return {
        status: httpStatusCodes.OK,
        data: partner,
        message: "Partner fetched successfully",
      };
    } catch (error) {
      return {
        status: httpStatusCodes.INTERNAL_SERVER_ERROR,
        message: "Error fetching partner",
      };
    }
  }

  async updatePartner(
    partner_id: number,
    user_id: number,
    data: Partial<Partner>
  ): Promise<{ status: number; data?: any; message: string }> {
    const dataSource = await getDataSource();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.startTransaction();

    try {
      const repo = queryRunner.manager.getRepository(Partner);
      const partner = await repo.findOne({ where: { partner_id } });

      if (!partner) {
        await queryRunner.rollbackTransaction();
        return {
          status: httpStatusCodes.NOT_FOUND,
          message: "Partner not found",
        };
      }

      await repo.update(partner_id, {
        ...data,
        updated_by: String(user_id).trim(),
        updated_at: getFinnishTime(),
      });

      const updated = await repo.findOne({ where: { partner_id } });
      await queryRunner.commitTransaction();

      return {
        status: httpStatusCodes.OK,
        data: updated,
        message: "Partner updated successfully",
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      return {
        status: httpStatusCodes.INTERNAL_SERVER_ERROR,
        message: "Error updating partner",
      };
    } finally {
      await queryRunner.release();
    }
  }

  async getDashboardStats(
    partner_id: number
  ): Promise<{ status: number; data?: any; message: string }> {
    const dataSource = await getDataSource();

    try {
      // Get partner's contract templates
      const contractTemplates = await dataSource.getRepository(ContractTemplate).find({
        where: { partner_id },
      });
      const totalContracts = contractTemplates.length;
      const templateIds = contractTemplates.map((ct) => ct.id);

      // Count signed contracts through partner's templates
      let signedContracts = 0;
      let signedContractsList: Contract[] = [];
      if (templateIds.length > 0) {
        signedContractsList = await dataSource
          .getRepository(Contract)
          .createQueryBuilder("c")
          .leftJoinAndSelect("c.visit", "visit")
          .leftJoinAndSelect("visit.lead", "lead")
          .where("c.contract_template_id IN (:...templateIds)", { templateIds })
          .getMany();
        signedContracts = signedContractsList.length;
      }

      // Count unique leads from signed contracts
      const leadIds = new Set(
        signedContractsList
          .filter((c) => c.visit?.lead_id)
          .map((c) => c.visit.lead_id)
      );
      const totalLeads = leadIds.size;

      // Also include partner's directly assigned leads
      const directLeads = await dataSource.getRepository(Leads).count({
        where: { partner_id },
      });

      const totalLeadsCount = Math.max(totalLeads, directLeads);
      const conversionRate = totalLeadsCount > 0
        ? ((signedContracts / totalLeadsCount) * 100).toFixed(1)
        : "0.0";

      return {
        status: httpStatusCodes.OK,
        data: {
          totalContracts,
          totalLeads: totalLeadsCount,
          signedLeads: signedContracts,
          signedContracts,
          conversionRate,
        },
        message: "Dashboard stats fetched successfully",
      };
    } catch (error) {
      return {
        status: httpStatusCodes.INTERNAL_SERVER_ERROR,
        message: "Error fetching dashboard stats",
      };
    }
  }

  async getPartnerContracts(
    partner_id: number,
    page: number,
    limit: number
  ): Promise<{ status: number; data?: any; message: string; total?: number }> {
    const dataSource = await getDataSource();

    try {
      const skip = (page - 1) * limit;
      const [contracts, total] = await dataSource
        .getRepository(ContractTemplate)
        .createQueryBuilder("ct")
        .where("ct.partner_id = :partner_id", { partner_id })
        .orderBy("ct.created_at", "DESC")
        .skip(skip)
        .take(limit)
        .getManyAndCount();

      return {
        status: httpStatusCodes.OK,
        data: contracts,
        total,
        message: "Contracts fetched successfully",
      };
    } catch (error) {
      return {
        status: httpStatusCodes.INTERNAL_SERVER_ERROR,
        message: "Error fetching contracts",
      };
    }
  }

  async getPartnerSignedContracts(
    partner_id: number,
    page: number,
    limit: number
  ): Promise<{ status: number; data?: any; message: string; total?: number }> {
    const dataSource = await getDataSource();

    try {
      const skip = (page - 1) * limit;

      const [contracts, total] = await dataSource
        .getRepository(Contract)
        .createQueryBuilder("c")
        .leftJoinAndSelect("c.template", "template")
        .leftJoinAndSelect("c.visit", "visit")
        .leftJoinAndSelect("visit.rep", "rep")
        .leftJoinAndSelect("visit.lead", "lead")
        .where("template.partner_id = :partner_id", { partner_id })
        .orderBy("c.signed_at", "DESC")
        .skip(skip)
        .take(limit)
        .getManyAndCount();

      return {
        status: httpStatusCodes.OK,
        data: contracts,
        total,
        message: "Signed contracts fetched successfully",
      };
    } catch (error) {
      return {
        status: httpStatusCodes.INTERNAL_SERVER_ERROR,
        message: "Error fetching signed contracts",
      };
    }
  }

  async createPartnerContractTemplate(
    partner_id: number,
    payload: {
      title: string;
      content: string;
      dropdown_fields?: any;
    }
  ): Promise<{ status: number; data?: any; message: string }> {
    const dataSource = await getDataSource();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.startTransaction();

    try {
      const template = queryRunner.manager.getRepository(ContractTemplate).create({
        title: payload.title,
        content: payload.content,
        partner_id,
        status: "draft",
        dropdown_fields: payload.dropdown_fields || undefined,
      });

      const saved = await queryRunner.manager.getRepository(ContractTemplate).save(template);
      await queryRunner.commitTransaction();

      return {
        status: httpStatusCodes.CREATED,
        data: saved,
        message: "Contract template created successfully",
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      return {
        status: httpStatusCodes.INTERNAL_SERVER_ERROR,
        message: "Error creating contract template",
      };
    } finally {
      await queryRunner.release();
    }
  }

  async getPartnerReports(
    partner_id: number
  ): Promise<{ status: number; data?: any; message: string }> {
    const dataSource = await getDataSource();

    try {
      const leads = await dataSource.getRepository(Leads).find({
        where: { partner_id },
      });

      const totalLeads = leads.length;
      const byStatus: Record<string, number> = {};
      leads.forEach((lead) => {
        byStatus[lead.status] = (byStatus[lead.status] || 0) + 1;
      });

      const contractTemplates = await dataSource
        .getRepository(ContractTemplate)
        .find({ where: { partner_id } });

      const templateIds = contractTemplates.map((ct) => ct.id);
      let signedContracts = 0;
      if (templateIds.length > 0) {
        signedContracts = await dataSource
          .getRepository(Contract)
          .createQueryBuilder("c")
          .where("c.contract_template_id IN (:...templateIds)", { templateIds })
          .andWhere("c.signed_at IS NOT NULL")
          .getCount();
      }

      return {
        status: httpStatusCodes.OK,
        data: {
          totalLeads,
          leadsByStatus: byStatus,
          totalContractTemplates: contractTemplates.length,
          signedContracts,
        },
        message: "Reports fetched successfully",
      };
    } catch (error) {
      return {
        status: httpStatusCodes.INTERNAL_SERVER_ERROR,
        message: "Error fetching reports",
      };
    }
  }
}
