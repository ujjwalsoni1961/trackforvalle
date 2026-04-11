import { afterNextRender, Component, inject, OnInit } from '@angular/core';
import { NavigationEnd, Router, RouterOutlet } from '@angular/router';
import { SupabaseService } from './core/services/supabase.service';
import { filter } from 'rxjs';
import { PageLoadingBarComponent } from '@elementar-ui/components/page-loading-bar';
import {
  AnalyticsService, EnvironmentService,
  InactivityTrackerService,
  SeoService,
  ThemeManagerService
} from '@elementar-ui/components/core';
import { SplashScreenComponent } from '@elementar-ui/components/splash-screen';
import { TextLogoComponent } from '@elementar-ui/components/logo';

@Component({
  selector: 'app-root',
  imports: [
    RouterOutlet,
    PageLoadingBarComponent,
    SplashScreenComponent,
    TextLogoComponent
  ],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent implements OnInit {
  private _themeManager = inject(ThemeManagerService);
  private _analyticsService = inject(AnalyticsService);
  private _inactivityTracker = inject(InactivityTrackerService);
  private _seoService = inject(SeoService);
  private _envService = inject(EnvironmentService);
  private _router = inject(Router);
  private _supabaseService = inject(SupabaseService);

  constructor() {
    afterNextRender(() => {
      // Listen for Supabase PASSWORD_RECOVERY event
      this._supabaseService.onAuthStateChange((event, session) => {
        if (event === 'PASSWORD_RECOVERY') {
          this._router.navigateByUrl('/auth/set-new-password');
        }
      });

      // Scroll a page to top if url changed
      this._router.events
        .pipe(
          filter(event=> event instanceof NavigationEnd)
        )
        .subscribe(() => {
          window.scrollTo({
            top: 0,
            left: 0
          });
        })
      ;

      this._analyticsService.trackPageViews();
      this._inactivityTracker.setupInactivityTimer()
        .subscribe(() => {
          // console.log('Inactive mode has been activated!');
          // this._inactivityTracker.reset();
        })
      ;
    });
  }

  ngOnInit(): void {
    this._themeManager.setColorScheme(this._themeManager.getPreferredColorScheme());
    this._seoService.trackCanonicalChanges(this._envService.getValue('siteUrl'));
  }
}
