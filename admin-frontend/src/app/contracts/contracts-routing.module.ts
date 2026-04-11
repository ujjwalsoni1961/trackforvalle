import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { ContractsComponent } from './contracts/contracts.component';
import { AddContractComponent } from './add-contract/add-contract.component';
import { SignedContractsComponent } from './signed-contracts/signed-contracts.component';
const routes: Routes = [
  {
    path: '',
    component: ContractsComponent
  },
  {
    path: 'add',
    component: AddContractComponent
  },
  {
    path: 'signed',
    component: SignedContractsComponent
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class ContractsRoutingModule { }