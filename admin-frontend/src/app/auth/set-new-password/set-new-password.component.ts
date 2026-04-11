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
    // Check if we have a valid session from Supabase recovery
    const { data: { session } } = await this._supabaseService.getSession();
    if (session) {
      this.sessionReady = true;
    } else {
      this.errorMessage = 'Auth session missing! Please use the reset link from your email again.';
    }
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