import { Component, OnInit, OnDestroy, ViewChild, TemplateRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormGroup, FormBuilder, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatPaginator, MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { ContractsService } from '../contracts.service';
import { Router } from '@angular/router';
import { finalize } from 'rxjs/operators';
import { UsersService } from '../../users/users.service';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { AuthService } from '../../auth/auth.service';
import { MatChipsModule } from '@angular/material/chips';
interface DropdownOption {
  label: string;
  value: string;
}

interface DropdownField {
  label: string;
  options: DropdownOption[];
  required: boolean;
  placeholder: string;
}

interface Contract {
  id: number;
  title: string;
  content: string;
  assigned_sales_rep_ids: string[];
  assigned_sales_reps: Array<{
    user_id: number;
    full_name: string;
    first_name: string;
    last_name: string;
    email: string;
  }>;
  signed_count: number;
  status: 'draft' | 'active' | 'published' | 'archived';
  created_by: string;
  created_at: string;
  updated_at: string;
  dropdown_fields?: { [key: string]: DropdownField };
  partner_id?: number;
  partner?: { partner_id: number; company_name: string } | null;
  docuseal_template_id?: number | null;
}

interface SalesRep {
  id: string;
  first_name: string;
  last_name: string;
}

@Component({
  selector: 'app-contracts',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatTableModule,
    MatIconModule,
    MatProgressBarModule,
    MatSnackBarModule,
    MatDialogModule,
    MatTooltipModule,
    MatPaginatorModule,
    MatChipsModule
  ],
  templateUrl: './contracts.component.html',
  styleUrl: './contracts.component.scss'
})
export class ContractsComponent implements OnInit {
  @ViewChild('viewContractDialog') viewContractDialog!: TemplateRef<any>;
  @ViewChild('reassignContractDialog') reassignContractDialog!: TemplateRef<any>;
  contracts: Contract[] = [];
  filteredContracts: Contract[] = [];
  salesReps: SalesRep[] = [];
  // DocuSeal popup state
  private docuSealPopup: Window | null = null;
  private popupCheckInterval: any = null;
  builderContractId: number | null = null;
  docusealBaseUrl = 'https://docuseal-585556848696.europe-west1.run.app';
  displayedColumns: string[] = ['title', 'partnerCompany', 'docusealId', 'salesRepNames', 'status', 'createdAt', 'actions'];
  filterForm: FormGroup;
  contractForm: FormGroup;
  isLoading = false;
  selectedContract: Contract | null = null;
  totalContracts = 0;
  pageSize = 10;
  pageIndex = 0;
  currentUserRole: string = '';
  canCreateContracts = false;
  canEditAllContracts = false;

  constructor(
    private fb: FormBuilder,
    private contractsService: ContractsService,
    private usersService: UsersService,
    private snackBar: MatSnackBar,
    private dialog: MatDialog,
    private router: Router,
    private sanitizer: DomSanitizer,
    private authService: AuthService
  ) {
    this.filterForm = this.fb.group({
      salesRepId: ['all'],
      status: ['all'],
      search: [''],
      sortBy: ['signed_count']
    });
    this.contractForm = this.fb.group({
      assigned_sales_rep_ids: [[], Validators.required]
    });
  }

  ngOnInit() {
    // Set up role-based permissions
    const currentUser = this.authService.getCurrentUser();
    this.currentUserRole = currentUser?.role || '';

    // Managers and above can create and edit contracts
    this.canCreateContracts = this.authService.hasAnyRole(['manager', 'admin']);
    this.canEditAllContracts = this.authService.hasAnyRole(['admin']);

    this.loadSalesReps();
    this.loadContracts();
    this.filterForm.valueChanges.subscribe(() => this.applyFilters());
  }

  loadSalesReps() {
    this.isLoading = true;
    this.usersService.getSalesReps({ page: 1, limit: 500 }).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        const reps = response?.data ?? [];
        this.salesReps = reps.map((member: any) => ({
          id: String(member.user_id),
          first_name: member.full_name ? member.full_name.split(' ')[0] : 'N/A',
          last_name: member.full_name ? member.full_name.split(' ').slice(1).join(' ') || '' : ''
        }));
      },
      error: () => {
        this.snackBar.open('Error loading sales reps', 'Close', { duration: 3000 });
      }
    });
  }

  loadContracts(page: number = 0, size: number = 10, sortBy: string = 'signed_count') {
    this.isLoading = true;
    const { salesRepId, status, search } = this.filterForm.value;
    const params: any = { page: page + 1, limit: size, sortBy };
    if (salesRepId !== 'all') params.salesRepId = salesRepId;
    if (status !== 'all') params.status = status;
    if (search) params.search = search;

    this.contractsService.getContracts(params).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        this.contracts = (response?.data?.contracts ?? []).map((contract: any) => ({
          ...contract,
          assigned_sales_rep_ids: (contract.assigned_sales_rep_ids || []).map((id: any) => String(id)),
          assigned_sales_reps: contract.assigned_sales_reps || []
        }));
        this.totalContracts = response?.data?.pagination?.total || this.contracts.length;
        this.applyFilters();
      },
      error: () => {
        this.snackBar.open('Error loading contract templates', 'Close', { duration: 3000 });
        this.applyFilters();
      }
    });
  }

  applyFilters() {
    let filtered = [...this.contracts];
    const { salesRepId, status, search, sortBy } = this.filterForm.value;

    if (salesRepId !== 'all') {
      filtered = filtered.filter(contract => contract.assigned_sales_rep_ids.includes(salesRepId));
    }
    if (status !== 'all') {
      filtered = filtered.filter(contract => contract.status === status);
    }
    if (search) {
      filtered = filtered.filter(contract => contract.title.toLowerCase().includes(search.toLowerCase()));
    }

    filtered.sort((a, b) => {
      if (sortBy === 'signed_count') return b.signed_count - a.signed_count;
      if (sortBy === 'created_at') return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
      if (sortBy === 'title') return a.title.localeCompare(b.title);
      return 0;
    });

    this.filteredContracts = filtered.slice(this.pageIndex * this.pageSize, (this.pageIndex + 1) * this.pageSize);
  }

  sanitizeHtml(content: string): SafeHtml {
    return this.sanitizer.bypassSecurityTrustHtml(content);
  }

  getSalesRepNames(contract: Contract): string {
    if (contract.assigned_sales_reps && contract.assigned_sales_reps.length > 0) {
      return contract.assigned_sales_reps
        .map(rep => rep.full_name || `${rep.first_name} ${rep.last_name}`.trim())
        .join(', ');
    }
    return 'No sales reps assigned';
  }

  getPartnerName(contract: Contract): string {
    if (contract.partner && contract.partner.company_name) {
      return contract.partner.company_name;
    }
    return '-';
  }

  navigateToAddContract() {
    this.router.navigate(['contracts/add']);
  }

  publishContract(contract: Contract) {
    this.isLoading = true;
    this.contractsService.updateContract(contract.id, { status: 'published' } as any).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: () => {
        this.snackBar.open('Contract published successfully', 'Close', { duration: 3000 });
        this.loadContracts();
      },
      error: () => {
        this.snackBar.open('Error publishing contract', 'Close', { duration: 3000 });
      }
    });
  }

  viewContract(contract: Contract) {
    this.selectedContract = contract;
    this.dialog.open(this.viewContractDialog, { width: '800px' });
  }

  downloadContract(contract: Contract) {
    this.isLoading = true;
    this.contractsService.exportContract(contract.id).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (blob: Blob) => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `${contract.title}.pdf`;
        a.click();
        window.URL.revokeObjectURL(url);
      },
      error: () => {
        this.snackBar.open('Error downloading contract', 'Close', { duration: 3000 });
      }
    });
  }

  openReassignContractDialog(contract: Contract) {
    this.selectedContract = contract;
    this.contractForm.patchValue({ assigned_sales_rep_ids: contract.assigned_sales_rep_ids });
    this.dialog.open(this.reassignContractDialog, { width: '400px' });
  }

  reassignContract() {
    if (!this.selectedContract || !this.contractForm.get('assigned_sales_rep_ids')?.valid) {
      this.snackBar.open('Please select at least one sales rep', 'Close', { duration: 3000 });
      return;
    }

    this.isLoading = true;
    const updatedContract = {
      assigned_sales_rep_ids: this.contractForm.get('assigned_sales_rep_ids')?.value
    };
    this.contractsService.reassignContract(this.selectedContract.id, updatedContract).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        this.snackBar.open('Contract reassigned successfully', 'Close', { duration: 3000 });
        this.contractForm.markAsUntouched();
        this.dialog.closeAll();
        this.loadContracts();
      },
      error: () => {
        this.snackBar.open('Error reassigning contract', 'Close', { duration: 3000 });
      }
    });
  }

  deleteContract(contract: Contract) {
    if (!confirm(`Are you sure you want to delete "${contract.title}"? This action cannot be undone.`)) return;

    this.isLoading = true;
    this.contractsService.deleteContract(contract.id).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response) => {
        this.snackBar.open('Contract deleted successfully', 'Close', { duration: 3000 });
        this.loadContracts();
      },
      error: (err) => {
        const errorMessage = err.error?.message || 'Error deleting contract';
        this.snackBar.open(errorMessage, 'Close', { duration: 3000 });
      }
    });
  }

  onPageChange(event: PageEvent) {
    this.pageIndex = event.pageIndex;
    this.pageSize = event.pageSize;
    this.loadContracts(this.pageIndex, this.pageSize, this.filterForm.value.sortBy);
  }

  canEditContract(contract: Contract): boolean {
    if (this.canEditAllContracts) {
      return true;
    }
    if (this.currentUserRole === 'manager') {
      const currentUser = this.authService.getCurrentUser();
      if (currentUser?.user_id) {
        return contract.assigned_sales_rep_ids?.includes(String(currentUser.user_id));
      }
    }
    return false;
  }

  canDeleteContract(contract: Contract): boolean {
    return this.canEditAllContracts;
  }

  openBuilderForNew() {
    this.builderContractId = null;
    const url = `${this.docusealBaseUrl}/templates/new`;
    this.openDocuSealPopup(url);
  }

  openBuilderForContract(contract: Contract) {
    this.builderContractId = contract.id;
    if (contract.docuseal_template_id) {
      const url = `${this.docusealBaseUrl}/templates/${contract.docuseal_template_id}/edit`;
      this.openDocuSealPopup(url);
    } else {
      const url = `${this.docusealBaseUrl}/templates/new`;
      this.openDocuSealPopup(url);
    }
  }

  private openDocuSealPopup(url: string) {
    const width = 1200;
    const height = 800;
    const left = (screen.width - width) / 2;
    const top = (screen.height - height) / 2;
    this.docuSealPopup = window.open(
      url,
      'DocuSealBuilder',
      `width=${width},height=${height},left=${left},top=${top},resizable=yes,scrollbars=yes`
    );

    // Poll for popup close, then refresh templates list
    this.clearPopupCheck();
    this.popupCheckInterval = setInterval(() => {
      if (this.docuSealPopup && this.docuSealPopup.closed) {
        this.clearPopupCheck();
        this.onDocuSealPopupClosed();
      }
    }, 500);
  }

  private clearPopupCheck() {
    if (this.popupCheckInterval) {
      clearInterval(this.popupCheckInterval);
      this.popupCheckInterval = null;
    }
  }

  private onDocuSealPopupClosed() {
    // Fetch latest DocuSeal templates and auto-link if needed
    this.contractsService.getDocuSealTemplates().subscribe({
      next: (response: any) => {
        const templates = response?.data?.data || [];
        if (templates.length > 0 && this.builderContractId) {
          // Find the most recently created/updated template
          const latest = templates.sort((a: any, b: any) =>
            new Date(b.updated_at || b.created_at).getTime() - new Date(a.updated_at || a.created_at).getTime()
          )[0];
          // Auto-link it to the contract
          this.linkDocuSealTemplate(this.builderContractId, latest.id);
        } else if (templates.length > 0) {
          this.snackBar.open(
            `DocuSeal template(s) available. Use the edit icon on a contract to link one.`,
            'Close',
            { duration: 5000 }
          );
        }
        this.loadContracts();
      },
      error: () => {
        this.loadContracts();
      }
    });
    this.builderContractId = null;
  }

  linkDocuSealTemplate(contractId: number, templateId: number) {
    this.contractsService.updateContract(contractId, {
      docuseal_template_id: templateId
    } as any).subscribe({
      next: () => {
        this.snackBar.open(`DocuSeal template #${templateId} linked successfully`, 'Close', { duration: 3000 });
        this.loadContracts();
      },
      error: () => {
        this.snackBar.open('Error linking DocuSeal template', 'Close', { duration: 3000 });
      }
    });
  }

  ngOnDestroy() {
    this.clearPopupCheck();
  }
}
