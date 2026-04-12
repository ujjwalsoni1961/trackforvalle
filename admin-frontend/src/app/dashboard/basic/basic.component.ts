import { Component, OnInit, OnDestroy, AfterViewInit, ElementRef, ViewChild } from '@angular/core';
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
    totalLeads: 0,
    totalSignedContracts: 0,
    activeSalesReps: 0,
    totalTerritories: 0,
    totalPartners: 0,
    pendingVisits: 0
  };
  isLoading = false;
  private intervals: any[] = [];
  private chartInstances: Chart[] = [];
  currentUser: any;
  isManager = false;

  @ViewChild('leadsByPartnerCanvas') leadsByPartnerCanvas!: ElementRef<HTMLCanvasElement>;

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

  ngAfterViewInit() {}

  ngOnDestroy() {
    this.clearIntervals();
    this.chartInstances.forEach(c => c.destroy());
  }

  fetchAnalytics() {
    this.isLoading = true;
    this.clearIntervals();
    this.resetDisplayedAnalytics();
    this.dashboardService.getAnalytics().subscribe({
      next: (response: any) => {
        this.isLoading = false;
        if (response.success) {
          this.analytics = response.data;
          this.animateCounters();
          setTimeout(() => this.renderCharts(), 100);
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
    const keys = Object.keys(this.displayedAnalytics);
    keys.forEach(key => {
      const target = this.analytics[key] || 0;
      if (target === 0) return;
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
    this.chartInstances.forEach(c => c.destroy());
    this.chartInstances = [];

    const leadsByPartner = this.analytics.leadsByPartner || [];
    if (leadsByPartner.length > 0 && this.leadsByPartnerCanvas) {
      const chart = new Chart(this.leadsByPartnerCanvas.nativeElement, {
        type: 'bar',
        data: {
          labels: leadsByPartner.map((p: any) => p.partnerName),
          datasets: [{
            label: 'Leads',
            data: leadsByPartner.map((p: any) => p.count),
            backgroundColor: '#4B7BF5',
            borderRadius: 4,
            barThickness: 28
          }]
        },
        options: {
          indexAxis: 'y',
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            x: {
              beginAtZero: true,
              grid: { color: '#F3F4F6' },
              ticks: { color: '#6B7280', stepSize: 1 }
            },
            y: {
              grid: { display: false },
              ticks: { color: '#374151', font: { size: 12 } }
            }
          },
          plugins: {
            legend: { display: false }
          }
        }
      });
      this.chartInstances.push(chart);
    }
  }
}
