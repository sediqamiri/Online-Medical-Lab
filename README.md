# Online Medical Lab

Online Medical Lab is a Flutter application for patients, doctors, and laboratory teams to manage medical test booking, appointments, and report access from one product.

## Features

- Patient-friendly onboarding with login, registration, and role selection
- Test search and booking flows
- Dashboard views for patients, doctors, and lab admins
- Appointment tracking and reports center
- Web-ready landing experience with responsive dashboard layouts
- Local profile storage and notification support

## Tech Stack

- Flutter
- Dart
- Provider
- Shared Preferences
- Flutter Local Notifications

## Project Structure

- `lib/screens/` contains the main UI flows
- `lib/providers/` contains state management
- `lib/models/` contains app data models
- `lib/services/` contains notifications and integration helpers
- `assets/` contains branding and app images

## Getting Started

1. Install Flutter.
2. Run `flutter pub get`.
3. Start the app with `flutter run` or `flutter run -d chrome` for web.

## Verification

- `flutter analyze lib/screens/welcome_screen.dart lib/screens/dashboard/home_tab.dart lib/screens/dashboard/dashboard_screen.dart`
- `flutter test test/widget_test.dart`
