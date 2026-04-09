# Rent Settlement App (Flutter MVP Scaffold)

This repository now includes a Flutter app scaffold based on the provided product document.

## Included in this scaffold

- Role selection (Tenant / Owner)
- Login page with Phone+OTP and Email+Password modes
- Tenant dashboard with status summary cards
- Monthly entry form (rent, bills, deductions, notes, proof count)
- Submission flow (record enters **Submitted** status)
- Owner dashboard showing pending submissions
- Owner review page with:
  - Approve & Freeze
  - Reject with comment
- In-memory state management for rapid prototyping

## Run locally

1. Install Flutter SDK.
2. Run:

```bash
flutter pub get
flutter run
```

> Note: CI in this environment does not include Flutter SDK, so runtime checks are expected to be run on a local Flutter setup.
