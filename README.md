# Wakeel AI — Mobile

[![CI](https://github.com/WakeelAI-Project/WakeelAI-Mobile/actions/workflows/ci.yml/badge.svg)](https://github.com/WakeelAI-Project/WakeelAI-Mobile/actions/workflows/ci.yml)
[![Release](https://github.com/WakeelAI-Project/WakeelAI-Mobile/actions/workflows/release.yml/badge.svg)](https://github.com/WakeelAI-Project/WakeelAI-Mobile/actions/workflows/release.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.44.4-02569B?logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)

The employee-facing Flutter app for **Wakeel AI**, an AI-assisted HR platform. Employees chat with an AI assistant to request leave, generate HR documents, and check their own status — in Arabic or English — without filing a ticket or waiting on HR.

This is one of four repositories that make up the Wakeel AI system:

| Repo | Role |
| --- | --- |
| **WakeelAI-Mobile** *(this repo)* | Employee-facing Flutter app |
| [WakeelAI-Frontend](https://github.com/WakeelAI-Project/WakeelAI-Frontend) | HR/admin web dashboard |
| [WakeelAI-Backend](https://github.com/WakeelAI-Project/WakeelAI-Backend) | ASP.NET Core API — auth, leave, employees, documents |
| [WakeelAI-AI](https://github.com/WakeelAI-Project/WakeelAI-AI) | Node.js AI orchestrator — chat, RAG over labor law/company policy, leave/document tool-calling |

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Testing](#testing)
- [Localization](#localization)
- [Project Structure](#project-structure)
- [CI/CD & Distribution](#cicd--distribution)
- [Contributing](#contributing)
- [Team](#team)

## Features

- **AI chat assistant** — a conversational interface that can draft and submit leave requests, generate HR documents, and answer labor-law/company-policy questions, backed by the [AI orchestrator](https://github.com/WakeelAI-Project/WakeelAI-AI)'s RAG pipeline.
- **Leave management** — request annual/sick/unpaid leave (with medical-report attachments where required), track request status, and see live leave balances.
- **Home dashboard** — at-a-glance leave balances and current-leave progress, computed in the employee's own local time zone (device time zone is synced to the backend on login).
- **Documents** — view and download HR-generated documents (contracts, certificates, etc.) as PDFs.
- **Profile** — view employee details, upload/crop a profile photo.
- **Auth** — JWT login with automatic refresh-token rotation, forced password change on first login, forgot-password via OTP.
- **Full Arabic/English localization** — every user-facing string, date, and number is locale-aware; layouts mirror correctly under RTL.
- **Light/dark theme, high-contrast mode.**

## Tech Stack

- **[Flutter](https://flutter.dev)** (Dart SDK `^3.12.2`) — targets Android
- **[Riverpod](https://riverpod.dev)** — state management (`flutter_riverpod`)
- **[go_router](https://pub.dev/packages/go_router)** — declarative routing
- **[Dio](https://pub.dev/packages/dio)** — HTTP client, with an interceptor handling JWT attachment and refresh-token rotation
- **`flutter_secure_storage`** — encrypted token storage
- **`intl` + `flutter_localizations`** — Arabic/English i18n, locale-aware date formatting
- **`pdfx`**, **`share_plus`**, **`flutter_file_downloader`** — in-app PDF preview, sharing, and downloads
- **`image_picker` + `image_cropper`** — profile photo capture/crop
- **`flutter_timezone`** — reports the device's IANA time zone to the backend

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `3.44.4` (matches the version pinned in CI — see [`ci.yml`](.github/workflows/ci.yml))
- Android Studio or another Android SDK/toolchain, plus a connected device or emulator
- A running instance of [WakeelAI-Backend](https://github.com/WakeelAI-Project/WakeelAI-Backend) (or use the hosted default — see [Configuration](#configuration))

### Installation

```bash
git clone https://github.com/WakeelAI-Project/WakeelAI-Mobile.git
cd WakeelAI-Mobile
flutter pub get
flutter run
```

## Configuration

The backend API base URL defaults to the hosted deployment and can be overridden at build/run time without touching any source file:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

(`10.0.2.2` is how the Android emulator reaches `localhost` on the host machine; use your machine's LAN IP for a physical device.) See [`lib/app.dart`](lib/app.dart) for the default value.

## Testing

```bash
flutter analyze
flutter test
```

Both commands run in CI on every pull request and on every push to `main` (see [`ci.yml`](.github/workflows/ci.yml)). The test suite covers unit tests (network interceptors, services) and widget tests (screens and chat flows) under [`test/`](test).

## Localization

Arabic and English strings live in [`lib/l10n/app_en.arb`](lib/l10n/app_en.arb) and [`lib/l10n/app_ar.arb`](lib/l10n/app_ar.arb). After editing an `.arb` file, regenerate the localization classes with:

```bash
flutter gen-l10n
```

All dates and numbers are formatted through [`lib/core/utils/app_date_format.dart`](lib/core/utils/app_date_format.dart) rather than hardcoded patterns, so they stay consistent and locale-correct across the app; anything sent to the backend is reformatted to the API's expected format first.

## Project Structure

The app follows a feature-first structure: each feature owns its own `data` / `domain` / `application` / `presentation` layers.

```
lib/
├── core/            # Cross-cutting: theme, network client, storage, routing, shared widgets
├── features/
│   ├── auth/        # Login, forgot/reset password, OTP verification
│   ├── home/         # Employee dashboard, leave balances, current-leave progress
│   ├── chat/          # AI assistant chat UI and conversation state
│   ├── leaves/        # Leave request creation, listing, status
│   ├── documents/    # Generated document listing, preview, download
│   ├── profile/       # Employee profile, photo upload/crop
│   ├── settings/      # Theme, locale, high-contrast toggles
│   └── shell/         # Bottom navigation / app shell
├── l10n/             # Arabic/English .arb files + generated localizations
└── main.dart
```

## CI/CD & Distribution

- **[`ci.yml`](.github/workflows/ci.yml)** — runs `flutter analyze` and `flutter test` on every PR and every push to `main`.
- **[`release.yml`](.github/workflows/release.yml)** — on every push to `main` (or manually via `workflow_dispatch`), builds and signs a release APK, then publishes it two ways:
  - **Firebase App Distribution**, to an invite-only tester group.
  - A **public GitHub Release** under a fixed `latest` tag, so this link always serves the newest build — no Google account, tester invite, or Play Store needed:
    ```
    https://github.com/WakeelAI-Project/WakeelAI-Mobile/releases/latest/download/WakeelAI.apk
    ```

## Contributing

Branch off `develop` (not `main`) and name branches by what they do: `feature/<name>` for new functionality, `fix/<name>` for bug fixes, `docs/<name>` for documentation, `chore/<name>` for maintenance. Open a PR into `develop`; `main` is only updated by merging a ready `develop` for release.

## Team

Built by the Wakeel AI graduation team as an ITI AI Capstone project:

- [Assem Mohamed](https://github.com/Assem-Mohamed)
- [Eyad Hany](https://github.com/EyadHanyMatador)