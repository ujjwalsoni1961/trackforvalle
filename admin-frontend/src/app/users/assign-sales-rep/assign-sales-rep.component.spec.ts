import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AssignSalesRepComponent } from './assign-sales-rep.component';

describe('AssignSalesRepComponent', () => {
  let component: AssignSalesRepComponent;
  let fixture: ComponentFixture<AssignSalesRepComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AssignSalesRepComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AssignSalesRepComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
