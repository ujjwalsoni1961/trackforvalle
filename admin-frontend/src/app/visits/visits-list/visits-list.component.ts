import { Component, OnInit, ViewChild, TemplateRef, NgZone, ElementRef } from '@angular/core';
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
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatPaginator, MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { UsersService } from '../../users/users.service';
import { debounceTime, finalize } from 'rxjs/operators';
import { BehaviorSubject } from 'rxjs';
import { VisitsService } from '../visits.service';

interface Visit {
  visit_id: number;
  lead_id: number;
  rep_id: number;
  check_in_time: string;
  check_out_time: string | null;
  latitude: number;
  longitude: number;
  notes: string | null;
  photo_urls: string[] | null;
  next_visit_date: string | null;
  action_required: string | null;
  is_active: boolean;
  created_by: string;
  updated_by: string | null;
  created_at: string;
  updated_at: string;
  lead?: {
    lead_id: number;
    name: string;
    address_id: number;
    assigned_rep_id: number;
    contact_name: string;
    contact_email: string;
    contact_phone: string;
    status: string;
    territory_id: number | null;
    org_id: number;
    is_active: boolean;
    is_visited: boolean | null;
    pending_assignment: boolean;
    source: string;
    created_by: string;
    updated_by: string;
    created_at: string;
    updated_at: string;
  };
  rep?: {
    user_id: number;
    email: string;
    password_hash: string;
    phone: string;
    google_oauth_id: string | null;
    is_email_verified: boolean;
    full_name: string;
    first_name: string;
    last_name: string;
    org_id: number;
    role_id: number;
    address_id: number | null;
    is_admin: boolean;
    is_active: boolean;
    created_by: string;
    updated_by: string | null;
    is_super_admin: boolean;
    created_at: string;
    updated_at: string;
  };
}

interface SalesRep {
  id: string;
  first_name: string;
  last_name: string;
}

interface Manager {
  id: string;
  first_name: string;
  last_name: string;
}

@Component({
  selector: 'app-visits-list',
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
    MatDatepickerModule,
    MatNativeDateModule,
    MatPaginatorModule
  ],
  templateUrl: './visits-list.component.html',
  styleUrl: './visits-list.component.scss'
})
export class VisitsListComponent implements OnInit {
  @ViewChild('visitDetailsDialog') visitDetailsDialog!: TemplateRef<any>;
  @ViewChild('mapContainer') mapContainer!: ElementRef;
  visits: Visit[] = [];
  filteredVisits: Visit[] = [];
  salesReps: SalesRep[] = [];
  managers: Manager[] = [];
  displayedColumns: string[] = ['repName', 'leadId', 'checkInTime', 'notes', 'isActive', 'actions'];
  filterForm: FormGroup;
  viewMode: 'table' | 'map' = 'table';
  isLoading = false;
  selectedVisit: Visit | null = null;
  totalVisits = 0;
  pageSize = 10;
  pageIndex = 0;
  map: google.maps.Map | null = null;
  markers: google.maps.Marker[] = [];
  private mapInitialized = new BehaviorSubject<boolean>(false);

  constructor(
    private fb: FormBuilder,
    private visitService: VisitsService,
    private usersService: UsersService,
    private snackBar: MatSnackBar,
    private dialog: MatDialog,
    private ngZone: NgZone
  ) {
    this.filterForm = this.fb.group({
      salesRepId: ['all'],
      managerId: ['all'],
      fromDate: [new Date()],
      toDate: [new Date()],
      sortBy: ['check_in_time']
    });
  }

  ngOnInit() {
    this.loadSalesReps();
    this.loadManagers();
    this.loadVisits(); // Call loadVisits with default arguments
    this.filterForm.valueChanges.pipe(
      debounceTime(300)
    ).subscribe(() => {
      this.loadVisits(0, this.pageSize);
    });
    this.filterForm.valueChanges.subscribe(() => this.applyFilters());
    this.mapInitialized.subscribe(initialized => {
      if (initialized && this.viewMode === 'map') {
        this.initMap();
      }
    });
    window.addEventListener('resize', () => this.ngZone.run(() => this.adjustMapBounds()));
  }

  ngOnDestroy() {
    window.removeEventListener('resize', () => this.ngZone.run(() => this.adjustMapBounds()));
    this.destroyMap();
  }

  loadSalesReps() {
    this.isLoading = true;
    this.usersService.getSalesReps().pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        const teamMembers = response?.data ?? [];
        this.salesReps = teamMembers.map((member: any) => ({
          id: String(member.user_id),
          first_name: member.full_name ? member.full_name.split(' ')[0] : 'N/A',
          last_name: member.full_name ? member.full_name.split(' ')[1] || '' : ''
        }));
      },
      error: (err: any) => {
        this.snackBar.open('Error loading sales representatives: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  loadManagers() {
    this.isLoading = true;
    this.usersService.getManagers().pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        const teamMembers = response?.data ?? [];
        this.managers = teamMembers.map((member: any) => ({
          id: String(member.user_id),
          first_name: member.full_name ? member.full_name.split(' ')[0] : 'N/A',
          last_name: member.full_name ? member.full_name.split(' ')[1] || '' : ''
        }));
      },
      error: (err: any) => {
        this.snackBar.open('Error loading managers: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  loadVisits(page: number = 0, size: number = 10) {
    this.isLoading = true;
    const { salesRepId, managerId, fromDate, toDate, sortBy } = this.filterForm.value;
    const params: any = { page: page + 1, limit: size };
    if (salesRepId !== 'all') params.salesRepId = salesRepId;
    if (managerId !== 'all') params.managerId = managerId;
    if (fromDate) params.from = fromDate.toISOString().split('T')[0];
    if (toDate) params.to = toDate.toISOString().split('T')[0];
    if (sortBy) {
      const mappedSortBy = sortBy === 'rep_id' ? 'sales_rep' : sortBy;
      params.sortBy = mappedSortBy;
      params.sortOrder = sortBy === 'check_in_time' ? 'DESC' : 'ASC';
    }

    this.visitService.getVisits(params).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        this.visits = Array.isArray(response.data?.data) ? response.data.data : [];
        this.totalVisits = response.data?.total || this.visits.length;
        this.applyFilters();
      },
      error: (err: any) => {
        console.error('Error loading visits:', err);
        this.snackBar.open('Error loading visits: ' + err.message, 'Close', { duration: 3000 });
        this.visits = [];
        this.applyFilters();
      }
    });
  }

  applyFilters() {
    let filtered = [...this.visits];
    const { salesRepId, managerId, fromDate, toDate } = this.filterForm.value;

    if (salesRepId !== 'all') {
      filtered = filtered.filter(visit => visit.rep_id === Number(salesRepId));
    }
    if (managerId !== 'all') {
      filtered = filtered.filter(visit => visit.created_by.trim() === managerId);
    }
    if (fromDate && toDate) {
      const from = fromDate.toISOString().split('T')[0];
      const to = toDate.toISOString().split('T')[0];
      filtered = filtered.filter(visit => {
        const visitDate = visit.check_in_time.split('T')[0];
        return visitDate >= from && visitDate <= to;
      });
    }

    this.filteredVisits = filtered.slice(this.pageIndex * this.pageSize, (this.pageIndex + 1) * this.pageSize);
    if (this.viewMode === 'map') {
      this.ngZone.run(() => this.initMap());
    }
  }

  getSalesRepName(repId: number): string {
    const visit: any = this.visits.find(v => v.rep_id === repId);
    if (visit?.rep) {
      return `${visit.rep.first_name} ${visit.rep.last_name}`;
    }
    const salesRep = this.salesReps.find(s => s.id === String(repId));
    return salesRep ? `${salesRep.first_name} ${salesRep.last_name}` : 'Unknown';
  }

  getManagerName(managerId: string): string {
    const manager = this.managers.find(m => m.id === managerId.trim());
    return manager ? `${manager.first_name} ${manager.last_name}` : 'Unknown';
  }

  setViewMode(mode: 'table' | 'map') {
    this.viewMode = mode;
    if (mode === 'map') {
      // Delay map initialization to ensure DOM is updated
      setTimeout(() => this.initMap(), 0);
    } else {
      this.destroyMap();
    }
  }

  initMap() {
    if (this.viewMode !== 'map') return;

    const mapElement = this.mapContainer?.nativeElement;
    if (!mapElement) {
      this.snackBar.open('Map container not found', 'Close', { duration: 5000 });
      this.viewMode = 'table';
      return;
    }

    if (typeof google === 'undefined' || !google.maps) {
      this.snackBar.open('Google Maps API not loaded', 'Close', { duration: 5000 });
      this.viewMode = 'table';
      return;
    }

    if (!this.map) {
      this.map = new google.maps.Map(mapElement, {
        center: { lat: 61.181, lng: 28.748 },
        zoom: 13
      });
      this.mapInitialized.next(true);
    }

    this.displayVisitMarkers();
  }

  displayVisitMarkers() {
    if (!this.map) return;

    // Clear existing markers
    this.markers.forEach(marker => marker.setMap(null));
    this.markers = [];

    // Add markers for visits
    const bounds = new google.maps.LatLngBounds();
    this.filteredVisits.forEach((visit, index) => {
      const position = { lat: visit.latitude, lng: visit.longitude };
      if (isFinite(position.lat) && isFinite(position.lng)) {
        const marker = new google.maps.Marker({
          position,
          map: this.map,
          title: `Visit ${visit.visit_id}`,
          label: {
            text: `${index + 1}`,
            color: 'white',
            fontWeight: 'bold'
          }
        });

        const infoWindow = new google.maps.InfoWindow({
          content: `
            <div>
              <strong>Visit ${visit.visit_id}</strong><br>
              Lead: ${visit.lead_id}<br>
              Sales Rep: ${this.getSalesRepName(visit.rep_id)}<br>
              Check-in: ${new Date(visit.check_in_time).toLocaleString()}<br>
              Notes: ${visit.notes || 'N/A'}
            </div>
          `
        });

        marker.addListener('click', () => {
          this.ngZone.run(() => {
            infoWindow.open(this.map, marker);
          });
        });

        this.markers.push(marker);
        bounds.extend(position);
      }
    });

    // Adjust map bounds to show all markers
    if (!bounds.isEmpty() && this.markers.length > 0) {
      // Use type assertion to bypass TypeScript error
      this.map.fitBounds(bounds, { padding: 50 } as any);
    } else {
      this.map.setCenter({ lat: 61.181, lng: 28.748 });
      this.map.setZoom(13);
    }
  }

  adjustMapBounds() {
    if (this.map && this.markers.length > 0) {
      const bounds = new google.maps.LatLngBounds();
      this.markers.forEach(marker => {
        const position = marker.getPosition();
        if (position) bounds.extend(position);
      });
      if (!bounds.isEmpty()) {
        // Use type assertion to bypass TypeScript error
        this.map.fitBounds(bounds, { padding: 50 } as any);
      }
    }
  }

  destroyMap() {
    if (this.map) {
      this.markers.forEach(marker => marker.setMap(null));
      this.markers = [];
      this.map = null;
      this.mapInitialized.next(false);
    }
  }

  viewVisitDetails(visit: Visit) {
    this.selectedVisit = visit;
    this.dialog.open(this.visitDetailsDialog, {
      width: '600px'
    });
  }

  exportVisits() {
    const csvContent = [
      ['Sales Rep', 'Manager', 'Lead ID', 'Check-in Time', 'Notes', 'Active'],
      ...this.filteredVisits.map(visit => [
        this.getSalesRepName(visit.rep_id),
        this.getManagerName(visit.created_by),
        visit.lead_id,
        new Date(visit.check_in_time).toLocaleString(),
        `"${visit.notes || 'N/A'}"`,
        visit.is_active ? 'Yes' : 'No'
      ])
    ].map(row => row.join(',')).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'visits_export.csv';
    a.click();
    window.URL.revokeObjectURL(url);
  }

  onPageChange(event: PageEvent) {
    this.pageIndex = event.pageIndex;
    this.pageSize = event.pageSize;
    this.loadVisits(this.pageIndex, this.pageSize);
  }
}