import { Component, OnInit, NgZone, ViewChild } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator, PageEvent } from '@angular/material/paginator';
import { SharedModule } from '../../shared/shared.module';
import { TerritoryService } from '../territory.service';
import { BehaviorSubject } from 'rxjs';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { MatDialog } from '@angular/material/dialog';
import { TerritoryDetailsDialogComponent } from '../territory-details-dialog/territory-details-dialog.component';

@Component({
  selector: 'app-territory-list',
  imports: [SharedModule],
  templateUrl: './territory-list.component.html',
  styleUrl: './territory-list.component.scss'
})
export class TerritoryListComponent implements OnInit {
  @ViewChild(MatSort) sort!: MatSort;
  @ViewChild(MatPaginator) paginator!: MatPaginator;
  map: google.maps.Map | null = null;
  drawingManager: google.maps.drawing.DrawingManager | null = null;
  currentPolygon: google.maps.Polygon | null = null;
  territories: any[] = [];
  salesmen: any[] = [];
  territoryForm: FormGroup;
  customers: any[] = [];
  autocomplete: google.maps.places.Autocomplete | null = null;
  private mapInitialized = new BehaviorSubject<boolean>(false);
  isSaving: boolean = false;
  dataSource = new MatTableDataSource<any>([]);
  displayedColumns: string[] = ['name', 'salesman', 'actions'];
  searchQuery: string = '';
  pagination = {
    page: 1,
    limit: 10,
    totalItems: 0,
    totalPages: 1
  };
  isLoading: Boolean = false;

  constructor(
    private fb: FormBuilder,
    private snackBar: MatSnackBar,
    private territoryService: TerritoryService,
    private ngZone: NgZone,
    private dialog: MatDialog
  ) {
    this.territoryForm = this.fb.group({
      name: ['', Validators.required],
      salesmanIds: [[], Validators.required],
      searchArea: ['']
    });
  }

  ngOnInit() {
    this.loadSalesmen();
    this.loadTerritories();
    this.initMap();

    this.mapInitialized.subscribe(initialized => {
      if (initialized) {
        this.territoryForm.get('salesmanIds')?.valueChanges.pipe(
          debounceTime(300),
          distinctUntilChanged((prev, curr) => JSON.stringify(prev) === JSON.stringify(curr))
        ).subscribe(salesmanIds => {
          if (salesmanIds.length > 0 && !this.currentPolygon) {
            this.filterTerritoriesBySalesman(salesmanIds[0]);
          }
        });
      }
    });

    window.addEventListener('resize', () => this.ngZone.run(() => this.adjustMapBounds()));
  }

  ngAfterViewInit() {
    this.dataSource.sort = this.sort;
    this.dataSource.paginator = this.paginator;
  }

  onPageChange(event: PageEvent) {
    this.pagination.page = event.pageIndex + 1;
    this.pagination.limit = event.pageSize;
    this.loadTerritories();
  }

  applyFilter() {
    this.pagination.page = 1; // Reset to first page on new search
    this.loadTerritories();
  }

  adjustMapBounds() {
    if (this.map && this.territories.length > 0) {
      const bounds = new google.maps.LatLngBounds();
      this.territories.forEach(territory => {
        if (territory.polygon && territory.polygon.getPath()) {
          const path = territory.polygon.getPath().getArray();
          if (this.isValidPolygonPaths(path.map((latLng: any) => ({ lat: latLng.lat(), lng: latLng.lng() })))) {
            path.forEach((latLng: google.maps.LatLng) => bounds.extend(latLng));
          }
        }
      });
      if (!bounds.isEmpty()) {
        this.map.fitBounds(bounds);
      }
    }
  }

  initMap() {
    const mapElement = document.getElementById('map') as HTMLElement;
    if (!mapElement) {
      this.snackBar.open('Map container not found', 'Close', { duration: 5000 });
      return;
    }

    if (typeof google === 'undefined' || !google.maps) {
      this.snackBar.open('Google Maps API not loaded', 'Close', { duration: 5000 });
      return;
    }

    this.map = new google.maps.Map(mapElement, {
      center: { lat: 61.0, lng: 23.5 },
      zoom: 7
    });

    this.drawingManager = new google.maps.drawing.DrawingManager({
      drawingMode: null,
      drawingControl: false,
      polygonOptions: {
        fillColor: '#2196F3',
        fillOpacity: 0.3,
        strokeWeight: 2,
        strokeColor: '#2196F3',
        editable: true
      }
    });
    this.drawingManager.setMap(this.map);

    google.maps.event.addListener(this.drawingManager, 'polygoncomplete', (polygon: google.maps.Polygon) => {
      this.ngZone.run(() => {
        this.currentPolygon = polygon;
        this.drawingManager!.setDrawingMode(null);
      });
    });

    this.initAutocomplete();
    this.mapInitialized.next(true);
    this.displayTerritories();
  }

  initAutocomplete() {
    const input = document.getElementById('area-search') as HTMLInputElement;
    if (!input) {
      this.snackBar.open('Search input not found', 'Close', { duration: 3000 });
      return;
    }

    if (!google.maps.places) {
      this.snackBar.open('Google Maps Places API not loaded', 'Close', { duration: 5000 });
      return;
    }

    try {
      this.autocomplete = new google.maps.places.Autocomplete(input, {
        componentRestrictions: { country: 'fi' }
      });

      this.autocomplete.bindTo('bounds', this.map!);

      this.autocomplete.addListener('place_changed', () => {
        this.ngZone.run(() => {
          const place: any = this.autocomplete?.getPlace();
          if (!place || !place.geometry) {
            this.snackBar.open('No valid place selected. Try another search term.', 'Close', { duration: 3000 });
            return;
          }

          this.territoryForm.patchValue({ name: place.name, searchArea: place.name });

          // Clear existing drawings
          this.clearDrawing();

          // Check for predefined area in territoryService
          const territory = this.territoryService.getPredefinedArea(place.name);
          if (territory) {
            try {
              const paths = JSON.parse(territory.geometry);
              if (this.isValidPolygonPaths(paths)) {
                this.currentPolygon = new google.maps.Polygon({
                  paths,
                  fillColor: '#2196F3',
                  fillOpacity: 0.3,
                  strokeWeight: 2,
                  strokeColor: '#2196F3',
                  editable: true,
                  map: this.map,
                });
                this.zoomToPolygon(this.currentPolygon);
                this.snackBar.open(`${place.name} loaded with predefined boundaries`, 'Close', { duration: 3000 });
                return;
              } else {
                this.snackBar.open(`Invalid predefined boundaries for ${place.name}`, 'Close', { duration: 3000 });
              }
            } catch (error) {
              console.error('Error parsing predefined geometry:', error);
              this.snackBar.open(`Error loading predefined boundaries for ${place.name}`, 'Close', { duration: 3000 });
            }
          }

          // Fetch boundaries via geocoding if no predefined area
          this.fetchPlaceBoundaries(place).then((paths) => {
            if (paths && this.isValidPolygonPaths(paths)) {
              this.currentPolygon = new google.maps.Polygon({
                paths,
                fillColor: '#2196F3',
                fillOpacity: 0.3,
                strokeWeight: 2,
                strokeColor: '#2196F3',
                editable: true,
                map: this.map,
              });
              this.zoomToPolygon(this.currentPolygon);
              this.snackBar.open(`${place.name} boundaries loaded`, 'Close', { duration: 3000 });
            } else {
              // No boundaries available, zoom to viewport or location
              if (place.geometry.viewport) {
                this.map!.fitBounds(place.geometry.viewport);
              } else if (place.geometry.location) {
                this.map!.panTo(place.geometry.location);
                this.map!.setZoom(15);
              }
              this.snackBar.open(`No boundaries for ${place.name}. Draw manually.`, 'Close', { duration: 3000 });
              this.enableDrawing();
            }
          }).catch((error) => {
            console.error('Error fetching boundaries:', error);
            this.snackBar.open(`Failed to load boundaries for ${place.name}. Draw manually.`, 'Close', { duration: 3000 });
            if (place.geometry.viewport) {
              this.map!.fitBounds(place.geometry.viewport);
            } else if (place.geometry.location) {
              this.map!.panTo(place.geometry.location);
              this.map!.setZoom(15);
            }
            this.enableDrawing();
          });
        });
      });
    } catch (error) {
      this.snackBar.open('Failed to initialize area search', 'Close', { duration: 3000 });
      console.error('Autocomplete initialization error:', error);
    }
  }

  zoomToPolygon(polygon: google.maps.Polygon) {
    if (!this.map || !polygon) return;
    const bounds = new google.maps.LatLngBounds();
    const path = polygon.getPath().getArray();
    path.forEach((latLng: google.maps.LatLng) => bounds.extend(latLng));
    if (!bounds.isEmpty()) {
      this.map.fitBounds(bounds);
    }
  }

  async fetchPlaceBoundaries(place: google.maps.places.PlaceResult): Promise<google.maps.LatLngLiteral[] | null> {
    if (!place.place_id) return null;

    const geocoder = new google.maps.Geocoder();
    return new Promise((resolve, reject) => {
      geocoder.geocode({ placeId: place.place_id }, (results, status) => {
        if (status === google.maps.GeocoderStatus.OK && results && results[0].geometry) {
          const geometry = results[0].geometry;
          if (geometry.viewport) {
            const bounds = geometry.viewport;
            const paths = [
              { lat: bounds.getNorthEast().lat(), lng: bounds.getNorthEast().lng() },
              { lat: bounds.getNorthEast().lat(), lng: bounds.getSouthWest().lng() },
              { lat: bounds.getSouthWest().lat(), lng: bounds.getSouthWest().lng() },
              { lat: bounds.getSouthWest().lat(), lng: bounds.getNorthEast().lng() }
            ];
            resolve(paths);
          } else if (geometry.bounds) {
            const bounds = geometry.bounds;
            const paths = [
              { lat: bounds.getNorthEast().lat(), lng: bounds.getNorthEast().lng() },
              { lat: bounds.getNorthEast().lat(), lng: bounds.getSouthWest().lng() },
              { lat: bounds.getSouthWest().lat(), lng: bounds.getSouthWest().lng() },
              { lat: bounds.getSouthWest().lat(), lng: bounds.getNorthEast().lng() }
            ];
            resolve(paths);
          } else {
            resolve(null);
          }
        } else {
          reject(new Error(`Geocoding failed: ${status}`));
        }
      });
    });
  }

  enableDrawing() {
    this.clearDrawing();
    if (this.drawingManager) {
      this.drawingManager.setDrawingMode(google.maps.drawing.OverlayType.POLYGON);
    }
    this.displayTerritories();
  }

  clearDrawing() {
    // Clear the current polygon
    if (this.currentPolygon) {
      this.currentPolygon.setMap(null);
      this.currentPolygon = null;
    }
    // Clear all territory polygons
    this.clearAllPolygons();
    // Reset drawing mode
    if (this.drawingManager) {
      this.drawingManager.setDrawingMode(null);
    }
  }

  clearAllPolygons() {
    this.territories.forEach(territory => {
      if (territory.polygon && typeof territory.polygon.setMap === 'function') {
        territory.polygon.setMap(null);
        territory.polygon = null;
      }
    });
  }

  loadSalesmen() {
    this.territoryService.getSalesmen().subscribe({
      next: (data: any) => {
        this.salesmen = data.data.map((salesman: any) => ({
          id: salesman.user_id,
          name: salesman.full_name
        }));
      },
      error: () => this.snackBar.open('Failed to load salesmen', 'Close', { duration: 3000 })
    });
  }

  loadTerritories() {
    this.isLoading = true;
    const params = {
      search: this.searchQuery || undefined,
      limit: this.pagination.limit,
      page: this.pagination.page
    };

    this.territoryService.getTerritories(params).subscribe({
      next: (response: any) => {
        this.isLoading = false;
        this.territories = response.data.flatMap((territory: any) => {
          const paths = territory.polygon.geometry.coordinates[0].map(([lng, lat]: [number, number]) => ({
            lat,
            lng
          }));
          let postalCodes = territory.postal_codes || [];
          let regions = territory.regions || [];
          let subregions = territory.subregions || [];
          try {
            postalCodes = typeof postalCodes === 'string' ? JSON.parse(postalCodes) : postalCodes;
            regions = typeof regions === 'string' ? JSON.parse(regions) : regions;
            subregions = typeof subregions === 'string' ? JSON.parse(subregions) : subregions;
          } catch (e) {
            console.warn('Error parsing territory fields', { postalCodes, regions, subregions }, e);
          }
          return territory.salesmen.map((s: any) => ({
            id: territory.territory_id,
            name: territory.name,
            salesmanId: s.user_id,
            geometry: JSON.stringify(paths),
            postal_codes: postalCodes,
            regions: regions,
            subregions: subregions,
            polygon: null
          }));
        });
        this.dataSource.data = this.territories;
        // Update pagination data
        this.pagination.totalItems = response.pagination.totalItems;
        this.pagination.totalPages = response.pagination.totalPages;
        if (this.mapInitialized.value) {
          this.displayTerritories();
        }
      },
      error: (error: any) => {
        this.snackBar.open('Failed to load territories', 'Close', { duration: 3000 });
        this.isLoading = false;
      }
    });
  }

  displayTerritories() {
    if (!this.map) {
      console.warn('Map not initialized in displayTerritories');
      return;
    }
    this.clearAllPolygons();
    const processedTerritoryIds = new Set<string>();
    this.territories.forEach(territory => {
      if (processedTerritoryIds.has(territory.id)) {
        return;
      }
      processedTerritoryIds.add(territory.id);
      try {
        const paths = JSON.parse(territory.geometry);
        if (!this.isValidPolygonPaths(paths)) {
          console.warn(`Invalid polygon paths for territory ${territory.name}`, paths);
          this.snackBar.open(`Skipping invalid polygon for ${territory.name}`, 'Close', { duration: 3000 });
          return;
        }
        const polygon = new google.maps.Polygon({
          paths,
          fillColor: '#2196F3',
          fillOpacity: 0.3,
          strokeWeight: 2,
          strokeColor: '#2196F3',
          editable: false,
          map: this.map
        });
        territory.polygon = polygon;
      } catch (error) {
        console.warn(`Failed to create polygon for territory ${territory.name}`, error);
        this.snackBar.open(`Failed to display polygon for ${territory.name}`, 'Close', { duration: 3000 });
      }
    });
  }

  isValidPolygonPaths(paths: any): boolean {
    if (!Array.isArray(paths) || paths.length === 0) return false;
    return paths.every(coord =>
      coord &&
      typeof coord.lat === 'number' &&
      typeof coord.lng === 'number' &&
      isFinite(coord.lat) &&
      isFinite(coord.lng)
    );
  }

  saveTerritory() {
    if (!this.map || !this.currentPolygon || !this.territoryForm.valid) {
      this.snackBar.open('Please complete the form, draw a polygon, and ensure map is loaded', 'Close', { duration: 3000 });
      return;
    }
    this.isSaving = true;
    const paths = this.currentPolygon.getPath().getArray().map((latLng: google.maps.LatLng) => ({
      lat: latLng.lat(),
      lng: latLng.lng()
    }));
    if (!this.isValidPolygonPaths(paths)) {
      this.snackBar.open('Invalid polygon coordinates', 'Close', { duration: 3000 });
      this.isSaving = false;
      return;
    }
    const territory = {
      name: this.territoryForm.get('name')?.value,
      salesmanIds: this.territoryForm.get('salesmanIds')?.value,
      geometry: JSON.stringify(paths)
    };

    this.territoryService.addTerritory(territory).subscribe({
      next: (response: any) => {
        const newTerritories = territory.salesmanIds.map((salesmanId: string) => ({
          id: response.id,
          name: territory.name,
          salesmanId,
          geometry: territory.geometry,
          polygon: this.currentPolygon
        }));
        this.territories = [...this.territories, ...newTerritories];
        this.dataSource.data = this.territories;
        const salesmanNames = territory.salesmanIds.map((id: string) => this.getSalesmanName(id)).join(', ');
        this.snackBar.open(`Territory ${territory.name} assigned to ${salesmanNames}`, ', Close', { duration: 3000 });
        this.currentPolygon = null;
        this.territoryForm.reset({ salesmanIds: [] });
        this.isSaving = false;
        this.pagination.page = 1; // Reset to first page after adding new territory
        this.loadTerritories(); // Reload territories to reflect changes
      },
      error: (error: any) => {
        this.snackBar.open(`Failed to save territory: ${error.message}`, 'Close', { duration: 5000 });
        console.error('Save territory error:', error);
        this.isSaving = false;
      }
    });
  }

  editTerritory(territory: any) {
    if (!this.map) {
      this.snackBar.open('Map not initialized', 'Close', { duration: 3000 });
      return;
    }
    try {
      const paths = JSON.parse(territory.geometry);
      if (!this.isValidPolygonPaths(paths)) {
        this.snackBar.open(`Cannot edit ${territory.name}: Invalid polygon coordinates`, 'Close', { duration: 3000 });
        return;
      }
      this.clearDrawing();
      this.territoryForm.patchValue({
        name: territory.name,
        salesmanIds: []
      });
      if (!territory.polygon) {
        territory.polygon = new google.maps.Polygon({
          paths,
          fillColor: '#2196F3',
          fillOpacity: 0.3,
          strokeWeight: 2,
          strokeColor: '#2196F3',
          editable: true,
          map: this.map
        });
      } else {
        territory.polygon.setEditable(true);
        territory.polygon.setMap(this.map);
      }
      this.currentPolygon = territory.polygon;
      this.zoomToTerritory(territory);
    } catch (error) {
      this.snackBar.open(`Cannot edit ${territory.name}: Failed to load polygon`, 'Close', { duration: 3000 });
      console.error('Edit territory error:', error);
    }
  }

  deleteTerritory(id: string, salesmanId: string) {
    this.isLoading = true;
    const otherAssignments = this.territories.filter(t => t.id === id && t.salesmanId !== salesmanId);
    if (otherAssignments.length > 0) {
      this.territoryService.updateTerritory(id, { salesmanIdToRemove: salesmanId }).subscribe({
        next: () => {
          this.isLoading = false;
          this.territories = this.territories.filter(t => !(t.id === id && t.salesmanId === salesmanId));
          this.dataSource.data = this.territories;
          const salesmanName = this.getSalesmanName(salesmanId);
          this.snackBar.open(`Salesman ${salesmanName} removed from territory`, 'Close', { duration: 3000 });
          this.pagination.page = 1; // Reset to first page after deletion
          this.loadTerritories(); // Reload territories to reflect changes
        },
        error: () => {
          this.isLoading = false;
          this.snackBar.open('Failed to remove salesman from territory', 'Close', { duration: 3000 })}
      });
    } else {
      this.territoryService.deleteTerritory(id).subscribe({
        next: () => {
          this.isLoading = false;
          const territory = this.territories.find(t => t.id === id);
          if (territory && territory.polygon) {
            territory.polygon.setMap(null);
          }
          this.territories = this.territories.filter(t => t.id !== id);
          this.dataSource.data = this.territories;
          const salesmanName = this.getSalesmanName(salesmanId);
          this.snackBar.open(`Territory deleted for ${salesmanName}`, 'Close', { duration: 3000 });
          this.pagination.page = 1; // Reset to first page after deletion
          this.loadTerritories(); // Reload territories to reflect changes
        },
        error: () => {
          this.isLoading = false;
          this.snackBar.open('Failed to delete territory', 'Close', { duration: 3000 })}
      });
    }
  }

  zoomToTerritory(territory: any) {
    if (!this.map) {
      this.snackBar.open('Map not initialized', 'Close', { duration: 3000 });
      return;
    }
    // Clear all existing polygons
    this.clearAllPolygons();

    // Redraw only the selected territory's polygon
    try {
      const paths = JSON.parse(territory.geometry);
      if (!this.isValidPolygonPaths(paths)) {
        this.snackBar.open(`Cannot zoom to ${territory.name}: Invalid coordinates`, 'Close', { duration: 3000 });
        return;
      }
      territory.polygon = new google.maps.Polygon({
        paths,
        fillColor: '#2196F3',
        fillOpacity: 0.3,
        strokeWeight: 2,
        strokeColor: '#2196F3',
        editable: false,
        map: this.map
      });
    const bounds = new google.maps.LatLngBounds();
    const path = territory.polygon.getPath().getArray();
    const convertedPath = path.map((latLng: any) => ({
      lat: latLng.lat(),
      lng: latLng.lng()
    }));
    if (!this.isValidPolygonPaths(convertedPath)) {
      console.warn(`Cannot zoom to ${territory.name}: Invalid coordinates`, convertedPath);
      this.snackBar.open(`Cannot zoom to ${territory.name}: Invalid coordinates`, 'Close', { duration: 3000 });
      return;
    }
    path.forEach((latLng: google.maps.LatLng) => bounds.extend(latLng));
    this.map.fitBounds(bounds);
  } catch (error) {
    console.warn(`Failed to recreate polygon for ${territory.name}`, error);
    this.snackBar.open(`Cannot zoom to ${territory.name}: Failed to load polygon`, 'Close', { duration: 3000 });
  }
  }

  getSalesmanName(id: string): string {
    const salesman = this.salesmen.find(s => s.id === id);
    return salesman ? salesman.name : 'Not Assigned';
  }

  filterTerritoriesBySalesman(salesmanId: string) {
    if (!this.map) {
      console.warn('Map not initialized in filterTerritoriesBySalesman');
      this.snackBar.open('Map not ready, please try again', 'Close', { duration: 3000 });
      return;
    }
    this.clearAllPolygons();
    const filtered = this.territories.filter(t => t.salesmanId === salesmanId && this.isValidPolygonPaths(JSON.parse(t.geometry)));
    filtered.forEach(t => {
      if (!t.polygon) {
        const paths = JSON.parse(t.geometry);
        t.polygon = new google.maps.Polygon({
          paths,
          fillColor: '#2196F3',
          fillOpacity: 0.3,
          strokeWeight: 2,
          strokeColor: '#2196F3',
          editable: false,
          map: this.map
        });
      } else {
        t.polygon.setMap(this.map);
      }
    });

    if (filtered.length > 0) {
      const bounds = new google.maps.LatLngBounds();
      filtered.forEach(territory => {
        if (territory.polygon && territory.polygon.getPath()) {
          const path = territory.polygon.getPath().getArray();
          if (this.isValidPolygonPaths(path.map((latLng: any) => ({ lat: latLng.lat(), lng: latLng.lng() })))) {
            path.forEach((latLng: google.maps.LatLng) => bounds.extend(latLng));
          }
        }
      });
      if (!bounds.isEmpty()) {
        this.map.fitBounds(bounds);
      }
      this.snackBar.open(`Showing ${filtered.length} territories for ${this.getSalesmanName(salesmanId)}`, 'Close', { duration: 3000 });
    } else {
      this.snackBar.open(`No valid territories assigned to ${this.getSalesmanName(salesmanId)}`, 'Close', { duration: 3000 });
    }
  }

  showTerritoryDetails(territory: any) {
    this.dialog.open(TerritoryDetailsDialogComponent, {
      width: '500px',
      data: {
        name: territory.name,
        postal_codes: territory.postal_codes,
        regions: territory.regions,
        subregions: territory.subregions
      }
    });
  }
}