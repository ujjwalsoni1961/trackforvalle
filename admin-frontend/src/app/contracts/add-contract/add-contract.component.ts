import { Component, OnInit, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormGroup, FormBuilder, Validators, FormArray } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatIconModule } from '@angular/material/icon';
import { MatExpansionModule } from '@angular/material/expansion';
import { Router, ActivatedRoute } from '@angular/router';
import { ContractsService } from '../contracts.service';
import { finalize } from 'rxjs/operators';
import { QuillModule } from 'ngx-quill';
import { MatProgressBar } from '@angular/material/progress-bar';
import { UsersService } from '../../users/users.service';
import { PartnerService } from '../../partner/partner.service';
import { DocusealBuilderComponent } from '@docuseal/angular';

interface SalesRep {
  id: string;
  first_name: string;
  last_name: string;
}

interface ContractTemplate {
  id: string;
  title: string;
  content: string;
}

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

@Component({
  selector: 'app-add-contract',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatSnackBarModule,
    MatCheckboxModule,
    MatIconModule,
    MatExpansionModule,
    MatProgressBar,
    QuillModule,
    DocusealBuilderComponent
  ],
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
  templateUrl: './add-contract.component.html',
  styleUrl: './add-contract.component.scss'
})
export class AddContractComponent implements OnInit {
  contractForm: FormGroup;
  salesReps: SalesRep[] = [];
  partners: Array<{ partner_id: number; company_name: string }> = [];
  isLoading = false;
  dropdownFields: { [key: string]: DropdownField } = {};
  isEditMode = false;
  templateId: number | null = null;
  currentTemplate: any = null;
  quillConfig = {
    toolbar: [
      ['bold', 'italic', 'underline', 'strike'],
      ['blockquote', 'code-block'],
      [{ header: 1 }, { header: 2 }],
      [{ list: 'ordered' }, { list: 'bullet' }],
      [{ indent: '-1' }, { indent: '+1' }],
      [{ size: ['small', false, 'large', 'huge'] }],
      [{ color: [] }, { background: [] }],
      [{ font: [] }],
      [{ align: [] }],
      ['clean'],
      ['link']
    ]
  };

  // DocuSeal builder state
  showBuilder = false;
  builderToken: string | null = null;
  docusealHost = 'docuseal-585556848696.europe-west1.run.app';

  predefinedTemplates: ContractTemplate[] = [
    {
      id: 'standard-sales',
      title: 'Standard Sales Agreement',
      content: `
      <h1 style="text-align: center; margin-bottom: 20px;">Standard Sales Agreement</h1>
      <p>
        This Sales Agreement ("Agreement") is entered into on <strong>{date_signed}</strong> between 
        <strong>{company_name}</strong> ("Seller") and <strong>{customer_name}</strong> ("Buyer").
      </p>

      <h2 style="margin-top: 20px;">1. Product Details</h2>
      <p>
        <strong>Product:</strong> {product_name}<br>
        <strong>Quantity:</strong> {quantity}<br>
        <strong>Price:</strong> {deal_amount}
      </p>

      <h2 style="margin-top: 20px;">2. Payment Terms</h2>
      <p>
        Buyer shall pay the total amount of <strong>{deal_amount}</strong> upon signing this Agreement. 
        Payment shall be made via <strong>{payment_method}</strong>.
      </p>

      <h2 style="margin-top: 20px;">3. Delivery</h2>
      <p>
        Seller shall deliver the products to <strong>{customer_address}</strong> by <strong>{delivery_date}</strong>.
      </p>

      <h2 style="margin-top: 20px;">4. Warranty</h2>
      <p>
        The products are warranted against defects for <strong>{warranty_period}</strong> from the date of delivery.
      </p>

      <h2 style="margin-top: 20px;">5. Signatures</h2>
      <p>
        Seller: ___________________________<br>
        Buyer: {signature_image}
      </p>
    `
    },
    {
      id: 'service-agreement-dropdown',
      title: 'Service Agreement with Dropdowns',
      content: `
      <h1 style="text-align: center; margin-bottom: 20px;">Service Agreement</h1>
      <p>
        This Service Agreement ("Agreement") is entered into on <strong>{date_signed}</strong> between 
        <strong>{company_name}</strong> ("Provider") and <strong>{customer_name}</strong> ("Client").
      </p>

      <h2 style="margin-top: 20px;">1. Service Details</h2>
      <p>
        <strong>Service Type:</strong> {dropdown:service_type}<br>
        <strong>Service Duration:</strong> {dropdown:service_duration}<br>
        <strong>Total Cost:</strong> {deal_amount}
      </p>

      <h2 style="margin-top: 20px;">2. Payment Terms</h2>
      <p>
        Client shall pay according to the selected payment schedule: <strong>{dropdown:payment_schedule}</strong>.
        Payment shall be made via <strong>{dropdown:payment_method}</strong>.
      </p>

      <h2 style="margin-top: 20px;">3. Service Delivery</h2>
      <p>
        Provider shall deliver services to <strong>{customer_address}</strong> with 
        <strong>{dropdown:support_level}</strong> support level.
      </p>

      <h2 style="margin-top: 20px;">4. Terms and Conditions</h2>
      <p>
        This agreement is subject to the terms and conditions outlined in our 
        <strong>{dropdown:contract_type}</strong> service level agreement.
      </p>

      <h2 style="margin-top: 20px;">5. Signatures</h2>
      <p>
        Provider: ___________________________<br>
        Client: {signature_image}
      </p>
    `
    },
    {
      id: 'bulk-purchase',
      title: 'Bulk Purchase Agreement',
      content: `
      <h1 style="text-align: center; margin-bottom: 20px;">Bulk Purchase Agreement</h1>
      <p>
        This Bulk Purchase Agreement ("Agreement") is entered into on <strong>{date_signed}</strong> between 
        <strong>{company_name}</strong> ("Seller") and <strong>{customer_name}</strong> ("Buyer").
      </p>

      <h2 style="margin-top: 20px;">1. Product Details</h2>
      <p>
        <strong>Product:</strong> {product_name}<br>
        <strong>Quantity:</strong> {quantity}<br>
        <strong>Total Price:</strong> {deal_amount}<br>
        <strong>Discount:</strong> {discount_percentage}%
      </p>

      <h2 style="margin-top: 20px;">2. Payment Terms</h2>
      <p>
        Buyer shall pay 50% of <strong>{deal_amount}</strong> upon signing and the remaining balance upon delivery. 
        Payment shall be made via <strong>{payment_method}</strong>.
      </p>

      <h2 style="margin-top: 20px;">3. Delivery Schedule</h2>
      <p>
        Seller shall deliver the products in <strong>{delivery_installments}</strong> installments to 
        <strong>{customer_address}</strong>, starting on <strong>{delivery_date}</strong>.
      </p>

      <h2 style="margin-top: 20px;">4. Returns</h2>
      <p>
        Buyer may return defective products within <strong>{return_period}</strong> days of delivery.
      </p>

      <h2 style="margin-top: 20px;">5. Signatures</h2>
      <p>
        Seller: ___________________________<br>
        Buyer: {signature_image}
      </p>
    `
    },
    {
      id: 'subscription',
      title: 'Subscription Agreement',
      content: `
      <h1 style="text-align: center; margin-bottom: 20px;">Subscription Agreement</h1>
      <p>
        This Subscription Agreement ("Agreement") is entered into on <strong>{date_signed}</strong> between 
        <strong>{company_name}</strong> ("Seller") and <strong>{customer_name}</strong> ("Buyer").
      </p>

      <h2 style="margin-top: 20px;">1. Subscription Details</h2>
      <p>
        <strong>Product:</strong> {product_name}<br>
        <strong>Frequency:</strong> {subscription_frequency}<br>
        <strong>Price per Cycle:</strong> {deal_amount}
      </p>

      <h2 style="margin-top: 20px;">2. Payment Terms</h2>
      <p>
        Buyer shall pay <strong>{deal_amount}</strong> <strong>{subscription_frequency}</strong> via 
        <strong>{payment_method}</strong>, starting on <strong>{date_signed}</strong>.
      </p>

      <h2 style="margin-top: 20px;">3. Delivery</h2>
      <p>
        Seller shall deliver the products to <strong>{customer_address}</strong> per the agreed schedule.
      </p>

      <h2 style="margin-top: 20px;">4. Cancellation</h2>
      <p>
        Buyer may cancel the subscription with <strong>{cancellation_notice}</strong> days' notice.
      </p>

      <h2 style="margin-top: 20px;">5. Signatures</h2>
      <p>
        Seller: ___________________________<br>
        Buyer: {signature_image}
      </p>
    `
    }
  ];

  constructor(
    private fb: FormBuilder,
    private contractsService: ContractsService,
    private usersService: UsersService,
    private partnerService: PartnerService,
    private snackBar: MatSnackBar,
    private router: Router,
    private route: ActivatedRoute
  ) {
    this.contractForm = this.fb.group({
      title: ['', Validators.required],
      content: ['', Validators.required],
      assigned_sales_rep_ids: [[], Validators.required],
      status: ['draft', Validators.required],
      partner_id: [null],
      docuseal_template_id: [null],
      templateId: [''], // For template selection
      dropdownFields: this.fb.array([]) // For dynamic dropdown fields
    });
  }

  ngOnInit() {
    // Check if we're in edit mode
    this.route.paramMap.subscribe(params => {
      const id = params.get('id');
      if (id) {
        this.isEditMode = true;
        this.templateId = parseInt(id, 10);
        this.loadTemplateForEdit();
      }
    });

    this.loadSalesReps();
    this.loadPartners();

    // Only set up template selection for create mode
    if (!this.isEditMode) {
      this.contractForm.get('templateId')?.valueChanges.subscribe(templateId => {
        if (templateId) {
          const selectedTemplate = this.predefinedTemplates.find(t => t.id === templateId);
          if (selectedTemplate) {
            this.contractForm.patchValue({
              title: selectedTemplate.title,
              content: selectedTemplate.content
            });
            
            // Auto-populate dropdown fields for service agreement template
            if (templateId === 'service-agreement-dropdown') {
              this.populateServiceAgreementDropdowns();
            }
          }
        }
      });
    }
  }

  loadTemplateForEdit() {
    if (!this.templateId) return;
    
    this.isLoading = true;
    this.contractsService.getTemplateDetails(this.templateId).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        this.currentTemplate = response.data;
        this.contractForm.patchValue({
          title: this.currentTemplate.title,
          content: this.currentTemplate.content,
          assigned_sales_rep_ids: this.currentTemplate.assigned_sales_rep_ids,
          status: this.currentTemplate.status,
          partner_id: this.currentTemplate.partner_id || null,
          docuseal_template_id: this.currentTemplate.docuseal_template_id || null
        });
        
        // Load existing dropdown fields
        if (this.currentTemplate.dropdown_fields) {
          this.loadExistingDropdownFields(this.currentTemplate.dropdown_fields);
        }
      },
      error: (err: any) => {
        this.snackBar.open('Error loading template: ' + err.message, 'Close', { duration: 3000 });
        this.router.navigate(['/contracts']);
      }
    });
  }

  loadExistingDropdownFields(dropdownFields: { [key: string]: DropdownField }) {
    // Clear existing dropdown fields
    while (this.dropdownFieldsArray.length !== 0) {
      this.dropdownFieldsArray.removeAt(0);
    }

    // Load existing dropdown fields
    Object.keys(dropdownFields).forEach(fieldName => {
      const field = dropdownFields[fieldName];
      const optionsArray = this.fb.array(
        field.options.map(option => this.fb.group({
          label: [option.label],
          value: [option.value]
        }))
      );

      const fieldFormGroup = this.fb.group({
        fieldName: [fieldName],
        label: [field.label],
        placeholder: [field.placeholder],
        required: [field.required],
        options: optionsArray
      });

      this.dropdownFieldsArray.push(fieldFormGroup);
    });
  }

  loadPartners() {
    this.partnerService.getAllPartners({ page: 1, limit: 100 }).subscribe({
      next: (response: any) => {
        this.partners = response?.data || [];
      },
      error: () => {
        // Non-critical, partner selector will just be empty
      }
    });
  }

  loadSalesReps() {
    this.isLoading = true;
    this.usersService.getSalesReps({ page: 1, limit: 500 }).pipe(
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
        this.snackBar.open('Error loading sales reps: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  openBuilder() {
    const existingTemplateId = this.contractForm.get('docuseal_template_id')?.value;
    const params: any = {};
    if (existingTemplateId) {
      params.template_id = existingTemplateId;
    }
    const title = this.contractForm.get('title')?.value;
    if (title) {
      params.name = title;
    }

    this.contractsService.getDocuSealBuilderToken(params).subscribe({
      next: (response) => {
        this.builderToken = response.data.token;
        this.showBuilder = true;
      },
      error: (err) => {
        this.snackBar.open('Error getting builder token: ' + (err.error?.message || err.message), 'Close', { duration: 3000 });
      }
    });
  }

  onBuilderSave(event: any) {
    const detail = event?.detail || event;
    const templateId = detail?.id || detail?.template_id;
    if (templateId) {
      this.contractForm.patchValue({ docuseal_template_id: templateId });
      this.snackBar.open(`DocuSeal template #${templateId} linked successfully`, 'Close', { duration: 3000 });
    }
    this.showBuilder = false;
    this.builderToken = null;
  }

  closeBuilder() {
    this.showBuilder = false;
    this.builderToken = null;
  }

  saveContract() {
    if (this.contractForm.invalid) {
      this.snackBar.open('Please fill all required fields', 'Close', { duration: 3000 });
      return;
    }

    this.isLoading = true;
    const { title, content, assigned_sales_rep_ids, status, partner_id, docuseal_template_id } = this.contractForm.value;
    const dropdownFields = this.buildDropdownFieldsPayload();

    const contractData: any = {
      title,
      content,
      assigned_sales_rep_ids,
      status,
      ...(Object.keys(dropdownFields).length > 0 && { dropdown_fields: dropdownFields }),
      ...(partner_id && { partner_id }),
      ...(docuseal_template_id && { docuseal_template_id })
    };
    
    const apiCall = this.isEditMode && this.templateId
      ? this.contractsService.updateContract(this.templateId, contractData)
      : this.contractsService.createContract(contractData);
    
    apiCall.pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: () => {
        const message = this.isEditMode ? 'Contract updated successfully' : 'Contract created successfully';
        this.snackBar.open(message, 'Close', { duration: 3000 });
        this.contractForm.markAsUntouched();
        this.router.navigate(['/contracts']);
      },
      error: () => {
        const message = this.isEditMode ? 'Error updating contract' : 'Error creating contract';
        this.snackBar.open(message, 'Close', { duration: 3000 });
      }
    });
  }

  cancel() {
    this.router.navigate(['/contracts']);
  }

  insertPlaceholder(placeholder: string) {
    const contentControl = this.contractForm.get('content');
    const currentContent = contentControl?.value || '';
    contentControl?.setValue(currentContent + placeholder);
  }

  insertDropdownPlaceholder(fieldName: string) {
    const placeholder = `{dropdown:${fieldName}}`;
    this.insertPlaceholder(placeholder);
  }

  get dropdownFieldsArray(): FormArray {
    return this.contractForm.get('dropdownFields') as FormArray;
  }

  createDropdownFieldFormGroup(): FormGroup {
    return this.fb.group({
      fieldName: ['', Validators.required],
      label: ['', Validators.required],
      placeholder: [''],
      required: [false],
      options: this.fb.array([this.createOptionFormGroup()])
    });
  }

  createOptionFormGroup(): FormGroup {
    return this.fb.group({
      label: ['', Validators.required],
      value: ['', Validators.required]
    });
  }

  addDropdownField() {
    this.dropdownFieldsArray.push(this.createDropdownFieldFormGroup());
  }

  removeDropdownField(index: number) {
    this.dropdownFieldsArray.removeAt(index);
  }

  getOptionsArray(fieldIndex: number): FormArray {
    return this.dropdownFieldsArray.at(fieldIndex).get('options') as FormArray;
  }

  addOption(fieldIndex: number) {
    this.getOptionsArray(fieldIndex).push(this.createOptionFormGroup());
  }

  removeOption(fieldIndex: number, optionIndex: number) {
    const optionsArray = this.getOptionsArray(fieldIndex);
    if (optionsArray.length > 1) {
      optionsArray.removeAt(optionIndex);
    }
  }

  private buildDropdownFieldsPayload(): { [key: string]: DropdownField } {
    const dropdownFields: { [key: string]: DropdownField } = {};
    
    this.dropdownFieldsArray.controls.forEach(control => {
      const fieldData = control.value;
      if (fieldData.fieldName) {
        dropdownFields[fieldData.fieldName] = {
          label: fieldData.label,
          options: fieldData.options,
          required: fieldData.required,
          placeholder: fieldData.placeholder
        };
      }
    });
    
    return dropdownFields;
  }

  private populateServiceAgreementDropdowns() {
    // Clear existing dropdown fields
    while (this.dropdownFieldsArray.length !== 0) {
      this.dropdownFieldsArray.removeAt(0);
    }

    // Service Type dropdown
    const serviceTypeField = this.fb.group({
      fieldName: ['service_type'],
      label: ['Service Type'],
      placeholder: ['Select service type'],
      required: [true],
      options: this.fb.array([
        this.fb.group({ label: ['Basic Service'], value: ['basic'] }),
        this.fb.group({ label: ['Premium Service'], value: ['premium'] }),
        this.fb.group({ label: ['Enterprise Service'], value: ['enterprise'] })
      ])
    });

    // Service Duration dropdown
    const serviceDurationField = this.fb.group({
      fieldName: ['service_duration'],
      label: ['Service Duration'],
      placeholder: ['Select duration'],
      required: [true],
      options: this.fb.array([
        this.fb.group({ label: ['1 Month'], value: ['1_month'] }),
        this.fb.group({ label: ['3 Months'], value: ['3_months'] }),
        this.fb.group({ label: ['6 Months'], value: ['6_months'] }),
        this.fb.group({ label: ['12 Months'], value: ['12_months'] })
      ])
    });

    // Payment Schedule dropdown
    const paymentScheduleField = this.fb.group({
      fieldName: ['payment_schedule'],
      label: ['Payment Schedule'],
      placeholder: ['Select payment schedule'],
      required: [true],
      options: this.fb.array([
        this.fb.group({ label: ['Monthly'], value: ['monthly'] }),
        this.fb.group({ label: ['Quarterly'], value: ['quarterly'] }),
        this.fb.group({ label: ['Annually'], value: ['annually'] }),
        this.fb.group({ label: ['One-time'], value: ['one_time'] })
      ])
    });

    // Payment Method dropdown
    const paymentMethodField = this.fb.group({
      fieldName: ['payment_method'],
      label: ['Payment Method'],
      placeholder: ['Select payment method'],
      required: [true],
      options: this.fb.array([
        this.fb.group({ label: ['Credit Card'], value: ['credit_card'] }),
        this.fb.group({ label: ['Bank Transfer'], value: ['bank_transfer'] }),
        this.fb.group({ label: ['Cash'], value: ['cash'] }),
        this.fb.group({ label: ['Check'], value: ['check'] })
      ])
    });

    // Support Level dropdown
    const supportLevelField = this.fb.group({
      fieldName: ['support_level'],
      label: ['Support Level'],
      placeholder: ['Select support level'],
      required: [false],
      options: this.fb.array([
        this.fb.group({ label: ['Basic Support'], value: ['basic'] }),
        this.fb.group({ label: ['Priority Support'], value: ['priority'] }),
        this.fb.group({ label: ['Premium Support'], value: ['premium'] })
      ])
    });

    // Contract Type dropdown
    const contractTypeField = this.fb.group({
      fieldName: ['contract_type'],
      label: ['Contract Type'],
      placeholder: ['Select contract type'],
      required: [false],
      options: this.fb.array([
        this.fb.group({ label: ['Standard SLA'], value: ['standard'] }),
        this.fb.group({ label: ['Premium SLA'], value: ['premium'] }),
        this.fb.group({ label: ['Enterprise SLA'], value: ['enterprise'] })
      ])
    });

    // Add all fields to the form array
    this.dropdownFieldsArray.push(serviceTypeField);
    this.dropdownFieldsArray.push(serviceDurationField);
    this.dropdownFieldsArray.push(paymentScheduleField);
    this.dropdownFieldsArray.push(paymentMethodField);
    this.dropdownFieldsArray.push(supportLevelField);
    this.dropdownFieldsArray.push(contractTypeField);
  }
}