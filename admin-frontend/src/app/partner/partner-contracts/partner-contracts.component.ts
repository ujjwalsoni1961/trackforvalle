import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatIcon } from '@angular/material/icon';
import { MatProgressBar } from '@angular/material/progress-bar';
import { MatButton, MatIconButton } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { PartnerService } from '../partner.service';
import { environment } from '../../../environments/environment';
import { downloadPdfFromHtml } from '../../shared/pdf-generator';

@Component({
  selector: 'app-partner-contracts',
  standalone: true,
  imports: [CommonModule, FormsModule, MatIcon, MatProgressBar, MatButton, MatIconButton, MatFormFieldModule, MatInputModule, MatSnackBarModule, MatDialogModule, MatTooltipModule],
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

  // View dialog
  @ViewChild('viewContractDialog') viewContractDialog!: TemplateRef<any>;
  selectedContract: any = null;
  contractHtml: string = '';
  loadingHtml = false;

  private baseUrl = environment.baseUri;

  constructor(
    private partnerService: PartnerService,
    private snackBar: MatSnackBar,
    private dialog: MatDialog
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

  viewSignedContract(contract: any): void {
    this.selectedContract = contract;
    this.contractHtml = '';
    this.loadingHtml = true;
    this.dialog.open(this.viewContractDialog, { width: '900px', maxHeight: '80vh' });

    // Fetch the styled HTML from the backend
    this.partnerService.getContractHtml(contract.id).subscribe({
      next: (html: string) => {
        this.contractHtml = html;
        this.loadingHtml = false;
      },
      error: () => {
        // Fall back to rendered_html if available
        this.contractHtml = contract.rendered_html || '<p>Unable to load contract content.</p>';
        this.loadingHtml = false;
      }
    });
  }

  async downloadSignedContract(contract: any): Promise<void> {
    try {
      this.loadingHtml = true;
      // Fetch the HTML from the backend
      this.partnerService.getContractHtml(contract.id).subscribe({
        next: async (html: string) => {
          try {
            const title = contract.template?.title || contract.contract_template_id || 'contract';
            await downloadPdfFromHtml(html, `contract_${title}_${contract.id}.pdf`);
            this.snackBar.open('PDF download started', 'Close', { duration: 2000 });
          } catch (err) {
            console.error('PDF generation error:', err);
            this.snackBar.open('Error generating PDF', 'Close', { duration: 3000 });
          } finally {
            this.loadingHtml = false;
          }
        },
        error: () => {
          this.loadingHtml = false;
          this.snackBar.open('Error loading contract', 'Close', { duration: 3000 });
        }
      });
    } catch (err) {
      this.loadingHtml = false;
      this.snackBar.open('Error downloading PDF', 'Close', { duration: 3000 });
    }
  }

  getLeadName(contract: any): string {
    return contract.visit?.lead?.name || contract.visit?.lead?.contact_name || 'N/A';
  }

  getSalesRepName(contract: any): string {
    if (contract.visit?.rep) {
      return contract.visit.rep.full_name || `${contract.visit.rep.first_name || ''} ${contract.visit.rep.last_name || ''}`.trim() || 'N/A';
    }
    return 'N/A';
  }
}
