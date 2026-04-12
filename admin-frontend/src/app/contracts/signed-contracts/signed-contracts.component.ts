import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormGroup, FormBuilder } from '@angular/forms';
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
import { UsersService } from '../../users/users.service';
import { DomSanitizer, SafeHtml, SafeUrl } from '@angular/platform-browser';
import { finalize } from 'rxjs/operators';
import { downloadPdfFromHtml } from '../../shared/pdf-generator';

interface SignedContract {
  id: number;
  contract_template_id: number;
  visit_id: number;
  rendered_html: string;
  metadata: {
    signature: string;
    date_signed: string;
    deal_amount: string;
    company_name: string;
    product_name: string;
    customer_name: string;
    customer_email: string;
    payment_method: string;
    customer_address: string;
    cancellation_notice: string;
    signature_image_url: string;
    subscription_frequency: string;
  };
  signed_at: string;
  template: {
    id: number;
    title: string;
    content: string;
    status: string;
    created_at: string;
    updated_at: string;
  };
  visit: {
    visit_id: number;
    lead_id: number;
    rep_id: number;
    check_in_time: string;
    check_out_time: string;
    latitude: number;
    longitude: number;
    notes: string;
    photo_urls: string[];
    next_visit_date: string | null;
    action_required: string | null;
    is_active: boolean;
    created_by: string;
    updated_by: string | null;
    created_at: string;
    updated_at: string;
    rep: {
      user_id: number;
      full_name: string;
      first_name: string;
      last_name: string;
    };
    lead: {
      lead_id: number;
      name: string;
      contact_name: string;
      contact_email: string;
      contact_phone: string;
      status: string;
    };
  };
}

interface Manager {
  id: string;
  first_name: string;
  last_name: string;
}

interface Salesman {
  id: string;
  first_name: string;
  last_name: string;
}

@Component({
  selector: 'app-signed-contracts',
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
    MatPaginatorModule
  ],
  templateUrl: './signed-contracts.component.html',
  styleUrl: './signed-contracts.component.scss'
})
export class SignedContractsComponent implements OnInit {
  @ViewChild('viewContractDialog') viewContractDialog!: TemplateRef<any>;
  signedContracts: SignedContract[] = [];
  filteredContracts: SignedContract[] = [];
  managers: Manager[] = [];
  salesmen: Salesman[] = [];
  displayedColumns: string[] = ['title', 'customerName', 'dealAmount', 'salesmanName', 'signedAt', 'status', 'actions'];
  filterForm: FormGroup;
  isLoading = false;
  selectedContract: SignedContract | null = null;
  totalContracts = 0;
  pageSize = 10;
  pageIndex = 0;
  pdfUrl: SafeUrl | null = null;

  constructor(
    private fb: FormBuilder,
    private contractsService: ContractsService,
    private usersService: UsersService,
    private snackBar: MatSnackBar,
    private dialog: MatDialog,
    private sanitizer: DomSanitizer
  ) {
    this.filterForm = this.fb.group({
      managerId: ['all'],
      salesmanId: ['all'],
      status: ['all'],
      search: [''],
      sortBy: ['signed_at']
    });
  }

  ngOnInit() {
    this.loadManagers();
    this.loadSalesmen();
    this.loadContracts();
    this.filterForm.valueChanges.subscribe(() => this.applyFilters());
  }

  loadManagers() {
    this.isLoading = true;
    this.usersService.getManagers().pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        const managers = response?.data ?? [];
        this.managers = managers.map((member: any) => ({
          id: String(member.user_id),
          first_name: member.full_name ? member.full_name.split(' ')[0] : 'N/A',
          last_name: member.full_name ? member.full_name.split(' ').slice(1).join(' ') || '' : ''
        }));
      },
      error: () => {
        this.snackBar.open('Error loading managers', 'Close', { duration: 3000 });
      }
    });
  }

  loadSalesmen() {
    this.isLoading = true;
    this.usersService.getSalesmen().pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        const salesmen = response?.data ?? [];
        this.salesmen = salesmen.map((member: any) => ({
          id: String(member.user_id),
          first_name: member.first_name || (member.full_name ? member.full_name.split(' ')[0] : 'N/A'),
          last_name: member.last_name || (member.full_name ? member.full_name.split(' ').slice(1).join(' ') || '' : '')
        }));
      },
      error: () => {
        this.snackBar.open('Error loading salesmen', 'Close', { duration: 3000 });
      }
    });
  }

  loadContracts(page: number = 0, size: number = 10, sortBy: string = 'signed_at') {
    this.isLoading = true;
    const { managerId, salesmanId, status, search } = this.filterForm.value;
    const params: any = { page: page + 1, limit: size, sortBy };
    if (managerId !== 'all') params.managerId = managerId;
    if (salesmanId !== 'all') params.salesmanId = salesmanId;
    if (status !== 'all') params.status = status;
    if (search) params.search = search;

    this.contractsService.getSignedContracts(params).subscribe({
      next: (response: any) => {
        this.isLoading = false
        this.signedContracts = (response?.data?.contracts ?? []).map((contract: any) => ({
          ...contract,
          visit: {
            ...contract.visit,
            rep_id: String(contract.visit.rep_id),
            rep: {
              ...contract.visit.rep,
              user_id: String(contract.visit.rep.user_id)
            }
          }
        }));
        this.totalContracts = response?.data?.pagination?.total || this.signedContracts.length;
        this.applyFilters();
      },
      error: () => {
        this.snackBar.open('Error loading signed contracts', 'Close', { duration: 3000 });
        this.applyFilters();
      }
    });
  }

  applyFilters() {
    let filtered = [...this.signedContracts];
    const { managerId, salesmanId, status, search, sortBy } = this.filterForm.value;

    if (managerId !== 'all') {
      filtered = filtered.filter(contract => contract.visit.created_by.trim() === managerId);
    }
    if (salesmanId !== 'all') {
      filtered = filtered.filter(contract => contract.visit.rep_id === salesmanId);
    }
    if (status !== 'all') {
      filtered = filtered.filter(contract => contract.template.status === status);
    }
    if (search) {
      filtered = filtered.filter(contract => contract.template.title.toLowerCase().includes(search.toLowerCase()));
    }

    filtered.sort((a, b) => {
      if (sortBy === 'signed_at') {
        return new Date(b.signed_at).getTime() - new Date(a.signed_at).getTime();
      }
      if (sortBy === 'title') {
        return a.template.title.localeCompare(b.template.title);
      }
      if (sortBy === 'deal_amount') {
        const aAmount = parseFloat(a.metadata.deal_amount.replace(/[^0-9.-]+/g, '')) || 0;
        const bAmount = parseFloat(b.metadata.deal_amount.replace(/[^0-9.-]+/g, '')) || 0;
        return bAmount - aAmount;
      }
      return 0;
    });

    this.filteredContracts = filtered.slice(this.pageIndex * this.pageSize, (this.pageIndex + 1) * this.pageSize);
  }

  sanitizeHtml(content: string): SafeHtml {
    return this.sanitizer.bypassSecurityTrustHtml(content);
  }

  getSalesmanName(repId: string): string {
    if (!this.salesmen.length) return 'Loading salesmen...';
    const salesman = this.salesmen.find(s => s.id === repId);
    return salesman ? `${salesman.first_name} ${salesman.last_name}`.trim() : 'Unknown';
  }

  getManagerName(createdBy: string): string {
    if (!this.managers.length) return 'Loading managers...';
    const manager = this.managers.find(m => m.id === createdBy.trim());
    return manager ? `${manager.first_name} ${manager.last_name}`.trim() : 'Unknown';
  }

  viewContract(contract: SignedContract) {
    this.isLoading = true;
    this.contractsService.getContractHtml(contract.id).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (html: string) => {
        const newWindow = window.open('', '_blank');
        if (newWindow) {
          newWindow.document.write(html);
          newWindow.document.close();
        } else {
          this.snackBar.open('Pop-up blocked. Please allow pop-ups.', 'Close', { duration: 3000 });
        }
      },
      error: () => {
        this.snackBar.open('Error loading contract', 'Close', { duration: 3000 });
      }
    });
  }

  async downloadContract(contract: SignedContract) {
    this.isLoading = true;
    this.contractsService.getContractHtml(contract.id).subscribe({
      next: async (html: string) => {
        try {
          const title = (contract.metadata as any)?.title || contract.contract_template_id || 'contract';
          await downloadPdfFromHtml(html, `contract_${title}_${contract.id}.pdf`);
          this.snackBar.open('PDF download started', 'Close', { duration: 2000 });
        } catch (err) {
          console.error('PDF generation error:', err);
          this.snackBar.open('Error generating PDF', 'Close', { duration: 3000 });
        } finally {
          this.isLoading = false;
        }
      },
      error: () => {
        this.isLoading = false;
        this.snackBar.open('Error loading contract', 'Close', { duration: 3000 });
      }
    });
  }

  onPageChange(event: PageEvent) {
    this.pageIndex = event.pageIndex;
    this.pageSize = event.pageSize;
    this.loadContracts(this.pageIndex, this.pageSize, this.filterForm.value.sortBy);
  }
}