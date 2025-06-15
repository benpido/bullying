# Admin Web Interface

This Flutter web application allows administrators to manage user accounts,
configure security settings and review recorded activity logs. All data is stored
in Firebase so changes persist across sessions.

## Running locally

Use Flutter's web support to launch the admin interface in Chrome:

```bash
flutter run -d chrome lib/src/admin_web/app_admin.dart
```

Ensure you have configured Firebase for the project using the files under this
directory. Admin logins persist locally so you stay signed in across browser
reloads.