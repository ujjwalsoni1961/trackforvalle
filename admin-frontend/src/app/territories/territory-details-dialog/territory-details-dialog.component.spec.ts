import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TerritoryDetailsDialogComponent } from './territory-details-dialog.component';

describe('TerritoryDetailsDialogComponent', () => {
  let component: TerritoryDetailsDialogComponent;
  let fixture: ComponentFixture<TerritoryDetailsDialogComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TerritoryDetailsDialogComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TerritoryDetailsDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
