import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { TerritoryListComponent } from './territory-list/territory-list.component';
import { TerritoryFormComponent } from './territory-form/territory-form.component';
import { ManagerListComponent } from './manager-list/manager-list.component';

const routes: Routes = [
  {
    path: 'salesman',
    title: 'Salesman Territory',
    component: TerritoryListComponent
  },
  {
    path: 'manager',
    title: 'Manager Territory',
    component: ManagerListComponent
  },
  {
    path: 'add',
    component: TerritoryFormComponent
  },
  {
    path: ':id/edit',
    component: TerritoryFormComponent
  }
];

@NgModule({
  imports: [
    CommonModule,
    RouterModule.forChild(routes)
  ],
  exports: [RouterModule]
})
export class TerritoryRoutingModule { }
