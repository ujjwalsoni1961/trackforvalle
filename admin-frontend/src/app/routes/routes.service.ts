import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class RoutesService {
  private baseUrl: string = environment.baseUri;

  constructor(private http: HttpClient) { }

  getDailyRoutes(params: any): Observable<any> {
    return this.http.get(this.baseUrl + '/admin/daily-routes', { params });
  }
  getVisits(params: any): Observable<any> {
    return this.http.get(this.baseUrl + '/admin/daily-routes', { params });
  }
}