import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class UsersService {
  private baseUrl: string = environment.baseUri;

  constructor(private http: HttpClient) { }

  getUsers(params: { page?: number, limit?: number, search?: string, role?: string, status?: string, territory?: string } = {}): Observable<any> {
    let httpParams = new HttpParams();
    if (params.page) httpParams = httpParams.set('page', params.page.toString());
    if (params.limit) httpParams = httpParams.set('limit', params.limit.toString());
    if (params.search) httpParams = httpParams.set('search', params.search);
    if (params.role) httpParams = httpParams.set('role', params.role);
    if (params.status) httpParams = httpParams.set('status', params.status);
    if (params.territory) httpParams = httpParams.set('territory', params.territory);
    return this.http.get<any[]>(this.baseUrl + '/user', { params: httpParams });
  }
  getRoles(): Observable<any[]> {
    return this.http.get<any[]>(this.baseUrl + '/admin/roles');
  }

  getManagers(params: { page?: number, limit?: number, search?: string, status?: string } = {}): Observable<any> {
    let httpParams = new HttpParams();
    if (params.page) httpParams = httpParams.set('page', params.page.toString());
    if (params.limit) httpParams = httpParams.set('limit', params.limit.toString());
    if (params.search) httpParams = httpParams.set('search', params.search);
    if (params.status) httpParams = httpParams.set('status', params.status);
    return this.http.get<any[]>(this.baseUrl + '/user/manager', { params: httpParams });
  }

  getSalesReps(params: { page?: number, limit?: number } = {}): Observable<any> {
    let httpParams = new HttpParams();
    if (params.page) httpParams = httpParams.set('page', params.page.toString());
    if (params.limit) httpParams = httpParams.set('limit', params.limit.toString());
    return this.http.get<any[]>(this.baseUrl + '/user/sales-rep', { params: httpParams });
  }

  getSalesmen(): Observable<any> {
    const httpParams = new HttpParams().set('limit', '500');
    return this.http.get<any[]>(`${this.baseUrl}/user/sales-rep`, { params: httpParams });
  }

  getUnassignedSalesReps(params: { page?: number, limit?: number } = {}): Observable<any> {
    let httpParams = new HttpParams();
    if (params.page) httpParams = httpParams.set('page', params.page.toString());
    if (params.limit) httpParams = httpParams.set('limit', params.limit.toString());
    return this.http.get(`${this.baseUrl}/user/unassigned-sales-rep`, { params: httpParams });
  }

  getAssignedSalesReps(): Observable<any> {
    return this.http.get(`${this.baseUrl}/admin/rep-manager`);
  }

  createUser(payload: any): Observable<any> {
    return this.http.post(this.baseUrl + '/user', payload);
  }

  updateUser(userId: string, payload: any): Observable<any> {
    return this.http.patch(`${this.baseUrl + '/user'}/${userId}`, payload);
  }

  updateUserStatus(userId: any, status: 'Active' | 'Inactive'): Observable<any> {
    const body = {
      status: status === 'Active',
      id: userId
    };
    return this.http.post(`${this.baseUrl}/user/status`, body);
  }

  resendInvitation(userId: string): Observable<any> {
    return this.http.post(`${this.baseUrl + '/user'}/${userId}/resend-invitation`, {});
  }

  resetPassword(email: string): Observable<any> {
    return this.http.post(`${this.baseUrl + '/auth/forget-password'}`, {email});
  }

  deleteUser(userId: any): Observable<any> {
    const body = {
      status: false,
      id: userId
    };
    return this.http.post(`${this.baseUrl}/user/status`, body);
  }

  assignSalesRepsToManager(payload: { manager_id: number, sale_rep_ids: number[] }): Observable<any> {
    return this.http.post(`${this.baseUrl}/user/assign-manager`, payload);
  }

  removeSalesmanFromManager(salesmanId: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/user/assign-manager/${salesmanId}`);
  }
}