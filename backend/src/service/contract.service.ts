// services/contractTemplate.service.ts

import { In } from "typeorm";
import { getDataSource } from "../config/data-source";
import { User } from "../models/User.entity";
import { ContractTemplate } from "../models/ContractTemplate.entity";
import { Contract } from "../models/Contracts.entity";

export const ContractTemplateService = {
  async createContractTemplate(payload: {
    title: string;
    content: string;
    status: string;
    assigned_sales_rep_ids: number[];
    partner_id?: number;
    template_type?: string;
    pdf_url?: string;
    field_positions?: Array<any>;
    dropdown_fields?: {
      [fieldName: string]: {
        label: string;
        options: Array<{
          label: string;
          value: string;
        }>;
        required?: boolean;
        placeholder?: string;
      };
    };
  }): Promise<{ status: number; data?: any; message: string }> {
    const dataSource = await getDataSource();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.startTransaction();

    try {
      const userRepo = queryRunner.manager.getRepository(User);
      const contractRepo = queryRunner.manager.getRepository(ContractTemplate);

      const salesReps = await userRepo.find({
        where: { user_id: In(payload.assigned_sales_rep_ids) },
      });

      const newTemplate = contractRepo.create({
        title: payload.title,
        content: payload.content,
        status: payload.status,
        assigned_sales_reps: salesReps,
        dropdown_fields: payload.dropdown_fields || undefined,
        ...(payload.partner_id && { partner_id: payload.partner_id }),
        ...(payload.template_type && { template_type: payload.template_type }),
        ...(payload.pdf_url && { pdf_url: payload.pdf_url }),
        ...(payload.field_positions && { field_positions: payload.field_positions }),
      });

      const savedTemplate = await contractRepo.save(newTemplate);
      await queryRunner.commitTransaction();

      return {
        status: 201,
        data: savedTemplate,
        message: "Contract template created successfully",
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      return {
        status: 500,
        message: "Failed to create contract template",
      };
    } finally {
      await queryRunner.release();
    }
  },

  async getAllContracts(filters: {
    salesRepId?: number;
    status?: string;
    search?: string;
    sortBy?: "signedCount" | "title" | "date";
    skip?: number;
    limit?: number;
    page?: number;
  }): Promise<{
    data: Contract[] | null;
    status: number;
    message: string;
    total: number;
  }> {
    const dataSource = await getDataSource();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.startTransaction();

    try {
      const contractRepo = queryRunner.manager.getRepository(Contract);

      let query = contractRepo
        .createQueryBuilder("contract")
        .leftJoinAndSelect("contract.template", "template")
        .leftJoinAndSelect("contract.visit", "visit")
        .leftJoinAndSelect("visit.rep", "rep")
        .leftJoinAndSelect("visit.lead", "lead");

      if (filters.salesRepId) {
        query = query
          .leftJoin("template.assigned_sales_reps", "salesRep")
          .andWhere("salesRep.user_id = :salesRepId", {
            salesRepId: filters.salesRepId,
          });
      }

      if (filters.status) {
        query = query.andWhere("template.status = :status", {
          status: filters.status,
        });
      }

      if (filters.search) {
        query = query.andWhere("LOWER(template.title) ILIKE :search", {
          search: `%${filters.search.toLowerCase()}%`,
        });
      }

      if (filters.sortBy === "signedCount") {
        query = query.orderBy("template.total_signed", "DESC");
      } else if (filters.sortBy === "title") {
        query = query.orderBy("template.title", "ASC");
      } else {
        query = query.orderBy("contract.signed_at", "DESC");
      }
      const [contracts, total] = await query
        .skip(filters.skip || 0)
        .take(filters.limit || 10)
        .getManyAndCount();

      await queryRunner.commitTransaction();

      return {
        data: contracts,
        status: 200,
        message: "Contracts fetched successfully",
        total,
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      return {
        data: null,
        status: 500,
        message: "Error fetching contracts",
        total: 0,
      };
    } finally {
      await queryRunner.release();
    }
  },
  async listContractTemplates(): Promise<{
    data: ContractTemplate[] | null;
    status: number;
    message: string;
  }> {
    const dataSource = await getDataSource();
    const queryRunner = await dataSource.createQueryRunner();
    await queryRunner.startTransaction();
    try {
      const contracts = await queryRunner.manager.find(ContractTemplate, {
        relations: { assigned_sales_reps: true, partner: true },
        order: { updated_at: "DESC" },
      });
      await queryRunner.commitTransaction();
      return {
        data: contracts,
        status: 200,
        message: "Contracts fetched successfully",
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      return {
        data: null,
        status: 500,
        message: "Error fetching contracts",
      };
    } finally {
      await queryRunner.release();
    }
  },

  async getTemplatesForSalesRep(
    repId: number
  ): Promise<{ data: any; status: number; message: string }> {
    const dataSource = await getDataSource();
    const queryRunner = await dataSource.createQueryRunner();
    await queryRunner.startTransaction();
    try {
      const templateRepo = dataSource.getRepository(ContractTemplate);
      // Directly query templates assigned to this sales rep, excluding drafts
      const templates = await templateRepo
        .createQueryBuilder("template")
        .leftJoin("template.assigned_sales_reps", "salesRep")
        .where("salesRep.user_id = :repId", { repId })
        .andWhere("template.status != :draftStatus", { draftStatus: "draft" })
        .getMany();
      await queryRunner.commitTransaction();

      return {
        data: templates,
        message: "Templates fetched successfully",
        status: 200,
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      return {
        data: null,
        message: "Error fetching templates",
        status: 500,
      };
    } finally {
      await queryRunner.release();
    }
  },

  async reassignContractTemplate(
    templateId: number,
    assigned_sales_rep_ids: number[]
  ): Promise<{ status: number; data?: any; message: string }> {
    const dataSource = await getDataSource();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.startTransaction();

    try {
      const userRepo = queryRunner.manager.getRepository(User);
      const contractRepo = queryRunner.manager.getRepository(ContractTemplate);

      // Find the existing template
      const existingTemplate = await contractRepo.findOne({
        where: { id: templateId },
        relations: { assigned_sales_reps: true },
      });

      if (!existingTemplate) {
        await queryRunner.rollbackTransaction();
        return {
          status: 404,
          message: "Contract template not found",
        };
      }

      // Find the new sales reps to assign
      const salesReps = await userRepo.find({
        where: { user_id: In(assigned_sales_rep_ids) },
      });

      if (salesReps.length !== assigned_sales_rep_ids.length) {
        await queryRunner.rollbackTransaction();
        return {
          status: 400,
          message: "One or more sales rep IDs are invalid",
        };
      }

      // Update the assigned sales reps
      existingTemplate.assigned_sales_reps = salesReps;
      existingTemplate.updated_at = new Date();

      const updatedTemplate = await contractRepo.save(existingTemplate);
      await queryRunner.commitTransaction();

      return {
        status: 200,
        data: updatedTemplate,
        message: "Contract template reassigned successfully",
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      console.error("Error reassigning contract template:", error);
      return {
        status: 500,
        message: "Failed to reassign contract template",
      };
    } finally {
      await queryRunner.release();
    }
  },

  async updateContractTemplate(
    templateId: number,
    updates: {
      title?: string;
      content?: string;
      status?: string;
      assigned_sales_rep_ids?: number[];
      template_type?: string;
      pdf_url?: string | null;
      field_positions?: Array<any> | null;
      dropdown_fields?: {
        [fieldName: string]: {
          label: string;
          options: Array<{
            label: string;
            value: string;
          }>;
          required?: boolean;
          placeholder?: string;
        };
      };
    }
  ): Promise<{ status: number; data?: any; message: string }> {
    const dataSource = await getDataSource();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.startTransaction();

    try {
      const userRepo = queryRunner.manager.getRepository(User);
      const contractRepo = queryRunner.manager.getRepository(ContractTemplate);

      // Find the existing template
      const existingTemplate = await contractRepo.findOne({
        where: { id: templateId },
        relations: { assigned_sales_reps: true },
      });

      if (!existingTemplate) {
        await queryRunner.rollbackTransaction();
        return {
          status: 404,
          message: "Contract template not found",
        };
      }

      // Update basic fields
      if (updates.title !== undefined) {
        existingTemplate.title = updates.title;
      }
      if (updates.content !== undefined) {
        existingTemplate.content = updates.content;
      }
      if (updates.status !== undefined) {
        existingTemplate.status = updates.status;
      }
      if (updates.dropdown_fields !== undefined) {
        existingTemplate.dropdown_fields = updates.dropdown_fields;
      }
      if (updates.template_type !== undefined) {
        existingTemplate.template_type = updates.template_type;
      }
      if (updates.pdf_url !== undefined) {
        existingTemplate.pdf_url = updates.pdf_url as any;
      }
      if (updates.field_positions !== undefined) {
        existingTemplate.field_positions = updates.field_positions as any;
      }

      // Update assigned sales reps if provided
      if (updates.assigned_sales_rep_ids) {
        const salesReps = await userRepo.find({
          where: { user_id: In(updates.assigned_sales_rep_ids) },
        });

        if (salesReps.length !== updates.assigned_sales_rep_ids.length) {
          await queryRunner.rollbackTransaction();
          return {
            status: 400,
            message: "One or more sales rep IDs are invalid",
          };
        }

        existingTemplate.assigned_sales_reps = salesReps;
      }

      existingTemplate.updated_at = new Date();

      const updatedTemplate = await contractRepo.save(existingTemplate);
      await queryRunner.commitTransaction();

      return {
        status: 200,
        data: updatedTemplate,
        message: "Contract template updated successfully",
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      console.error("Error updating contract template:", error);
      return {
        status: 500,
        message: "Failed to update contract template",
      };
    } finally {
      await queryRunner.release();
    }
  },

  async getContractTemplateById(templateId: number): Promise<{
    data: ContractTemplate | null;
    status: number;
    message: string;
  }> {
    try {
      const dataSource = await getDataSource();
      const contractRepo = dataSource.getRepository(ContractTemplate);

      const template = await contractRepo.findOne({
        where: { id: templateId },
        relations: { assigned_sales_reps: true, partner: true },
      });

      if (!template) {
        return {
          data: null,
          status: 404,
          message: "Contract template not found",
        };
      }

      return {
        data: template,
        status: 200,
        message: "Contract template fetched successfully",
      };
    } catch (error) {
      console.error("Error fetching contract template:", error);
      return {
        data: null,
        status: 500,
        message: "Failed to fetch contract template",
      };
    }
  },

  async deleteContractTemplate(templateId: number): Promise<{
    status: number;
    message: string;
    data?: any;
  }> {
    const dataSource = await getDataSource();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.startTransaction();

    try {
      const templateRepo = queryRunner.manager.getRepository(ContractTemplate);

      const template = await templateRepo.findOne({
        where: { id: templateId },
      });

      if (!template) {
        await queryRunner.rollbackTransaction();
        return {
          status: 404,
          message: "Contract template not found",
        };
      }

      // Clear the many-to-many relation first
      await queryRunner.query(
        `DELETE FROM contract_template_sales_reps WHERE contract_template_id = $1`,
        [templateId]
      );
      // Also clear legacy table if exists
      await queryRunner.query(
        `DELETE FROM contract_template_managers WHERE contract_template_id = $1`,
        [templateId]
      );

      // Delete the template (signed contracts will cascade due to FK)
      await templateRepo.delete(templateId);

      await queryRunner.commitTransaction();

      return {
        status: 200,
        message: "Contract template deleted successfully",
        data: { templateId },
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      console.error("Error deleting contract template:", error);
      return {
        status: 500,
        message: "Failed to delete contract template",
      };
    } finally {
      await queryRunner.release();
    }
  },

  async deleteContract(contractId: number): Promise<{
    status: number;
    message: string;
    data?: any;
  }> {
    const dataSource = await getDataSource();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.startTransaction();

    try {
      const contractRepo = queryRunner.manager.getRepository(Contract);

      // Find the contract with all related data
      const contract = await contractRepo.findOne({
        where: { id: contractId },
        relations: ["images", "pdf", "visit"],
      });

      if (!contract) {
        await queryRunner.rollbackTransaction();
        return {
          status: 404,
          message: "Contract not found",
        };
      }

      // Delete related contract images (cascade should handle this, but explicit for safety)
      if (contract.images && contract.images.length > 0) {
        await queryRunner.manager.delete("contract_images", {
          contract_id: contractId,
        });
      }

      // Delete related contract PDF
      if (contract.pdf) {
        await queryRunner.manager.delete("contract_pdfs", {
          contract_id: contractId,
        });
      }

      // Finally, delete the contract itself
      await queryRunner.manager.delete("contracts", { id: contractId });

      await queryRunner.commitTransaction();

      return {
        status: 200,
        message: "Contract deleted successfully",
        data: { contractId },
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      console.error("Error deleting contract:", error);
      return {
        status: 500,
        message: "Failed to delete contract",
      };
    } finally {
      await queryRunner.release();
    }
  },
};
