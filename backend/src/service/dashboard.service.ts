import { getDataSource } from "../config/data-source"; // Updated import
import { Role } from "../models/Role.entity";
import { Leads } from "../models/Leads.entity";
import { Visit } from "../models/Visits.entity";
import httpStatusCodes from "http-status-codes";
import { In, IsNull, Not, MoreThanOrEqual, Between } from "typeorm";
import { isEmpty } from "class-validator";
import { getCurrentMonthData } from "../utils/workingDays";
import { LeadStatus, leadStatusColors } from "../enum/leadStatus";

export class DashboardService {
  async getDashboard(
    orgId: number,
    userId: number,
    role_id: number
  ): Promise<{ status: number; message: string; data: any }> {
    const dataSource = await getDataSource();
    const visitRepo = dataSource.getRepository(Visit);
    const leadsRepo = dataSource.getRepository(Leads);

    try {
      // Today's date range
      const todayStart = new Date();
      todayStart.setHours(0, 0, 0, 0);
      const todayEnd = new Date();
      todayEnd.setHours(23, 59, 59, 999);

      // Run queries in parallel
      const [
        unVisitedLeads,
        visitedLeads,
        totalLeads,
        signedLeads,
        unSignedLeads,
        calender,
        todaysVisits,
        recentVisits,
        leadsByStatusRaw,
      ] = await Promise.all([
        leadsRepo.count({
          where: {
            status: In([LeadStatus.Prospect, LeadStatus.Start_Signing]),
            assigned_rep_id: userId,
          },
        }),
        leadsRepo.count({
          where: {
            status: Not(In([LeadStatus.Prospect, LeadStatus.Start_Signing])),
            assigned_rep_id: userId,
          },
        }),
        leadsRepo.count({
          where: { assigned_rep_id: userId },
        }),
        leadsRepo.count({
          where: {
            status: LeadStatus.Signed,
            assigned_rep_id: userId,
          },
        }),
        leadsRepo.count({
          where: {
            status: Not(In([LeadStatus.Signed])),
            assigned_rep_id: userId,
          },
        }),
        getCurrentMonthData(),
        visitRepo.count({
          where: {
            rep_id: userId,
            check_in_time: Between(todayStart, todayEnd),
          },
        }),
        visitRepo.find({
          where: {
            rep_id: userId,
          },
          order: { check_in_time: "DESC" },
          take: 5,
          relations: ["lead"],
        }),
        // Get leads grouped by status
        leadsRepo
          .createQueryBuilder("lead")
          .select("lead.status", "status")
          .addSelect("COUNT(*)", "count")
          .where("lead.assigned_rep_id = :userId", { userId })
          .groupBy("lead.status")
          .getRawMany(),
      ]);

      // Build leadsByStatus with colors
      const leadsByStatus = leadsByStatusRaw.map((row: any) => ({
        status: row.status,
        count: parseInt(row.count, 10),
        color: leadStatusColors[row.status as LeadStatus]?.hex || "#999999",
      }));

      // Conversion rate
      const conversionRate = totalLeads > 0
        ? Math.round((signedLeads / totalLeads) * 100)
        : 0;

      // Format recent visits
      const recentActivity = recentVisits.map((v: any) => ({
        visitId: v.visit_id,
        leadName: v.lead?.name || v.lead?.street_address || `Lead #${v.lead_id}`,
        status: v.status || "Unknown",
        date: v.check_in_time,
        notes: v.notes ? v.notes.substring(0, 100) : null,
      }));

      return {
        status: httpStatusCodes.OK,
        message: "Dashboard data retrieved successfully",
        data: {
          unSignedLeads,
          signedLeads,
          totalLeads,
          unVisitedLeads,
          visitedLeads,
          calender,
          todaysVisits,
          conversionRate,
          leadsByStatus,
          recentActivity,
        },
      };
    } catch (error: any) {
      return {
        status: httpStatusCodes.BAD_REQUEST,
        message: error.message,
        data: null,
      };
    }
  }
}
