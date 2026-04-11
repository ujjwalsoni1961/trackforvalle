import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class PartnerService {
  private baseUrl: string = environment.baseUri;

  constructor(private http: HttpClient) {}

  getDashboardStats(): Observable<any> {
    return this.http.get(`${this.baseUrl}/partner/dashboard`);
  }

  getContracts(params: { page?: number; limit?: number } = {}): Observable<any> {
    let httpParams = new HttpParams();
    if (params.page) httpParams = httpParams.set('page', params.page.toString());
    if (params.limit) httpParams = httpParams.set('limit', params.limit.toString());
    return this.http.get(`${this.baseUrl}/partner/contracts`, { params: httpParams });
  }

  getReports(): Observable<any> {
    return this.http.get(`${this.baseUrl}/partner/reports`);
  }

  getProfile(): Observable<any> {
    return this.http.get(`${this.baseUrl}/partner/profile`);
  }

  updateProfile(data: any): Observable<any> {
    return this.http.put(`${this.baseUrl}/partner/profile`, data);
  }

  getSignedContracts(params: { page?: number; limit?: number } = {}): Observable<any> {
    let httpParams = new HttpParams();
    if (params.page) httpParams = httpParams.set('page', params.page.toString());
    if (params.limit) httpParams = httpParams.set('limit', params.limit.toString());
    return this.http.get(`${this.baseUrl}/partner/signed-contracts`, { params: httpParams });
  }

  createContractTemplate(data: { title: string; content: string; dropdown_fields?: any }): Observable<any> {
    return this.http.post(`${this.baseUrl}/partner/contracts`, data);
  }

  // Admin methods
  getAllPartners(params: { page?: number; limit?: number; search?: string } = {}): Observable<any> {
    let httpParams = new HttpParams();
    if (params.page) httpParams = httpParams.set('page', params.page.toString());
    if (params.limit) httpParams = httpParams.set('limit', params.limit.toString());
    if (params.search) httpParams = httpParams.set('search', params.search);
    return this.http.get(`${this.baseUrl}/partner`, { params: httpParams });
  }

  createPartner(data: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/partner`, data);
  }
}
