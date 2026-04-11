import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { VisitsListComponent } from './visits-list/visits-list.component';
import { VisitsRoutingModule } from './visits-routing.module';

@NgModule({
  declarations: [],
  imports: [
    CommonModule,
    VisitsListComponent,
    VisitsRoutingModule
  ]
})
export class VisitsModule { }
