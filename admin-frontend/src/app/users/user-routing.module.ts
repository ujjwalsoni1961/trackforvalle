import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { UserListComponent } from './user-list/user-list.component';
import { UserAddComponent } from './user-add/user-add.component';
import { ManagerListComponent } from './manager-list/manager-list.component';
import { SalesRepListComponent } from './sales-rep-list/sales-rep-list.component';
import { AssignSalesRepComponent } from './assign-sales-rep/assign-sales-rep.component';

const routes: Routes = [
  {
    path: '',
    title: 'Users',
    component: UserListComponent
  },
  {
    path: 'add',
    title: 'Add User',
    component: UserAddComponent
  },
  {
    path: 'managers',
    title: 'Managers',
    component: ManagerListComponent
  },
  {
    path: 'reps',
    title: 'Sales Reps',
    component: SalesRepListComponent
  },
    {
    path: 'assign',
    title: 'Assign Sales Representatives',
    component: AssignSalesRepComponent
  }
];

@NgModule({
  imports: [
    CommonModule,
    RouterModule.forChild(routes)
  ],
  exports: [RouterModule]
})
export class UserRoutingModule { }