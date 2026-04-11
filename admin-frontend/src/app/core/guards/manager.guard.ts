import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../../auth/auth.service';

export const managerGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  const currentUser = authService.getCurrentUser();
  const userRole = currentUser?.role;
  
  // Allow access if user is manager or admin (using API role names)
  if (userRole === 'manager' || userRole === 'admin') {
    return true;
  } else {
    // Redirect to dashboard if not authorized
    router.navigate(['/dashboard']);
    return false;
  }
};
