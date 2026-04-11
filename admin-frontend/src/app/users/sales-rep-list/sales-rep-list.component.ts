import { Component, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormGroup, FormBuilder } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatPaginator, MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { UsersService } from '../users.service';
import { EditUserDialogComponent } from '../edit-user-dialog/edit-user-dialog.component';
import { finalize } from 'rxjs/operators';
import { ConfirmationDialogComponent } from '../../shared/dialog/confirmation-dialog/confirmation-dialog.component';

interface SalesRep {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
  role: 'sales_rep';
  status: 'Active' | 'Inactive';
  createdAt: string;
}

@Component({
  selector: 'app-sales-rep-list',
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
    MatPaginatorModule
  ],
  templateUrl: './sales-rep-list.component.html',
  styleUrl: './sales-rep-list.component.scss'
})
export class SalesRepListComponent implements OnInit {
  salesReps: SalesRep[] = [];
  dataSource = new MatTableDataSource<SalesRep>([]);
  displayedColumns: string[] = ['fullName', 'email', 'status', 'createdAt', 'actions'];
  filterForm: FormGroup;
  statuses = [
    { id: 'all', label: 'All Statuses' },
    { id: 'Active', label: 'Active' },
    { id: 'Inactive', label: 'Inactive' }
  ];
  isLoading = false;

  // Pagination properties
  totalItems = 0;
  pageSize = 10;
  pageIndex = 0;

  @ViewChild(MatPaginator) paginator!: MatPaginator;

  constructor(
    private fb: FormBuilder,
    private usersService: UsersService,
    private snackBar: MatSnackBar,
    private dialog: MatDialog
  ) {
    this.filterForm = this.fb.group({
      search: [''],
      status: ['all']
    });
  }

  ngOnInit() {
    this.loadSalesReps();
    this.filterForm.valueChanges.subscribe(() => this.applyFilters());
  }

  loadSalesReps(page: number = 1, limit: number = this.pageSize) {
    this.isLoading = true;
    this.usersService.getSalesReps({ page, limit }).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        // Handle data as an array directly
        const teamMembers = response?.data ?? [];
        this.salesReps = teamMembers.map((member: any) => {
          const [first_name = 'N/A', last_name = ''] = member.full_name ? member.full_name.split(' ') : ['N/A', ''];
          return {
            id: String(member.user_id),
            first_name,
            last_name,
            email: member.email,
            role: 'sales_rep',
            status: member.is_active ? 'Active' : 'Inactive',
            createdAt: member.created_at
          };
        });

        // Update pagination metadata from API response
        this.totalItems = response.pagination.totalItems;
        this.pageSize = limit;
        this.pageIndex = response.pagination.currentPage - 1; // API is 1-based, paginator is 0-based
        this.paginator.pageIndex = this.pageIndex;
        this.paginator.pageSize = this.pageSize;
        this.paginator.length = this.totalItems;

        this.applyFilters();
      },
      error: (err: any) => {
        this.snackBar.open('Error loading sales representatives: ' + err.message, 'Close', { duration: 3000 });
        this.applyFilters();
      }
    });
  }

  applyFilters() {
    let filtered = [...this.salesReps];
    const { search, status } = this.filterForm.value;

    if (search) {
      const searchLower = search.toLowerCase();
      filtered = filtered.filter(salesRep =>
        salesRep.first_name.toLowerCase().includes(searchLower) ||
        salesRep.last_name.toLowerCase().includes(searchLower) ||
        salesRep.email.toLowerCase().includes(searchLower)
      );
    }

    if (status !== 'all') {
      filtered = filtered.filter(salesRep => salesRep.status === status);
    }

    this.dataSource.data = filtered;
  }

  onPageChange(event: PageEvent) {
    this.pageIndex = event.pageIndex;
    this.pageSize = event.pageSize;
    this.loadSalesReps(this.pageIndex + 1, this.pageSize); // API is 1-based
  }

  editSalesRep(salesRep: SalesRep) {
    const dialogRef = this.dialog.open(EditUserDialogComponent, {
      width: '600px',
      data: { ...salesRep, fullName: `${salesRep.first_name} ${salesRep.last_name}` }
    });

    dialogRef.afterClosed().subscribe((result: any) => {
      this.isLoading = true;
      if (result) {
        const payload: any = {};
        if (result.first_name !== salesRep.first_name) {
          payload.first_name = result.first_name;
        }
        if (result.last_name !== salesRep.last_name) {
          payload.last_name = result.last_name;
        }
        if (result.email !== salesRep.email) {
          payload.email = result.email;
        }

        if (Object.keys(payload).length > 0) {
          this.usersService.updateUser(salesRep.id, payload).subscribe({
            next: (response: any) => {
              this.isLoading = false;
              const updatedSalesRep = {
                ...response.data,
                first_name: response.data.first_name || salesRep.first_name,
                last_name: response.data.last_name || salesRep.last_name
              };
              const index = this.salesReps.findIndex((m: any) => m.id === salesRep.id);
              if (index !== -1) {
                this.salesReps[index] = { ...this.salesReps[index], ...updatedSalesRep };
                this.applyFilters();
                this.snackBar.open('Sales Representative updated successfully', 'Close', { duration: 3000 });
              }
            },
            error: (err: any) => {
              this.snackBar.open('Error updating sales representative: ' + err.message, 'Close', { duration: 3000 });
              this.isLoading = false;
            }
          });
        } else {
          this.isLoading = false;
          this.snackBar.open('No changes to update', 'Close', { duration: 3000 });
        }
      } else {
        this.isLoading = false;
      }
    });
  }

  exportSalesReps() {
    console.log(this.dataSource.data); // Debugging: Check data being exported
    const csvContent = [
      ['First Name', 'Last Name', 'Email', 'Status', 'Created At'],
      ...this.dataSource.data.map(salesRep => [
        salesRep.first_name,
        salesRep.last_name,
        salesRep.email,
        salesRep.status,
        new Date(salesRep.createdAt).toLocaleDateString()
      ])
    ].map(row => row.join(',')).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'sales_reps_export.csv';
    a.click();
    window.URL.revokeObjectURL(url);
  }

  toggleStatus(salesRep: SalesRep) {
    const newStatus = salesRep.status === 'Active' ? 'Inactive' : 'Active';
    this.usersService.updateUserStatus(salesRep.id, newStatus).subscribe({
      next: () => {
        salesRep.status = newStatus;
        this.applyFilters();
        this.snackBar.open(`Sales Representative ${newStatus.toLowerCase()} successfully`, 'Close', { duration: 3000 });
      },
      error: (err: any) => {
        this.snackBar.open('Error updating status: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  resetPassword(salesRep: SalesRep) {
    this.usersService.resetPassword(salesRep.id).subscribe({
      next: () => {
        this.snackBar.open('Password reset link sent', 'Close', { duration: 3000 });
      },
      error: (err: any) => {
        this.snackBar.open('Error sending reset link: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  deleteSalesRep(salesRep: SalesRep) {
    const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
      width: '400  px',
      data: {
        title: 'Delete Sales Representative',
        message: `Are you sure you want to delete ${salesRep.first_name} ${salesRep.last_name}? This action cannot be undone.`,
        confirmText: 'Delete',
        cancelText: 'Cancel',
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.usersService.deleteUser(salesRep.id).subscribe({
          next: () => {
            this.salesReps = this.salesReps.filter(m => m.id !== salesRep.id);
            this.totalItems -= 1; // Update totalItems after deletion
            this.applyFilters();
            this.snackBar.open('Sales Representative deleted successfully', 'Close', {
              duration: 3000,
              panelClass: ['success-snackbar']
            });
          },
          error: (err: any) => {
            this.snackBar.open('Error deleting sales representative: ' + err.message, 'Close', {
              duration: 3000,
              panelClass: ['error-snackbar']
            });
          }
        });
      }
    });
  }
}