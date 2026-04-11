import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatChipsModule } from '@angular/material/chips';
import { MatTableModule } from '@angular/material/table';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../auth/auth.service';
import { ManagerDashboardService, ManagerDashboardData, SalesRep } from '../../services/manager-dashboard.service';
import { finalize } from 'rxjs/operators';

@Component({
  selector: 'app-manager-dashboard-widget',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatProgressBarModule,
    MatChipsModule,
    MatTableModule,
    RouterModule
  ],
  templateUrl: './manager-dashboard-widget.component.html',
  styleUrl: './manager-dashboard-widget.component.scss'
})
export class ManagerDashboardWidgetComponent implements OnInit {
  dashboardData: ManagerDashboardData | null = null;
  isLoading = true;
  currentUser: any;
  salesRepColumns: string[] = ['name', 'leads', 'visits', 'contracts', 'performance'];

  constructor(
    private managerDashboardService: ManagerDashboardService,
    private authService: AuthService,
    private router: Router
  ) {}

  ngOnInit() {
    this.currentUser = this.authService.getCurrentUser();
    this.loadManagerDashboard();
  }

  loadManagerDashboard() {
    this.isLoading = true;
    const token = this.authService.getToken();
    
    this.managerDashboardService.getManagerDashboard(token || undefined).pipe(
      finalize(() => this.isLoading = false)
    ).subscribe({
      next: (response) => {
        if (response.success) {
          this.dashboardData = response.data;
        }
      },
      error: (error) => {
        console.error('Error loading manager dashboard:', error);
      }
    });
  }

  getPerformancePercentage(salesRep: SalesRep): number {
    const totalLeads = parseInt(salesRep.total_leads) || 0;
    const signedLeads = parseInt(salesRep.signed_leads) || 0;
    return totalLeads > 0 ? Math.round((signedLeads / totalLeads) * 100) : 0;
  }

  getPerformanceColor(percentage: number): string {
    if (percentage >= 80) return 'primary';
    if (percentage >= 60) return 'accent';
    return 'warn';
  }

  getVisitCompletionRate(salesRep: SalesRep): number {
    const totalVisits = parseInt(salesRep.total_visits) || 0;
    const completedVisits = parseInt(salesRep.completed_visits) || 0;
    return totalVisits > 0 ? Math.round((completedVisits / totalVisits) * 100) : 0;
  }

  navigateToLeads() {
    this.router.navigate(['/leads']);
  }

  navigateToContracts() {
    this.router.navigate(['/contracts']);
  }

  navigateToUsers() {
    this.router.navigate(['/users']);
  }

  navigateToVisits() {
    this.router.navigate(['/visits']);
  }
}
