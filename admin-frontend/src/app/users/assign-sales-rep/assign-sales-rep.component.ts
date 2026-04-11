import { Component, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormGroup, FormBuilder, Validators } from '@angular/forms';
import { MatSnackBar } from '@angular/material/snack-bar';
import { UsersService } from '../users.service';
import { finalize } from 'rxjs/operators';
import { MatTableDataSource } from '@angular/material/table';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSelectModule } from '@angular/material/select';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

interface Manager {
  id: string;
  full_name: string;
  email: string;
}

interface SalesRep {
  id: string;
  full_name: string;
  email: string;
  phone: string;
}

interface Assignment {
  manager: Manager;
  salesman: SalesRep;
}

@Component({
  selector: 'app-assign-sales-rep',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    MatTableModule,
    MatPaginatorModule,
    MatButtonModule,
    MatIconModule,
    MatSelectModule,
    MatInputModule,
    MatFormFieldModule,
    MatProgressBarModule,
    MatProgressSpinnerModule 
  ],
  templateUrl: './assign-sales-rep.component.html',
  styleUrls: ['./assign-sales-rep.component.scss']
})
export class AssignSalesRepComponent implements OnInit {
  assignmentForm: FormGroup;
  managers: Manager[] = [];
  unassignedSalesReps: SalesRep[] = [];
  isLoading = false;
  isLoadingSalesReps = false;
  showAssignmentForm = false;
  displayedColumns: string[] = ['manager', 'salesman', 'phone', 'actions'];
  dataSource = new MatTableDataSource<Assignment>();
  managerFilter: string = '';
  salesmanFilter: string = '';
  currentPage: number = 1;
  totalPages: number = 1;
  hasMoreSalesReps: boolean = false;

  @ViewChild(MatPaginator) paginator!: MatPaginator;

  constructor(
    private fb: FormBuilder,
    private usersService: UsersService,
    private snackBar: MatSnackBar
  ) {
    this.assignmentForm = this.fb.group({
      managerId: ['', Validators.required],
      salesRepIds: [[], Validators.required]
    });
  }

  ngOnInit() {
    this.loadManagers();
    this.loadUnassignedSalesReps();
    this.loadAssignments();
  }

  loadManagers() {
    this.isLoading = true;
    this.usersService.getManagers().pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        const teamMembers = response?.data ?? [];
        this.managers = teamMembers.map((member: any) => {
          const [first_name = 'N/A', last_name = ''] = member.full_name ? member.full_name.split(' ') : ['N/A', ''];
          const full_name = member.full_name;
          return {
            id: String(member.user_id),
            first_name,
            last_name,
            full_name,
            email: member.email
          };
        });
      },
      error: (err: any) => {
        this.snackBar.open('Error loading managers: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  loadUnassignedSalesReps(page: number = 1, limit: number = 10) {
    this.isLoadingSalesReps = true;
    this.usersService.getUnassignedSalesReps({ page, limit }).pipe(
      finalize(() => this.isLoadingSalesReps = false)
    ).subscribe({
      next: (response: any) => {
        const salesReps = response.data.map((member: any) => ({
          id: String(member.user_id),
          full_name: member.full_name,
          email: member.email,
          phone: member.phone
        }));
        if (page === 1) {
          this.unassignedSalesReps = salesReps;
        } else {
          this.unassignedSalesReps = [...this.unassignedSalesReps, ...salesReps];
        }
        this.currentPage = response.pagination.currentPage;
        this.totalPages = response.pagination.totalPages;
        this.hasMoreSalesReps = !!response.pagination.nextPage;
      },
      error: (err: any) => {
        this.snackBar.open('Error loading unassigned sales reps: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  loadMoreSalesReps() {
    if (this.hasMoreSalesReps) {
      this.loadUnassignedSalesReps(this.currentPage + 1);
    }
  }

  loadAssignments() {
    this.isLoading = true;
    this.usersService.getAssignedSalesReps().pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        const assignments: Assignment[] = [];
        response.data.forEach((group: any) => {
          group.sales_reps.forEach((rep: any) => {
            assignments.push({
              manager: {
                id: String(group.manager.user_id),
                full_name: group.manager.full_name,
                email: group.manager.email
              },
              salesman: {
                id: String(rep.user_id),
                full_name: rep.full_name,
                email: rep.email,
                phone: rep.phone
              }
            });
          });
        });
        this.dataSource.data = assignments;
        this.dataSource.paginator = this.paginator;
        this.applyFilters();
      },
      error: (err: any) => {
        this.snackBar.open('Error loading assignments: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  applyFilters() {
    this.dataSource.filterPredicate = (data: Assignment, filter: string) => {
      const filters = JSON.parse(filter);
      const matchesManager = !filters.managerId || data.manager.id === filters.managerId;
      const matchesSalesman = !filters.salesmanFilter ||
        data.salesman.full_name.toLowerCase().includes(filters.salesmanFilter.toLowerCase()) ||
        data.salesman.email.toLowerCase().includes(filters.salesmanFilter.toLowerCase());
      return matchesManager && matchesSalesman;
    };

    this.dataSource.filter = JSON.stringify({
      managerId: this.managerFilter,
      salesmanFilter: this.salesmanFilter
    });
  }

  clearFilters() {
    this.managerFilter = '';
    this.salesmanFilter = '';
    this.applyFilters();
  }

  assignSalesReps() {
    if (this.assignmentForm.valid) {
      this.isLoading = true;
      const { managerId, salesRepIds } = this.assignmentForm.value;
      const payload = {
        manager_id: Number(managerId),
        sale_rep_ids: salesRepIds.map((id: string) => Number(id))
      };

      this.usersService.assignSalesRepsToManager(payload).pipe(
        finalize(() => {
          this.isLoading = false;
          this.loadAssignments();
          this.loadUnassignedSalesReps();
        })
      ).subscribe({
        next: () => {
          this.snackBar.open('Sales representatives assigned successfully', 'Close', { duration: 3000 });
          this.resetForm();
        },
        error: (err: any) => {
          this.snackBar.open('Error assigning sales representatives: ' + err.message, 'Close', { duration: 3000 });
        }
      });
    }
  }

  removeSalesman(salesmanId: string) {
    if (confirm('Are you sure you want to remove this salesman from their manager?')) {
      this.isLoading = true;
      this.usersService.removeSalesmanFromManager(Number(salesmanId)).pipe(
        finalize(() => {
          this.isLoading = false;
          this.loadAssignments();
          this.loadUnassignedSalesReps();
        })
      ).subscribe({
        next: () => {
          this.snackBar.open('Salesman removed successfully', 'Close', { duration: 3000 });
        },
        error: (err: any) => {
          this.snackBar.open('Error removing salesman: ' + err.message, 'Close', { duration: 3000 });
        }
      });
    }
  }

  resetForm() {
    this.assignmentForm.reset({
      managerId: '',
      salesRepIds: []
    });
  }
}