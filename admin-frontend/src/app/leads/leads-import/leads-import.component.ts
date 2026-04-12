import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormGroup, FormBuilder, FormArray, Validators } from '@angular/forms';
import { Papa, ParseResult } from 'ngx-papaparse';
import { read, utils } from 'xlsx';
import { LeadsService } from '../leads.service';
import { finalize } from 'rxjs/operators';
import { SharedModule } from '../../shared/shared.module';
import { MatSnackBar } from '@angular/material/snack-bar';

interface Lead {
  serialNumber?: number;
  customerName?: string;
  email?: string;
  phone?: string;
  streetAddress?: string;
  city?: string;
  state?: string;
  postalCode?: string;
  country?: string;
  comments?: string;
  partner?: string;
  errors?: string[];
}

interface Mapping {
  csvColumn: string;
  systemField: string;
}

@Component({
  selector: 'app-leads-import',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    SharedModule
  ],
  templateUrl: './leads-import.component.html',
  styleUrl: './leads-import.component.scss'
})
export class LeadsImportComponent implements OnInit {
  fileName: string | null = null;
  columns: string[] = [];
  mappings: Mapping[] = [];
  previewData: Lead[] = [];
  partners: { partner_id: number; company_name: string }[] = [];
  systemFields = [
    { id: 'customerName', label: 'Customer Name' },
    { id: 'email', label: 'Email' },
    { id: 'phone', label: 'Phone' },
    { id: 'streetAddress', label: 'Street Address' },
    { id: 'city', label: 'City' },
    { id: 'state', label: 'State' },
    { id: 'postalCode', label: 'Postal Code' },
    { id: 'country', label: 'Country' },
    { id: 'comments', label: 'Comments' },
    { id: 'partner', label: 'Partner' }
  ];
  requiredFields = ['streetAddress', 'city', 'postalCode'];
  displayedColumns: string[] = ['serialNumber'];
  totalRows = 0;
  validRows = 0;
  rowsWithErrors = 0;
  isSubmitting = false;
  mappingForm: FormGroup;
  manualLeadsForm: FormGroup;
  csvPartner: number | null = null;
  csvLeadSetName: string = '';
  private rawData: any[] = [];

  constructor(
    private papa: Papa,
    private fb: FormBuilder,
    private leadsService: LeadsService,
    private snackBar: MatSnackBar
  ) {
    this.mappingForm = this.fb.group({
      saveMapping: [false]
    });
    this.manualLeadsForm = this.fb.group({
      leads: this.fb.array([this.createLeadFormGroup()])
    });
  }

  ngOnInit() {
    this.loadPartners();
  }

  loadPartners(): void {
    this.leadsService.getPartners().subscribe({
      next: (response: any) => {
        this.partners = (response.data || []).map((p: any) => ({
          partner_id: p.partner_id,
          company_name: p.company_name
        }));
      },
      error: () => {}
    });
  }

  get leads(): FormArray {
    return this.manualLeadsForm.get('leads') as FormArray;
  }

  createLeadFormGroup(): FormGroup {
    return this.fb.group({
      customerName: [''],
      email: [''],
      phone: [''],
      streetAddress: [''],
      city: [''],
      state: [''],
      postalCode: [''],
      country: [''],
      comments: [''],
      partner_id: [null, Validators.required]
    });
  }

  addLeadForm() {
    this.leads.push(this.createLeadFormGroup());
  }

  removeLeadForm(index: number) {
    this.leads.removeAt(index);
  }

  submitManualLeads() {
    this.isSubmitting = true;
    const leads = this.leads.controls
      .map((control, index: number) => {
        const group = control as FormGroup;
        const lead: Lead = {
          serialNumber: index + 1,
          ...group.value
        };
        const errors: string[] = [];

        // Validate required fields
        this.requiredFields.forEach(field => {
          if (!lead[field as keyof Lead]) {
            errors.push(field);
          }
        });

        // Validate email
        if (!this.isBlankish(lead.email) && !this.isValidEmail(lead.email!)) {
          errors.push('email');
        }

        // Validate phone
        // if (lead.phone && !this.isValidPhone(lead.phone)) {
        //   errors.push('phone');
        // }

        if (errors.length > 0) {
          lead.errors = errors;
        }

        return lead;
      })
      .filter(lead => !lead.errors?.length)
      .map(lead => ({
        name: lead.customerName || '',
        contact_email: this.isBlankish(lead.email) ? '' : lead.email,
        phone: this.isBlankish(lead.phone) ? '' : lead.phone,
        street_address: lead.streetAddress,
        city: lead.city,
        state: lead.state,
        postal_code: lead.postalCode,
        country: lead.country,
        comments: this.isBlankish(lead.comments) ? '' : lead.comments,
        partner_id: (lead as any).partner_id || undefined
      }));


    if (leads.length === 0) {
      this.snackBar.open('No valid leads to import', 'Close', { duration: 3000 });
      this.isSubmitting = false;
      return;
    }

    const payload = { leads };
    
    this.leadsService.importLeads(payload).pipe(
      finalize(() => this.isSubmitting = false)
    ).subscribe({
      next: () => {
        this.snackBar.open('Manual leads imported successfully!', 'Close', { duration: 3000 });
        this.resetManualForm();
      },
      error: (err: any) => {
        const msg = err?.error?.error?.message || 'An unexpected error occurred';
        const details = err?.error?.errors;
        if (details?.length) {
          this.snackBar.open(details[0], 'Close', { duration: 5000 });
        } else {
          this.snackBar.open(msg, 'Close', { duration: 5000 });
        }
      }
    });
  }

  resetManualForm() {
    this.manualLeadsForm = this.fb.group({
      leads: this.fb.array([this.createLeadFormGroup()])
    });
  }

  getFieldLabel(fieldId: string): string {
    const field = this.systemFields.find(f => f.id === fieldId);
    return field ? field.label : fieldId;
  }

  onDragOver(event: DragEvent) {
    event.preventDefault();
    event.dataTransfer!.dropEffect = 'copy';
  }

  onDrop(event: DragEvent) {
    event.preventDefault();
    const files = event.dataTransfer?.files;
    if (files && files.length > 0) {
      this.handleFile(files[0]);
    }
  }

  onFileSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.handleFile(input.files[0]);
    }
  }

  handleFile(file: File) {
    this.fileName = file.name;
    if (file.name.endsWith('.csv')) {
      this.parseCsv(file);
    } else if (file.name.endsWith('.xlsx')) {
      this.parseExcel(file);
    } else {
      this.snackBar.open('Unsupported file format. Please upload CSV or Excel.', 'Close', { duration: 3000 });
    }
  }

  parseCsv(file: File) {
    this.papa.parse(file, {
      header: true,
      skipEmptyLines: true,
      transformHeader: (header) => header.trim().replace(/^"|"$/g, ''),
      transform: (value) => value.trim().replace(/^"|"$/g, ''),
      complete: (result: ParseResult<any>) => {
        this.processData(result.meta.fields, result.data);
      },
      error: (err: any) => {
        this.snackBar.open('Error parsing CSV file.', 'Close', { duration: 3000 });
        console.error(err);
      }
    });
  }

  parseExcel(file: File) {
    const reader = new FileReader();
    reader.onload = (e) => {
      const fileData = new Uint8Array(e.target!.result as ArrayBuffer);
      const workbook = read(fileData, { type: 'array' });
      const sheetName = workbook.SheetNames[0];
      const worksheet = workbook.Sheets[sheetName];
      const json = utils.sheet_to_json(worksheet, { header: 1, blankrows: false });
      const headers = json[0] as string[];
      const rows = json.slice(1) as any[][];
      const rowData = rows
        .map(row => {
          const obj: any = {};
          headers.forEach((header, i) => {
            obj[header] = row[i]?.toString()?.trim() || '';
          });
          return obj;
        })
        .filter(row => Object.values(row).some(val => val !== '')); // Skip rows where all values are empty
      this.processData(headers, rowData);
    };
    reader.readAsArrayBuffer(file);
  }

  processData(columns: string[], data: any[]) {
    this.columns = columns;
    this.rawData = data;
    this.mappings = columns.map(col => ({
      csvColumn: col,
      systemField: this.autoSuggestMapping(col)
    }));
    this.mappingForm = this.fb.group({
      saveMapping: [false],
      ...columns.reduce((acc, col) => ({
        ...acc,
        [col]: [this.autoSuggestMapping(col)]
      }), {})
    });
    
    // Subscribe to form changes for live preview updates
    this.mappingForm.valueChanges.subscribe(() => {
      this.refreshPreview();
    });
    
    this.validateAndPreparePreview(data);
  }

  autoSuggestMapping(column: string): string {
    const lowerCol = column.toLowerCase();
    if (lowerCol.includes('name') || lowerCol.includes('myyjä')) return 'customerName';
    if (lowerCol.includes('email')) return 'email';
    if (lowerCol.includes('phone') || lowerCol.includes('puhelin')) return 'phone';
    if (lowerCol.includes('address') || lowerCol.includes('osoite') || lowerCol.includes('katu')) return 'streetAddress';
    if (lowerCol.includes('city') || lowerCol.includes('kaupunki')) return 'city';
    if (lowerCol.includes('state')) return 'state';
    if (lowerCol.includes('postal') || lowerCol.includes('postin')) return 'postalCode';
    if (lowerCol.includes('country')) return 'country';
    if (lowerCol.includes('comment') || lowerCol.includes('huomio') || lowerCol.includes('kommentti')) return 'comments';
    if (lowerCol.includes('partner') || lowerCol.includes('kumppani')) return 'partner';
    return '';
  }

  refreshPreview() {
    if (this.rawData.length > 0) {
      // Update mappings from form values
      this.mappings = this.columns.map(col => ({
        csvColumn: col,
        systemField: this.mappingForm.get(col)?.value || ''
      }));
      this.validateAndPreparePreview(this.rawData);
    }
  }

  validateAndPreparePreview(data: any[]) {
    this.previewData = data.map((row, index) => {
      const lead: Lead = { serialNumber: index + 1 };
      const errors: string[] = [];
      this.mappings.forEach(mapping => {
        if (mapping.systemField) {
          (lead as any)[mapping.systemField] = row[mapping.csvColumn] || '';
          if (this.requiredFields.includes(mapping.systemField) && !(lead as any)[mapping.systemField]) {
            errors.push(mapping.systemField);
          }
          if (mapping.systemField === 'email' && !this.isBlankish((lead as any)[mapping.systemField]) && !this.isValidEmail((lead as any)[mapping.systemField])) {
            errors.push('email');
          }
          if (mapping.systemField === 'phone' && !this.isBlankish((lead as any)[mapping.systemField]) && !this.isValidPhone((lead as any)[mapping.systemField])) {
            errors.push('phone');
          }
        }
      });
      if (errors.length > 0) {
        lead.errors = errors;
      }
      return lead;
    });
    this.displayedColumns = ['serialNumber', ...this.systemFields
      .filter(field => this.mappings.some(m => m.systemField === field.id))
      .map(field => field.id)];
    this.totalRows = data.length;
    this.validRows = this.previewData.filter(lead => !lead.errors?.length).length;
    this.rowsWithErrors = this.totalRows - this.validRows;
  }

  /** Treat '-', 'N/A', 'none', etc. as blank */
  private isBlankish(value: string | undefined): boolean {
    if (!value) return true;
    const trimmed = value.trim().toLowerCase();
    return ['', '-', '--', 'n/a', 'na', 'none', 'nil', '.'].includes(trimmed);
  }

  isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  isValidPhone(phone: string): boolean {
    return /^\+?\d{7,15}$/.test(phone.replace(/\s/g, ''));
  }

  isRequiredField(field: string): boolean {
    return this.requiredFields.includes(field) && field !== 'serialNumber';
  }

  downloadErrorReport() {
    const errorRows = this.previewData.filter(row => row.errors?.length);
    const csvContent = [
      ['Row', ...this.displayedColumns.map(col => col === 'serialNumber' ? 'Serial Number' : this.getFieldLabel(col)), 'Errors'],
      ...errorRows.map((row, i) => [
        row.serialNumber,
        ...this.displayedColumns.map(col => (row as any)[col] || ''),
        row.errors?.map(err => this.getFieldLabel(err)).join(', ') || ''
      ])
    ].map(row => row.join(',')).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'lead_import_errors.csv';
    a.click();
    window.URL.revokeObjectURL(url);
  }

  submitLeads() {
    this.isSubmitting = true;

    // Check for duplicates client-side
    const uniqueLeads = new Set();
    const leads = this.previewData.filter((row: any) => {
      if (row.errors?.length) return false;
      const key = `${row.customerName}-${row.streetAddress}-${row.city}-${row.state}-${row.postalCode}-${row.country}`;
      if (uniqueLeads.has(key)) {
        row.errors = row.errors || [];
        row.errors.push(`Duplicate customer at ${row.streetAddress}, ${row.city}`);
        return false;
      }
      uniqueLeads.add(key);
      return true;
    }).map((row: any) => ({
      name: row.customerName,
      contact_email: row.email,
      phone: row.phone,
      street_address: row.streetAddress,
      city: row.city,
      state: row.state,
      postal_code: row.postalCode,
      country: row.country,
      comments: row.comments,
      partner_name: row.partner || undefined
    }));

    if (!leads.length) {
      this.snackBar.open('No valid leads to import.', 'Close', { duration: 3000 });
      this.isSubmitting = false;
      return;
    }

    // Assign selected partner to all leads
    if (this.csvPartner) {
      leads.forEach((lead: any) => {
        lead.partner_id = this.csvPartner;
      });
    }

    const payload: any = { leads };
    if (this.csvLeadSetName?.trim()) {
      payload.lead_set = this.csvLeadSetName.trim();
    }
    this.leadsService.importLeads(payload).pipe(
      finalize(() => this.isSubmitting = false)
    ).subscribe({
      next: (response: any) => {
        if (response.success) {
          this.snackBar.open('Leads imported successfully!', 'Close', { duration: 3000 });
          this.reset();
        } else if (response.errors?.length) {
          this.snackBar.open(`Some leads failed to import: ${response.errors.join('; ')}`, 'Close', { duration: 5000 });
        }
      },
      error: (err: any) => {
        const errorMessage = err?.error?.error.message || 'An unexpected error occurred';
        const errorDetails = err?.error?.errors || [];
        errorDetails.forEach((error: any, index: number) => {
          setTimeout(() => {
            this.snackBar.open(error, 'Close', { duration: 3000 });
          }, index * 3500); // Sequential display with 3.5s intervals
          const rowIndex = parseInt(error.match(/Row (\d+)/)?.[1] || 0) - 1;
          if (this.previewData[rowIndex]) {
            this.previewData[rowIndex].errors = this.previewData[rowIndex].errors || [];
            this.previewData[rowIndex].errors.push(error);
          }
        });
        this.snackBar.open(`Error importing manual leads: ${errorMessage}`, 'Close', { duration: 3000 });
      }
    });
  }

  reset() {
    this.fileName = null;
    this.columns = [];
    this.mappings = [];
    this.previewData = [];
    this.rawData = [];
    this.displayedColumns = ['serialNumber'];
    this.totalRows = 0;
    this.validRows = 0;
    this.rowsWithErrors = 0;
    this.isSubmitting = false;
    this.csvPartner = null;
    this.csvLeadSetName = '';
    this.mappingForm = this.fb.group({
      saveMapping: [false]
    });
  }
}