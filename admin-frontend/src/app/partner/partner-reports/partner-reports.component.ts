import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIcon } from '@angular/material/icon';
import { MatProgressBar } from '@angular/material/progress-bar';
import { PartnerService } from '../partner.service';

@Component({
  selector: 'app-partner-reports',
  standalone: true,
  imports: [CommonModule, MatIcon, MatProgressBar],
  templateUrl: './partner-reports.component.html',
  styleUrl: './partner-reports.component.scss'
})
export class PartnerReportsComponent implements OnInit {
  reports: any = null;
  loading = true;
  statusEntries: { status: string; count: number }[] = [];

  constructor(private partnerService: PartnerService) {}

  ngOnInit(): void {
    this.loadReports();
  }

  loadReports(): void {
    this.loading = true;
    this.partnerService.getReports().subscribe({
      next: (response: any) => {
        if (response.success && response.data) {
          this.reports = response.data;
          if (response.data.leadsByStatus) {
            this.statusEntries = Object.entries(response.data.leadsByStatus).map(
              ([status, count]) => ({ status, count: count as number })
            );
          }
        }
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      }
    });
  }

  formatStatus(status: string): string {
    return status.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
  }
}
