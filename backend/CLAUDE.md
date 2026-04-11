# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

- **Start development server**: `npm start` (uses nodemon to watch TypeScript files)
- **Build for production**: `npm run build` (compiles TypeScript to dist/ folder)
- **Start production server**: `npm start:prod` (runs compiled JavaScript from dist/)
- **Test**: Currently no test script configured

## Architecture Overview

This is a Node.js/Express TypeScript backend for a field sales management application deployed on Vercel.

### Core Technology Stack
- **Runtime**: Node.js with Express
- **Language**: TypeScript 
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT tokens with Google OAuth support
- **File Storage**: AWS S3 with multer
- **Email**: AWS SES via nodemailer
- **Maps**: Google Maps API with @turf/turf for geospatial operations
- **Deployment**: Vercel with serverless functions

### Key Architectural Patterns

**Database Layer**: Uses TypeORM with a singleton DataSource pattern in `src/config/data-source.ts` for serverless compatibility. Connection pooling is configured for Neon PostgreSQL.

**Route Structure**: Modular routing with prefix-based organization:
- `/api/auth` - Authentication endpoints
- `/api/user` - User management
- `/api/leads` - Lead/customer management
- `/api/visit` - Visit tracking and planning
- `/api/territory` - Territory and route management
- `/api/dashboard` - Analytics and reporting
- `/api/contract` - Contract generation and management

**Entity Relationships**: Complex domain model with key entities:
- Users, Roles, Organizations with permission-based access
- Territories with polygon-based geographic boundaries
- Leads/Customers with address validation
- Visits with route optimization and follow-up scheduling
- Contracts with PDF generation and image attachments

**Service Layer**: Business logic separated into services in `src/service/` with dedicated AWS integrations for S3, SES, and SNS.

**Middleware**: Authentication via JWT tokens, permission-based access control, and request validation.

## Vercel Deployment

The app uses Vercel's serverless functions with configuration in `vercel.json`. Entry point is `api/index.ts` which imports the main application from `src/index.ts`.

Includes a cron job for daily visit planning that runs at 1:30 AM via `/api/cron/daily-visit`.

## Environment Configuration

Requires `.env` file with database connection string and AWS credentials. Database connection uses SSL for production PostgreSQL (likely Neon or similar cloud provider).

## Key Business Logic

**Territory Management**: Geographic boundaries defined by polygons, with salesperson assignments and route optimization.

**Visit Planning**: Automated daily visit scheduling with follow-up tracking and geolocation validation.

**Contract System**: Dynamic PDF generation with template support and digital signature workflow.

**Lead Management**: Customer lifecycle tracking with address validation and territory assignment.