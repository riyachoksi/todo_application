# TODO App - Flutter Application

A TODO application built with Flutter, demonstrating production-level practices including state management, offline support, security, and error handling.

## Architecture

This application follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── main.dart                   # Entry point with flavor configuration
├── app.dart                    # App widget with global providers
├── config/
│   ├── app_config.dart         # Environment configuration
│   ├── flavor.dart             # Flavor definitions
│   └── constants.dart          # App constants
├── core/
│   ├── database/               # Local database (SQLite)
│   ├── network/                # API client & interceptors
│   ├── error/                  # Error handling & exceptions
│   └── utils/                  # Utility classes
├── features/
│   └── todo/
│       ├── data/
│       │   ├── models/         # Data models
│       │   ├── datasources/    # Local & Remote data sources
│       │   └── repositories/   # Repository implementations
│       ├── domain/
│       │   ├── entities/       # Business entities
│       │   └── repositories/   # Repository interfaces
│       └── presentation/
│           ├── providers/      # Riverpod providers
│           ├── pages/          # UI screens
│           └── widgets/        # Reusable widgets
└── shared/
    └── widgets/                # Global widgets
```

### State Management: Riverpod

**Why Riverpod?**
- Modern, compile-safe state management
- Excellent async/await support
- Built-in error handling
- Easy testing and dependency injection
- No BuildContext required for state access

## Setup Instructions

### Prerequisites
- Flutter Version 3.38.7
- Android Studio / VS Code
- iOS development tools (for iOS builds)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd todo_application
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Running Different Flavors

The app supports 4 flavors: **dev**, **qa**, **staging**, and **prod**

### Development
```bash
flutter run --flavor dev --dart-define=FLAVOR=dev
```

### QA
```bash
flutter run --flavor qa --dart-define=FLAVOR=qa
```

### Staging
```bash
flutter run --flavor staging --dart-define=FLAVOR=staging
```

### Production
```bash
flutter run --flavor prod --dart-define=FLAVOR=prod
```

### Building APK/IPA

**Android:**
```bash
flutter build apk --flavor prod --dart-define=FLAVOR=prod
```

**iOS:**
```bash
flutter build ipa --flavor prod --dart-define=FLAVOR=prod
```

## Flavor Configuration

### Android Configuration

Edit `android/app/build.gradle`:

```gradle
flavorDimensions "environment"
productFlavors {
    dev {
        dimension "environment"
        applicationIdSuffix ".dev"
        versionNameSuffix "-dev"
        resValue "string", "app_name", "TODO Dev"
    }
    qa {
        dimension "environment"
        applicationIdSuffix ".qa"
        versionNameSuffix "-qa"
        resValue "string", "app_name", "TODO QA"
    }
    staging {
        dimension "environment"
        applicationIdSuffix ".staging"
        versionNameSuffix "-staging"
        resValue "string", "app_name", "TODO Staging"
    }
    prod {
        dimension "environment"
        resValue "string", "app_name", "TODO"
    }
}
```

### iOS Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Create schemes for each flavor (dev, qa, staging, prod)
3. Add build configurations for each flavor
4. Update Info.plist with flavor-specific values

## Features

### Core Features
- [x] Create, Read, Update, Delete TODOs
- [x] Mark TODOs as complete/incomplete
- [x] Offline data persistence with SQLite
- [x] Automatic sync when online

### Security
- [x] Rooted/Jailbroken device detection
- [x] App blocks execution on compromised devices

### Network & API
- [x] RESTful API integration (JSONPlaceholder)
- [x] Offline-first architecture
- [x] Automatic retry mechanism
- [x] Network connectivity monitoring

### Error Handling
- [x] Global error boundary
- [x] Graceful crash handling
- [x] User-friendly error messages
- [x] Crash recovery page with retry

### Offline Support
- [x] Local SQLite database
- [x] Queue system for pending operations
- [x] Automatic sync on reconnection
- [x] Conflict resolution (last-write-wins)
