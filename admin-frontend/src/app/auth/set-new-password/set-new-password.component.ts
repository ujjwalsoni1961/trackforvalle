import { Component, inject, OnInit } from '@angular/core';
import { MatIcon } from '@angular/material/icon';
import { Router, RouterLink, ActivatedRoute } from '@angular/router';
import { FormControl, FormGroup, ReactiveFormsModule, ValidatorFn, Validators } from '@angular/forms';
import { MatButton } from '@angular/material/button';
import { MatFormField, MatLabel, MatError } from '@angular/material/form-field';
import { MatInput } from '@angular/material/input';
import { PasswordStrengthComponent } from '@elementar-ui/components/password-strength';
import { LogoComponent } from '@elementar-ui/components/logo';
import { NgOptimizedImage } from '@angular/common';
import { AuthService } from '../auth.service';
import { MatSpinner } from '@angular/material/progress-spinner';
import { SupabaseService } from '../../core/services/supabase.service';

@Component({
  selector: 'app-set-new-password',
  imports: [
    MatIcon,
    RouterLink,
    ReactiveFormsModule,
    MatButton,
    MatFormField,
    MatInput,
    MatLabel,
    MatError,
    PasswordStrengthComponent,
    LogoComponent,
    NgOptimizedImage,
    MatSpinner
  ],
  templateUrl: './set-new-password.component.html',
  styleUrl: './set-new-password.component.scss'
})
export class SetNewPasswordComponent implements OnInit {
  private _router = inject(Router);
  private _route = inject(ActivatedRoute);
  private _authService = inject(AuthService);
  private _supabaseService = inject(SupabaseService);

  errorMessage: string | null = null;
  successMessage: string | null = null;
  loading = false;
  sessionReady = false;
  resetMode: 'jwt' | 'supabase' = 'supabase';
  jwtToken: string | null = null;
  isSalesRep = false;
  readonly SALESMAN_APP_URL = 'https://web-opal-eight-21.vercel.app';

  form = new FormGroup({
    password: new FormControl('', [
      Validators.required,
      Validators.minLength(8),
      Validators.pattern(/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/)
    ]),
    confirmPassword: new FormControl('', [Validators.required])
  }, { validators: this.passwordMatchValidator() });

  constructor() {}

  async ngOnInit() {
    this._route.queryParams.subscribe(async (params) => {
      // Flow 1: JWT token from backend (salesman app forgot password)
      const token = params['token'];
      if (token) {
        this.jwtToken = token;
        this.sessionReady = true;
        this.resetMode = 'jwt';
        // Decode JWT to check user role (sales rep = role_id 4)
        try {
          const payload = JSON.parse(atob(token.split('.')[1]));
          if (payload.role_id === 4) {
            this.isSalesRep = true;
          }
        } catch (e) {
          // If decode fails, default to admin redirect
        }
        return;
      }

      // Flow 2: PKCE code from Supabase (admin forgot password)
      const code = params['code'];
      if (code) {
        try {
          const { data, error } = await this._supabaseService.exchangeCodeForSession(code);
          if (error) {
            this.errorMessage = 'Reset link expired or already used. Please request a new one.';
            return;
          }
          if (data.session) {
            this.sessionReady = true;
            this.resetMode = 'supabase';
            this.errorMessage = null;
            return;
          }
        } catch (e) {
          this.errorMessage = 'Reset link expired or already used. Please request a new one.';
          return;
        }
      }

      // Flow 3: check for existing Supabase session
      const { data: { session } } = await this._supabaseService.getSession();
      if (session) {
        this.sessionReady = true;
        this.resetMode = 'supabase';
        this.errorMessage = null;
        return;
      }

      // Flow 4: listen for PASSWORD_RECOVERY event
      const { data: { subscription } } = this._supabaseService.onAuthStateChange((event, session) => {
        if (event === 'PASSWORD_RECOVERY' || event === 'SIGNED_IN') {
          this.sessionReady = true;
          this.resetMode = 'supabase';
          this.errorMessage = null;
          subscription.unsubscribe();
        }
      });

      setTimeout(() => {
        if (!this.sessionReady) {
          this.errorMessage = 'No active reset session. Please request a new password reset link.';
          subscription.unsubscribe();
        }
      }, 3000);
    });
  }

  passwordMatchValidator(): any {
    return (form: FormGroup) => {
      return form.get('password')?.value === form.get('confirmPassword')?.value
        ? null
        : { mismatch: true };
    };
  }

  get passwordValue(): string {
    return this.form.get('password')?.value as string;
  }

  resetPassword() {
    if (this.form.valid && this.sessionReady) {
      this.loading = true;

      if (this.resetMode === 'jwt' && this.jwtToken) {
        // Backend JWT flow: call backend resetPassword endpoint
        this._authService.resetPasswordWithToken(this.jwtToken, this.form.get('password')?.value!).subscribe({
          next: (response: any) => {
            this.successMessage = response.message || 'Password updated successfully!';
            this.errorMessage = null;
            this.loading = false;
            this.form.markAsUntouched();
            setTimeout(() => {
              if (this.isSalesRep) {
                // Redirect sales reps to their own login page
                window.location.href = this.SALESMAN_APP_URL + '/login';
              } else {
                this._router.navigateByUrl('/auth/sign-in');
              }
            }, 2000);
          },
          error: (error) => {
            this.errorMessage = error.error?.error?.message || error.message || 'An error occurred';
            this.successMessage = null;
            this.loading = false;
          }
        });
      } else {
        // Supabase flow: update password via Supabase Auth
        this._authService.resetPassword('recovery', this.form.get('password')?.value!).subscribe({
          next: (response: any) => {
            this.successMessage = response.message || 'Password updated successfully!';
            this.errorMessage = null;
            this.loading = false;
            this.form.markAsUntouched();
            setTimeout(() => {
              this._router.navigateByUrl('/auth/sign-in');
            }, 2000);
          },
          error: (error) => {
            this.errorMessage = error.error?.error?.message || error.message || 'An error occurred';
            this.successMessage = null;
            this.loading = false;
          }
        });
      }
    }
  }
}