import { Component, inject } from '@angular/core';
import { MatButton } from '@angular/material/button';
import { MatFormField, MatHint, MatLabel } from '@angular/material/form-field';
import { MatInput } from '@angular/material/input';
import { Router, RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HorizontalDividerComponent } from '@elementar-ui/components/divider';
import { LogoComponent } from '@elementar-ui/components/logo';
import { NgOptimizedImage } from '@angular/common';
import { AuthService } from '../auth.service';
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({
  imports: [
    MatButton,
    MatFormField,
    MatInput,
    MatLabel,
    RouterLink,
    ReactiveFormsModule,
    HorizontalDividerComponent,
    LogoComponent,
    NgOptimizedImage
  ],
  templateUrl: './signup.component.html',
  styleUrl: './signup.component.scss'
})
export class SignupComponent {
  private _formBuilder = inject(FormBuilder);
  private _authService = inject(AuthService);
  private _router = inject(Router);
  private _snackBar = inject(MatSnackBar);

  loading = false;

  form = this._formBuilder.group({
    name: this._formBuilder.control('', [Validators.required]),
    email: this._formBuilder.control('', [Validators.required, Validators.email]),
    password: this._formBuilder.control('', [Validators.required]),
  });

  onSubmit(): void {
    if (this.form.invalid) {
      return;
    }

    this.loading = true;
    const { name, email, password } = this.form.value;

    this._authService.signUp(email!, password!, { name }).subscribe({
      next: () => {
        this._snackBar.open('Account created successfully. Please sign in.', 'Dismiss', {
          duration: 3000,
          panelClass: ['success-snackbar']
        });
        this._router.navigate(['/auth/sign-in']);
      },
      error: (err: any) => {
        this.loading = false;
        const message = err?.error?.message || 'Signup failed. Please try again.';
        this._snackBar.open(message, 'Dismiss', {
          duration: 5000,
          panelClass: ['error-snackbar']
        });
      },
      complete: () => {
        this.loading = false;
      }
    });
  }
}
