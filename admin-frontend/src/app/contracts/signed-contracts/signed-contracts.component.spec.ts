import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SignedContractsComponent } from './signed-contracts.component';

describe('SignedContractsComponent', () => {
  let component: SignedContractsComponent;
  let fixture: ComponentFixture<SignedContractsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SignedContractsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SignedContractsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
