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
  ) {}

  private async checkAuth(): Promise<boolean> {
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
