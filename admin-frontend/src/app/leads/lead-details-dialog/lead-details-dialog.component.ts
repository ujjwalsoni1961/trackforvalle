import { Component, OnInit, Inject, NgZone, ViewChild } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatSelectModule } from '@angular/material/select';
import { MatTabsModule } from '@angular/material/tabs';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatSnackBarModule, MatSnackBar } from '@angular/material/snack-bar';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatAutocompleteModule } from '@angular/material/autocomplete';
import { LeadsService } from '../leads.service';
import { VisitsService } from '../../visits/visits.service';
import { CommonModule } from '@angular/common';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatIconModule } from '@angular/material/icon';
import { MatTabGroup } from '@angular/material/tabs';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule, MatPaginator } from '@angular/material/paginator';
import { MatTooltipModule } from '@angular/material/tooltip'; // Added for notes tooltip
import { ContractsService } from '../../contracts/contracts.service';
import { downloadPdfFromHtml } from '../../shared/pdf-generator';

// Define LeadStatus type
type LeadStatus = 'Get Back' | 'Not Available' | 'Not Interested' | 'Meeting' | 'Hot Lead' | 'Signed' | 'Start Signing' | 'Not Sellable' | 'Prospect';

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
  is_visited: boolean | null;
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

interface LeadStatusColor {
  status: LeadStatus;
  color: {
    name: string;
    hex: string;
  };
}

interface FollowUp {
  follow_up_id: number;
  subject: string;
  notes: string;
  scheduled_date: string;
  is_completed: boolean;
  created_by: number;
  created_at: string;
  updated_at: string;
}

interface FollowUpVisit {
  follow_up_visit_id: number;
  follow_up_id: number;
  visit_id: number;
  created_at: string;
  followUp: FollowUp;
}

interface Visit {
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
  status: string;
  lead: Lead;
  contract: {
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
  } | null;
  followUpVisits: FollowUpVisit[];
}

@Component({
  selector: 'app-lead-details-dialog',
  standalone: true,
  imports: [
    CommonModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSelectModule,
    MatTabsModule,
    FormsModule,
    ReactiveFormsModule,
    MatSnackBarModule,
    MatProgressBarModule,
    MatIconModule,
    MatTableModule,
    MatPaginatorModule,
    MatTooltipModule,
    MatAutocompleteModule
  ],
  templateUrl: './lead-details-dialog.component.html',
  styleUrls: ['./lead-details-dialog.component.scss']
})
export class LeadDetailsDialogComponent implements OnInit {
  @ViewChild(MatTabGroup) tabGroup!: MatTabGroup;
  @ViewChild(MatPaginator) paginator!: MatPaginator;
  leadForm: FormGroup;
  addressForm: FormGroup;
  assignForm: FormGroup;
  googleMapsUrl: string;
  map: google.maps.Map | null = null;
  salesmen: User[] = [];
  isLoading: boolean = false;
  visitsLoading: boolean = false;
  statuses: LeadStatus[] = ['Get Back', 'Not Available', 'Not Interested', 'Meeting', 'Hot Lead', 'Signed', 'Start Signing', 'Not Sellable', 'Prospect'];
  statusColors: Record<LeadStatus, { backgroundColor: string; color: string }> = {
    'Get Back': { backgroundColor: '#FB9D4A', color: '#FFFFFF' },
    'Not Available': { backgroundColor: '#F9F984', color: '#000000' },
    'Not Interested': { backgroundColor: '#F94E5E', color: '#FFFFFF' },
    'Meeting': { backgroundColor: '#68D1F3', color: '#000000' },
    'Hot Lead': { backgroundColor: '#B57FB5', color: '#FFFFFF' },
    'Signed': { backgroundColor: '#59A559', color: '#FFFFFF' },
    'Start Signing': { backgroundColor: '#A8F5FF', color: '#000000' },
    'Not Sellable': { backgroundColor: '#D3D3D3', color: '#808080' },
    'Prospect': { backgroundColor: '#FB9D4A', color: '#FFFFFF' }
  };
  visits: Visit[] = [];
  followUps: FollowUpVisit[] = [];

  // City autocomplete
  finnishCities: string[] = [
    'Helsinki', 'Espoo', 'Tampere', 'Vantaa', 'Oulu', 'Turku', 'Jyväskylä', 'Lahti',
    'Kuopio', 'Pori', 'Kouvola', 'Joensuu', 'Lappeenranta', 'Hämeenlinna', 'Vaasa',
    'Seinäjoki', 'Rovaniemi', 'Mikkeli', 'Kotka', 'Salo', 'Porvoo', 'Kokkola',
    'Hyvinkää', 'Lohja', 'Järvenpää', 'Rauma', 'Kajaani', 'Kerava', 'Savonlinna',
    'Nokia', 'Ylöjärvi', 'Kangasala', 'Riihimäki', 'Raseborg', 'Imatra', 'Sastamala',
    'Raisio', 'Hollola', 'Iisalmi', 'Siilinjärvi', 'Valkeakoski', 'Tornio',
    'Kirkkonummi', 'Sipoo', 'Kemi', 'Naantali', 'Heinola', 'Forssa', 'Pieksämäki',
    'Lempäälä', 'Akaa', 'Kuusamo', 'Hamina', 'Äänekoski', 'Uusikaupunki',
    'Laukaa', 'Lieto', 'Pirkkala', 'Jämsä', 'Kaarina', 'Nurmo', 'Vammala',
    'Loviisa', 'Parainen', 'Ylivieska', 'Nivala', 'Lieksa', 'Outokumpu',
    'Kankaanpää', 'Kemijärvi', 'Sotkamo', 'Mäntsälä', 'Nurmijärvi', 'Tuusula',
    'Kauniainen', 'Pietarsaari', 'Raahe', 'Orimattila', 'Janakkala'
  ].sort();

  filteredCities: string[] = [];

  // Country dropdown
  countries: string[] = [
    'Finland', 'Sweden', 'Norway', 'Denmark', 'Estonia', 'Germany', 'United Kingdom',
    'France', 'Spain', 'Italy', 'Netherlands', 'Belgium', 'Austria', 'Switzerland',
    'Poland', 'Czech Republic', 'Portugal', 'Ireland', 'Latvia', 'Lithuania',
    'Iceland', 'Luxembourg', 'United States', 'Canada', 'India', 'Other'
  ];

  displayedColumns: string[] = ['visit_id', 'check_in_time', 'status', 'notes', 'location', 'next_visit_date', 'contract', 'created_at']; // Added location and next_visit_date
  followUpColumns: string[] = ['follow_up_id', 'subject', 'notes', 'scheduled_date', 'is_completed', 'visit_id', 'created_at'];
  totalItems: number = 0;
  currentPage: number = 1;
  pageSize: number = 10;

  constructor(
    @Inject(MAT_DIALOG_DATA) public data: { lead: Lead; salesmen: User[] },
    public dialogRef: MatDialogRef<LeadDetailsDialogComponent>,
    private fb: FormBuilder,
    private leadsService: LeadsService,
    private visitsService: VisitsService,
    private contractService: ContractsService,
    private snackBar: MatSnackBar,
    private ngZone: NgZone
  ) {
    this.leadForm = this.fb.group({
      name: [this.data.lead.name],
      contact_email: [this.data.lead.contact_email, [Validators.email]],
      contact_phone: [this.data.lead.contact_phone, [Validators.pattern(/^\+?\d{10,15}$/)]],
      status: [this.data.lead.status, Validators.required]
    });

    this.addressForm = this.fb.group({
      street_address: [this.data.lead.address?.street_address || '', Validators.required],
      city: [this.data.lead.address?.city || '', Validators.required],
      state: [this.data.lead.address?.state || '', Validators.required],
      postal_code: [this.data.lead.address?.postal_code || '', [Validators.required, Validators.pattern(/^[A-Za-z0-9\s\-]{3,10}$/)]],
      country: [this.data.lead.address?.country || '', Validators.required],
      latitude: [this.data.lead.address?.latitude || null, [Validators.required, Validators.min(-90), Validators.max(90)]],
      longitude: [this.data.lead.address?.longitude || null, [Validators.required, Validators.min(-180), Validators.max(180)]],
      landmark: [this.data.lead.address?.landmark || '']
    });

    this.assignForm = this.fb.group({
      assigned_rep_id: [this.data.lead.assigned_rep_id || '']
    });

    this.googleMapsUrl = this.data.lead.address
      ? `https://www.google.com/maps/dir/?api=1&destination=${this.data.lead.address.latitude},${this.data.lead.address.longitude}`
      : '';

    this.salesmen = this.data.salesmen;

    this.leadForm.markAllAsTouched();
    this.addressForm.markAllAsTouched();
  }

  ngOnInit() {
    this.fetchLeadStatusColors();
    if (this.data.lead.address) {
      this.initializeMap();
    }
    this.fetchVisits();
    this.filteredCities = this.finnishCities;
    this.addressForm.get('city')?.valueChanges.subscribe(value => {
      this.filterCities(value || '');
    });
  }

  filterCities(value: string): void {
    const filterValue = value.toLowerCase();
    this.filteredCities = this.finnishCities.filter(city =>
      city.toLowerCase().includes(filterValue)
    );
  }

  fetchLeadStatusColors(): void {
    this.leadsService.getLeadStatusColors().subscribe({
      next: (response) => {
        const statusColors = response.data.reduce((acc, item) => {
          acc[item.status] = {
            backgroundColor: item.color.hex,
            color: this.getContrastColor(item.color.hex)
          };
          return acc;
        }, {} as Record<LeadStatus, { backgroundColor: string; color: string }>);
        this.statusColors = { ...this.statusColors, ...statusColors };
      },
      error: (err) => {
        this.snackBar.open('Failed to load status colors', 'Close', { duration: 3000 });
      }
    });
  }

  private getContrastColor(hex: string): string {
    hex = hex.replace('#', '');
    const r = parseInt(hex.slice(0, 2), 16);
    const g = parseInt(hex.slice(2, 4), 16);
    const b = parseInt(hex.slice(4, 6), 16);
    const luminance = (r * 299 + g * 587 + b * 114) / 1000;
    return luminance >= 128 ? '#000000' : '#FFFFFF';
  }

  initializeMap() {
    this.ngZone.runOutsideAngular(() => {
      setTimeout(() => {
        const mapElement = document.getElementById('map') as HTMLElement;
        if (!mapElement) {
          this.snackBar.open('Map container not found', 'Close', { duration: 3000 });
          return;
        }

        if (typeof google === 'undefined' || !google.maps) {
          this.snackBar.open('Google Maps API not loaded', 'Close', { duration: 3000 });
          return;
        }

        this.map = new google.maps.Map(mapElement, {
          center: { lat: this.data.lead.address!.latitude, lng: this.data.lead.address!.longitude },
          zoom: 15,
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          styles: [
            { featureType: "poi", stylers: [{ visibility: "simplified" }] },
            { featureType: "transit", stylers: [{ visibility: "simplified" }] }
          ],
          mapTypeControl: false,
          streetViewControl: false
        });

        new google.maps.Marker({
          position: { lat: this.data.lead.address!.latitude, lng: this.data.lead.address!.longitude },
          map: this.map,
          icon: {
            path: google.maps.SymbolPath.CIRCLE,
            fillColor: this.statusColors[this.data.lead.status]?.backgroundColor || '#808080',
            fillOpacity: 1,
            strokeColor: '#FFFFFF',
            strokeWeight: 2,
            scale: 12
          },
          title: this.data.lead.name
        });
      }, 0);
    });
  }

  fetchVisits(page: number = 1) {
    this.visitsLoading = true;
    this.visitsService.getPastVisits(this.data.lead.lead_id, page, this.pageSize).subscribe({
      next: (response: any) => {
        this.visits = response.data;
        this.totalItems = response.pagination.totalItems;
        this.currentPage = response.pagination.currentPage;
        
        // Extract all follow-ups from visits
        this.followUps = [];
        this.visits.forEach(visit => {
          if (visit && visit.followUpVisits && Array.isArray(visit.followUpVisits) && visit.followUpVisits.length > 0) {
            // Filter out any null or undefined follow-ups
            const validFollowUps = visit.followUpVisits.filter(followUp => followUp && followUp.followUp);
            this.followUps.push(...validFollowUps);
          }
        });
        
        this.visitsLoading = false;
      },
      error: (err: any) => {
        this.visitsLoading = false;
        this.snackBar.open('Failed to load visits', 'Close', { duration: 3000 });
      }
    });
  }

  onPageChange(event: any) {
    this.pageSize = event.pageSize;
    this.fetchVisits(event.pageIndex + 1);
  }

  updateLead() {
    console.log('Save Changes clicked');
    console.log('leadForm:', { value: this.leadForm.value, valid: this.leadForm.valid, dirty: this.leadForm.dirty });
    console.log('addressForm:', { value: this.addressForm.value, valid: this.addressForm.valid, dirty: this.addressForm.dirty });

    this.isLoading = true;
    const leadPayload: any = {};
    const addressPayload: any = {};

    Object.keys(this.leadForm.controls).forEach(key => {
      const control = this.leadForm.get(key);
      if (control?.dirty && control?.valid) {
        leadPayload[key] = control.value;
      }
    });

    Object.keys(this.addressForm.controls).forEach(key => {
      const control = this.addressForm.get(key);
      if (control?.dirty && control?.valid) {
        addressPayload[key] = control.value;
      }
    });

    // Merge address fields flat into payload (backend expects flat keys like city, street_address, etc.)
    const payload = { ...leadPayload, ...addressPayload };

    if (Object.keys(payload).length === 0) {
      this.isLoading = false;
      this.snackBar.open('No changes to save', 'Close', { duration: 3000 });
      return;
    }

    console.log('Update Lead Payload:', payload);

    this.leadsService.updateLead(this.data.lead.lead_id, payload).subscribe({
      next: () => {
        this.isLoading = false;
        this.snackBar.open('Lead updated successfully', 'Close', { duration: 3000 });
        this.leadForm.markAsUntouched();
        this.addressForm.markAsUntouched();
        this.dialogRef.close(true);
      },
      error: (err) => {
        this.isLoading = false;
        console.error('Update Lead Error:', err);
        this.snackBar.open('Failed to update lead', 'Close', { duration: 3000 });
      }
    });
  }

  assignSalesman() {
    const assignedRepId = this.assignForm.get('assigned_rep_id')?.value;
    if (!assignedRepId) {
      this.snackBar.open('Please select a salesman', 'Close', { duration: 3000 });
      return;
    }

    if (!this.assignForm.get('assigned_rep_id')?.dirty) {
      this.snackBar.open('No changes to save', 'Close', { duration: 3000 });
      return;
    }

    this.isLoading = true;
    const payload = {
      rep_id: assignedRepId,
      lead_ids: [this.data.lead.lead_id]
    };

    console.log('Assign Salesman Payload:', payload);

    this.leadsService.bulkAssignLeads(payload).subscribe({
      next: () => {
        this.isLoading = false;
        this.snackBar.open('Salesman assigned successfully', 'Close', { duration: 3000 });
        this.assignForm.markAsUntouched();
        this.dialogRef.close(true);
      },
      error: (err) => {
        this.isLoading = false;
        console.error('Assign Salesman Error:', err);
        this.snackBar.open('Failed to assign salesman', 'Close', { duration: 3000 });
      }
    });
  }

  getStatusStyles(status: LeadStatus | string): { backgroundColor: string; color: string } {
    return this.statusColors[status as LeadStatus] || { backgroundColor: '#D3D3D3', color: '#808080' };
  }

  openContractPdf(contractId: number | null): void {
    if (!contractId) {
      this.snackBar.open('No contract available', 'Close', { duration: 3000 });
      return;
    }

    this.contractService.getContractHtml(contractId).subscribe({
      next: async (html: string) => {
        try {
          await downloadPdfFromHtml(html, `contract_${contractId}.pdf`);
        } catch (err) {
          console.error('PDF generation error:', err);
          // Fallback: open HTML in new tab
          const newWindow = window.open('', '_blank');
          if (newWindow) {
            newWindow.document.write(html);
            newWindow.document.close();
          }
        }
      },
      error: (err: any) => {
        console.error('Error fetching contract:', err);
        this.snackBar.open('Failed to load contract', 'Close', { duration: 3000 });
      }
    });
  }

  navigateToLocation(latitude: number, longitude: number): void {
    if (latitude && longitude) {
      const url = `https://www.google.com/maps?q=${latitude},${longitude}`;
      window.open(url, '_blank');
    } else {
      this.snackBar.open('Invalid coordinates', 'Close', { duration: 3000 });
    }
  }

  onTabChange(index: number): void {
    // Footer is hidden in Visits tab (index 3) and Follow-ups tab (index 4)
    this.tabGroup.selectedIndex = index;
  }

  hasFollowUps(visit: Visit): boolean {
    return visit && visit.followUpVisits && Array.isArray(visit.followUpVisits) && visit.followUpVisits.length > 0;
  }

  getFollowUpCount(visit: Visit): number {
    return visit && visit.followUpVisits && Array.isArray(visit.followUpVisits) ? visit.followUpVisits.length : 0;
  }
  
}