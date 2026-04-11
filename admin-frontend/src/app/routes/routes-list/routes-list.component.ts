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
import { finalize } from 'rxjs/operators';
import { BehaviorSubject } from 'rxjs';
import { RoutesService } from '../routes.service';

interface Visit {
  lead_id: number;
  visit_id: number;
  latitude: number;
  longitude: number;
  distance: number;
  eta: string;
}

interface Route {
  route_id: number;
  rep_id: number;
  route_date: string;
  route_order: Visit[];
  is_active: boolean;
  created_by: string;
  updated_by: string | null;
  created_at: string;
  updated_at: string;
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
  selector: 'app-routes-list',
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
  templateUrl: './routes-list.component.html',
  styleUrl: './routes-list.component.scss'
})
export class RoutesListComponent implements OnInit {
  @ViewChild('routeDetailsDialog') routeDetailsDialog!: TemplateRef<any>;
  @ViewChild('mapContainer') mapContainer!: ElementRef;
  routes: Route[] = [];
  filteredRoutes: Route[] = [];
  salesReps: SalesRep[] = [];
  managers: Manager[] = [];
  displayedColumns: string[] = ['repName', 'managerName', 'routeDate', 'visitCount', 'totalDistance', 'isActive', 'actions'];
  filterForm: FormGroup;
  viewMode: 'table' | 'map' = 'table';
  isLoading = false;
  selectedRoute: Route | null = null;
  totalRoutes = 0;
  pageSize = 10;
  pageIndex = 0;
  map: google.maps.Map | null = null;
  markers: google.maps.Marker[] = [];
  polylines: google.maps.Polyline[] = [];
  private mapInitialized = new BehaviorSubject<boolean>(false);

  constructor(
    private fb: FormBuilder,
    private usersService: UsersService,
    private routesService: RoutesService,
    private snackBar: MatSnackBar,
    private dialog: MatDialog,
    private ngZone: NgZone
  ) {
    this.filterForm = this.fb.group({
      salesRepId: ['all'],
      managerId: ['all'],
      routeDate: [null],
      sortBy: ['route_date']
    });
  }

  ngOnInit() {
    this.loadSalesReps();
    this.loadManagers();
    this.loadRoutes();
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

  loadRoutes(page: number = 0, size: number = 10, sortBy: string = 'route_date') {
    this.isLoading = true;
    const { salesRepId, managerId, routeDate } = this.filterForm.value;
    const params: any = { page: page + 1, limit: size, sortBy };
    if (salesRepId !== 'all') params.salesRepId = salesRepId;
    if (managerId !== 'all') params.managerId = managerId;
    if (routeDate) params.routeDate = routeDate.toISOString().split('T')[0];

    this.routesService.getDailyRoutes(params).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        this.routes = response?.data?.routes ?? [];
        this.totalRoutes = response?.data?.pagination?.total || this.routes.length;
        this.applyFilters();
      },
      error: (err: any) => {
        this.snackBar.open('Error loading routes: ' + err.message, 'Close', { duration: 3000 });
        this.applyFilters();
      }
    });
  }

  applyFilters() {
    let filtered = [...this.routes];
    const { salesRepId, managerId, routeDate, sortBy } = this.filterForm.value;

    if (salesRepId !== 'all') {
      filtered = filtered.filter(route => route.rep_id === Number(salesRepId));
    }
    if (managerId !== 'all') {
      filtered = filtered.filter(route => route.created_by.trim() === managerId);
    }
    if (routeDate) {
      const dateStr = routeDate.toISOString().split('T')[0];
      filtered = filtered.filter(route => route.route_date === dateStr);
    }

    // Client-side sorting (to be replaced by backend sorting)
    filtered.sort((a, b) => {
      if (sortBy === 'route_date') return new Date(b.route_date).getTime() - new Date(a.route_date).getTime();
      if (sortBy === 'rep_id') return b.rep_id - a.rep_id;
      if (sortBy === 'distance') {
        return this.calculateTotalDistance(b.route_order) - this.calculateTotalDistance(a.route_order);
      }
      return 0;
    });

    this.filteredRoutes = filtered.slice(this.pageIndex * this.pageSize, (this.pageIndex + 1) * this.pageSize);
    if (this.viewMode === 'map') {
      this.ngZone.run(() => this.initMap());
    }
  }

  getSalesRepName(repId: number): string {
    const salesRep = this.salesReps.find(s => s.id === String(repId));
    return salesRep ? `${salesRep.first_name} ${salesRep.last_name}` : 'Unknown';
  }

  getManagerName(managerId: string): string {
    const manager = this.managers.find(m => m.id === managerId.trim());
    return manager ? `${manager.first_name} ${manager.last_name}` : 'Unknown';
  }

  calculateTotalDistance(routeOrder: Visit[]): number {
    return routeOrder.reduce((sum, visit) => sum + visit.distance, 0);
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
        center: { lat: 60.575, lng: 27.145 }, // Centered on sample coordinates
        zoom: 13
      });
      this.mapInitialized.next(true);
    }

    this.displayRouteMarkers();
  }

  displayRouteMarkers() {
    if (!this.map) return;

    // Clear existing markers and polylines
    this.markers.forEach(marker => marker.setMap(null));
    this.polylines.forEach(polyline => polyline.setMap(null));
    this.markers = [];
    this.polylines = [];

    // Add markers and polylines for routes
    const bounds = new google.maps.LatLngBounds();
    this.filteredRoutes.forEach(route => {
      route.route_order.forEach((visit, index) => {
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
                Sales Rep: ${this.getSalesRepName(route.rep_id)}<br>
                Manager: ${this.getManagerName(route.created_by)}<br>
                ETA: ${visit.eta}<br>
                Distance: ${visit.distance.toFixed(2)} km
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

      // Draw polyline for route
      if (route.route_order.length > 1) {
        const path = route.route_order.map(visit => ({
          lat: visit.latitude,
          lng: visit.longitude
        }));
        const polyline = new google.maps.Polyline({
          path,
          geodesic: true,
          strokeColor: '#FF0000',
          strokeOpacity: 1.0,
          strokeWeight: 2,
          map: this.map
        });
        this.polylines.push(polyline);
      }
    });

    // Adjust map bounds to show all markers
    if (!bounds.isEmpty() && this.markers.length > 0) {
      this.map.fitBounds(bounds, { padding: 50 } as any); // Type assertion to fix TS error
    } else {
      this.map.setCenter({ lat: 60.575, lng: 27.145 });
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
        this.map.fitBounds(bounds, { padding: 50 } as any); // Type assertion to fix TS error
      }
    }
  }

  destroyMap() {
    if (this.map) {
      this.markers.forEach(marker => marker.setMap(null));
      this.polylines.forEach(polyline => polyline.setMap(null));
      this.markers = [];
      this.polylines = [];
      this.map = null;
      this.mapInitialized.next(false);
    }
  }

  viewRouteDetails(route: Route) {
    this.selectedRoute = route;
    this.dialog.open(this.routeDetailsDialog, {
      width: '600px'
    });
  }

  exportRoutes() {
    const csvContent = [
      ['Sales Rep', 'Manager', 'Route Date', 'Visit Count', 'Total Distance (km)', 'Active'],
      ...this.filteredRoutes.map(route => [
        this.getSalesRepName(route.rep_id),
        this.getManagerName(route.created_by),
        new Date(route.route_date).toLocaleDateString(),
        route.route_order.length,
        this.calculateTotalDistance(route.route_order).toFixed(2),
        route.is_active ? 'Yes' : 'No'
      ])
    ].map(row => row.join(',')).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'routes_export.csv';
    a.click();
    window.URL.revokeObjectURL(url);
  }

  onPageChange(event: PageEvent) {
    this.pageIndex = event.pageIndex;
    this.pageSize = event.pageSize;
    this.loadRoutes(this.pageIndex, this.pageSize, this.filterForm.value.sortBy);
  }
}