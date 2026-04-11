import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormGroup, FormBuilder, Validators } from '@angular/forms';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { UsersService } from '../users.service';
import { PartnerService } from '../../partner/partner.service';
import { finalize } from 'rxjs/operators';
import { SharedModule } from '../../shared/shared.module';

@Component({
  selector: 'app-user-add',
  imports: [SharedModule, MatProgressBarModule, CommonModule],
  templateUrl: './user-add.component.html',
  styleUrl: './user-add.component.scss'
})
export class UserAddComponent implements OnInit {
  userForm: FormGroup;
  roles: { id: number; label: string; name: string }[] = [];
  partners: { id: number; name: string }[] = [];
  territories: any[] = [
    { id: 'territory1', name: 'Imatra' },
    { id: 'territory2', name: 'Hamina' },
    { id: 'territory3', name: 'Lappeenranta' }
  ];
  isSubmitting = false;
  selectedRoleName = '';

  constructor(
    private fb: FormBuilder,
    private usersService: UsersService,
    private partnerService: PartnerService,
    private snackBar: MatSnackBar
  ) {
    this.userForm = this.fb.group({
      first_name: ['', [Validators.required, Validators.minLength(2)]],
      last_name: ['', [Validators.required, Validators.minLength(2)]],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.required, Validators.pattern(/^[0-9]{10,15}$/)]],
      role_id: [null, Validators.required],
      partner_id: [null],
      territory: ['']
    });
  }

  ngOnInit() {
    this.getRoles();
    this.loadPartners();
    // Dynamically update field validation based on role
    this.userForm.get('role_id')?.valueChanges.subscribe(roleId => {
      const role = this.roles.find(r => r.id === +roleId);
      this.selectedRoleName = role?.name || '';

      const territoryControl = this.userForm.get('territory');
      const partnerControl = this.userForm.get('partner_id');

      if (this.selectedRoleName === 'manager' || this.selectedRoleName === 'sales_rep') {
        territoryControl?.setValidators([Validators.required]);
      } else {
        territoryControl?.clearValidators();
      }
      territoryControl?.updateValueAndValidity();

      if (this.selectedRoleName === 'partner') {
        partnerControl?.setValidators([Validators.required]);
      } else {
        partnerControl?.clearValidators();
        partnerControl?.setValue(null);
      }
      partnerControl?.updateValueAndValidity();
    });
  }

  getRoles() {
    this.usersService.getRoles().subscribe({
      next: (response: any) => {
        if (response.success && response.data) {
          this.roles = response.data.map((role: any) => ({
            id: role.role_id,
            name: role.role_name,
            label: this.formatRoleLabel(role.role_name)
          }));
        }
      },
      error: (err) => {
        this.snackBar.open('Error fetching roles: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  loadPartners() {
    this.partnerService.getAllPartners({ limit: 100 }).subscribe({
      next: (response: any) => {
        if (response.success && response.data) {
          this.partners = response.data.map((p: any) => ({
            id: p.partner_id,
            name: p.company_name
          }));
        }
      },
      error: () => {}
    });
  }

  private formatRoleLabel(roleName: string): string {
    return roleName
      .split('_')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
      .join(' ');
  }

  onSubmit() {
    if (this.userForm.invalid) {
      this.userForm.markAllAsTouched();
      return;
    }

    this.isSubmitting = true;
    const payload: any = {
      email: this.userForm.value.email,
      first_name: this.userForm.value.first_name,
      last_name: this.userForm.value.last_name,
      territory: this.userForm.value.territory || null,
      phone: this.userForm.value.phone,
      role_id: +this.userForm.value.role_id
    };

    if (this.selectedRoleName === 'partner' && this.userForm.value.partner_id) {
      payload.partner_id = +this.userForm.value.partner_id;
    }

    this.usersService.createUser(payload).pipe(
      finalize(() => this.isSubmitting = false)
    ).subscribe({
      next: () => {
        this.snackBar.open('User created successfully!', 'Close', { duration: 3000 });
        this.userForm.reset();
        this.userForm.markAsUntouched();
      },
      error: (err: any) => {
        console.log(err);
        if (err.status === 409) {
          this.snackBar.open('Email already exists.', 'Close', { duration: 3000 });
        } else {
          this.snackBar.open('Error creating user: ' + err.error.error.message, 'Close', { duration: 3000 });
        }
      }
    });
  }

  getErrorMessage(controlName: string): string {
    const control = this.userForm.get(controlName);
    if (control?.hasError('required')) {
      return `${controlName.replace('_', ' ')} is required`;
    }
    if (controlName === 'email' && control?.hasError('email')) {
      return 'Invalid email format';
    }
    if ((controlName === 'first_name' || controlName === 'last_name') && control?.hasError('minlength')) {
      return `${controlName.replace('_', ' ')} must be at least 2 characters`;
    }
    if (controlName === 'phone' && control?.hasError('pattern')) {
      return 'Phone number must be 10–15 digits';
    }
    return '';
  }
}
