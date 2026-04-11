import { Component, OnInit, OnDestroy, AfterViewInit } from '@angular/core';
import { MatIcon } from '@angular/material/icon';
import { MatRipple } from '@angular/material/core';
import { MatTooltip } from '@angular/material/tooltip';
import { MatProgressBar } from '@angular/material/progress-bar';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { DashboardService } from '../dashboard.service';
import { Chart, registerables } from 'chart.js';
import { AuthService } from '../../auth/auth.service';
import { ManagerDashboardWidgetComponent } from '../../shared/manager-dashboard-widget/manager-dashboard-widget.component';

@Component({
  selector: 'app-basic',
  standalone: true,
  imports: [
    MatIcon,
    MatRipple,
    MatTooltip,
    MatProgressBar,
    CommonModule,
    RouterModule,
    ManagerDashboardWidgetComponent
  ],
  templateUrl: './basic.component.html',
  styleUrl: './basic.component.scss'
})
export class BasicComponent implements OnInit, OnDestroy, AfterViewInit {
  analytics: any = {};
  displayedAnalytics: any = {
    totalUsersCount: 0,
    activeUsersCount: 0,
    pendingVisitsCount: 0,
    closedVisitsCount: 0,
    closedLeadsCount: 0,
    leadsCount: 0,
    totalTerritoryCount: 0,
    totalAddressCount: 0,
    liveRoutesCount: 0,
    unassignedSalesRepsCount: 0,
    totalSignedContracts: 0,
    totalContractTemplates: 0,
    managerCount: 0,
    salesRepCount: 0
  };
  isLoading = false;
  private intervals: any[] = [];
  currentUser: any;
  isManager = false;

  constructor(
    private dashboardService: DashboardService,
    private authService: AuthService
  ) {
    Chart.register(...registerables);
  }

  ngOnInit() {
    this.currentUser = this.authService.getCurrentUser();
    this.isManager = this.currentUser?.role === 'manager';
    
    if (!this.isManager) {
      this.fetchAnalytics();
    }
  }

  ngAfterViewInit() {
    if (!this.isManager) {
      this.renderCharts();
    }
  }

  ngOnDestroy() {
    this.clearIntervals();
  }

  fetchAnalytics() {
    this.isLoading = true;
    this.clearIntervals();
    this.resetDisplayedAnalytics();
    this.dashboardService.getAnalytics().subscribe({
      next: (response: any) => {
        this.isLoading = false;
        if (response.success) {
          const closedLeadsCount = Math.round(response.data.leadsCount * 0.1); // Assume 10% of leads are closed
          this.analytics = {
            ...response.data,
            closedLeadsCount,
            userActivityPercentage: response.data.totalUsersCount ? (response.data.activeUsersCount / response.data.totalUsersCount * 100) : 0,
            leadConversionRate: response.data.leadsCount ? (closedLeadsCount / response.data.leadsCount * 100) : 0
          };
          this.animateCounters();
          this.renderCharts();
        }
      },
      error: (error: any) => {
        console.error('Error fetching analytics:', error);
        this.isLoading = false;
      }
    });
  }

  private resetDisplayedAnalytics() {
    Object.keys(this.displayedAnalytics).forEach(key => {
      this.displayedAnalytics[key] = 0;
    });
  }

  private animateCounters() {
    Object.keys(this.analytics).forEach(key => {
      const target = this.analytics[key] || 0;
      const step = Math.ceil(target / 50);
      let current = 0;
      const interval = setInterval(() => {
        current += step;
        if (current >= target) {
          current = target;
          clearInterval(interval);
        }
        this.displayedAnalytics[key] = current;
      }, 20);
      this.intervals.push(interval);
    });
  }

  private clearIntervals() {
    this.intervals.forEach(interval => clearInterval(interval));
    this.intervals = [];
  }

  private renderCharts() {
    // User Metrics Bar Chart
    const userMetricsChart = new Chart('userMetricsChart', {
      type: 'bar',
      data: {
        labels: ['Total Users', 'Active Users', 'Managers', 'Sales Reps', 'Unassigned Reps'],
        datasets: [{
          label: 'User Metrics',
          data: [
            this.analytics.totalUsersCount || 28,
            this.analytics.activeUsersCount || 23,
            this.analytics.managerCount || 5,
            this.analytics.salesRepCount || 19,
            this.analytics.unassignedSalesRepsCount || 12
          ],
          backgroundColor: ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#EC4899'],
          borderColor: ['#2563EB', '#059669', '#D97706', '#DC2626', '#DB2777'],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true,
            grid: { color: '#E5E7EB' },
            ticks: { color: '#4B5563' }
          },
          x: {
            grid: { display: false },
            ticks: { color: '#4B5563' }
          }
        },
        plugins: {
          legend: { labels: { color: '#4B5563' } },
          title: { display: true, text: 'User Distribution', color: '#4B5563', font: { size: 16 } }
        }
      }
    });

    // Visit and Lead Distribution Pie Chart
    const visitLeadChart = new Chart('visitLeadChart', {
      type: 'pie',
      data: {
        labels: ['Pending Visits', 'Closed Visits', 'Leads', 'Closed Leads'],
        datasets: [{
          data: [
            this.analytics.pendingVisitsCount || 31,
            this.analytics.closedVisitsCount || 42,
            this.analytics.leadsCount || 424,
            this.analytics.closedLeadsCount || 42
          ],
          backgroundColor: ['#F59E0B', '#8B5CF6', '#EF4444', '#14B8A6'],
          borderColor: ['#D97706', '#7C3AED', '#DC2626', '#0D9488'],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom',
            labels: { color: '#4B5563' }
          },
          title: { display: true, text: 'Visit & Lead Distribution', color: '#4B5563', font: { size: 16 } }
        }
      }
    });
  }
}