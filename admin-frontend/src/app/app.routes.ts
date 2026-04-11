import { Routes } from '@angular/router';
import { AuthGuard } from './core/guards/auth.guard'; // Import AuthGuard
// import { managerGuard } from './core/guards/manager.guard';

export const routes: Routes = [
  {
    path: 'auth',
    loadChildren: () => import('./auth/auth.module').then(m => m.AuthModule)
  },
  {
    path: 'error',
    loadChildren: () => import('./error/error.module').then(m => m.ErrorModule)
  },
  {
    path: 'onboarding',
    loadChildren: () => import('./onboarding/onboarding.module').then(m => m.OnboardingModule)
  },
  {
    path: '',
    canActivate: [AuthGuard],
    canLoad: [AuthGuard],
    loadComponent: () => import('./app/app.component').then(c => c.AppComponent),
    children: [
      {
        path: '',
        pathMatch: 'full',
        redirectTo: 'dashboard',
      },
      {
        path: 'dashboard',
        loadChildren: () => import('./dashboard/dashboard.module').then(m => m.DashboardModule)
      },
      {
        path: 'territories',
        loadChildren: () => import('./territories/territory.module').then(m => m.TerritoryModule)
      },
      {
        path: 'leads',
        loadChildren: () => import('./leads/leads.module').then(m => m.LeadsModule)
      },
      {
        path: 'users',
        loadChildren: () => import('./users/users.module').then(m => m.UsersModule)
      },
      {
        path: 'visits',
        loadChildren: () => import('./visits/visits.module').then(m => m.VisitsModule)
      },
      {
        path: 'routes',
        loadChildren: () => import('./routes/routes.module').then(m => m.RoutesModule)
      },
      {
        path: 'contracts',
        loadChildren: () => import('./contracts/contracts.module').then(m => m.ContractsModule)
      },
      // {
      //   path: 'manager',
      //   canActivate: [managerGuard],
      //   loadChildren: () => import('./manager/manager.module').then(m => m.ManagerModule)
      // },
      {
        path: 'user-profile',
        loadChildren: () => import('./user-profile/user-profile.module').then(m => m.UserProfileModule)
      },
      {
        path: 'account/notifications',
        loadComponent: () => import('./account/notifications/notifications.component').then(m => m.NotificationsComponent)
      },
      {
        path: 'account/settings',
        loadChildren: () => import('./account/settings/settings.module').then(m => m.SettingsModule)
      },
      {
        path: 'store',
        loadChildren: () => import('./store/store.module').then(m => m.StoreModule)
      },
      {
        path: 'pricing',
        loadChildren: () => import('./pricing/pricing.module').then(m => m.PricingModule)
      },
      {
        path: 'applications',
        loadChildren: () => import('./applications/applications.module').then(m => m.ApplicationsModule)
      },
      {
        path: 'content',
        loadChildren: () => import('./content/content.module').then(m => m.ContentModule)
      },
      {
        path: 'service-pages',
        loadChildren: () => import('./service-pages/service-pages.module').then(m => m.ServicePagesModule)
      },
      {
        path: 'themes',
        loadChildren: () => import('./themes/themes.module').then(m => m.ThemesModule)
      },
    ]
  },
  {
    path: '**',
    title: 'Page Not Found',
    loadComponent: () => import('./error/not-found/not-found.component').then(c => c.NotFoundComponent)
  },
];
