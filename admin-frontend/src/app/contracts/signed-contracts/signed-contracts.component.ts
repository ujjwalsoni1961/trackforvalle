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

interface SignedContract {
  id: number;
  contract_template_id: number;
  visit_id: number | null;
  lead_id: number | null;
  rendered_html: string;
  metadata: any;
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
    rep_id: string;
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
      user_id: string;
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
  } | null;
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
        this.isLoading = false;
        this.signedContracts = (response?.data?.contracts ?? []).map((contract: any) => {
          // Safely handle contracts without a visit (e.g. signed via custom signing flow)
          const visit = contract.visit;
          return {
            ...contract,
            visit: visit ? {
              ...visit,
              rep_id: String(visit.rep_id || ''),
              rep: visit.rep ? {
                ...visit.rep,
                user_id: String(visit.rep.user_id || '')
              } : { user_id: '', full_name: 'N/A', first_name: 'N/A', last_name: '' },
              lead: visit.lead || { lead_id: 0, name: 'N/A', contact_name: '', contact_email: '', contact_phone: '', status: '' }
            } : null
          };
        });
        this.totalContracts = response?.data?.pagination?.total || this.signedContracts.length;
        this.applyFilters();
      },
      error: () => {
        this.isLoading = false;
        this.snackBar.open('Error loading signed contracts', 'Close', { duration: 3000 });
        this.applyFilters();
      }
    });
  }

  applyFilters() {
    let filtered = [...this.signedContracts];
    const { managerId, salesmanId, status, search, sortBy } = this.filterForm.value;

    if (managerId !== 'all') {
      filtered = filtered.filter(contract => contract.visit?.created_by?.trim() === managerId);
    }
    if (salesmanId !== 'all') {
      filtered = filtered.filter(contract => contract.visit?.rep_id === salesmanId);
    }
    if (status !== 'all') {
      filtered = filtered.filter(contract => contract.template?.status === status);
    }
    if (search) {
      filtered = filtered.filter(contract => contract.template?.title?.toLowerCase().includes(search.toLowerCase()));
    }

    filtered.sort((a, b) => {
      if (sortBy === 'signed_at') {
        return new Date(b.signed_at).getTime() - new Date(a.signed_at).getTime();
      }
      if (sortBy === 'title') {
        return (a.template?.title || '').localeCompare(b.template?.title || '');
      }
      if (sortBy === 'deal_amount') {
        const aAmount = parseFloat(String(a.metadata?.deal_amount || '0').replace(/[^0-9.-]+/g, '')) || 0;
        const bAmount = parseFloat(String(b.metadata?.deal_amount || '0').replace(/[^0-9.-]+/g, '')) || 0;
        return bAmount - aAmount;
      }
      return 0;
    });

    this.filteredContracts = filtered.slice(this.pageIndex * this.pageSize, (this.pageIndex + 1) * this.pageSize);
  }

  sanitizeHtml(content: string): SafeHtml {
    return this.sanitizer.bypassSecurityTrustHtml(content);
  }

  getSalesmanName(contract: SignedContract): string {
    if (!contract.visit?.rep) return 'N/A';
    const repId = contract.visit.rep.user_id;
    if (!this.salesmen.length) return 'Loading...';
    const salesman = this.salesmen.find(s => s.id === repId);
    return salesman ? `${salesman.first_name} ${salesman.last_name}`.trim() : (contract.visit.rep.full_name || 'Unknown');
  }

  getCustomerName(contract: SignedContract): string {
    // Try metadata first
    if (contract.metadata?.customer_name) return contract.metadata.customer_name;
    // Then visit.lead
    if (contract.visit?.lead?.contact_name) return contract.visit.lead.contact_name;
    if (contract.visit?.lead?.name) return contract.visit.lead.name;
    return 'N/A';
  }

  getManagerName(createdBy: string): string {
    if (!this.managers.length) return 'Loading managers...';
    const manager = this.managers.find(m => m.id === createdBy?.trim());
    return manager ? `${manager.first_name} ${manager.last_name}`.trim() : 'Unknown';
  }

  viewContract(contract: SignedContract) {
    // Open the contract PDF/HTML viewer URL directly in a new window
    const url = this.contractsService.getContractPdfUrl(contract.id);
    window.open(url, '_blank');
  }

  downloadContract(contract: SignedContract) {
    // Open the download URL directly — browser will handle the download via Content-Disposition header
    const url = this.contractsService.getContractPdfDownloadUrl(contract.id);
    window.open(url, '_blank');
  }

  onPageChange(event: PageEvent) {
    this.pageIndex = event.pageIndex;
    this.pageSize = event.pageSize;
    this.loadContracts(this.pageIndex, this.pageSize, this.filterForm.value.sortBy);
  }
}
