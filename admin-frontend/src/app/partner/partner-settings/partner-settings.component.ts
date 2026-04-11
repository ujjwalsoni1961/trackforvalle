import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormGroup, FormBuilder } from '@angular/forms';
import { MatFormField, MatLabel } from '@angular/material/form-field';
import { MatInput } from '@angular/material/input';
import { MatButton } from '@angular/material/button';
import { MatProgressBar } from '@angular/material/progress-bar';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { PartnerService } from '../partner.service';

@Component({
  selector: 'app-partner-settings',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    MatFormField,
    MatLabel,
    MatInput,
    MatButton,
    MatProgressBar,
    MatSnackBarModule
  ],
  templateUrl: './partner-settings.component.html',
  styleUrl: './partner-settings.component.scss'
})
export class PartnerSettingsComponent implements OnInit {
  profileForm: FormGroup;
  loading = true;
  saving = false;

  constructor(
    private fb: FormBuilder,
    private partnerService: PartnerService,
    private snackBar: MatSnackBar
  ) {
    this.profileForm = this.fb.group({
      company_name: [''],
      description: [''],
      contact_email: [''],
      contact_phone: [''],
      website: [''],
      logo_url: ['']
    });
  }

  ngOnInit(): void {
    this.loadProfile();
  }

  loadProfile(): void {
    this.loading = true;
    this.partnerService.getProfile().subscribe({
      next: (response: any) => {
        if (response.success && response.data) {
          this.profileForm.patchValue({
            company_name: response.data.company_name || '',
            description: response.data.description || '',
            contact_email: response.data.contact_email || '',
            contact_phone: response.data.contact_phone || '',
            website: response.data.website || '',
            logo_url: response.data.logo_url || ''
          });
        }
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      }
    });
  }

  onSave(): void {
    this.saving = true;
    this.partnerService.updateProfile(this.profileForm.value).subscribe({
      next: (response: any) => {
        this.saving = false;
        if (response.success) {
          this.snackBar.open('Profile updated successfully', 'Close', { duration: 3000 });
        } else {
          this.snackBar.open(response.message || 'Error updating profile', 'Close', { duration: 3000 });
        }
      },
      error: (err: any) => {
        this.saving = false;
        this.snackBar.open('Error updating profile', 'Close', { duration: 3000 });
      }
    });
  }
}
