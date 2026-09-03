# Rentra Flutter App

Rentra is a Material 3 Flutter client for the Laravel rental-management API in
`../Rentra`. The production app uses explicit Bloc events and states, a
centralized HTTP client, Laravel Sanctum bearer authentication, and secure token
storage. It does not fall back to local or generated data.

## Supported workflows

- Authentication with `identifier`, `password`, and `device_name`, including
  `/me` session restoration, role-aware routing, logout, and global 401 expiry.
- Owner property creation/editing, publication changes, and multipart image and
  video upload.
- Owner application review, tenancy creation and terms management, monthly
  record review/freeze/reopen, and maintenance transitions/history.
- Renter listing discovery and details, applications, tenancy history, monthly
  drafts/submission/proofs, and maintenance requests/comments/history.
- Role-aware notifications with read/unread and mark-read actions.
- Shared loading, empty, API-error, retry, status, property-card, and media
  states. Laravel 422 field errors are retained and rendered in readable form.

Favorites are intentionally absent from the production client because Laravel
does not expose a favorites endpoint under `/api/v1`. Property deletion and
existing property-media deletion are also omitted because their API routes do
not exist. The supported media upload contract is fully integrated.

## Architecture

- `lib/core/api/app_api_client.dart` — `/api/v1` requests, multipart, paging,
  timeouts, network errors, Laravel errors, and 401 events.
- `lib/repositories` — authentication and feature data boundaries.
- `lib/features` — event/state/Bloc modules for every API-backed feature.
- `lib/models/entities.dart` — defensive Laravel resource parsing and enums.
- `lib/screens` — role-gated Owner and Renter mobile workflows.
- `lib/widgets` — shared feature states, status badges, cards, and media UI.

## Run locally

The Android emulator reaches a Laravel server on the host through the default
base URL `http://10.0.2.2:8000`:

```bash
flutter pub get
flutter run
```

Override it for a physical device or another environment:

```bash
flutter run --dart-define=RENTRA_API_BASE_URL=http://192.168.1.10:8000
```

The configured value may include or omit `/api/v1`; the client normalizes it.

## Verification

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```
