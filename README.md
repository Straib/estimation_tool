# estimation_tool

A Flutter planning poker app with a lightweight Dart session backend.

## App

```bash
flutter pub get
flutter run
```

The app reads the backend URL from a Dart define named `API_BASE_URL`.

Example:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

## Session Server

The backend server lives in `server/` and exposes REST endpoints for sessions.

```bash
cd server
dart pub get
dart run bin/server.dart
```

Default address: `http://localhost:8080`

### API Endpoints

- `GET /health`
- `GET /sessions`
- `POST /sessions`
- `GET /sessions/:id`
- `DELETE /sessions/:id`
- `POST /sessions/:id/users`
- `POST /sessions/:id/votes`
- `POST /sessions/:id/status`
