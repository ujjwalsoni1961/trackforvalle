import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface SalesRep {
  user_id: number;
  first_name: string;
  last_name: string;
  email: string;
  phone_number: string;
  is_active: boolean;
  total_leads: string;
  signed_leads: string;
  total_visits: string;
  completed_visits: string;
  total_contracts: string;
}

export interface ManagerDashboardData {
  salesRepsCount: number;
  totalLeads: number;
  visitedLeads: number;
  unVisitedLeads: number;
  signedLeads: number;
  unSignedLeads: number;
  pendingVisits: number;
  completedVisits: number;
  totalContracts: number;
  salesRepDetails: SalesRep[];
}

export interface ManagerDashboardResponse {
  success: boolean;
  message: string;
  data: ManagerDashboardData;
}

@Injectable({
  providedIn: 'root'
})
export class ManagerDashboardService {
  private baseUrl: string = environment.baseUri;

  constructor(private http: HttpClient) { }

  getManagerDashboard(token?: string): Observable<ManagerDashboardResponse> {
    let headers = new HttpHeaders();
    
    if (token) {
      headers = headers.set('Authorization', `Bearer ${token}`);
    }

    return this.http.get<ManagerDashboardResponse>(`${this.baseUrl}/user/manager/dashboard`, { headers });
  }
}