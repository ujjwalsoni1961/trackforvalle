import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MaterialModule } from './material.module';
import { DicebearComponent } from '@elementar-ui/components/avatar';
import { HorizontalDividerComponent } from '@elementar-ui/components/divider';
import { FormsModule } from '@angular/forms';

const importedAndExported = [
  MaterialModule,
  DicebearComponent,
  HorizontalDividerComponent,
  CommonModule,
  FormsModule
];

@NgModule({
  declarations: [],
  imports: [
    ...importedAndExported,
  ],
  exports: [
    ...importedAndExported,
  ]
})
export class SharedModule { }
