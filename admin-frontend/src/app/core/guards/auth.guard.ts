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
    // Check if the URL hash contains recovery type (Supabase redirect)
    if (typeof window !== 'undefined') {
      const hash = window.location.hash;
      if (hash && hash.includes('type=recovery')) {
        // Store the full hash so set-new-password page can use it
        sessionStorage.setItem('supabase_recovery_hash', hash);
        AuthGuard.isRecoveryMode = true;
        // Don't return false - let Supabase process the hash first
        // Wait for Supabase to establish the session from the hash
        await new Promise(resolve => setTimeout(resolve, 1500));
        this.router.navigateByUrl('/auth/set-new-password');
        return false;
      }
    }

    // If we're in recovery mode, redirect to set-new-password
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
