import { Component, OnInit } from '@angular/core';
import { SharedModule } from '../../../shared/shared.module';
import { AuthService } from '../../../auth/auth.service';
import { Router } from '@angular/router';
import { MatSnackBar } from '@angular/material/snack-bar';
import { ConfirmationDialogComponent } from '../../../shared/dialog/confirmation-dialog/confirmation-dialog.component';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { map, Observable, of } from 'rxjs';

@Component({
  selector: 'emr-sidebar-toolbar',
  imports: [SharedModule
  ],
  templateUrl: './toolbar.component.html',
  styleUrl: './toolbar.component.scss'
})
export class ToolbarComponent implements OnInit {

  constructor(
    private authService: AuthService,
    private router: Router,
    private snackBar: MatSnackBar,
    private dialog: MatDialog
  ) { }

  user$: Observable<User | null> = of(null);
  name$: Observable<string> = of('Guest');
  email$: Observable<string> = of('');
  role$: Observable<string> = of('');

  ngOnInit(): void {
    this.user$ = this.authService.currentUser$;
    this.name$ = this.user$.pipe(
      map((user: any) => user?.name || 'Guest')
    );
    this.email$ = this.user$.pipe(
      map((user: any) => user?.email || '')
    );
    this.role$ = this.user$.pipe(
      map((user: any) => user?.role || '')
    );
  }

  logout(): void {
    const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
      data: {
        title: 'Logout',
        message: 'Are you sure you want to logout?'
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.authService.logout();
        this.snackBar.open('Logged out successfully', 'Dismiss', {
          duration: 3000,
          panelClass: ['success-snackbar']
        });
        this.router.navigate(['/auth/sign-in']);
      }
    });
  }

  getRoleClass(role: string): string {
    switch (role) {
      case 'Admin': return 'bg-red-100 text-red-800 border-red-200';
      case 'Manager': return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'Sales Rep': return 'bg-green-100 text-green-800 border-green-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  }
}

export interface User {
  user_id: number;
  email: string;
  first_name: string;
  last_name: string;
  role_id: number;
}