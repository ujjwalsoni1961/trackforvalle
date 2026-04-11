import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { MatButton } from '@angular/material/button';
import { MatFormField, MatLabel, MatSuffix } from '@angular/material/form-field';
import { MatInput } from '@angular/material/input';
import { LogoComponent } from '@elementar-ui/components/logo';
import { NgIf, NgOptimizedImage } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../auth.service';
import { SharedModule } from '../../shared/shared.module';
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({
  selector: 'app-signin',
  standalone: true,
  imports: [
    RouterLink,
    MatButton,
    MatFormField,
    MatLabel,
    MatInput,
    MatSuffix,
    LogoComponent,
    NgOptimizedImage,
    ReactiveFormsModule,
    NgIf,
    SharedModule
  ],
  templateUrl: './signin.component.html',
  styleUrl: './signin.component.scss'
})
export class SigninComponent {
  loginForm: FormGroup;
  loading = false;
  errorMessage = '';

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private router: Router,
    private snackBar: MatSnackBar
  ) {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required]],
    });
  }

  onSubmit(): void {
    if (this.loginForm.invalid) {
      return;
    }

    this.loading = true;
    const { email, password } = this.loginForm.value;

    this.authService.login(email, password).subscribe({
      next: (response) => {
        const user = response?.data?.user;

        if (response?.success && response?.data?.token) {
          // Check role using role names after roles are fetched
          const allowedRoles = ['admin', 'manager']; // Admin and Manager role names
          const userRole = this.authService.getRoleName(user.role_id);
          
          if (!allowedRoles.includes(userRole)) {
            this.showError('Please use Salesman Mobile App. This panel is made for Admin and Manager only.');
            this.loading = false;
            return;
          }

          this.authService.setToken(response.data.token);
          this.authService.setCurrentUser(user);
          this.router.navigate(['/dashboard']);
        } else {
          this.showError(response?.message || 'Invalid response from server');
        }
      },
      error: (err) => {
        console.error('Login error:', err);
        const message =
          err?.error?.error?.message ||
          err?.error?.message ||
          err?.message ||
          'Login failed. Please try again.';
        this.showError(message);
      },
      complete: () => {
        this.loading = false;
      }
    });
  }

  private showError(message: string): void {
    this.loading = false;
    this.snackBar.open(message, 'Dismiss', {
      duration: 5000,
      panelClass: ['error-snackbar']
    });
  }

  private showSuccess(message: string): void {
    this.snackBar.open(message, 'Dismiss', {
      duration: 3000,
      panelClass: ['success-snackbar']
    });
  }

  get email() {
    return this.loginForm.get('email');
  }

  get password() {
    return this.loginForm.get('password');
  }
}