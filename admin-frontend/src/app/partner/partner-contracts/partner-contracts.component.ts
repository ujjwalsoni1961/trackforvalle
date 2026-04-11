import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatIcon } from '@angular/material/icon';
import { MatProgressBar } from '@angular/material/progress-bar';
import { MatButton } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { PartnerService } from '../partner.service';

@Component({
  selector: 'app-partner-contracts',
  standalone: true,
  imports: [CommonModule, FormsModule, MatIcon, MatProgressBar, MatButton, MatFormFieldModule, MatInputModule, MatSnackBarModule],
  templateUrl: './partner-contracts.component.html',
  styleUrl: './partner-contracts.component.scss'
})
export class PartnerContractsComponent implements OnInit {
  // Templates
  contracts: any[] = [];
  loading = true;
  currentPage = 1;
  totalPages = 1;
  totalItems = 0;

  // Signed contracts
  signedContracts: any[] = [];
  signedLoading = false;
  signedCurrentPage = 1;
  signedTotalPages = 1;
  signedTotalItems = 0;

  // Create form
  showCreateForm = false;
  creating = false;
  newTemplate = { title: '', content: '' };

  constructor(
    private partnerService: PartnerService,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    this.loadContracts();
    this.loadSignedContracts();
  }

  loadContracts(): void {
    this.loading = true;
    this.partnerService.getContracts({ page: this.currentPage, limit: 10 }).subscribe({
      next: (response: any) => {
        if (response.success && response.data) {
          this.contracts = response.data;
          if (response.pagination) {
            this.totalPages = response.pagination.totalPages;
            this.totalItems = response.pagination.totalItems;
          }
        }
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      }
    });
  }

  loadSignedContracts(): void {
    this.signedLoading = true;
    this.partnerService.getSignedContracts({ page: this.signedCurrentPage, limit: 10 }).subscribe({
      next: (response: any) => {
        if (response.success && response.data) {
          this.signedContracts = response.data;
          if (response.pagination) {
            this.signedTotalPages = response.pagination.totalPages;
            this.signedTotalItems = response.pagination.totalItems;
          }
        }
        this.signedLoading = false;
      },
      error: () => {
        this.signedLoading = false;
      }
    });
  }

  nextPage(): void {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
      this.loadContracts();
    }
  }

  prevPage(): void {
    if (this.currentPage > 1) {
      this.currentPage--;
      this.loadContracts();
    }
  }

  signedNextPage(): void {
    if (this.signedCurrentPage < this.signedTotalPages) {
      this.signedCurrentPage++;
      this.loadSignedContracts();
    }
  }

  signedPrevPage(): void {
    if (this.signedCurrentPage > 1) {
      this.signedCurrentPage--;
      this.loadSignedContracts();
    }
  }

  toggleCreateForm(): void {
    this.showCreateForm = !this.showCreateForm;
    if (!this.showCreateForm) {
      this.newTemplate = { title: '', content: '' };
    }
  }

  submitTemplate(): void {
    if (!this.newTemplate.title.trim() || !this.newTemplate.content.trim()) {
      this.snackBar.open('Title and content are required', 'Close', { duration: 3000 });
      return;
    }

    this.creating = true;
    this.partnerService.createContractTemplate(this.newTemplate).subscribe({
      next: (response: any) => {
        if (response.success) {
          this.snackBar.open('Contract template created successfully', 'Close', { duration: 3000 });
          this.showCreateForm = false;
          this.newTemplate = { title: '', content: '' };
          this.loadContracts();
        }
        this.creating = false;
      },
      error: () => {
        this.snackBar.open('Error creating contract template', 'Close', { duration: 3000 });
        this.creating = false;
      }
    });
  }
}
