import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../../auth/auth.service';
import { Router } from '@angular/router';
import { HttpErrorResponse, HttpRequest, HttpHandlerFn, HttpEvent } from '@angular/common/http';
import { catchError, switchMap } from 'rxjs/operators';
import { Observable, throwError } from 'rxjs';

let isRefreshing = false; // Keep track of refresh state globally

export const jwtInterceptor: HttpInterceptorFn = (
  req: HttpRequest<any>,
  next: HttpHandlerFn
): Observable<HttpEvent<any>> => {
  const authService = inject(AuthService);
  const router = inject(Router);

  // Skip token for auth endpoints
  if (isAuthEndpoint(req.url)) {
    return next(req);
  }

  const token = authService.getToken();
  if (token) {
    req = addTokenToRequest(req, token);
  }

  return next(req).pipe(
    catchError((error: any) => {
      if (error instanceof HttpErrorResponse && error.status === 401) {
        // return handle401Error(req, next, authService, router);
        if (error instanceof HttpErrorResponse && error.status === 401) {
        // Unauthorized: Log out and redirect to sign-in
        authService.logout();
        router.navigate(['/auth/sign-in']);
        return throwError(() => new Error('Session expired or Unauthorized access - please log in again'));
      }
      }
      return throwError(() => error);
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

function handle401Error(
  request: HttpRequest<any>,
  next: HttpHandlerFn,
  authService: AuthService,
  router: Router
): Observable<HttpEvent<any>> {
  
  // if (!isRefreshing) {
  //   isRefreshing = true;

  //   return authService.refreshToken().pipe(
  //     switchMap((response: any) => {
  //       isRefreshing = false;

  //       if (response?.success && response?.data?.token) {
  //         authService.setToken(response.data.token);
  //         const newRequest = addTokenToRequest(request, response.data.token);
  //         return next(newRequest);
  //       } else {
  //         authService.logout();
  //         return throwError(() => new Error('Token refresh failed'));
  //       }
  //     }),
  //     catchError((error) => {
  //       isRefreshing = false;
  //       authService.logout();
  //       return throwError(() => error);
  //     })
  //   );
  // }

  // If already refreshing, just forward original request
  return next(request);
}
