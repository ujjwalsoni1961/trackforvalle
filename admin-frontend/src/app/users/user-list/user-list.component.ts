import { Component, OnInit } from '@angular/core';
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
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { UsersService } from '../users.service';
import { EditUserDialogComponent } from '../edit-user-dialog/edit-user-dialog.component';
import { finalize } from 'rxjs/operators';
import { ConfirmationDialogComponent } from '../../shared/dialog/confirmation-dialog/confirmation-dialog.component';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { AuthService } from '../../auth/auth.service';

interface User {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string | null;
  role: 'admin' | 'manager' | 'sales_rep';
  status: 'active' | 'inactive' | 'pending';
  createdAt: string;
}

@Component({
  selector: 'app-user-list',
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
    MatPaginatorModule,
    MatSlideToggleModule
  ],
  templateUrl: './user-list.component.html',
  styleUrl: './user-list.component.scss'
})
export class UserListComponent implements OnInit {
  users: User[] = [];
  filteredUsers: User[] = [];
  displayedColumns: string[] = ['fullName', 'email', 'phone', 'role', 'status', 'createdAt', 'actions'];
  filterForm: FormGroup;
  roles = [
    { id: 'all', label: 'All Roles' },
    { id: 'admin', label: 'Admin' },
    { id: 'manager', label: 'Manager' },
    { id: 'sales_rep', label: 'Sales Representative' }
  ];
  statuses = [
    { id: 'all', label: 'All Statuses' },
    { id: 'active', label: 'Active' },
    { id: 'inactive', label: 'Inactive' },
    { id: 'pending', label: 'Verification Pending' }
  ];
  isLoading = false;
  currentPage = 1;
  pageSize = 10;
  totalItems = 0;
  pageSizeOptions = [5, 10, 25, 50];
  currentUserRole: string = '';
  canEditUsers = false;
  canDeleteUsers = false;

  constructor(
    private fb: FormBuilder,
    private usersService: UsersService,
    private snackBar: MatSnackBar,
    private dialog: MatDialog,
    private authService: AuthService
  ) {
    this.filterForm = this.fb.group({
      search: [''],
      role: ['all'],
      status: ['active']
    });
  }

  ngOnInit() {
    // Set up role-based permissions
    const currentUser = this.authService.getCurrentUser();
    this.currentUserRole = currentUser?.role || '';
    
    // Managers can edit sales reps but not other managers or admins
    // Only Admins can edit all users and delete users
    this.canEditUsers = this.authService.hasAnyRole(['manager', 'admin']);
    this.canDeleteUsers = this.authService.hasAnyRole(['admin']);
    
    this.filterForm.valueChanges.pipe(
      debounceTime(300), // Apply debounce to all form changes
      distinctUntilChanged((prev, curr) => JSON.stringify(prev) === JSON.stringify(curr)) // Prevent duplicate emissions
    ).subscribe((formValues) => {
      this.loadUsers();
    });

    // Initial load
    this.loadUsers();
  }

  loadUsers(page: number = 1, limit: number = this.pageSize) {
    this.isLoading = true;
    const { search, role, status } = this.filterForm.value;
    const params: any = { page, limit };
    if (search) params.search = search;
    if (role !== 'all') params.role = role; // Adjust if backend expects numeric IDs
    if (status !== 'all') {
      // Map frontend status to backend-expected values
      params.status = status;
    }

    this.usersService.getUsers(params).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        const teamMembers = response?.data?.teamMembers ?? [];
        this.users = teamMembers.map((member: any) => {
          const [first_name = 'N/A', last_name = ''] = member.full_name ? member.full_name.split(' ') : ['N/A', ''];
          return {
            id: String(member.user_id),
            first_name,
            last_name,
            email: member.email,
            phone: member.phone || null,
            role: member.role?.role_name || 'unknown',
            status: member.is_active ? 'active' : member.invitation_pending ? 'pending' : 'inactive',
            createdAt: member.created_at
          };
        });
        this.currentPage = response.data.pagination.page;
        this.pageSize = response.data.pagination.limit;
        this.totalItems = response.data.pagination.total;
        this.filteredUsers = [...this.users];
      },
      error: (err: any) => {
        this.snackBar.open('Error loading users: ' + err.message, 'Close', { duration: 3000 });
        this.users = [];
        this.filteredUsers = [];
      }
    });
  }

  onPageChange(event: PageEvent) {
    this.currentPage = event.pageIndex + 1;
    this.pageSize = event.pageSize;
    this.loadUsers(this.currentPage, this.pageSize);
  }

  editUser(user: User) {
    const dialogRef = this.dialog.open(EditUserDialogComponent, {
      width: '600px',
      data: { ...user, fullName: `${user.first_name} ${user.last_name}` }
    });

    dialogRef.afterClosed().subscribe((result: any) => {
      this.isLoading = true;
      if (result) {
        const payload: any = {};
        if (result.first_name !== user.first_name) payload.first_name = result.first_name;
        if (result.last_name !== user.last_name) payload.last_name = result.last_name;
        if (result.email !== user.email) payload.email = result.email;
        if (result.phone !== user.phone) payload.phone = result.phone;
        if (result.role !== user.role) payload.role = result.role;

        if (Object.keys(payload).length > 0) {
          this.usersService.updateUser(user.id, payload).subscribe({
            next: (response: any) => {
              this.isLoading = false;
              const updatedUser = {
                ...response.data,
                first_name: response.data.first_name || user.first_name,
                last_name: response.data.last_name || user.last_name,
                phone: response.data.phone || user.phone,
                role: response.data.role?.role_name || user.role
              };
              const index = this.users.findIndex((u: any) => u.id === user.id);
              if (index !== -1) {
                this.users[index] = { ...this.users[index], ...updatedUser };
                this.filteredUsers = [...this.users];
                this.snackBar.open('User updated successfully', 'Close', { duration: 3000 });
              }
            },
            error: (err: any) => {
              this.isLoading = false;
              this.snackBar.open('Error updating user: ' + err.message, 'Close', { duration: 3000 });
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

  exportUsers() {
    this.isLoading = true;
    this.usersService.getUsers({ limit: 1000 }).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response: any) => {
        const teamMembers = response?.data?.teamMembers ?? [];
        const usersForExport = teamMembers.map((member: any) => {
          const [first_name = 'N/A', last_name = ''] = member.full_name ? member.full_name.split(' ') : ['N/A', ''];
          return {
            first_name,
            last_name,
            email: member.email,
            phone: member.phone || 'N/A',
            role: member.role?.role_name || 'unknown',
            status: member.is_active ? 'active' : member.invitation_pending ? 'pending' : 'inactive',
            createdAt: member.created_at
          };
        });

        const csvContent = [
          ['First Name', 'Last Name', 'Email', 'Phone Number', 'Role', 'Status', 'Created At'],
          ...usersForExport.map((user: any) => [
            user.first_name,
            user.last_name,
            user.email,
            user.phone,
            this.getRoleLabel(user.role),
            user.status,
            new Date(user.createdAt).toLocaleDateString()
          ])
        ].map(row => row.join(',')).join('\n');
        const blob = new Blob([csvContent], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'users_export.csv';
        a.click();
        window.URL.revokeObjectURL(url);
      },
      error: (err: any) => {
        this.snackBar.open('Error exporting users: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  toggleStatus(user: User) {
    this.isLoading = true;
    const newStatus = user.status === 'active' ? 'inactive' : 'active';
    // Map to backend-expected value: 'Active' for active, 'Inactive' for inactive
    const backendStatus: 'Active' | 'Inactive' = newStatus === 'active' ? 'Active' : 'Inactive';
    
    this.usersService.updateUserStatus(user.id, backendStatus).subscribe({
      next: () => {
        this.isLoading = false;
        const index = this.users.findIndex(u => u.id === user.id);
        if (index !== -1) {
          this.users[index].status = newStatus;
          this.filteredUsers = [...this.users];
          if (this.filterForm.value.status === 'active' && newStatus === 'inactive') {
            this.loadUsers(this.currentPage, this.pageSize); // Refresh to respect active filter
          }
          this.snackBar.open(`User ${newStatus} successfully`, 'Close', { duration: 3000 });
        }
      },
      error: (err: any) => {
        this.isLoading = false;
        this.snackBar.open('Error updating status: ' + err.message, 'Close', { duration: 3000 });
        // Revert the toggle state on error by refreshing the data
        this.loadUsers(this.currentPage, this.pageSize);
      }
    });
  }

  resendInvitation(user: User) {
    this.isLoading = true;
    this.usersService.resendInvitation(user.id).subscribe({
      next: () => {
        this.isLoading = false;
        this.snackBar.open('Invitation resent successfully', 'Close', { duration: 3000 });
      },
      error: (err: any) => {
        this.isLoading = false;
        this.snackBar.open('Error resending invitation: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  /**
   * Resets the password for a given user, sending a password reset link
   * to their email address.
   *
   * @param user The user whose password should be reset
   */
  resetPassword(user: User) {
    this.isLoading = true;
    this.usersService.resetPassword(user.email).subscribe({
      next: () => {
        this.isLoading = false;
        this.snackBar.open('Password reset link sent', 'Close', { duration: 3000 });
      },
      error: (err: any) => {
        this.isLoading = false;
        this.snackBar.open('Error sending reset link: ' + err.message, 'Close', { duration: 3000 });
      }
    });
  }

  deleteUser(user: User) {
    const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
      width: '400px',
      data: {
        title: 'Delete User',
        message: `Are you sure you want to delete ${user.first_name} ${user.last_name}? This action cannot be undone.`,
        confirmText: 'Delete',
        cancelText: 'Cancel',
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.isLoading = true;
        this.usersService.deleteUser(user.id).subscribe({
          next: () => {
            this.isLoading = false;
            this.users = this.users.filter(u => u.id !== user.id);
            this.filteredUsers = [...this.users];
            this.snackBar.open('User deleted successfully', 'Close', {
              duration: 3000,
              panelClass: ['success-snackbar']
            });
          },
          error: (err: any) => {
            this.isLoading = false;
            this.snackBar.open('Error deleting user: ' + err.message, 'Close', {
              duration: 3000,
              panelClass: ['error-snackbar']
            });
          }
        });
      }
    });
  }

  getRoleLabel(role: string): string {
    return this.roles.find(r => r.id === role)?.label || role;
  }

  canEditUser(user: User): boolean {
    // Admin can edit anyone
    if (this.authService.hasAnyRole(['admin'])) {
      return true;
    }
    
    // Manager can only edit Sales Reps, not other Managers or Admins
    if (this.currentUserRole === 'manager') {
      return user.role === 'sales_rep';
    }
    
    return false;
  }

  canDeleteUser(user: User): boolean {
    // Only Admins can delete users
    return this.canDeleteUsers;
  }

  canToggleUserStatus(user: User): boolean {
    // Same logic as edit - Managers can only toggle Sales Rep status
    return this.canEditUser(user);
  }
}