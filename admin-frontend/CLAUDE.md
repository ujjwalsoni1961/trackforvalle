# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Commands
- **Development server**: `ng serve` or `npm start` - Starts development server at http://localhost:4200/
- **Build**: `ng build` - Creates development build in dist/
- **Production build**: `ng build --configuration production` or `npm run build:prod`
- **Test**: `ng test` - Runs unit tests with Karma/Jasmine
- **Watch build**: `ng build --watch --configuration development`

### Angular CLI Scaffolding
- Generate component: `ng generate component component-name`
- Generate service: `ng generate service service-name`
- Generate module: `ng generate module module-name`
- Available schematics: `ng generate --help`

## Architecture Overview

### Application Type
Field Sales Admin dashboard built with Angular 19, using modular architecture with lazy-loaded feature modules.

### Key Technologies
- **Framework**: Angular 19 with standalone components
- **UI Library**: Angular Material + Elementar UI Components
- **Styling**: SCSS + Tailwind CSS
- **State Management**: NgRx Signals
- **Authentication**: JWT-based with custom guards
- **Charts**: Chart.js, ECharts, D3.js
- **Rich Text**: TipTap editor
- **Data Import**: Papa Parse for CSV

### Project Structure
```
src/app/
├── _app/           # Core layout components (header, sidebar, screen-loader)
├── _meta/          # Shared utilities and playground components
├── _state/         # Global app state management (NgRx Signals)
├── _store/         # UI component library (widgets, notifications, selects)
├── core/           # Core services, guards, and interceptors
├── shared/         # Shared modules and components
├── auth/           # Authentication module
├── dashboard/      # Dashboard views (analytics, basic, ecommerce, finance)
├── territories/    # Territory management
├── leads/          # Lead management
├── users/          # User management
├── visits/         # Visit tracking
├── routes/         # Route management
├── contracts/      # Contract management
└── themes/         # Theme switching
```

### Key Services & Architecture
- **AuthService**: JWT authentication with role-based access control (src/app/auth/auth.service.ts)
- **AppStore**: Global state using NgRx Signals for announcements (src/app/_state/app.store.ts)
- **AuthGuard**: Route protection (src/app/core/guards/auth.guard.ts)
- **JwtInterceptor**: Automatic token attachment (src/app/core/interceptors/jwt.interceptor.ts)

### Module Architecture
- Feature modules use lazy loading for optimal performance
- Each module has its own routing, services, and components
- Shared MaterialModule provides consistent Angular Material imports
- Core module provides authentication and HTTP interceptors

### Environment Configuration
- Development API: http://localhost:3002/api
- Environment files handle different build configurations
- JWT tokens stored in localStorage with minimal user data caching

### UI Framework Details
- Uses Angular Material with custom theme variants (rose-red, magenta-violet, cyan-orange)
- Elementar UI provides additional dashboard components
- Custom widget system for dashboard analytics
- Responsive design with SCSS and Tailwind utilities

### Testing
- Karma + Jasmine test runner
- Component specs follow Angular testing patterns
- Test files use `.spec.ts` extension

### Code Style
- TypeScript strict mode enabled
- SCSS for component styling
- Angular component prefix: "app"
- Follow Angular style guide conventions