import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { UserRoutingModule } from './user-routing.module';
import { ManagerListComponent } from './manager-list/manager-list.component';
import { SalesRepListComponent } from './sales-rep-list/sales-rep-list.component';
import { AssignSalesRepComponent } from './assign-sales-rep/assign-sales-rep.component';

@NgModule({
  declarations: [],
  imports: [
    CommonModule,
    UserRoutingModule,
    ManagerListComponent,
    SalesRepListComponent,
    AssignSalesRepComponent
  ]
})
export class UsersModule { }
