import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormGroup, FormBuilder, Validators } from '@angular/forms';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatAutocompleteModule, MatAutocompleteSelectedEvent } from '@angular/material/autocomplete';
import { UsersService } from '../users.service';
import { PartnerService } from '../../partner/partner.service';
import { TerritoryService } from '../../territories/territory.service';
import { finalize } from 'rxjs/operators';
import { SharedModule } from '../../shared/shared.module';

@Component({
  selector: 'app-user-add',
  imports: [SharedModule, MatProgressBarModule, MatAutocompleteModule, CommonModule],
  templateUrl: './user-add.component.html',
  styleUrl: './user-add.component.scss'
})
export class UserAddComponent implements OnInit {
  userForm: FormGroup;
  roles: { id: number; label: string; name: string }[] = [];
  partners: { id: number; name: string }[] = [];
  filteredPartners: { id: number; name: string }[] = [];
  territories: any[] = [];
  isLoadingTerritories = false;
  isSubmitting = false;
  selectedRoleName = '';
  selectedPartner: { id: number | null; name: string } | null = null;
  partnerSearchText = '';
  showCreateNew = false;

  constructor(
    private fb: FormBuilder,
    private usersService: UsersService,
    private partnerService: PartnerService,
    private territoryService: TerritoryService,
    private snackBar: MatSnackBar
  ) {
    this.userForm = this.fb.group({
      first_name: ['', [Validators.required, Validators.minLength(2)]],
      last_name: ['', [Validators.required, Validators.minLength(2)]],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.required, Validators.pattern(/^[0-9]{10,15}$/)]],
      role_id: [null, Validators.required],
      partner_company_name: [''],
      territory: ['']
    });
  }

  ngOnInit() {
    this.getRoles();
    this.loadPartners();
    this.loadTerritories();

    // Watch role changes
    this.userForm.get('role_id')?.valueChanges.subscribe(roleId => {
      const role = this.roles.find(r => r.id === +roleId);
      this.selectedRoleName = role?.name || '';

      const territoryControl = this.userForm.get('territory');
      const partnerControl = this.userForm.get('partner_company_name');

      // Territory is always optional - no required validator
      territoryControl?.clearValidators();
      territoryControl?.updateValueAndValidity();

      if (this.selectedRoleName === 'partner') {
        partnerControl?.setValidators([Validators.required]);
      } else {
        partnerControl?.clearValidators();
        partnerControl?.setValue('');
        this.selectedPartner = null;
      }
      partnerControl?.updateValueAndValidity();
    });

    // Watch partner company name input for filtering
    this.userForm.get('partner_company_name')?.valueChanges.subscribe(value => {
      if (typeof value === 'string') {
        this.partnerSearchText = value;
        this.filterPartners(value);
        // If user clears the field or types something new, deselect
        if (this.selectedPartner && this.selectedPartner.name !== value) {
          this.selectedPartner = null;
        }
      }
    });
  }

  filterPartners(search: string) {
    if (!search || search.length === 0) {
      this.filteredPartners = [...this.partners];
      this.showCreateNew = false;
      return;
    }
    const lower = search.toLowerCase();
    this.filteredPartners = this.partners.filter(p =>
      p.name.toLowerCase().includes(lower)
    );
    // Show "Create new" option if no exact match
    this.showCreateNew = !this.partners.some(p =>
      p.name.toLowerCase() === lower
    );
  }

  onPartnerSelected(event: MatAutocompleteSelectedEvent) {
    const selected = event.option.value;
    this.selectedPartner = selected;
    this.partnerSearchText = selected.name;
  }

  displayPartner(partner: any): string {
    return partner?.name || partner || '';
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
          this.filteredPartners = [...this.partners];
        }
      },
      error: () => {}
    });
  }

  loadTerritories() {
    this.isLoadingTerritories = true;
    this.territoryService.getTerritories({ limit: 500 }).subscribe({
      next: (response: any) => {
        this.isLoadingTerritories = false;
        if (response.data) {
          this.territories = response.data.map((t: any) => ({
            id: t.territory_id,
            name: t.name
          }));
        }
      },
      error: () => {
        this.isLoadingTerritories = false;
        this.snackBar.open('Error loading territories', 'Close', { duration: 3000 });
      }
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

    if (this.selectedRoleName === 'partner') {
      if (this.selectedPartner && this.selectedPartner.id) {
        // Existing partner selected
        payload.partner_id = this.selectedPartner.id;
      } else {
        // New partner company — backend will create it
        payload.partner_company_name = this.partnerSearchText.trim();
      }
    }

    this.usersService.createUser(payload).pipe(
      finalize(() => this.isSubmitting = false)
    ).subscribe({
      next: () => {
        this.snackBar.open('User created successfully!', 'Close', { duration: 3000 });
        this.userForm.reset();
        this.userForm.markAsUntouched();
        this.selectedPartner = null;
        this.partnerSearchText = '';
        // Reload partners in case a new one was created
        this.loadPartners();
      },
      error: (err: any) => {
        console.log(err);
        if (err.status === 409) {
          this.snackBar.open('Email already exists.', 'Close', { duration: 3000 });
        } else {
          const msg = err.error?.error?.message || err.message || 'Unknown error';
          this.snackBar.open('Error creating user: ' + msg, 'Close', { duration: 3000 });
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
