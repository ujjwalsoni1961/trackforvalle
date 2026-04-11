import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../../auth/auth.service';
import { SupabaseService } from '../services/supabase.service';
import { Router } from '@angular/router';
import { HttpErrorResponse, HttpRequest, HttpHandlerFn, HttpEvent } from '@angular/common/http';
import { catchError, switchMap } from 'rxjs/operators';
import { Observable, throwError, from } from 'rxjs';

export const jwtInterceptor: HttpInterceptorFn = (
  req: HttpRequest<any>,
  next: HttpHandlerFn
): Observable<HttpEvent<any>> => {
  const authService = inject(AuthService);
  const supabaseService = inject(SupabaseService);
  const router = inject(Router);

  // Skip token for auth endpoints
  if (isAuthEndpoint(req.url)) {
    return next(req);
  }

  // Get the Supabase session token asynchronously
  return from(supabaseService.getSession()).pipe(
    switchMap(({ data: { session } }) => {
      const token = session?.access_token;
      if (token) {
        req = addTokenToRequest(req, token);
      }

      return next(req).pipe(
        catchError((error: any) => {
          if (error instanceof HttpErrorResponse && error.status === 401) {
            authService.logout();
            router.navigate(['/auth/sign-in']);
            return throwError(() => new Error('Session expired or Unauthorized access - please log in again'));
          }
          return throwError(() => error);
        })
      );
    })
  );
};

function isAuthEndpoint(url: string): boolean {
  return (
    url.includes('/auth/login') ||
    url.includes('/auth/signup') ||
    url.includes('/auth/forgot-password') ||
    url.includes('/auth/refresh-token')
  );
}

function addTokenToRequest(request: HttpRequest<any>, token: string): HttpRequest<any> {
  return request.clone({
    setHeaders: {
      Authorization: `Bearer ${token}`
    }
  });
}
