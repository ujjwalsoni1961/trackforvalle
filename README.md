# Track for Valle - Field Sales Management Platform

A comprehensive field sales management platform with three main components:

## Architecture

```
trackforvalle/
├── backend/          # Node.js + Express + TypeScript API (Vercel serverless)
├── admin-frontend/   # Angular 19 Admin Dashboard
└── salesman-app/     # Flutter Sales Rep App (Android, iOS, Web)
```

## Components

### 1. Backend API (`/backend`)
- **Stack**: Node.js, Express 5, TypeScript, TypeORM
- **Database**: PostgreSQL (Neon)
- **Auth**: JWT-based authentication with role-based access control
- **Services**: AWS S3 (file storage), Google Maps API, Email (nodemailer)
- **Deployment**: Vercel Serverless Functions
- **Features**: User management, lead tracking, visit logging, contracts, territories, routes

### 2. Admin Dashboard (`/admin-frontend`)
- **Stack**: Angular 19, Angular Material, Tailwind CSS, NgRx Signals
- **UI**: Elementar UI Components, Chart.js, ECharts, D3.js
- **Features**: Dashboard analytics, user management, territory management, lead management, visit tracking, route management, contracts
- **Deployment**: Vercel (Static)

### 3. Salesman Mobile App (`/salesman-app`)
- **Stack**: Flutter (Dart), BLoC/Cubit state management, Clean Architecture
- **Platforms**: Android, iOS, Web
- **Features**: Authentication, dashboard, lead management, visit tracking, GPS route tracking, digital contract signing, offline-first with Hive
- **Firebase**: Auth, Firestore (chat), Push Notifications

## User Roles & Platforms

| Role | Platform | Description |
|------|----------|-------------|
| **Super Admin** | Admin Dashboard (Angular) | Full system access, org management |
| **Admin** | Admin Dashboard (Angular) | Organization-level admin access |
| **Manager** | Admin Dashboard (Angular) | Team management, analytics |
| **Sales Rep** | Salesman App (Flutter - Mobile/Web) | Field sales operations |
| **Customer** | N/A (managed via system) | Lead/customer records |

## Setup

### Backend
```bash
cd backend
npm install
cp .env.example .env  # Configure environment variables
npm start             # Development with nodemon
npm run build         # Build TypeScript
```

### Admin Frontend
```bash
cd admin-frontend
npm install
ng serve              # Development at http://localhost:4200
ng build --configuration production  # Production build
```

### Salesman App
```bash
cd salesman-app
flutter pub get
flutter run           # Run on connected device/emulator
flutter build web     # Web build
flutter build apk     # Android build
```

## Environment Variables (Backend)

See `.env.example` for required configuration:
- Database (PostgreSQL/Neon)
- JWT secrets
- AWS credentials (S3)
- Google Maps API key
- Email SMTP configuration
