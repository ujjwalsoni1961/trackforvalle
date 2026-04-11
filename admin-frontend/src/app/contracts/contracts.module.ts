import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ContractsComponent } from './contracts/contracts.component';
import { QuillModule } from 'ngx-quill';
import { ContractsRoutingModule } from './contracts-routing.module';
import { AddContractComponent } from './add-contract/add-contract.component';

@NgModule({
  imports: [
    CommonModule,
    ContractsComponent,
    AddContractComponent,
    ContractsRoutingModule,
    QuillModule.forRoot()
  ],
})
export class ContractsModule {}