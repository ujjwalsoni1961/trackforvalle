import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIcon } from '@angular/material/icon';
import { MatProgressBar } from '@angular/material/progress-bar';
import { RouterModule } from '@angular/router';
import { PartnerService } from '../partner.service';

@Component({
  selector: 'app-partner-dashboard',
  standalone: true,
  imports: [CommonModule, MatIcon, MatProgressBar, RouterModule],
  templateUrl: './partner-dashboard.component.html',
  styleUrl: './partner-dashboard.component.scss'
})
export class PartnerDashboardComponent implements OnInit {
  stats: any = null;
  loading = true;

  constructor(private partnerService: PartnerService) {}

  ngOnInit(): void {
    this.loadStats();
  }

  loadStats(): void {
    this.loading = true;
    this.partnerService.getDashboardStats().subscribe({
      next: (response: any) => {
        if (response.success && response.data) {
          this.stats = response.data;
        }
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      }
    });
  }
}
