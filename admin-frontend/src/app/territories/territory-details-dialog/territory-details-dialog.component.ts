import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';

@Component({
  selector: 'app-territory-details-dialog',
  imports: [MatDialogModule],
  templateUrl: './territory-details-dialog.component.html',
  styleUrl: './territory-details-dialog.component.scss'
})
export class TerritoryDetailsDialogComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public data: any) { }

  formatArray(input: string | string[] | null | undefined): string {
    // Handle null or undefined
    if (!input) return 'None';

    try {
      let arr: string[];
      if (typeof input === 'string') {
        // Parse the input, handling possible double-encoded JSON
        let parsed = JSON.parse(input);
        // If parsed result is a string (double-encoded), parse again
        if (typeof parsed === 'string') {
          parsed = JSON.parse(parsed);
        }
        arr = Array.isArray(parsed) ? parsed : [parsed];
      } else if (Array.isArray(input)) {
        // If input is already an array, use it directly
        arr = input;
      } else {
        // If input is neither a string nor an array, treat as single item
        arr = [String(input)];
      }

      // Verify arr is an array
      if (!Array.isArray(arr)) {
        console.warn('formatArray: Final input is not an array', arr);
        return 'None';
      }

      // Join array elements with commas, filtering out null/undefined
      return arr.filter(item => item != null).join(', ');
    } catch (e) {
      console.error('formatArray: Error parsing input', input, e);
      return 'Invalid data';
    }
  }
}
