# estimation_tool

A Flutter planning poker app with a lightweight Dart session backend.

## Project layout

- `lib/`: Flutter client
- `server/`: Dart Shelf backend
- `.github/workflows/release.yml`: Tag-based release automation

## Run locally (without Docker)

### 1) Start the backend

```bash
cd server
dart pub get
dart run bin/server.dart
```

Default backend address: `http://127.0.0.1:8080`

### 2) Start the Flutter app

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

The app reads the backend URL from the `API_BASE_URL` Dart define.

## Run backend with Docker

### Build the image

```bash
cd server
docker build -t estimation-tool-server:local .
```

### Run the container

```bash
docker run --rm -p 8080:8080 \
	-e HOST=0.0.0.0 \
	-e PORT=8080 \
	estimation-tool-server:local
```

Then run the app and point it to the Dockerized backend:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

## Host with Docker (production)

The repository is configured to publish a server image to GitHub Container Registry (GHCR) for each release tag.

### Pull and run a published image

Replace `OWNER` and `TAG`:

```bash
docker pull ghcr.io/OWNER/estimation-tool-server:TAG
docker run -d --name estimation-tool-server -p 8080:8080 \
	-e HOST=0.0.0.0 \
	-e PORT=8080 \
	ghcr.io/OWNER/estimation-tool-server:TAG
```

If you host behind a domain and reverse proxy, point your frontend to that URL:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.your-domain.com
```

Deploy the contents of `build/web/` to any static host (Netlify, Vercel, GitHub Pages, S3/CloudFront, etc.).

## GitHub release flow

Pushing a semantic version tag (`v*.*.*`) triggers `.github/workflows/release.yml`.

The workflow automatically:

- Builds Flutter web in release mode
- Uploads `estimation_tool_web_<tag>.zip` as a GitHub Release asset
- Builds and pushes `ghcr.io/<owner>/estimation-tool-server:<tag>`
- Pushes `latest` for non-prerelease tags

### Create a release

```bash
git add .
git commit -m "release: v0.2.0"
git tag v0.2.0
git push origin main
git push origin v0.2.0
```

After the workflow finishes, find artifacts in:

- GitHub Releases: web zip artifact
- GitHub Packages (GHCR): Docker server image

## Backend API endpoints

- `GET /health`
- `GET /sessions`
- `POST /sessions`
- `GET /sessions/:id`
- `DELETE /sessions/:id`
- `POST /sessions/:id/users`
- `DELETE /sessions/:id/users/:userId`
- `POST /sessions/:id/votes`
- `POST /sessions/:id/status`
