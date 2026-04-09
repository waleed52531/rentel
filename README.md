# Rent Settlement App (Flutter MVP)

A Flutter MVP application based on the Rent Settlement product document.

## What this build includes

### Core flow
- Splash screen
- Language selection (English / Urdu)
- Role selection (Tenant / Owner)
- Role-based login with:
  - Phone + OTP mode
  - Email + Password mode

### Tenant side
- Tenant dashboard with status counters
- Create monthly record flow (step-based sections)
  - Month + base rent
  - Electricity/Water/Gas/Other bill amounts
  - Per-bill manual deduction amounts
  - Deduction reason + notes
  - Proof upload simulation (proof type tagging)
- Record submission
- Rejected record edit + resubmission
- Monthly history list with lock/edit state

### Owner side
- Owner dashboard with pending, approved/frozen, and rejected sections
- Submission review screen with:
  - Full monthly summary
  - Bill/deduction review
  - Proof list review
  - Approve & Freeze action
  - Reject with reason

### System behaviors
- Status model: Draft, Submitted, Under Review, Rejected, Approved, Frozen
- Business rules:
  - One active monthly record per month
  - Tenant can edit only Draft/Rejected
  - Submitted/Approved/Frozen are tenant-locked
- In-memory notifications for tenant and owner
- In-memory audit log for key actions

## Project structure

- `lib/models/entities.dart` - domain models and enums
- `lib/state/app_state.dart` - app controller, workflow rules, notifications, audit logging
- `lib/screens/*` - all UI screens
- `lib/widgets/status_badge.dart` - reusable status chip
- `lib/app.dart` / `lib/main.dart` - app bootstrap

## Run locally

```bash
flutter pub get
flutter run
```

> This environment does not include Flutter SDK, so runtime checks were not executable here.
