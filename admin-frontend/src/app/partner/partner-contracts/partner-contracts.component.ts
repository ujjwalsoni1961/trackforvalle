import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIcon } from '@angular/material/icon';
import { MatProgressBar } from '@angular/material/progress-bar';
import { MatButton } from '@angular/material/button';
import { PartnerService } from '../partner.service';

@Component({
  selector: 'app-partner-contracts',
  standalone: true,
  imports: [CommonModule, MatIcon, MatProgressBar, MatButton],
  templateUrl: './partner-contracts.component.html',
  styleUrl: './partner-contracts.component.scss'
})
export class PartnerContractsComponent implements OnInit {
  contracts: any[] = [];
  loading = true;
  currentPage = 1;
  totalPages = 1;
  totalItems = 0;

  constructor(private partnerService: PartnerService) {}

  ngOnInit(): void {
    this.loadContracts();
  }

  loadContracts(): void {
    this.loading = true;
    this.partnerService.getContracts({ page: this.currentPage, limit: 10 }).subscribe({
      next: (response: any) => {
        if (response.success && response.data) {
          this.contracts = response.data;
          if (response.pagination) {
            this.totalPages = response.pagination.totalPages;
            this.totalItems = response.pagination.totalItems;
          }
        }
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      }
    });
  }

  nextPage(): void {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
      this.loadContracts();
    }
  }

  prevPage(): void {
    if (this.currentPage > 1) {
      this.currentPage--;
      this.loadContracts();
    }
  }
}
