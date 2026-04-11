import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RoutesRoutingModule } from './routes-routing.module';
import { RoutesListComponent } from './routes-list/routes-list.component';

@NgModule({
  declarations: [],
  imports: [
    CommonModule,
    RoutesRoutingModule,
    RoutesListComponent
  ]
})
export class RoutesModule { }
