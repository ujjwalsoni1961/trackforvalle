import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, of, throwError } from 'rxjs';
import { catchError, switchMap, map } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private baseUrl: string = environment.baseUri;
  private readonly accessTokenKey = 'access_token';
  private readonly refreshTokenKey = 'refresh_token';
  private readonly currentUserKey = 'current_user';
  private currentUserSubject = new BehaviorSubject<any>(null);
  currentUser$ = this.currentUserSubject.asObservable();
  private roles: { [key: number]: string } = {};

  constructor(
    private http: HttpClient,
    private router: Router
  ) {
    const storedUser = this.getCurrentUser();
    if (storedUser) {
      this.currentUserSubject.next(storedUser);
      // Defer role loading to avoid circular dependency
      setTimeout(() => this.ensureRolesLoaded(), 0);
    }
  }

  private fetchRoles(token?: string): Observable<any> {
    const authToken = token || this.getToken();
    let headers = new HttpHeaders();
    
    if (authToken) {
      headers = headers.set('Authorization', `Bearer ${authToken}`);
    }
    
    return this.http.get(`${this.baseUrl}/admin/roles`, { headers }).pipe(
      map((response: any) => {
        if (response.success && response.data) {
          // Store roles mapping with role_id as key and role_name as value
          this.roles = response.data.reduce((acc: { [key: number]: string }, role: any) => {
            acc[role.role_id] = role.role_name;
            return acc;
          }, {});
          console.log('Roles loaded:', this.roles); // Debug log
          return this.roles;
        }
        return {};
      }),
      catchError(error => {
        console.error('Error fetching roles:', error);
        return of({});
      })
    );
  }

  login(email: string, password: string): Observable<any> {
    return this.http.post(`${this.baseUrl}/auth/login`, { email, password }).pipe(
      switchMap((response: any) => {
        // Extract token from response and fetch roles with that token
        const token = response?.data?.token;
        if (token) {
          return this.fetchRoles(token).pipe(
            map(() => response)
          );
        } else {
          return of(response);
        }
      })
    );
  }

  // setTokens(accessToken: string, refreshToken: string): void {
  setTokens(accessToken: string): void {
    localStorage.setItem(this.accessTokenKey, accessToken);
    // localStorage.setItem(this.refreshTokenKey, refreshToken);
  }

  setToken(accessToken: string): void {
    localStorage.setItem(this.accessTokenKey, accessToken);
  }

  getToken(): string | null {
    return localStorage.getItem(this.accessTokenKey);
  }

  // getRefreshToken(): string | null {
  //   return localStorage.getItem(this.refreshTokenKey);
  // }

  clearTokens(): void {
    localStorage.removeItem(this.accessTokenKey);
    // localStorage.removeItem(this.refreshTokenKey);
    localStorage.removeItem(this.currentUserKey);
    this.currentUserSubject.next(null);
  }

  isAuthenticated(): boolean {
    return !!this.getToken();
  }

  logout(): void {
    this.clearTokens();
    this.router.navigate(['/auth/sign-in']);
    this.currentUserSubject.next(null);
  }

  setCurrentUser(user: any): void {
    // Ensure roles are loaded before setting user
    this.ensureRolesLoaded();
    
    const roleName = this.getRoleName(user.role_id);
    console.log('Setting current user:', user.role_id, '→', roleName); // Debug log
    
    const minimalUser = {
      name: `${user.first_name} ${user.last_name}`.trim(),
      email: user.email,
      role_id: user.role_id,
      role: roleName,
      user_id: user.user_id // Include user_id for contract assignment checks
    };
    localStorage.setItem(this.currentUserKey, JSON.stringify(minimalUser));
    this.currentUserSubject.next(minimalUser);
  }


  getCurrentUser(): any {
    const user = localStorage.getItem(this.currentUserKey);
    return user ? JSON.parse(user) : null;
  }

  private ensureRolesLoaded(): void {
    if (Object.keys(this.roles).length === 0 && this.isAuthenticated()) {
      this.fetchRoles().subscribe(() => {
        console.log('Roles loaded after ensure:', this.roles); // Debug log
      });
    }
  }

  getRoleName(roleId: number): string {
    this.ensureRolesLoaded();
    const roleName = this.roles[roleId];
    console.log('Getting role name for ID:', roleId, 'from roles:', this.roles, '→', roleName); // Debug log
    return roleName || 'User';
  }

  forgotPassword(email: string): Observable<any> {
    return this.http.post(`${this.baseUrl}/auth/forget-password`, { email }).pipe(
      catchError(error => throwError(() => error))
    );
  }

  resetPassword(token: string, newPassword: string): Observable<any> {
    return this.http.post(`${this.baseUrl}/auth/reset-password`, { token, newPassword }).pipe(
      catchError(error => throwError(() => error))
    );
  }

  // Role-based access methods using API role names
  hasRole(roleName: string): boolean {
    const currentUser = this.getCurrentUser();
    return currentUser?.role === roleName;
  }

  hasAnyRole(roleNames: string[]): boolean {
    const currentUser = this.getCurrentUser();
    return roleNames.includes(currentUser?.role);
  }

  isManager(): boolean {
    return this.hasRole('manager');
  }

  isAdmin(): boolean {
    return this.hasRole('admin');
  }

  canAccessManagerPanel(): boolean {
    return this.hasAnyRole(['manager', 'admin']);
  }

  // Get all available roles
  getAllRoles(): { [key: number]: string } {
    return { ...this.roles };
  }

  // Get role information
  getRoleInfo(roleId: number): { id: number, name: string } | null {
    const roleName = this.roles[roleId];
    return roleName ? { id: roleId, name: roleName } : null;
  }

}