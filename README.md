# Solehead

Discover, rate, and track the latest sneaker drops from a curated catalog backed by Firebase Auth and a custom Render-hosted API. Solehead ships with a Pinterest-style explore surface, detailed sneaker pages, and social-ready user profiles.

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Core-FFCA28?logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/iOS%20%7C%20Android%20%7C%20Web-multi-blue)

## Table of Contents
- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Running & Testing](#running--testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Features
- **Explore feed**: Infinite, Pinterest-style grid backed by deterministic shuffling so sneakers keep their order until a refresh.
- **Featured carousel**: Auto-scrolling hero section that surfaces the hottest drops with metadata highlights.
- **Search & filters**: Debounced search powered by the backend plus brand filters and pull-to-refresh.
- **Sneaker detail pages**: Ratings, price info, metadata rows, and external links sourced directly from backend spreadsheets.
- **User auth & profiles**: Firebase Authentication, profile photos, follower/following lists, and post tracking.
- **Media handling**: Cached network images, Lottie animations, and graceful fallbacks for brand tiles.
- **Multi-platform**: Android, iOS, macOS, Windows, Linux, and Web targets are scaffolded out of the box.

## Architecture
| Layer | Tech | Notes |
| --- | --- | --- |
| UI | Flutter (Material 3) | Responsive layouts, custom widgets, Lottie animations |
| State | `provider` | SneakerProvider centralizes catalog, search, and featured data |
| Networking | `http` + `dio` | REST integration via `ApiService`, automatic auth headers |
| Backend | Render-hosted Node/Express | Base URL configured in `lib/utils/constants.dart` |
| Auth | Firebase Auth | Token injection handled in `ApiService` |
| Storage | Firebase + REST | Sneaker catalog served from Render API; user-generated posts stored via backend |

## Getting Started
1. **Prerequisites**
	- Flutter SDK 3.24+ and Dart 3.9+
	- Firebase project with iOS/Android/Web apps configured
	- Render (or compatible) backend deployed at `https://soulheads-backend.onrender.com/api`

2. **Clone & install**
	```bash
	git clone https://github.com/chetan2921/solehead.git
	cd solehead
	flutter pub get
	```

3. **Configure Firebase**
	- Update `lib/firebase_options.dart` with your project config (or run `flutterfire configure`).
	- Place updated `GoogleService-Info.plist`, `google-services.json`, and `firebase_app_id_file.json` in the respective platform folders (`ios/Runner`, `android/app`, etc.).

4. **Set backend endpoints**
	- Check `lib/utils/constants.dart` and confirm `ApiConstants.baseUrl` targets your backend.
	- Optional: toggle `isDevelopmentMode` or add alternate URLs if you run local tunnels.

5. **Run the app**
	```bash
	flutter run
	```
	Use `-d chrome`, `-d macos`, etc., for other targets.

## Project Structure
```
lib/
  main.dart                # Entry point, theme wiring
  firebase_options.dart    # Generated Firebase config
  models/                  # Sneaker, user, and provider models
  providers/               # Provider classes (SneakerProvider, AuthProvider, ...)
  screens/                 # UI screens (Explore, Auth, Profiles, Sneaker detail)
  services/                # API, Firebase, sneaker service abstractions
  utils/                   # Constants, theme helpers
  widgets/                 # Reusable UI components
assets/
  animations/              # Lottie animations used across onboarding & loaders
  images/                  # Brand logos, fallback art
```

## Running & Testing
- **Analyze**: `flutter analyze`
- **Tests**: `flutter test` (unit tests live in `test/`)
- **Format**: `dart format .`
- **Hot reload**: `flutter run` and press `r` / `R` in the terminal.

## Troubleshooting
- **Blank images on Explore**: Ensure the backend returns catalog sneakers with `photoUrl`/metadata; user-posted entries without images are filtered out by `SneakerProvider`.
- **Auth errors**: Re-run `flutterfire configure` or confirm Firebase app IDs match each platform.
- **Render API unavailable**: Update `ApiConstants.baseUrl` to point to your staging/local tunnel and restart the app.
- **Dependency mismatch**: Run `flutter clean && flutter pub get` after major Flutter upgrades.

## Contributing
1. Fork the repo and create a feature branch.
2. Keep changes formatted (`dart format`) and linted (`flutter analyze`).
3. Add or update tests when you change business logic.
4. Open a PR describing the change, screenshots/video for UI tweaks, and backend requirements if any.

Happy building! 👟
