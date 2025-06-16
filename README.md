# Byllying
This repository contains a Flutter application that helps manage emergency contacts and records potential bullying incidents. The app interfaces with Firebase services for authentication and data storage. When a user logs in, their account status and emergency contact list are retrieved from Firestore so the app can dispatch alerts to the correct numbers. Remote configuration from the backend also controls how long audio is recorded during an emergency.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## Web Admin

The administration interface is a Flutter web app located under
`lib/src/admin_web`. It allows administrators to create and manage user
accounts and review activity logs. Accounts created through this interface are
persisted in Firebase Authentication and Firestore so they remain available
across sessions.

### Running locally

Build and serve the web admin by running:

```bash
flutter run -d chrome lib/src/admin_web/app_admin.dart
```

The application connects to Firebase using the configuration in
`lib/src/admin_web/firebase_options.dart`.
Admin sessions use Firebase's local persistence so you remain logged in across
browser refreshes.