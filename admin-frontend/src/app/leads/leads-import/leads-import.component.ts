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
      const workbook = read(fileData, { type: 'array', cellDates: true });
      const sheetName = workbook.SheetNames[0];
      const worksheet = workbook.Sheets[sheetName];
      const json = utils.sheet_to_json(worksheet, { header: 1, blankrows: false, raw: false, dateNF: 'yyyy-mm-dd' });

      // Detect header row: find the first row with 2+ non-empty cells (skip title rows)
      let headerRowIndex = 0;
      for (let i = 0; i < Math.min(json.length, 5); i++) {
        const row = json[i] as any[];
        const nonEmpty = row.filter(cell => cell !== undefined && cell !== null && cell.toString().trim() !== '').length;
        if (nonEmpty >= 2) {
          headerRowIndex = i;
          break;
        }
      }

      const headerRow = json[headerRowIndex] as any[];
      // Only use columns that have actual header values (skip trailing empty cols)
      const headers: string[] = [];
      for (let i = 0; i < headerRow.length; i++) {
        const val = headerRow[i];
        if (val !== undefined && val !== null && val.toString().trim() !== '') {
          headers.push(val.toString().trim());
        } else {
          break; // stop at first empty header
        }
      }

      const dataRows = json.slice(headerRowIndex + 1) as any[][];
      const rowData = dataRows
        .map(row => {
          const obj: any = {};
          let hasData = false;
          headers.forEach((header, i) => {
            let val = row[i];
            if (val === undefined || val === null) {
              obj[header] = '';
            } else {
              let strVal = val.toString().trim();
              // Clean numeric strings that look like postal codes (e.g. "16320" from float)
              if (/^\d+\.0*$/.test(strVal)) {
                strVal = strVal.replace(/\.0*$/, '');
              }
              obj[header] = strVal;
              if (strVal !== '') hasData = true;
            }
          });
          return hasData ? obj : null;
        })
        .filter((row): row is Record<string, string> => row !== null);

      // Extract emails and phones from comments column into separate fields
      const commentsHeader = headers.find(h => {
        const lower = h.toLowerCase();
        return lower.includes('kommentti') || lower.includes('comment') || lower.includes('huomio');
      });
      if (commentsHeader) {
        rowData.forEach(row => {
          const comment = row[commentsHeader] || '';
          if (!comment) return;
          // Extract email
          const emailMatch = comment.match(/([a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,})/);
          if (emailMatch) {
            row['__extracted_email'] = emailMatch[1];
          }
          // Extract phone (Finnish format: 04x or +358)
          const phoneMatch = comment.match(/((?:\+358|0)[\d\s]{7,14})/);
          if (phoneMatch) {
            row['__extracted_phone'] = phoneMatch[1].replace(/\s/g, '');
          }
          // Extract name (look for patterns like "Name /" or "/ Name /" that aren't email/phone)
          const parts = comment.split('/');
          if (parts.length > 1) {
            for (const part of parts) {
              const trimmed = part.trim();
              // Skip if it looks like email, phone, or is too long (likely a note)
              if (trimmed.includes('@') || /^[\d+]/.test(trimmed) || trimmed.length > 40) continue;
              // If it looks like a name (1-3 words, starts with uppercase)
              if (/^[A-ZÄÖÅ][a-zäöå]+(\s[A-ZÄÖÅ][a-zäöå]+){0,2}$/.test(trimmed)) {
                row['__extracted_name'] = trimmed;
                break;
              }
            }
          }
        });
      }

      // Add extracted fields as virtual headers for mapping
      const hasExtractedEmails = rowData.some(r => r['__extracted_email']);
      const hasExtractedPhones = rowData.some(r => r['__extracted_phone']);
      const hasExtractedNames = rowData.some(r => r['__extracted_name']);
      const allHeaders = [...headers];
      if (hasExtractedEmails) allHeaders.push('__extracted_email');
      if (hasExtractedPhones) allHeaders.push('__extracted_phone');
      if (hasExtractedNames) allHeaders.push('__extracted_name');

      this.processData(allHeaders, rowData);
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
    // Extracted fields from smart parsing
    if (column === '__extracted_email') return 'email';
    if (column === '__extracted_phone') return 'phone';
    if (column === '__extracted_name') return 'customerName';
    // Finnish column names
    if (lowerCol.includes('valle') || lowerCol.includes('pennala')) return 'streetAddress';
    if (lowerCol.includes('name') || lowerCol.includes('myyjä') || lowerCol.includes('nimi')) return 'customerName';
    if (lowerCol.includes('email') || lowerCol.includes('sähköposti')) return 'email';
    if (lowerCol.includes('phone') || lowerCol.includes('puhelin')) return 'phone';
    if (lowerCol.includes('address') || lowerCol.includes('osoite') || lowerCol.includes('katu')) return 'streetAddress';
    if (lowerCol.includes('city') || lowerCol.includes('kaupunki')) return 'city';
    if (lowerCol.includes('state')) return 'state';
    if (lowerCol.includes('postal') || lowerCol.includes('postin') || lowerCol.includes('postinro')) return 'postalCode';
    if (lowerCol.includes('country') || lowerCol.includes('maa')) return 'country';
    if (lowerCol.includes('comment') || lowerCol.includes('huomio') || lowerCol.includes('kommentti')) return 'comments';
    if (lowerCol.includes('partner') || lowerCol.includes('kumppani')) return 'partner';
    if (lowerCol.includes('kontaktit') || lowerCol.includes('contact')) return ''; // skip contact dates by default
    return '';
  }

  /** Get display name for column headers including extracted fields */
  getColumnDisplayName(column: string): string {
    if (column === '__extracted_email') return 'Email (extracted from comments)';
    if (column === '__extracted_phone') return 'Phone (extracted from comments)';
    if (column === '__extracted_name') return 'Name (extracted from comments)';
    return column;
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