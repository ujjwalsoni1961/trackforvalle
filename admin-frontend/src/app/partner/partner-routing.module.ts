import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    redirectTo: 'dashboard',
  },
  {
    path: 'dashboard',
    title: 'Partner Dashboard',
    loadComponent: () => import('./partner-dashboard/partner-dashboard.component').then(c => c.PartnerDashboardComponent)
  },
  {
    path: 'contracts',
    title: 'Partner Contracts',
    loadComponent: () => import('./partner-contracts/partner-contracts.component').then(c => c.PartnerContractsComponent)
  },
  {
    path: 'reports',
    title: 'Partner Reports',
    loadComponent: () => import('./partner-reports/partner-reports.component').then(c => c.PartnerReportsComponent)
  },
  {
    path: 'settings',
    title: 'Partner Settings',
    loadComponent: () => import('./partner-settings/partner-settings.component').then(c => c.PartnerSettingsComponent)
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class PartnerRoutingModule { }
