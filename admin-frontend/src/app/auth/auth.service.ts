import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, of, throwError, from } from 'rxjs';
import { catchError, switchMap, map } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import { Router } from '@angular/router';
import { SupabaseService } from '../core/services/supabase.service';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private baseUrl: string = environment.baseUri;
  private readonly currentUserKey = 'current_user';
  private currentUserSubject = new BehaviorSubject<any>(null);
  currentUser$ = this.currentUserSubject.asObservable();
  private roles: { [key: number]: string } = {};

  constructor(
    private http: HttpClient,
    private router: Router,
    private supabaseService: SupabaseService
  ) {
    const storedUser = this.getCurrentUser();
    if (storedUser) {
      this.currentUserSubject.next(storedUser);
      setTimeout(() => this.ensureRolesLoaded(), 0);
    }
  }

  private fetchRoles(token?: string): Observable<any> {
    return from(this.getAccessToken()).pipe(
      switchMap(sessionToken => {
        const authToken = token || sessionToken;
        let headers = new HttpHeaders();

        if (authToken) {
          headers = headers.set('Authorization', `Bearer ${authToken}`);
        }

        return this.http.get(`${this.baseUrl}/admin/roles`, { headers }).pipe(
          map((response: any) => {
            if (response.success && response.data) {
              this.roles = response.data.reduce((acc: { [key: number]: string }, role: any) => {
                acc[role.role_id] = role.role_name;
                return acc;
              }, {});
              return this.roles;
            }
            return {};
          }),
          catchError(error => {
            console.error('Error fetching roles:', error);
            return of({});
          })
        );
      })
    );
  }

  /**
   * Login flow:
   * 1. Authenticate with Supabase Auth (signInWithPassword)
   * 2. Use the Supabase access token to call backend /auth/login for app-specific user data
   */
  login(email: string, password: string): Observable<any> {
    return from(this.supabaseService.signInWithPassword(email, password)).pipe(
      switchMap((supabaseResult) => {
        if (supabaseResult.error) {
          return throwError(() => ({
            error: { message: supabaseResult.error.message }
          }));
        }

        const supabaseToken = supabaseResult.data.session?.access_token;
        if (!supabaseToken) {
          return throwError(() => ({
            error: { message: 'No session token received from Supabase' }
          }));
        }

        // Call backend login with the Supabase token for app-specific data
        const headers = new HttpHeaders().set('Authorization', `Bearer ${supabaseToken}`);
        return this.http.post(`${this.baseUrl}/auth/login`, { email, password }, { headers }).pipe(
          switchMap((response: any) => {
            return this.fetchRoles(supabaseToken).pipe(
              map(() => response)
            );
          })
        );
      })
    );
  }

  /**
   * Signup flow:
   * 1. Create user in Supabase Auth
   * 2. Call backend signup for app-specific user record
   */
  signUp(email: string, password: string, userData?: any): Observable<any> {
    return from(this.supabaseService.signUp(email, password)).pipe(
      switchMap((supabaseResult) => {
        if (supabaseResult.error) {
          return throwError(() => ({
            error: { message: supabaseResult.error.message }
          }));
        }

        return this.http.post(`${this.baseUrl}/auth/signup`, { email, password, ...userData });
      })
    );
  }

  /**
   * Get the current Supabase access token.
   */
  async getAccessToken(): Promise<string | null> {
    const { data: { session } } = await this.supabaseService.getSession();
    return session?.access_token ?? null;
  }

  /**
   * Kept for backward compatibility - reads from Supabase session.
   */
  getToken(): string | null {
    // Synchronous fallback: check if we have a stored user as proxy for auth state.
    // The actual token is fetched async via getAccessToken().
    // This is used by the guard for quick synchronous checks.
    return this.getCurrentUser() ? 'supabase-session-active' : null;
  }

  setToken(accessToken: string): void {
    // No-op: Supabase manages its own session tokens
  }

  setTokens(accessToken: string): void {
    // No-op: Supabase manages its own session tokens
  }

  clearTokens(): void {
    localStorage.removeItem(this.currentUserKey);
    this.currentUserSubject.next(null);
  }

  isAuthenticated(): boolean {
    return !!this.getCurrentUser();
  }

  async isAuthenticatedAsync(): Promise<boolean> {
    const { data: { session } } = await this.supabaseService.getSession();
    return !!session;
  }

  async logout(): Promise<void> {
    await this.supabaseService.signOut();
    this.clearTokens();
    this.router.navigate(['/auth/sign-in']);
  }

  setCurrentUser(user: any): void {
    this.ensureRolesLoaded();

    const roleName = this.getRoleName(user.role_id);

    const minimalUser = {
      name: `${user.first_name} ${user.last_name}`.trim(),
      email: user.email,
      role_id: user.role_id,
      role: roleName,
      user_id: user.user_id
    };
    localStorage.setItem(this.currentUserKey, JSON.stringify(minimalUser));
    this.currentUserSubject.next(minimalUser);
  }

  getCurrentUser(): any {
    const user = localStorage.getItem(this.currentUserKey);
    return user ? JSON.parse(user) : null;
  }

  private ensureRolesLoaded(): void {
    if (Object.keys(this.roles).length === 0 && this.getCurrentUser()) {
      this.fetchRoles().subscribe();
    }
  }

  getRoleName(roleId: number): string {
    this.ensureRolesLoaded();
    const roleName = this.roles[roleId];
    return roleName || 'User';
  }

  forgotPassword(email: string): Observable<any> {
    return from(this.supabaseService.resetPasswordForEmail(email)).pipe(
      switchMap((result) => {
        if (result.error) {
          return throwError(() => ({
            error: { error: { message: result.error.message } }
          }));
        }
        return of({ success: true, message: 'Password reset email sent. Check your inbox.' });
      })
    );
  }

  resetPassword(token: string, newPassword: string): Observable<any> {
    return from(this.supabaseService.updateUser({ password: newPassword })).pipe(
      switchMap((result) => {
        if (result.error) {
          return throwError(() => ({
            error: { error: { message: result.error.message } }
          }));
        }
        return of({ success: true, message: 'Password updated successfully.' });
      })
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

  getAllRoles(): { [key: number]: string } {
    return { ...this.roles };
  }

  getRoleInfo(roleId: number): { id: number, name: string } | null {
    const roleName = this.roles[roleId];
    return roleName ? { id: roleId, name: roleName } : null;
  }
}
