import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class TerritoryService {
  private baseUrl: string = environment.baseUri;

  constructor(private http: HttpClient) { }

  getSalesmen(): Observable<any> {
    const httpParams = new HttpParams().set('limit', '500');

    return this.http.get<any[]>(`${this.baseUrl}/user/sales-rep`, { params: httpParams });
  }

  getManagers(): Observable<any[]> {
    return this.http.get<any>(`${this.baseUrl}/user/manager`).pipe(
      map(response => response.data.teamMembers),
      catchError(this.handleError)
    );
  }

  getTerritories(params?: { search?: string; limit?: number; page?: number }): Observable<any[]> {
    let httpParams = new HttpParams();
    if (params?.search) {
      httpParams = httpParams.set('search', params.search);
    }
    if (params?.limit) {
      httpParams = httpParams.set('limit', params.limit.toString());
    }
    if (params?.page) {
      httpParams = httpParams.set('page', params.page.toString());
    }

    return this.http.get<any[]>(`${this.baseUrl}/territory`, { params: httpParams }).pipe(
      catchError(this.handleError)
    );
  }

  addTerritory(territory: any): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}/territory`, territory).pipe(
      map(response => ({
        ...territory,
        id: response.id // Assuming the API returns the saved territory with an ID
      })),
      catchError(this.handleError)
    );
  }

  updateTerritory(id: string, update: { salesmanIds?: string[], managerIds?: string[], salesmanIdToRemove?: string }): Observable<any> {
    const body: any = {};
    if (update.salesmanIds) {
      body.salesmanIds = update.salesmanIds;
    }
    if (update.managerIds) {
      body.managerIds = update.managerIds;
    }
    if (update.salesmanIdToRemove) {
      body.salesmanIdToRemove = update.salesmanIdToRemove;
    }
    return this.http.patch(`${this.baseUrl}/territory/${id}`, body).pipe(
      catchError(this.handleError)
    );
  }

  deleteTerritory(id: string): Observable<any> {
    return this.http.delete(`${this.baseUrl}/territory/${id}`).pipe(
      catchError(this.handleError)
    );
  }

  reassignTerritory(territoryId: string, newSalesmanId: string): Observable<any> {
    return this.http.put(`${this.baseUrl}/territory/${territoryId}/reassign`, { newSalesmanId }).pipe(
      catchError(this.handleError)
    );
  }

  getPredefinedArea(areaName: string): any {
    const predefinedAreas = [
      {
        name: 'Töölö',
        geometry: JSON.stringify([
          { lat: 60.1840, lng: 24.9150 },
          { lat: 60.1840, lng: 24.9300 },
          { lat: 60.1740, lng: 24.9300 },
          { lat: 60.1740, lng: 24.9150 }
        ])
      },
      {
        name: 'Kamppi',
        geometry: JSON.stringify([
          { lat: 60.1700, lng: 24.9300 },
          { lat: 60.1700, lng: 24.9450 },
          { lat: 60.1620, lng: 24.9450 },
          { lat: 60.1620, lng: 24.9300 }
        ])
      }
    ];
    return predefinedAreas.find(area => area.name.toLowerCase() === areaName.toLowerCase());
  }

  private handleError(error: HttpErrorResponse): Observable<never> {
    let errorMessage = 'An error occurred while processing the request.';
    if (error.error instanceof ErrorEvent) {
      // Client-side or network error
      errorMessage = `Error: ${error.error.message}`;
    } else {
      // Backend returned an error
      errorMessage = `Error Code: ${error.status}\nMessage: ${error.message}`;
      if (error.error && error.error.message) {
        errorMessage += `\nDetails: ${error.error.message}`;
      }
    }
    console.error(errorMessage);
    return throwError(() => new Error(errorMessage));
  }
}