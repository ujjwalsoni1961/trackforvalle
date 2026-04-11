import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

// Define LeadStatus type
type LeadStatus = 'Get Back' | 'Not Available' | 'Not Interested' | 'Meeting' | 'Hot Lead' | 'Signed' | 'Start Signing' | 'Not Sellable';

interface Lead {
  lead_id: number;
  name: string;
  address_id: number | null;
  assigned_rep_id: number | null;
  contact_name: string;
  contact_email: string;
  contact_phone: string;
  status: LeadStatus;
  territory_id: number | null;
  org_id: number;
  is_active: boolean;
  pending_assignment: boolean;
  source: string;
  created_by: string;
  updated_by: string;
  created_at: string;
  updated_at: string;
  address: {
    address_id: number;
    street_address: string;
    building_unit: string | null;
    landmark: string | null;
    city: string;
    state: string;
    postal_code: string;
    area_name: string;
    subregion: string;
    region: string;
    country: string;
    latitude: number;
    longitude: number;
    comments: string | null;
    territory_id: number | null;
    polygon_id: number | null;
    org_id: number;
    is_active: boolean;
    created_by: string;
    updated_by: string;
    created_at: string;
    updated_at: string;
  } | null;
}

interface ApiResponse {
  success: boolean;
  data: {
    leads: Lead[];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  };
  message: string;
}

interface LeadStatusColor {
  status: LeadStatus;
  color: {
    name: string;
    hex: string;
  };
}

interface LeadStatusResponse {
  data: LeadStatusColor[];
  status: number;
  message: string;
}

@Injectable({
  providedIn: 'root'
})
export class LeadsService {
  baseUrl: string = environment.baseUri;

  constructor(public http: HttpClient) {}

  getLeads(
    search: string = '',
    page: number = 1,
    limit: number = 10,
    salesmanId: number | null = null,
    managerId: number | null = null
  ): Observable<ApiResponse> {
    let params = new HttpParams()
      .set('search', search)
      .set('page', page.toString())
      .set('limit', limit.toString());

    if (salesmanId) {
      params = params.set('salesmanId', salesmanId.toString());
    }
    if (managerId) {
      params = params.set('managerId', managerId.toString());
    }

    return this.http.get<ApiResponse>(`${this.baseUrl}/leads`, { params });
  }

  importLeads(payload: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/leads/import`, payload);
  }

  bulkAssignLeads(payload: { rep_id: number; lead_ids: number[] }): Observable<any> {
    return this.http.post(`${this.baseUrl}/leads/bulk-assign`, payload);
  }

  updateLead(leadId: number, payload: any): Observable<any> {
    return this.http.patch(`${this.baseUrl}/leads/${leadId}`, payload);
  }

  // New method to fetch lead status colors
  getLeadStatusColors(): Observable<LeadStatusResponse> {
    return this.http.get<LeadStatusResponse>(`${this.baseUrl}/user/lead-status`);
  }

  // New method to delete a single lead
  deleteLead(leadId: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/leads/${leadId}`);
  }

  // New method for bulk lead deletion
  bulkDeleteLeads(leadIds: number[]): Observable<any> {
    return this.http.post(`${this.baseUrl}/leads/bulk-delete`, { lead_ids: leadIds });
  }
}