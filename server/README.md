# estimation_tool_server

A small Dart backend for handling planning sessions.

## Run

```bash
dart pub get
dart run bin/server.dart
```

By default the server listens on `http://localhost:8080`.

## Endpoints

- `GET /health`
- `GET /sessions`
- `POST /sessions`
- `GET /sessions/:id`
- `DELETE /sessions/:id`
- `POST /sessions/:id/users`
- `POST /sessions/:id/votes`
- `POST /sessions/:id/status`
