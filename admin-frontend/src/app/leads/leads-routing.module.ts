import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LeadsImportComponent } from './leads-import/leads-import.component';
import { AllLeadsComponent } from './all-leads/all-leads.component';

const routes: Routes = [
  {
    path: 'import-export',
    title: 'Leads Import Export',
    component: LeadsImportComponent
  },
  {
    path: '',
    title: 'All Leads',
    component: AllLeadsComponent
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class LeadsRoutingModule { }
