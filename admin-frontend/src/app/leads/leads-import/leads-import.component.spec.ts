import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LeadsImportComponent } from './leads-import.component';

describe('LeadsImportComponent', () => {
  let component: LeadsImportComponent;
  let fixture: ComponentFixture<LeadsImportComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LeadsImportComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(LeadsImportComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
