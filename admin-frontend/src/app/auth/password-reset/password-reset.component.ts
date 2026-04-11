// password-reset.component.ts
import { Component, inject } from '@angular/core';
import { FormControl, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink, ActivatedRoute } from '@angular/router';
import { MatIcon } from '@angular/material/icon';
// import { PinInputComponent } from '@elementar-ui/components/pin-input';
import { LogoComponent } from '@elementar-ui/components/logo';
import { NgOptimizedImage } from '@angular/common';
import { AuthService } from '../auth.service';

@Component({
  selector: 'app-password-reset',
  imports: [
    ReactiveFormsModule,
    // MatButton,
    RouterLink,
    MatIcon,
    // PinInputComponent,
    LogoComponent,
    NgOptimizedImage
  ],
  templateUrl: './password-reset.component.html',
  styleUrl: './password-reset.component.scss'
})
export class PasswordResetComponent {
  private _router = inject(Router);
  private _route = inject(ActivatedRoute);
  private _authService = inject(AuthService);

  email: string | null = null;
  errorMessage: string | null = null;
  successMessage: string | null = null;
  pin = new FormControl('', [Validators.required]);

  constructor() {
    this._route.queryParams.subscribe(params => {
      this.email = params['email'] || null;
    });
  }

  resendCode(): void {
    if (this.email) {
      this._authService.forgotPassword(this.email).subscribe({
        next: (response) => {
          this.successMessage = 'Reset link resent successfully';
          this.errorMessage = null;
          this.pin.markAsUntouched();
        },
        error: (error) => {
          this.errorMessage = error.error?.message || 'An error occurred';
          this.successMessage = null;
        }
      });
    }
  }

  continue() {
    // For now, assuming the link-based flow is used
    this._router.navigateByUrl('/auth/set-new-password');
  }
}