import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { environment } from '../../environments/environment';

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
  assigned_sales_rep_ids: string[];
  assigned_sales_reps: Array<{
    user_id: number;
    full_name: string;
    first_name: string;
    last_name: string;
    email: string;
  }>;
  signed_count: number;
  status: 'draft' | 'active' | 'published' | 'archived';
  created_by: string;
  created_at: string;
  updated_at: string;
  dropdown_fields?: { [key: string]: DropdownField };
  partner_id?: number;
  partner?: { partner_id: number; company_name: string } | null;
  template_type?: 'richtext' | 'pdf_upload';
  pdf_url?: string;
  field_positions?: any[];
}

interface SignedContract {
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
  template: {
    id: number;
    title: string;
    content: string;
    status: string;
    created_at: string;
    updated_at: string;
  };
  visit: {
    visit_id: number;
    lead_id: number;
    rep_id: string;
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
    rep: {
      user_id: string;
      full_name: string;
      first_name: string;
      last_name: string;
    };
    lead: {
      lead_id: number;
      name: string;
      contact_name: string;
      contact_email: string;
      contact_phone: string;
      status: string;
    };
  };
}

@Injectable({
  providedIn: 'root'
})
export class ContractsService {
  private baseUrl = environment.baseUri;

  constructor(private http: HttpClient) {}

  getContractTemplates(params?: any): Observable<{ success: boolean; data: Contract[]; message: string }> {
    let httpParams = new HttpParams();
    if (params) {
      Object.keys(params).forEach(key => {
        httpParams = httpParams.set(key, params[key]);
      });
    }
    return this.http.get<{ success: boolean; data: any[]; message: string }>(`${this.baseUrl}/contract/templates`, { params: httpParams }).pipe(
      map(response => ({
        success: response.success,
        message: response.message,
        data: response.data.map(item => ({
          id: item.id,
          title: item.title,
          content: item.content,
          assigned_sales_rep_ids: (item.assigned_sales_reps || item.assigned_managers)?.map((rep: any) => String(rep.user_id)) || [],
          assigned_sales_reps: (item.assigned_sales_reps || item.assigned_managers)?.map((rep: any) => ({
            user_id: rep.user_id,
            full_name: rep.full_name,
            first_name: rep.first_name,
            last_name: rep.last_name,
            email: rep.email
          })) || [],
          signed_count: item.signed_count || 0,
          status: item.status as 'draft' | 'active' | 'published' | 'archived',
          created_by: (item.assigned_sales_reps || item.assigned_managers)?.[0]?.full_name || 'Unknown',
          created_at: item.created_at,
          updated_at: item.updated_at
        }))
      }))
    );
  }

  getSignedContracts(params: any): Observable<{ success: boolean; data: { contracts: SignedContract[]; pagination: { total: number; page: number; limit: number; totalPages: number } }; message: string }> {
    let httpParams = new HttpParams();
    Object.keys(params).forEach(key => {
      httpParams = httpParams.set(key, params[key]);
    });
    return this.http.get<{ success: boolean; data: { contracts: any[]; pagination: any }; message: string }>(`${this.baseUrl}/contract`, { params: httpParams }).pipe(
      map(response => ({
        success: response.success,
        message: response.message,
        data: {
          contracts: response.data.contracts.map(item => ({
            id: item.id,
            contract_template_id: item.contract_template_id,
            visit_id: item.visit_id,
            rendered_html: item.rendered_html,
            metadata: item.metadata,
            signed_at: item.signed_at,
            template: {
              id: item.template.id,
              title: item.template.title,
              content: item.template.content,
              status: item.template.status,
              created_at: item.template.created_at,
              updated_at: item.template.updated_at
            },
            visit: {
              visit_id: item.visit.visit_id,
              lead_id: item.visit.lead_id,
              rep_id: String(item.visit.rep_id),
              check_in_time: item.visit.check_in_time,
              check_out_time: item.visit.check_out_time,
              latitude: item.visit.latitude,
              longitude: item.visit.longitude,
              notes: item.visit.notes,
              photo_urls: item.visit.photo_urls,
              next_visit_date: item.visit.next_visit_date,
              action_required: item.visit.action_required,
              is_active: item.visit.is_active,
              created_by: item.visit.created_by,
              updated_by: item.visit.updated_by,
              created_at: item.visit.created_at,
              updated_at: item.visit.updated_at,
              rep: {
                user_id: String(item.visit.rep.user_id),
                full_name: item.visit.rep.full_name,
                first_name: item.visit.rep.first_name || (item.visit.rep.full_name ? item.visit.rep.full_name.split(' ')[0] : 'N/A'),
                last_name: item.visit.rep.last_name || (item.visit.rep.full_name ? item.visit.rep.full_name.split(' ').slice(1).join(' ') || '' : '')
              },
              lead: {
                lead_id: item.visit.lead.lead_id,
                name: item.visit.lead.name,
                contact_name: item.visit.lead.contact_name,
                contact_email: item.visit.lead.contact_email,
                contact_phone: item.visit.lead.contact_phone,
                status: item.visit.lead.status
              }
            }
          })),
          pagination: {
            total: response.data.pagination.total,
            page: response.data.pagination.page,
            limit: response.data.pagination.limit,
            totalPages: response.data.pagination.totalPages
          }
        }
      }))
    );
  }

  getContracts(params: any): Observable<{ success: boolean; data: { contracts: Contract[]; pagination?: { total: number } } }> {
    let httpParams = new HttpParams();
    Object.keys(params).forEach(key => {
      httpParams = httpParams.set(key, params[key]);
    });
    return this.http.get<{ success: boolean; data: any[]; message: any }>(`${this.baseUrl}/contract/templates`, { params: httpParams }).pipe(
      map(response => ({
        success: response.success,
        message: response.message,
        data: {
          contracts: response.data.map(item => ({
            id: item.id,
            title: item.title,
            content: item.content,
            assigned_sales_rep_ids: (item.assigned_sales_reps || item.assigned_managers)?.map((rep: any) => String(rep.user_id)) || [],
            assigned_sales_reps: (item.assigned_sales_reps || item.assigned_managers)?.map((rep: any) => ({
              user_id: rep.user_id,
              full_name: rep.full_name,
              first_name: rep.first_name,
              last_name: rep.last_name,
              email: rep.email
            })) || [],
            signed_count: 0,
            status: item.status as 'draft' | 'active' | 'published' | 'archived',
            created_by: (item.assigned_sales_reps || item.assigned_managers)?.[0]?.full_name || 'Unknown',
            created_at: item.created_at,
            updated_at: item.updated_at,
            partner_id: item.partner_id || null,
            partner: item.partner || null,
            template_type: item.template_type || 'richtext',
            pdf_url: item.pdf_url || null,
            field_positions: item.field_positions || []
          })),
          pagination: { total: response.data.length }
        }
      }))
    );
  }

  createContract(data: Partial<Contract>): Observable<{ success: boolean; data: Contract }> {
    return this.http.post<{ success: boolean; data: Contract }>(`${this.baseUrl}/contract/templates`, {
      ...data,
      assigned_sales_rep_ids: data.assigned_sales_rep_ids?.map(id => Number(id)) || []
    });
  }

  updateContract(id: number, data: Partial<Contract>): Observable<{ success: boolean; data: Contract }> {
    return this.http.patch<{ success: boolean; data: Contract }>(`${this.baseUrl}/contract/templates/${id}`, {
      ...data,
      assigned_sales_rep_ids: data.assigned_sales_rep_ids?.map(id => Number(id)) || []
    });
  }

  reassignContract(id: number, data: { assigned_sales_rep_ids: string[] }): Observable<{ success: boolean; message: string }> {
    return this.http.put<{ success: boolean; message: string }>(`${this.baseUrl}/contract/templates/${id}`, {
      assigned_sales_rep_ids: data.assigned_sales_rep_ids.map(id => Number(id))
    });
  }

  getTemplateDetails(id: number): Observable<{ success: boolean; data: Contract }> {
    return this.http.get<{ success: boolean; data: any }>(`${this.baseUrl}/contract/templates/${id}`).pipe(
      map(response => ({
        success: response.success,
        data: {
          id: response.data.id,
          title: response.data.title,
          content: response.data.content,
          assigned_sales_rep_ids: (response.data.assigned_sales_reps || response.data.assigned_managers)?.map((rep: any) => String(rep.user_id)) || [],
          assigned_sales_reps: (response.data.assigned_sales_reps || response.data.assigned_managers)?.map((rep: any) => ({
            user_id: rep.user_id,
            full_name: rep.full_name,
            first_name: rep.first_name,
            last_name: rep.last_name,
            email: rep.email
          })) || [],
          signed_count: response.data.signed_count || 0,
          status: response.data.status as 'draft' | 'active' | 'published' | 'archived',
          created_by: (response.data.assigned_sales_reps || response.data.assigned_managers)?.[0]?.full_name || 'Unknown',
          created_at: response.data.created_at,
          updated_at: response.data.updated_at,
          dropdown_fields: response.data.dropdown_fields || {},
          partner_id: response.data.partner_id || null,
          partner: response.data.partner || null,
          template_type: response.data.template_type || 'richtext',
          pdf_url: response.data.pdf_url || null,
          field_positions: response.data.field_positions || []
        }
      }))
    );
  }

  deleteContract(id: number): Observable<{ success: boolean; message: string; data: { templateId: number } }> {
    return this.http.delete<{ success: boolean; message: string; data: { templateId: number } }>(`${this.baseUrl}/contract/templates/${id}`);
  }

  submitContract(data: {
    lead_id: number;
    contract_template_id: number;
    metadata: any;
    dropdownValues?: any;
    signature?: File;
  }): Observable<{ success: boolean; data: any }> {
    const formData = new FormData();
    formData.append('lead_id', data.lead_id.toString());
    formData.append('contract_template_id', data.contract_template_id.toString());
    formData.append('metadata', JSON.stringify(data.metadata));

    if (data.dropdownValues) {
      formData.append('dropdownValues', JSON.stringify(data.dropdownValues));
    }

    if (data.signature) {
      formData.append('signature', data.signature);
    }

    return this.http.post<{ success: boolean; data: any }>(`${this.baseUrl}/contract/submit`, formData);
  }

    exportContract(id: number): Observable<Blob> {
    return this.http.get(`${this.baseUrl}/contract/${id}/export`, { responseType: 'blob' });
  }

  getContractPdf(id: number): Observable<Blob> {
    return this.http.get(`${this.baseUrl}/contract/${id}/pdf`, { responseType: 'blob' });
  }

  getContractPdfUrl(id: number): string {
    return `${this.baseUrl}/contract/${id}/pdf`;
  }

  getContractPdfDownloadUrl(id: number): string {
    return `${this.baseUrl}/contract/${id}/pdf?download=true`;
  }

  getContractHtml(id: number): Observable<string> {
    return this.http.get(`${this.baseUrl}/contract/${id}/pdf`, { responseType: 'text' });
  }

  // ─── PDF Upload method ───

  uploadTemplatePdf(file: File): Observable<{ success: boolean; data: { url: string } }> {
    const formData = new FormData();
    formData.append('contract_pdf', file);
    return this.http.post<{ success: boolean; data: { url: string } }>(`${this.baseUrl}/contract/templates/upload-pdf`, formData);
  }
}
