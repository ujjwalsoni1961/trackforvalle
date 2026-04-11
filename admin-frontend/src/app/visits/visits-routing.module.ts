import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { VisitsListComponent } from './visits-list/visits-list.component';

const routes: Routes = [
  {
    path: '',
    title: 'All Visits',
    component: VisitsListComponent
  }
];

@NgModule({
  imports: [
    CommonModule,
    RouterModule.forChild(routes)
  ],
  exports: [RouterModule]
})
export class VisitsRoutingModule { }