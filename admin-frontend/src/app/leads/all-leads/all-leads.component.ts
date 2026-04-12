import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { FormsModule } from '@angular/forms';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatDialogModule, MatDialog } from '@angular/material/dialog';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatSnackBarModule, MatSnackBar } from '@angular/material/snack-bar';
import { LeadsService } from '../leads.service';
import { UsersService } from '../../users/users.service';
import { Subject, Subscription } from 'rxjs';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { LeadDetailsDialogComponent } from '../lead-details-dialog/lead-details-dialog.component';
import { MatDialogConfig } from '@angular/material/dialog';
import { ConfirmationDialogComponent } from '../../shared/dialog/confirmation-dialog/confirmation-dialog.component';
import { AuthService } from '../../auth/auth.service';

// Define LeadStatus type
type LeadStatus = 'Get Back' | 'Not Available' | 'Not Interested' | 'Meeting' | 'Hot Lead' | 'Signed' | 'Start Signing' | 'Not Sellable';

interface Lead {
  lead_id: number;
  name: string;
  address_id: number | null;
  assigned_rep_id: number | null;
  contact_name: string;
  contact_email: string;
  contact_phone: string;
  status: LeadStatus;
  territory_id: number | null;
  org_id: number;
  is_active: boolean;
  pending_assignment: boolean;
  source: string;
  created_by: string;
  updated_by: string;
  created_at: string;
  updated_at: string;
  address: {
    address_id: number;
    street_address: string;
    building_unit: string | null;
    landmark: string | null;
    city: string;
    state: string;
    postal_code: string;
    area_name: string;
    subregion: string;
    region: string;
    country: string;
    latitude: number;
    longitude: number;
    comments: string | null;
    territory_id: number | null;
    polygon_id: number | null;
    org_id: number;
    is_active: boolean;
    created_by: string;
    updated_by: string;
    created_at: string;
    updated_at: string;
  } | null;
  partner: {
    partner_id: number;
    company_name: string;
    contact_email: string;
  } | null;
}

interface User {
  user_id: number;
  full_name: string;
  role: string;
}

interface ApiResponse {
  success: boolean;
  data: {
    leads: Lead[];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  };
  message: string;
}

@Component({
  selector: 'app-all-leads',
  standalone: true,
  imports: [
    CommonModule,
    MatTableModule,
    MatPaginatorModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    MatMenuModule,
    FormsModule,
    MatProgressBarModule,
    MatDialogModule,
    MatCheckboxModule,
    MatSnackBarModule
  ],
  templateUrl: './all-leads.component.html',
  styleUrls: ['./all-leads.component.scss']
})
export class AllLeadsComponent implements OnInit, OnDestroy {
  displayedColumns: string[] = ['select', 'lead_id', 'street_address', 'city', 'postal_code', 'name', 'partner_name', 'status', 'assigned_to', 'created_at', 'actions'];
  dataSource = new MatTableDataSource<Lead>([]);
  selection = new Set<number>();
  totalItems = 0;
  pageSize = 10;
  currentPage = 1;
  isLoading = false;
  searchQuery = '';
  statusFilter: LeadStatus | '' = '';
  salesmanFilter: number | null = null;
  managerFilter: number | null = null;
  partnerFilter: number | null = null;
  territoryFilter: string | null = null;
  leadSetFilter: string | null = null;
  salesmen: User[] = [];
  managers: User[] = [];
  partners: { partner_id: number; company_name: string }[] = [];
  territories: { territory_id: number; name: string }[] = [];
  leadSets: string[] = [];
  currentUserRole: string = '';
  canEditLeads = false;
  canDeleteLeads = false;
  selectedSalesman: number | null = null;
  private searchSubject = new Subject<string>();
  private searchSubscription: Subscription | null = null;
  private statusStyles: Record<LeadStatus, { backgroundColor: string; color: string }> = {
    'Get Back': { backgroundColor: '#FFE4B5', color: '#FFA500' },
    'Not Available': { backgroundColor: '#FFFFE0', color: '#FFD700' },
    'Not Interested': { backgroundColor: '#FFB6C1', color: '#FF0000' },
    'Meeting': { backgroundColor: '#ADD8E6', color: '#0000FF' },
    'Hot Lead': { backgroundColor: '#E6E6FA', color: '#800080' },
    'Signed': { backgroundColor: '#90EE90', color: '#008000' },
    'Start Signing': { backgroundColor: '#87CEFA', color: '#00B7EB' },
    'Not Sellable': { backgroundColor: '#D3D3D3', color: '#808080' }
  };

  constructor(
    private leadsService: LeadsService,
    private usersService: UsersService,
    private dialog: MatDialog,
    private snackBar: MatSnackBar,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    // Set up role-based permissions
    const currentUser = this.authService.getCurrentUser();
    this.currentUserRole = currentUser?.role || '';
    
    // Managers and above can edit and delete leads
    this.canEditLeads = this.authService.hasAnyRole(['manager', 'admin']);
    this.canDeleteLeads = this.authService.hasAnyRole(['manager', 'admin']);
    
    this.setupSearchDebounce();
    this.loadSalesmen();
    this.loadManagers();
    this.loadPartners();
    this.loadTerritories();
    this.loadLeadSets();
    this.fetchLeadStatusColors(); // Fetch status colors on init
    this.fetchLeads();
  }

  ngOnDestroy(): void {
    if (this.searchSubscription) {
      this.searchSubscription.unsubscribe();
    }
  }

  setupSearchDebounce(): void {
    this.searchSubscription = this.searchSubject
      .pipe(
        debounceTime(300),
        distinctUntilChanged()
      )
      .subscribe(searchQuery => {
        this.searchQuery = searchQuery;
        this.currentPage = 1;
        this.fetchLeads();
      });
  }

  loadSalesmen(): void {
    this.usersService.getSalesmen().subscribe({
      next: (response: any) => {
        this.salesmen = response.data.map((user: any) => ({
          user_id: user.user_id,
          full_name: user.full_name,
          role: user.role.role_name
        }));
      },
      error: (err: any) => {
        console.error('Error loading sales reps:', err);
        this.snackBar.open('Failed to load sales representatives', 'Close', { duration: 3000 });
      }
    });
  }

  loadManagers(): void {
    this.usersService.getManagers().subscribe({
      next: (response: any) => {
        this.managers = response.data.map((user: any) => ({
          user_id: user.user_id,
          full_name: user.full_name,
          role: user.role.role_name
        }));
      },
      error: (err: any) => {
        console.error('Error loading managers:', err);
        this.snackBar.open('Failed to load managers', 'Close', { duration: 3000 });
      }
    });
  }

  loadPartners(): void {
    this.leadsService.getPartners().subscribe({
      next: (response: any) => {
        this.partners = (response.data || []).map((p: any) => ({
          partner_id: p.partner_id,
          company_name: p.company_name
        }));
      },
      error: (err: any) => {
        console.error('Error loading partners:', err);
      }
    });
  }

  loadTerritories(): void {
    this.leadsService.getTerritories().subscribe({
      next: (response: any) => {
        const data = response.data?.territories || response.data || [];
        this.territories = data.map((t: any) => ({
          territory_id: t.territory_id,
          name: t.name
        }));
      },
      error: (err: any) => {
        console.error('Error loading territories:', err);
      }
    });
  }

  loadLeadSets(): void {
    this.leadsService.getLeadSets().subscribe({
      next: (response: any) => {
        this.leadSets = response.data || [];
      },
      error: (err: any) => {
        console.error('Error loading lead sets:', err);
      }
    });
  }

  onLeadSetFilterChange(leadSet: string | null): void {
    this.leadSetFilter = leadSet;
    this.currentPage = 1;
    this.fetchLeads();
  }

  onPartnerFilterChange(partnerId: number | null): void {
    this.partnerFilter = partnerId;
    this.currentPage = 1;
    this.fetchLeads();
  }

  onTerritoryFilterChange(territoryId: string | null): void {
    this.territoryFilter = territoryId;
    this.currentPage = 1;
    this.fetchLeads();
  }

  // Fetch lead status colors from API
  fetchLeadStatusColors(): void {
    this.leadsService.getLeadStatusColors().subscribe({
      next: (response) => {
        const statusColors = response.data.reduce((acc, item) => {
          acc[item.status] = {
            backgroundColor: item.color.hex, // Use original color for background
            color: this.lightenColor(item.color.hex, 0.8) // Lighten for text
          };
          return acc;
        }, {} as Record<LeadStatus, { backgroundColor: string; color: string }>);
        this.statusStyles = { ...this.statusStyles, ...statusColors };
      },
      error: (err) => {
        console.error('Error fetching lead status colors:', err);
        this.snackBar.open('Failed to load lead status colors', 'Close', { duration: 3000 });
      }
    });
  }

  // Utility function to lighten a hex color (remains unchanged)
  private lightenColor(hex: string, factor: number): string {
    hex = hex.replace('#', '');
    const r = Math.min(255, Math.round(parseInt(hex.slice(0, 2), 16) + (255 - parseInt(hex.slice(0, 2), 16)) * factor));
    const g = Math.min(255, Math.round(parseInt(hex.slice(2, 4), 16) + (255 - parseInt(hex.slice(2, 4), 16)) * factor));
    const b = Math.min(255, Math.round(parseInt(hex.slice(4, 6), 16) + (255 - parseInt(hex.slice(4, 6), 16)) * factor));
    return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
  }

  fetchLeads(): void {
    this.isLoading = true;
    this.leadsService.getLeads(
      this.searchQuery,
      this.currentPage,
      this.pageSize,
      this.salesmanFilter,
      this.managerFilter,
      this.partnerFilter,
      this.territoryFilter,
      this.leadSetFilter
    ).subscribe({
      next: (response) => {
        let leads = response.data.leads;
        if (this.statusFilter) {
          leads = leads.filter(lead => lead.status === this.statusFilter);
        }
        this.dataSource.data = leads;
        this.totalItems = response.data.pagination.total;
        const previousSelections = new Set(this.selection);
        this.selection.clear();
        leads.forEach(lead => {
          if (previousSelections.has(lead.lead_id)) {
            this.selection.add(lead.lead_id);
          }
        });
        this.isLoading = false;
      },
      error: () => {
        this.isLoading = false;
        this.snackBar.open('Failed to load leads', 'Close', { duration: 3000 });
      }
    });
  }

  getSalesmanName(salesmanId: number | null): string {
    if (!salesmanId) return '-';
    const salesman = this.salesmen.find(s => s.user_id === salesmanId);
    return salesman ? salesman.full_name : 'Unassigned';
  }

  onPageChange(event: PageEvent): void {
    this.currentPage = event.pageIndex + 1;
    this.pageSize = event.pageSize;
    this.fetchLeads();
  }

  onSearchChange(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.searchSubject.next(input.value);
  }

  onStatusFilterChange(status: LeadStatus | ''): void {
    this.statusFilter = status;
    this.currentPage = 1;
    this.fetchLeads();
  }

  onSalesmanFilterChange(salesmanId: number | null): void {
    this.salesmanFilter = salesmanId;
    this.currentPage = 1;
    this.fetchLeads();
  }

  onManagerFilterChange(managerId: number | null): void {
    this.managerFilter = managerId;
    this.currentPage = 1;
    this.fetchLeads();
  }

  toggleSelection(leadId: number): void {
    if (this.selection.has(leadId)) {
      this.selection.delete(leadId);
    } else {
      this.selection.add(leadId);
    }
  }

  toggleAllSelection(checked: boolean): void {
    this.selection.clear();
    if (checked) {
      this.dataSource.data.forEach(lead => this.selection.add(lead.lead_id));
    }
  }

  assignLeads(): void {
    if (!this.selectedSalesman || this.selection.size === 0) {
      this.snackBar.open('Please select a salesman and at least one lead', 'Close', { duration: 3000 });
      return;
    }

    this.isLoading = true;
    const payload = {
      rep_id: this.selectedSalesman,
      lead_ids: Array.from(this.selection)
    };

    this.leadsService.bulkAssignLeads(payload).subscribe({
      next: () => {
        this.isLoading = false;
        this.snackBar.open('Leads assigned successfully', 'Close', { duration: 3000 });
        this.selection.clear();
        this.selectedSalesman = null;
        this.fetchLeads();
      },
      error: () => {
        this.isLoading = false;
        this.snackBar.open('Failed to assign leads', 'Close', { duration: 3000 });
      }
    });
  }

  getStatusStyles(status: LeadStatus): { backgroundColor: string; color: string } {
    return this.statusStyles[status] || { backgroundColor: '#FFFFFF', color: '#000000' };
  }

  viewLead(lead: Lead): void {
    const dialogRef = this.dialog.open(LeadDetailsDialogComponent, {
      width: '1200px',
      maxWidth: 'none',
      data: { lead, salesmen: this.salesmen }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.fetchLeads();
      }
    });
  }

  editLead(lead: Lead): void {
    this.viewLead(lead);
  }

  deleteLead(lead: Lead): void {
    const dialogConfig = new MatDialogConfig();
    dialogConfig.data = {
      title: 'Confirm Delete',
      message: `Are you sure you want to delete lead "${lead.name}" (ID: ${lead.lead_id})?`,
      confirmText: 'Delete',
      cancelText: 'Cancel'
    };
    dialogConfig.width = '400px';

    const dialogRef = this.dialog.open(ConfirmationDialogComponent, dialogConfig);

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.isLoading = true;
        this.leadsService.deleteLead(lead.lead_id).subscribe({
          next: () => {
            this.isLoading = false;
            this.snackBar.open('Lead deleted successfully', 'Close', { duration: 3000 });
            this.selection.delete(lead.lead_id);
            this.fetchLeads();
          },
          error: () => {
            this.isLoading = false;
            this.snackBar.open('Failed to delete lead', 'Close', { duration: 3000 });
          }
        });
      }
    });
  }

  bulkDeleteLeads(): void {
    if (this.selection.size === 0) {
      this.snackBar.open('Please select at least one lead to delete', 'Close', { duration: 3000 });
      return;
    }

    const dialogConfig = new MatDialogConfig();
    dialogConfig.data = {
      title: 'Confirm Bulk Delete',
      message: `Are you sure you want to delete ${this.selection.size} selected lead(s)?`,
      confirmText: 'Delete',
      cancelText: 'Cancel'
    };
    dialogConfig.width = '400px';

    const dialogRef = this.dialog.open(ConfirmationDialogComponent, dialogConfig);

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.isLoading = true;
        const leadIds = Array.from(this.selection);
        this.leadsService.bulkDeleteLeads(leadIds).subscribe({
          next: () => {
            this.isLoading = false;
            this.snackBar.open('Leads deleted successfully', 'Close', { duration: 3000 });
            this.selection.clear();
            this.fetchLeads();
          },
          error: () => {
            this.isLoading = false;
            this.snackBar.open('Failed to delete leads', 'Close', { duration: 3000 });
          }
        });
      }
    });
  }


  openActionMenu(event: MouseEvent): void {
    event.stopPropagation(); // Prevent row click event from triggering
  }
}