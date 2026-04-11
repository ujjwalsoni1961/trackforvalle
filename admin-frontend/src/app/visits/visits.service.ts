import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class VisitsService {
  private baseUrl: string = environment.baseUri;

  constructor(private http: HttpClient) { }

  getDailyRoutes(params: any): Observable<any> {
    return this.http.get(`${this.baseUrl}/admin/daily-routes`, { params });
  }

  getVisits(params: any): Observable<any> {
    let httpParams = new HttpParams();

    if (params.salesRepId && params.salesRepId !== 'all') {
      httpParams = httpParams.set('salesRepId', params.salesRepId);
    }
    if (params.managerId && params.managerId !== 'all') {
      httpParams = httpParams.set('managerId', params.managerId);
    }
    if (params.from) {
      httpParams = httpParams.set('from', params.from);
    }
    if (params.to) {
      httpParams = httpParams.set('to', params.to);
    }
    if (params.sortBy) {
      httpParams = httpParams.set('sortBy', params.sortBy);
    }
    if (params.sortOrder) {
      httpParams = httpParams.set('sortOrder', params.sortOrder);
    }
    httpParams = httpParams.set('page', (params.page || 1).toString());
    httpParams = httpParams.set('limit', (params.limit || 10).toString());

    return this.http.get(`${this.baseUrl}/admin/visit/history`, { params: httpParams });
  }

  getPastVisits(leadId: number, page: number = 1, limit: number = 10): Observable<any> {
    let httpParams = new HttpParams();
    // httpParams = httpParams.set('view', 'past_visits');
    httpParams = httpParams.set('lead_id', leadId.toString());
    httpParams = httpParams.set('page', page.toString());
    httpParams = httpParams.set('limit', limit.toString());

    return this.http.get(`${this.baseUrl}/visit/past-vists`, { params: httpParams });
  }
}