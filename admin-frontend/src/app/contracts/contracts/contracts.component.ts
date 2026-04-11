import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
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
  assigned_manager_ids: string[];
  assigned_managers: Array<{
    user_id: number;
    full_name: string;
    first_name: string;
    last_name: string;
    email: string;
  }>;
  signed_count: number;
  status: 'draft' | 'active' | 'archived';
  created_by: string;
  created_at: string;
  updated_at: string;
  dropdown_fields?: { [key: string]: DropdownField };
  partner_id?: number;
  partner?: { partner_id: number; company_name: string } | null;
}

interface Manager {
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
    MatPaginatorModule
  ],
  templateUrl: './contracts.component.html',
  styleUrl: './contracts.component.scss'
})
export class ContractsComponent implements OnInit {
  @ViewChild('viewContractDialog') viewContractDialog!: TemplateRef<any>;
  @ViewChild('reassignContractDialog') reassignContractDialog!: TemplateRef<any>;
  contracts: Contract[] = [];
  filteredContracts: Contract[] = [];
  managers: Manager[] = [];
  displayedColumns: string[] = ['title', 'partnerCompany', 'managerNames', 'status', 'createdAt', 'actions'];
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
      managerId: ['all'],
      status: ['all'],
      search: [''],
      sortBy: ['signed_count']
    });
    this.contractForm = this.fb.group({
      assigned_manager_ids: [[], Validators.required]
    });
  }

  ngOnInit() {
    // Set up role-based permissions
    const currentUser = this.authService.getCurrentUser();
    this.currentUserRole = currentUser?.role || '';
    
    // Managers and above can create and edit contracts
    this.canCreateContracts = this.authService.hasAnyRole(['manager', 'admin']);
    this.canEditAllContracts = this.authService.hasAnyRole(['admin']);
    
    this.loadManagers();
    this.loadContracts();
    this.filterForm.valueChanges.subscribe(() => this.applyFilters());
  }

  loadManagers() {
    this.isLoading = true;
    this.usersService.getManagers().pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        const managers = response?.data ?? []; // Directly use response.data
        this.managers = managers.map((member: any) => ({
          id: String(member.user_id), // Convert number to string
          first_name: member.full_name ? member.full_name.split(' ')[0] : 'N/A',
          last_name: member.full_name ? member.full_name.split(' ').slice(1).join(' ') || '' : ''
        }));
      },
      error: () => {
        this.snackBar.open('Error loading managers', 'Close', { duration: 3000 });
      }
    });
  }

  loadContracts(page: number = 0, size: number = 10, sortBy: string = 'signed_count') {
    this.isLoading = true;
    const { managerId, status, search } = this.filterForm.value;
    const params: any = { page: page + 1, limit: size, sortBy };
    if (managerId !== 'all') params.managerId = managerId;
    if (status !== 'all') params.status = status;
    if (search) params.search = search;

    this.contractsService.getContracts(params).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        this.contracts = (response?.data?.contracts ?? []).map((contract: any) => ({
          ...contract,
          assigned_manager_ids: contract.assigned_manager_ids.map((id: any) => String(id)), // Ensure IDs are strings
          assigned_managers: contract.assigned_managers || [] // Ensure assigned_managers array is available
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
    const { managerId, status, search, sortBy } = this.filterForm.value;

    if (managerId !== 'all') {
      filtered = filtered.filter(contract => contract.assigned_manager_ids.includes(managerId));
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

  getManagerNames(contract: Contract): string {
    if (contract.assigned_managers && contract.assigned_managers.length > 0) {
      return contract.assigned_managers
        .map(manager => manager.full_name)
        .join(', ');
    }
    return 'No managers assigned';
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
    this.contractForm.patchValue({ assigned_manager_ids: contract.assigned_manager_ids });
    this.dialog.open(this.reassignContractDialog, { width: '400px' });
  }

  reassignContract() {
    if (!this.selectedContract || !this.contractForm.get('assigned_manager_ids')?.valid) {
      this.snackBar.open('Please select at least one manager', 'Close', { duration: 3000 });
      return;
    }

    this.isLoading = true;
    const updatedContract = {
      assigned_manager_ids: this.contractForm.get('assigned_manager_ids')?.value
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
    // Admins and Super Admins can edit any contract
    if (this.canEditAllContracts) {
      return true;
    }
    
    // Managers can edit contracts they are assigned to
    if (this.currentUserRole === 'manager') {
      const currentUser = this.authService.getCurrentUser();
      if (currentUser?.user_id) {
        return contract.assigned_manager_ids?.includes(String(currentUser.user_id));
      }
    }
    
    return false;
  }

  canDeleteContract(contract: Contract): boolean {
    // Only Admins can delete contracts
    return this.canEditAllContracts;
  }
}