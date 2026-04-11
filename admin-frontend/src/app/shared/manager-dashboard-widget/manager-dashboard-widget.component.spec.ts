import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ManagerDashboardWidgetComponent } from './manager-dashboard-widget.component';

describe('ManagerDashboardWidgetComponent', () => {
  let component: ManagerDashboardWidgetComponent;
  let fixture: ComponentFixture<ManagerDashboardWidgetComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ManagerDashboardWidgetComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ManagerDashboardWidgetComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
