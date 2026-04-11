import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { RoutesListComponent } from './routes-list/routes-list.component';

const routes: Routes = [
  {
    path: '',
    title: 'All Routes',
    component: RoutesListComponent
  }
];

@NgModule({
  imports: [
    CommonModule,
    RouterModule.forChild(routes)
  ],
  exports: [RouterModule]
})
export class RoutesRoutingModule { }