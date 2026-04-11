import { Component, OnInit, ViewChild, NgZone } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { TerritoryService } from '../territory.service';
import { BehaviorSubject } from 'rxjs';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { SharedModule } from '../../shared/shared.module';

@Component({
  selector: 'app-manager-list',
  templateUrl: './manager-list.component.html',
  styleUrls: ['./manager-list.component.scss'],
  imports: [SharedModule]
})
export class ManagerListComponent implements OnInit {
  @ViewChild(MatSort) sort!: MatSort;
  map: google.maps.Map | null = null;
  drawingManager: google.maps.drawing.DrawingManager | null = null;
  currentPolygon: google.maps.Polygon | null = null;
  territories: any[] = [];
  managers: any[] = [];
  managerForm: FormGroup;
  autocomplete: google.maps.places.Autocomplete | null = null;
  isSaving: boolean = false;
  dataSource = new MatTableDataSource<any>([]);
  displayedColumns: string[] = ['name', 'manager', 'actions'];
  private mapInitialized = new BehaviorSubject<boolean>(false);

  constructor(
    private fb: FormBuilder,
    private snackBar: MatSnackBar,
    private territoryService: TerritoryService,
    private ngZone: NgZone
  ) {
    this.managerForm = this.fb.group({
      name: ['', Validators.required],
      managerIds: [[], Validators.required],
      searchArea: ['']
    });
  }

  ngOnInit() {
    this.loadManagers();
    this.loadTerritories();
    this.initMap();

    this.managerForm.get('managerIds')?.valueChanges.pipe(
      debounceTime(300),
      distinctUntilChanged((prev, curr) => JSON.stringify(prev) === JSON.stringify(curr))
    ).subscribe(managerIds => {
      if (managerIds.length > 0 && !this.currentPolygon) {
        this.filterTerritoriesByManager(managerIds[0]);
      }
    });

    window.addEventListener('resize', () => this.ngZone.run(() => this.adjustMapBounds()));
  }

  ngAfterViewInit() {
    this.dataSource.sort = this.sort;
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
        fillColor: '#FF9800',
        fillOpacity: 0.3,
        strokeWeight: 2,
        strokeColor: '#FF9800',
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

          this.managerForm.patchValue({ name: place.name, searchArea: place.name });
          this.clearDrawing();

          const territory = this.territoryService.getPredefinedArea(place.name);
          if (territory) {
            const paths = JSON.parse(territory.geometry);
            if (!this.isValidPolygonPaths(paths)) {
              this.snackBar.open(`Invalid predefined boundaries for ${place.name}`, 'Close', { duration: 3000 });
              return;
            }
            this.currentPolygon = new google.maps.Polygon({
              paths,
              fillColor: '#FF9800',
              fillOpacity: 0.3,
              strokeWeight: 2,
              strokeColor: '#FF9800',
              editable: true,
              map: this.map
            });
            this.zoomToTerritory({ polygon: this.currentPolygon });
            this.snackBar.open(`${place.name} loaded with predefined boundaries`, 'Close', { duration: 3000 });
            return;
          }

          this.fetchPlaceBoundaries(place).then((paths) => {
            if (paths) {
              this.currentPolygon = new google.maps.Polygon({
                paths,
                fillColor: '#FF9800',
                fillOpacity: 0.3,
                strokeWeight: 2,
                strokeColor: '#FF9800',
                editable: true,
                map: this.map
              });
              this.zoomToTerritory({ polygon: this.currentPolygon });
              this.snackBar.open(`${place.name} boundaries loaded`, 'Close', { duration: 3000 });
            } else if (place.geometry.viewport) {
              this.map!.fitBounds(place.geometry.viewport);
              this.snackBar.open(`No boundaries for ${place.name}. Draw manually.`, 'Close', { duration: 3000 });
              this.enableDrawing();
            } else if (place.geometry.location) {
              this.map!.panTo(place.geometry.location);
              this.map!.setZoom(15);
              this.snackBar.open(`No boundaries for ${place.name}. Draw manually.`, 'Close', { duration: 3000 });
              this.enableDrawing();
            } else {
              this.snackBar.open(`No boundaries available for ${place.name}. Draw manually.`, 'Close', { duration: 3000 });
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
  }

  clearDrawing() {
    if (this.currentPolygon) {
      this.currentPolygon.setMap(null);
      this.currentPolygon = null;
    }
    this.clearAllPolygons();
    if (this.drawingManager) {
      this.drawingManager.setDrawingMode(null);
    }
  }

  clearAllPolygons() {
    this.territories.forEach(territory => {
      if (territory.polygon && typeof territory.polygon.setMap === 'function') {
        try {
          territory.polygon.setMap(null);
          territory.polygon = null;
        } catch (error) {
          console.warn(`Failed to clear polygon for territory ${territory.name}`, error);
        }
      }
    });
  }

  loadManagers() {
    this.territoryService.getManagers().subscribe({
      next: (teamMembers: any[]) => {
        this.managers = teamMembers.map((manager: any) => ({
          id: manager.user_id,
          name: manager.full_name && manager.full_name !== 'undefined undefined' ? manager.full_name : manager.email
        }));
      },
      error: () => this.snackBar.open('Failed to load managers', 'Close', { duration: 3000 })
    });
  }

  loadTerritories() {
    this.territoryService.getTerritories().subscribe({
      next: (response: any) => {
        this.territories = response.flatMap((territory: any) => {
          const paths = territory.polygon.geometry.coordinates[0].map(([lng, lat]: [number, number]) => ({
            lat,
            lng
          }));
          return (territory.managers || []).map((m: any) => ({
            id: territory.territory_id,
            name: territory.name,
            managerIds: [m.user_id],
            geometry: JSON.stringify(paths),
            polygon: null
          }));
        });
        this.dataSource.data = this.territories;
        if (this.mapInitialized.value) {
          this.displayTerritories();
        }
      },
      error: () => this.snackBar.open('Failed to load territories', 'Close', { duration: 3000 })
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
          fillColor: '#FF9800',
          fillOpacity: 0.3,
          strokeWeight: 2,
          strokeColor: '#FF9800',
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

  saveManagerAssignment() {
    if (!this.map || !this.currentPolygon || !this.managerForm.valid) {
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
      name: this.managerForm.get('name')?.value,
      managerIds: this.managerForm.get('managerIds')?.value,
      geometry: JSON.stringify(paths)
    };

    this.territoryService.addTerritory(territory).subscribe({
      next: (response: any) => {
        const newTerritories = territory.managerIds.map((managerId: string) => ({
          id: response.id,
          name: territory.name,
          managerIds: [managerId],
          geometry: territory.geometry,
          polygon: this.currentPolygon
        }));
        this.territories = [...this.territories, ...newTerritories];
        this.dataSource.data = this.territories;
        const managerNames = this.getManagerNames(territory.managerIds);
        this.snackBar.open(`Territory ${territory.name} assigned to ${managerNames}`, 'Close', { duration: 3000 });
        this.currentPolygon = null;
        this.managerForm.reset({ name: '', managerIds: [], searchArea: '' });
        this.isSaving = false;
        this.displayTerritories();
      },
      error: (error: any) => {
        this.snackBar.open(`Failed to save territory: ${error.message}`, 'Close', { duration: 5000 });
        console.error('Save territory error:', error);
        this.isSaving = false;
      }
    });
  }

  removeManagerAssignment(territoryId: string, managerIds: string[]) {
    const otherAssignments = this.territories.filter(t => t.id === territoryId && !managerIds.includes(t.managerIds[0]));
    if (otherAssignments.length > 0) {
      this.territories = this.territories.filter(t => t.id !== territoryId || !managerIds.includes(t.managerIds[0]));
      this.dataSource.data = this.territories;
      this.territoryService.updateTerritory(territoryId, { managerIds: otherAssignments.map(t => t.managerIds[0]) }).subscribe({
        next: () => {
          const managerNames = this.getManagerNames(managerIds);
          this.snackBar.open(`Managers ${managerNames} removed from territory`, 'Close', { duration: 3000 });
          this.displayTerritories();
        },
        error: () => this.snackBar.open('Failed to remove manager from territory', 'Close', { duration: 3000 })
      });
    } else {
      this.territoryService.deleteTerritory(territoryId).subscribe({
        next: () => {
          const territory = this.territories.find(t => t.id === territoryId);
          if (territory && territory.polygon) {
            territory.polygon.setMap(null);
          }
          this.territories = this.territories.filter(t => t.id !== territoryId);
          this.dataSource.data = this.territories;
          const managerNames = this.getManagerNames(managerIds);
          this.snackBar.open(`Territory deleted for ${managerNames}`, 'Close', { duration: 3000 });
          this.displayTerritories();
        },
        error: () => this.snackBar.open('Failed to delete territory', 'Close', { duration: 3000 })
      });
    }
  }

  zoomToTerritory(territory: any) {
    if (!this.map) {
      this.snackBar.open('Map not initialized', 'Close', { duration: 3000 });
      return;
    }
    this.clearAllPolygons();
    try {
      const paths = JSON.parse(territory.geometry);
      if (!this.isValidPolygonPaths(paths)) {
        this.snackBar.open(`Cannot zoom to ${territory.name}: Invalid coordinates`, 'Close', { duration: 3000 });
        return;
      }
      territory.polygon = new google.maps.Polygon({
        paths,
        fillColor: '#FF9800',
        fillOpacity: 0.3,
        strokeWeight: 2,
        strokeColor: '#FF9800',
        editable: false,
        map: this.map
      });
      const bounds = new google.maps.LatLngBounds();
      const path = territory.polygon.getPath().getArray();
      path.forEach((latLng: google.maps.LatLng) => bounds.extend(latLng));
      this.map.fitBounds(bounds);
    } catch (error) {
      console.warn(`Failed to recreate polygon for ${territory.name}`, error);
      this.snackBar.open(`Cannot zoom to ${territory.name}: Failed to load polygon`, 'Close', { duration: 3000 });
    }
  }

  getManagerNames(ids: string[]): string {
    if (!ids || ids.length === 0) return 'None';
    return ids.map(id => this.managers.find(m => m.id === id)?.name || 'Unknown').join(', ');
  }

  filterTerritoriesByManager(managerId: string) {
    if (!this.map) {
      console.warn('Map not initialized in filterTerritoriesByManager');
      this.snackBar.open('Map not ready, please try again', 'Close', { duration: 3000 });
      return;
    }
    this.clearAllPolygons();

    const filtered = this.territories.filter(t => t.managerIds.includes(managerId) && this.isValidPolygonPaths(JSON.parse(t.geometry)));
    filtered.forEach(t => {
      if (!t.polygon) {
        const paths = JSON.parse(t.geometry);
        t.polygon = new google.maps.Polygon({
          paths,
          fillColor: '#FF9800',
          fillOpacity: 0.3,
          strokeWeight: 2,
          strokeColor: '#FF9800',
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
      this.snackBar.open(`Showing ${filtered.length} territories for ${this.getManagerNames([managerId])}`, 'Close', { duration: 3000 });
    } else {
      this.snackBar.open(`No valid territories assigned to ${this.getManagerNames([managerId])}`, 'Close', { duration: 3000 });
    }
  }
}