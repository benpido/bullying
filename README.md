# bullying

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## Web Admin

A simple Node.js web application is provided in `web_admin/` to manage users and view emergency events recorded by the mobile app.

### Deployment

1. Install dependencies:
   ```bash
   cd web_admin
   npm install
   ```
2. Start the server:
   ```bash
   npm start
   ```
3. Open your browser at `http://localhost:3000` to access the admin UI.

The server stores data in `web_admin/data/` and serves encrypted recordings from `web_admin/recordings/`.
