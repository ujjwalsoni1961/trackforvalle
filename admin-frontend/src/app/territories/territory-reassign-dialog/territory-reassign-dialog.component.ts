import { Component, Inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { FormsModule } from '@angular/forms';
import { TerritoryService } from '../territory.service';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';

@Component({
  selector: 'app-territory-reassign-dialog',
  standalone: true,
  imports: [
    CommonModule,
    MatDialogModule,
    MatSelectModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    MatSnackBarModule,
    FormsModule
  ],
  template: `
    <h2 mat-dialog-title>Reassign Territory</h2>
    <mat-dialog-content>
      <p class="mb-4">Reassign <strong>{{ data.territoryName }}</strong> to a new salesman.</p>
      <p class="text-sm text-neutral-500 mb-4">
        All unsigned leads will be transferred to the new salesman.
        Signed contracts will remain with the original salesman.
      </p>
      <mat-form-field class="w-full" appearance="outline">
        <mat-label>New Salesman</mat-label>
        <mat-select [(value)]="selectedSalesmanId">
          <mat-option *ngFor="let salesman of salesmen" [value]="salesman.id">
            {{ salesman.name }}
          </mat-option>
        </mat-select>
      </mat-form-field>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>Cancel</button>
      <button mat-flat-button color="primary"
              [disabled]="!selectedSalesmanId || isReassigning"
              (click)="reassign()">
        <mat-spinner *ngIf="isReassigning" diameter="20" class="inline-block mr-2"></mat-spinner>
        Reassign
      </button>
    </mat-dialog-actions>
  `
})
export class TerritoryReassignDialogComponent implements OnInit {
  salesmen: { id: string; name: string }[] = [];
  selectedSalesmanId: string | null = null;
  isReassigning = false;

  constructor(
    @Inject(MAT_DIALOG_DATA) public data: { territoryId: string; territoryName: string; currentSalesmanId?: string },
    private dialogRef: MatDialogRef<TerritoryReassignDialogComponent>,
    private territoryService: TerritoryService,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit() {
    this.territoryService.getSalesmen().subscribe({
      next: (response: any) => {
        this.salesmen = (response.data || []).map((s: any) => ({
          id: s.user_id,
          name: s.full_name
        }));
      },
      error: () => {
        this.snackBar.open('Failed to load salesmen', 'Close', { duration: 3000 });
      }
    });
  }

  reassign() {
    if (!this.selectedSalesmanId) return;
    this.isReassigning = true;
    this.territoryService.reassignTerritory(this.data.territoryId, this.selectedSalesmanId).subscribe({
      next: (response: any) => {
        this.isReassigning = false;
        this.snackBar.open(response.message || 'Territory reassigned successfully', 'Close', { duration: 5000 });
        this.dialogRef.close(true);
      },
      error: (err: any) => {
        this.isReassigning = false;
        this.snackBar.open('Failed to reassign territory: ' + (err.message || 'Unknown error'), 'Close', { duration: 5000 });
      }
    });
  }
}
