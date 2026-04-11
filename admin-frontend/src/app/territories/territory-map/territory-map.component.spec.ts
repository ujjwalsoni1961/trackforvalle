import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TerritoryMapComponent } from './territory-map.component';

describe('TerritoryMapComponent', () => {
  let component: TerritoryMapComponent;
  let fixture: ComponentFixture<TerritoryMapComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TerritoryMapComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TerritoryMapComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
