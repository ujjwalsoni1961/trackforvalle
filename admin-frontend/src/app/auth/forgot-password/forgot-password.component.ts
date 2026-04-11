import { Component, inject } from '@angular/core';
import { MatButton } from '@angular/material/button';
import { MatFormField, MatLabel, MatError } from '@angular/material/form-field';
import { MatInput } from '@angular/material/input';
import { Router, RouterLink } from '@angular/router';
import { FormControl, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatIcon } from '@angular/material/icon';
import { LogoComponent } from '@elementar-ui/components/logo';
import { NgOptimizedImage } from '@angular/common';
import { AuthService } from '../auth.service';
import { MatSpinner } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-forgot-password',
  imports: [
    MatButton,
    MatFormField,
    MatInput,
    MatLabel,
    MatError,
    RouterLink,
    ReactiveFormsModule,
    MatIcon,
    LogoComponent,
    NgOptimizedImage,
    MatSpinner
  ],
  templateUrl: './forgot-password.component.html',
  styleUrl: './forgot-password.component.scss'
})
export class ForgotPasswordComponent {
  private _router = inject(Router);
  private _authService = inject(AuthService);
  loading = false;

  email = new FormControl('', [Validators.required, Validators.email]);
  errorMessage: string | null = null;
  successMessage: string | null = null;

  resetPassword() {
    if (this.email.valid) {
      this.loading = true;
      this._authService.forgotPassword(this.email.value!).subscribe({
        next: (response: any) => {
          this.successMessage = response.message;
          this.errorMessage = null;
          this.loading = false;
          this.email.markAsUntouched();
          this._router.navigate(['/auth/password-reset'], { 
            queryParams: { email: this.email.value }
          });
        },
        error: (error: any) => {
          this.errorMessage = error.error.error?.message || 'An error occurred';
          this.successMessage = null;
          this.loading = false;
        }
      });
    }
  }
}