import { Component, inject, OnInit, viewChild } from '@angular/core';
import { MatIcon } from '@angular/material/icon';
import { NavigationEnd, Router, RouterLink } from '@angular/router';
import { filter } from 'rxjs';
import { Location } from '@angular/common';
import { v7 as uuid } from 'uuid';
import { MatIconButton } from '@angular/material/button';
import {
  SidebarBodyComponent,
  SidebarCompactViewModeDirective,
  SidebarFooterComponent,
  SidebarFullViewModeDirective,
  SidebarHeaderComponent,
  SidebarNavComponent,
  SidebarComponent as EmrSidebarComponent,
  SidebarNavGroupComponent,
  SidebarNavItemComponent,
  SidebarNavHeadingComponent,
  SidebarNavItemBadgeDirective,
  SidebarNavGroupToggleComponent,
  SidebarNavGroupMenuComponent,
  SidebarNavItemIconDirective,
  SidebarNavGroupToggleIconDirective
} from '@elementar-ui/components/sidebar';
import { LogoComponent } from '@elementar-ui/components/logo';
import { DicebearComponent } from '@elementar-ui/components/avatar';
import { OrderByPipe } from '@elementar-ui/components/core';
import { ToolbarComponent } from '../../_store/sidebar';
import { AuthService } from '../../auth/auth.service';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [
    MatIcon,
    RouterLink,
    ToolbarComponent,
    EmrSidebarComponent,
    SidebarBodyComponent,
    SidebarCompactViewModeDirective,
    SidebarFullViewModeDirective,
    SidebarFooterComponent,
    SidebarHeaderComponent,
    SidebarNavComponent,
    DicebearComponent,
    MatIconButton,
    LogoComponent,
    SidebarNavGroupComponent,
    SidebarNavItemComponent,
    SidebarNavHeadingComponent,
    SidebarNavItemBadgeDirective,
    SidebarNavGroupToggleIconDirective,
    SidebarNavGroupToggleComponent,
    SidebarNavGroupMenuComponent,
    SidebarNavItemIconDirective,
    OrderByPipe
  ],
  templateUrl: './sidebar.component.html',
  styleUrl: './sidebar.component.scss',
  host: {
    'class': 'sidebar',
    '[class.compact]': 'compact'
  }
})
export class SidebarComponent implements OnInit {
  private authService = inject(AuthService);
  private router = inject(Router);
  private location = inject(Location);

  height: string | null = '200px';
  compact = false;

  readonly navigation = viewChild.required<any>('navigation');

  navItems: any[] = [
    {
      type: 'group',
      name: 'Dashboard',
      icon: 'dashboard',
      children: [
        { key: uuid(), type: 'link', name: 'Overview', link: '/dashboard/basic' },
        // { key: uuid(), type: 'link', name: 'Reports (Demo)', link: '/dashboard/analytics' }
      ]
    },
    {
      type: 'group',
      name: 'User Management',
      icon: 'group',
      children: [
        { key: uuid(), type: 'link', name: 'All Users', link: '/users' },
        { key: uuid(), type: 'link', name: 'Add User', link: '/users/add', roles: ['admin'] }
      ]
    },
    {
      type: 'group',
      name: 'Sales Team',
      icon: 'supervisor_account',
      children: [
        { key: uuid(), type: 'link', name: 'Managers', link: '/users/managers' },
        { key: uuid(), type: 'link', name: 'Reps', link: '/users/reps' },
        { key: uuid(), type: 'link', name: 'Assign Sales Representatives', link: '/users/assign' }
      ]
    },
    {
      type: 'group',
      name: 'Leads',
      icon: 'people_alt',
      children: [
        { key: uuid(), type: 'link', name: 'All Leads', link: '/leads' },
        { key: uuid(), type: 'link', name: 'Import / Export', link: '/leads/import-export' }
      ]
    },
    {
      type: 'group',
      name: 'Territory',
      icon: 'map',
      children: [
        { key: uuid(), type: 'link', name: 'Salesman Territory', link: '/territories/salesman' },
        // { key: uuid(), type: 'link', name: 'Manager Territory', link: '/territories/manager' }
      ]
    },
    {
      type: 'group',
      name: 'Visits',
      icon: 'event_note',
      children: [
        // { key: uuid(), type: 'link', name: 'Planned Visits', link: '/visits/planned' },
        { key: uuid(), type: 'link', name: 'Visit Logs', link: '/visits' }
      ]
    },
    {
      type: 'group',
      name: 'Routes',
      icon: 'alt_route',
      children: [
        { key: uuid(), type: 'link', name: 'Live Routes', link: '/routes' },
        // { key: uuid(), type: 'link', name: 'Route History', link: '/routes/history' }
      ]
    },
    {
      type: 'group',
      name: 'Contracts',
      icon: 'description',
      children: [
        { key: uuid(), type: 'link', name: 'Contract Templates', link: '/contracts' },
        { key: uuid(), type: 'link', name: 'Create Contract', link: '/contracts/add' },
        { key: uuid(), type: 'link', name: 'Signed Contracts', link: '/contracts/signed' }
      ]
    },
    // {
    //   type: 'group',
    //   name: 'Messaging',
    //   icon: 'chat',
    //   children: [
    //     { key: uuid(), type: 'link', name: 'Chat', link: '/messaging/chat' },
    //     { key: uuid(), type: 'link', name: 'Message History', link: '/messaging/history' }
    //   ]
    // },
    // {
    //   type: 'group',
    //   name: 'Notifications',
    //   icon: 'notifications',
    //   children: [
    //     { key: uuid(), type: 'link', name: 'All Notifications', link: '/notifications' }
    //   ]
    // },
    // {
    //   type: 'group',
    //   name: 'Settings',
    //   icon: 'settings',
    //   children: [
    //     { key: uuid(), type: 'link', name: 'Organization', link: '/settings/org' },
    //     { key: uuid(), type: 'link', name: 'System Logs', link: '/settings/logs' }
    //   ]
    // },
    // {
    //   type: 'heading',
    //   name: 'Legacy / Reference'
    // }
  ];

  navItemLinks: any[] = [];
  activeKey: null | string = null;

  ngOnInit() {
    const currentUser = this.authService.getCurrentUser();
    const userRole = currentUser?.role;

    // Filter navigation items based on user role
    const filteredNavItems = this.navItems.filter(navItem => {
      // If item has role restriction, check if user role matches
      if (navItem.roles && navItem.roles.length > 0) {
        return navItem.roles.includes(userRole);
      }
      return true; // Show item if no role restriction
    }).map(navItem => {
      // Filter children based on role restrictions
      if (navItem.children) {
        const filteredChildren = navItem.children.filter((child: any) => {
          // Check if child has role restrictions
          if (child.roles && child.roles.length > 0) {
            return child.roles.includes(userRole);
          }
          // Special case for Sales Team - hide Managers from Manager role
          if (navItem.name === 'Sales Team' && userRole === 'manager' && child.name === 'Managers') {
            return false;
          }
          return true;
        });
        
        return { ...navItem, children: filteredChildren };
      }
      return navItem;
    });

    filteredNavItems.forEach(navItem => {
      this.navItemLinks.push(navItem);

      if (navItem.children) {
        this.navItemLinks = this.navItemLinks.concat(navItem.children);
      }
    });
    
    // Use filtered items for display
    this.navItems = filteredNavItems;
    
    this._activateLink();
    this.router.events
      .pipe(filter(event => event instanceof NavigationEnd))
      .subscribe(() => this._activateLink());
  }

  private _activateLink() {
    const activeLink = this.navItemLinks.find(navItem => {
      if (navItem.link === this.location.path()) return true;

      if (navItem.type === 'group') {
        return this.location.path() !== '/' && this.location.path().includes(navItem.link as string);
      }

      return false;
    });

    this.activeKey = activeLink?.key || null;
  }
}
