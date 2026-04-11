# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Flutter Sales Rep Mobile App

This is a field sales representative Flutter application built with Clean Architecture principles, featuring authentication, dashboard, lead management, visit tracking, and contract signing capabilities.

## Development Commands

### Essential Flutter Commands
- **Build/Run**: `flutter run` (debug mode) or `flutter run --release` (release mode)
- **Clean Build**: `flutter clean && flutter pub get`
- **Install Dependencies**: `flutter pub get`
- **Code Generation**: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- **Analyze Code**: `flutter analyze`
- **Format Code**: `flutter format .`
- **Run Tests**: `flutter test` (if tests exist)

### Platform-Specific Build Commands
- **Android APK**: `flutter build apk`
- **iOS Build**: `flutter build ios`
- **Web Build**: `flutter build web --release`
- **Web Development**: `flutter run -d chrome`

### Hive Code Generation
When modifying Hive entities (files with @HiveType annotations), run:
```
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Architecture Overview

### Clean Architecture Pattern
The app follows Clean Architecture with three main layers:

1. **Presentation Layer** (`lib/src/features/*/presentation/`)
   - **Views**: UI screens and widgets
   - **Cubits**: BLoC pattern state management using flutter_bloc
   - **Widgets**: Reusable UI components

2. **Domain Layer** (`lib/src/features/*/domain/`)
   - **Entities**: Core business models with Hive annotations for local storage
   - **Repositories**: Abstract repository interfaces
   - **Use Cases**: Business logic implementations

3. **Data Layer** (`lib/src/features/*/data/`)
   - **Models**: Data transfer objects extending entities
   - **Repositories**: Concrete repository implementations
   - **Data Sources**: Remote (API) and local (Hive) data sources

### Core Architecture Components

- **Dependency Injection**: GetIt service locator (`lib/src/core/injector/injector.dart`)
- **Navigation**: GoRouter for declarative routing (`lib/src/core/ui/routes/routes.dart`)
- **State Management**: BLoC/Cubit pattern with flutter_bloc
- **Local Storage**: Hive database for offline-first architecture
- **API Client**: Dio with interceptors for HTTP requests
- **Firebase Integration**: Authentication, Firestore, and messaging
- **Error Handling**: Dartz Either pattern for functional error handling

### Feature Modules

1. **Authentication** (`lib/src/features/authentication/`)
   - Login/Register with email and Google Sign-In
   - OTP verification and forgot password flows
   - JWT token management and session handling

2. **Dashboard** (`lib/src/features/dashboard/`)
   - Home screen with analytics and metrics
   - Profile management and settings
   - Chat functionality with Firebase

3. **Visits** (`lib/src/features/visits/`)
   - **Daily Routes**: Route planning and GPS tracking
   - **Leads Management**: Add, edit, and track sales leads
   - **Visit Logging**: Record visit outcomes and activities  
   - **Contract Signing**: Digital signature and document handling
   - **Past Visits**: Historical visit data and reports

4. **Edit Profile** (`lib/src/features/edit_profile/`)
   - User profile updates and address management

## Key Technical Implementation Details

### State Management Pattern
- Each feature uses Cubit for state management
- States are defined with sealed classes using Equatable
- All Cubits are registered in the dependency injection container using GetIt
- Cubits are provided to the widget tree via BlocProvider in `main.dart`

### Data Flow with Error Handling
1. UI triggers events on Cubits
2. Cubits call Use Cases from domain layer
3. Use Cases interact with Repository interfaces
4. Repository implementations coordinate between remote and local data sources
5. API responses are cached locally using Hive for offline support
6. Errors are returned as `Either<Failure, T>` using the Dartz package
   - `Left(Failure)` represents an error
   - `Right(T)` represents successful data

### Use Case Pattern
- All use cases extend either `UseCaseWithParams<T, Params>` or `UseCaseWithoutParams<T>`
- Use cases return `ResultFuture<T>` which is `Future<Either<Failure, T>>`
- This pattern ensures consistent error handling across the app

### Navigation Architecture
- Centralized routing configuration in `Routes` class
- Type-safe navigation with route parameters using GoRouter
- Support for nested navigation and deep linking
- Custom `UnfocusNavigatorObserver` to unfocus text fields on navigation

### Firebase Integration
- Firebase Auth for Google Sign-In
- Cloud Firestore for real-time chat functionality
- Firebase Messaging for push notifications
- Firebase initialized in `main.dart` before app starts

### Local Data Management
- Hive database for offline-first architecture
- Entities with @HiveType annotations for type-safe local storage
- Local adapters registered during app initialization in `HiveConfig.init()`
- Boxes: `userBox`, `registerBox`, `appLockBox`, `themeModeBox`

### API Architecture
- RESTful API client using Dio
- Base URL: `https://track-seven-omega.vercel.app/api` (production)
- Staging URL: `https://salesman-app.onrender.com/api`
- Request/response interceptors for authentication and logging
- `APIInterceptor` handles:
  - Automatic JWT token injection into headers
  - Token refresh on 401 errors
  - Auto-logout on authentication failures
  - Session extension on 403 errors
- Pretty Dio Logger for debugging API calls
- Error handling with custom exceptions and failure classes
- API documentation available in `API_DOCUMENTATION.md`

### Network Status Management
- `NetworkStatus` class monitors connectivity using connectivity_plus
- Provides connection status (WiFi, mobile data, ethernet, offline)
- Tracks last sync time and syncing state
- Notifies listeners on connectivity changes

## Development Guidelines

### Adding New Features
1. Create feature folder structure following existing pattern
2. Implement entities in domain layer with Hive annotations if needed
3. Create repository interface in domain layer
4. Implement use cases for business logic (extending `UseCaseWithParams` or `UseCaseWithoutParams`)
5. Create data models extending entities
6. Implement repository with remote/local data sources
7. Create Cubit for state management with Equatable states
8. Build UI views and widgets
9. Register all dependencies in `injector.dart` (use cases, repositories, data sources, cubits)
10. Add BlocProvider in `main.dart` MultiBlocProvider list
11. Define routes in `routes.dart` if navigation is needed
12. Run code generation if Hive entities were added/modified

### Working with APIs
- All API endpoints are documented in `API_DOCUMENTATION.md`
- Use the existing Dio instance from GetIt (`sl<API>().dio`)
- Implement proper error handling with Either pattern
- Token refresh is handled automatically by `APIInterceptor`
- Toggle between staging and production by setting `APIInterceptor.isStaging`

### Local Storage
- Use Hive for any local data persistence needs
- Ensure entities have proper Hive annotations with unique typeIds
- Run `flutter packages pub run build_runner build --delete-conflicting-outputs` after modifying entities
- Access local data through data sources (e.g., `UserLocalDataSource`)

### Error Handling Pattern
- Return `Either<Failure, T>` from repositories and use cases
- Use `.fold()` to handle success/error cases in Cubits
- Define custom Failure classes for different error scenarios
- Display errors to users via Cubit states

### Testing Considerations
- The project currently uses the standard flutter_test setup
- Consider adding unit tests for use cases and cubits
- Integration tests for critical user flows would be valuable

## Web Platform Support

The app has been configured to support web platform with the following considerations:

### Firebase Web Configuration
- Firebase options are configured in `lib/firebase_options.dart`
- Web-specific Firebase configuration is automatically selected when running on web
- Main.dart uses `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
- To update Firebase configuration, run: `flutterfire configure` (requires FlutterFire CLI)

### Web Compatibility Notes
Some features may have limited functionality on web:
- **Geolocation**: Works but requires HTTPS in production and user permission
- **File Picker**: Works with web-specific file selection dialog
- **Push Notifications**: Limited compared to mobile (uses browser notifications API)
- **Signature**: Canvas-based signature widget works on web
- **Local Storage**: Hive works on web using IndexedDB backend
- **Camera/Photo**: Limited to file upload picker on web
- **Google Maps**: Requires proper API key configuration for web

### Building and Testing Web Version
1. **Development**: `flutter run -d chrome`
2. **Production Build**: `flutter build web --release`
3. **Local Server**: Serve from `build/web` directory using any HTTP server
4. **Deploy**: Upload `build/web` contents to web hosting (Firebase Hosting, Netlify, etc.)

### Known Web Limitations
- Some native mobile features won't work (device sensors, background services)
- Firebase Messaging requires additional service worker configuration
- Google Sign-In on web requires proper OAuth client ID configuration

## Important Files

- **Entry Point**: `lib/main.dart` - App initialization, Firebase setup, and BLoC providers
- **Firebase Configuration**: `lib/firebase_options.dart` - Platform-specific Firebase options
- **Dependency Injection**: `lib/src/core/injector/injector.dart` - Service registration with GetIt
- **Routes**: `lib/src/core/ui/routes/routes.dart` - Navigation configuration with GoRouter
- **API Client**: `lib/src/core/network/api.dart` - HTTP client setup
- **API Interceptor**: `lib/src/core/network/api_interceptor.dart` - Token management and error handling
- **API Documentation**: `API_DOCUMENTATION.md` - Complete API reference
- **App Configuration**: `pubspec.yaml` - Dependencies and assets
- **Hive Setup**: `lib/src/core/local/hive_config.dart` - Local database initialization
- **Use Case Base Classes**: `lib/src/core/utils/usecase.dart` - Base classes for business logic
- **Type Definitions**: `lib/src/core/utils/typedef.dart` - Common type aliases (ResultFuture, DataMap)
- **Network Status**: `lib/src/core/network/network_status.dart` - Connectivity monitoring

## Common Patterns

### Dependency Injection Registration
```dart
// In injector.dart
..registerFactory(() => MyCubit(sl()))  // For Cubits (new instance each time)
..registerLazySingleton(() => MyUseCase(sl()))  // For use cases (singleton)
..registerLazySingleton<MyRepository>(() => MyRepositoryImpl(sl()))  // For repositories
..registerLazySingleton<MyDataSource>(() => MyDataSourceImpl(sl()))  // For data sources
```

### Use Case Implementation
```dart
class MyUseCase extends UseCaseWithParams<ReturnType, Params> {
  final MyRepository repository;

  MyUseCase(this.repository);

  @override
  ResultFuture<ReturnType> call(Params params) async {
    return await repository.someMethod(params);
  }
}
```

### Cubit State Management
```dart
// Define states with Equatable
abstract class MyState extends Equatable {}
class MyInitial extends MyState {}
class MyLoading extends MyState {}
class MySuccess extends MyState {
  final Data data;
  MySuccess(this.data);
  @override
  List<Object> get props => [data];
}
class MyError extends MyState {
  final String message;
  MyError(this.message);
  @override
  List<Object> get props => [message];
}

// Use in Cubit
void loadData() async {
  emit(MyLoading());
  final result = await useCase(params);
  result.fold(
    (failure) => emit(MyError(failure.message)),
    (data) => emit(MySuccess(data)),
  );
}
```