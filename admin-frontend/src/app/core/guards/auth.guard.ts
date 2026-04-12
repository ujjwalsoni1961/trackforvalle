import { Injectable } from '@angular/core';
import { CanActivate, CanLoad, Router, Route, UrlSegment, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { AuthService } from '../../auth/auth.service';
import { SupabaseService } from '../services/supabase.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate, CanLoad {
  constructor(
    private authService: AuthService,
    private supabaseService: SupabaseService,
    private router: Router
  ) {
    // Listen for PASSWORD_RECOVERY event globally
    this.supabaseService.onAuthStateChange((event, session) => {
      if (event === 'PASSWORD_RECOVERY') {
        AuthGuard.isRecoveryMode = true;
        this.router.navigateByUrl('/auth/set-new-password');
      }
    });
  }

  private static isRecoveryMode = false;

  private async checkAuth(): Promise<boolean> {
    if (typeof window !== 'undefined') {
      // PKCE flow: check for ?code= in the URL (Supabase recovery redirect)
      const urlParams = new URLSearchParams(window.location.search);
      const code = urlParams.get('code');
      if (code) {
        this.router.navigate(['/auth/set-new-password'], { queryParams: { code } });
        return false;
      }

      // Implicit flow fallback: check for #type=recovery in hash
      const hash = window.location.hash;
      if (hash && hash.includes('type=recovery')) {
        window.location.href = '/auth/set-new-password' + hash;
        return false;
      }
    }

    // If recovery mode was set by onAuthStateChange
    if (AuthGuard.isRecoveryMode) {
      AuthGuard.isRecoveryMode = false;
      this.router.navigateByUrl('/auth/set-new-password');
      return false;
    }

    const { data: { session } } = await this.supabaseService.getSession();
    if (session) {
      return true;
    }
    this.router.navigate(['/auth/sign-in']);
    return false;
  }

  async canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Promise<boolean> {
    return this.checkAuth();
  }

  async canLoad(route: Route, segments: UrlSegment[]): Promise<boolean> {
    return this.checkAuth();
  }
}
