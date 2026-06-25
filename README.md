
# Wayther 🌤️

> **Know Before You Go** — Weather-aware route planning for Android

Wayther is a Flutter mobile app that combines real-time weather data with interactive route planning, so you always know what weather to expect along your journey.

---

## Features

| Feature | Description |
|---------|-------------|
| 📍 **Auto Location** | Detects GPS position on launch; weather loads automatically |
| 🌡️ **Live Weather** | Current temperature, condition, wind speed, precipitation % |
| ⚠️ **Smart Warnings** | Animated banners with Low / Caution / High-Risk severity |
| 🗺️ **Route Planning** | Map-based origin & destination picker (tap map or search by name) |
| 🌦️ **Route Weather** | Up to 5 weather checkpoints distributed along the route |
| 📊 **Weather Timeline** | Horizontal scrollable timeline showing conditions at each checkpoint |
| 🌙 **Dark Mode** | Follows the OS dark/light preference automatically |
| 🔄 **Pull-to-Refresh** | Re-fetches location + weather from the home screen |

---

## Architecture

```
lib/
├── config/
│   └── app_config.dart        # Backend URL, timeouts, constants
├── models/
│   ├── checkpoint.dart        # FutureWeatherCheckpoint
│   ├── route.dart             # OsrmRouteResponse + getIntermediatePoints()
│   └── weather.dart           # WeatherSnapshot
├── providers/
│   ├── location_provider.dart # GPS position state
│   ├── route_provider.dart    # Route fetching state
│   └── weather_provider.dart  # Weather state (current + batch)
├── screens/
│   ├── splash_screen.dart     # Animated launch screen
│   ├── home_screen.dart       # Current weather dashboard
│   └── route_planner_screen.dart  # Full-screen map + route + weather
├── services/
│   ├── api_service.dart       # HTTP client (GET + POST)
│   ├── location_service.dart  # Geolocator wrapper
│   ├── route_service.dart     # OSRM route endpoint
│   └── weather_service.dart   # Weather API endpoints
├── theme/
│   ├── app_colors.dart        # Central color palette
│   └── app_theme.dart         # Light & dark ThemeData
├── utils/
│   └── error_handler.dart     # User-friendly error messages + snack bars
└── widgets/
    ├── map_widget.dart         # flutter_map wrapper with markers + polyline
    ├── route_info_card.dart    # Distance / Duration / ETA card
    ├── search_field.dart       # Debounced animated search field
    ├── shimmer_loader.dart     # Skeleton loading placeholders
    ├── warning_banner.dart     # Animated severity-based warning
    ├── weather_card.dart       # Gradient weather card (full + compact)
    └── weather_timeline.dart   # Horizontal route checkpoint timeline
```

**State management:** Provider  
**Map:** flutter_map + OpenStreetMap tiles  
**Geocoding:** geocoding package (Google Maps Platform)  
**Fonts:** Outfit (headings) + Inter (body) via google_fonts

---

## Setup

### Prerequisites

- Flutter **3.x** or later (`flutter --version` to check)
- A running instance of the **Wayther backend** (see backend repo)
- Android SDK / connected Android device or emulator

### 1 — Clone & install dependencies

```bash
git clone <repo-url>
cd wayther
flutter pub get
```

### 2 — Configure the backend URL

By default the app connects to `http://10.0.2.2:8080` (Android emulator localhost).

To point to a real server, pass the URL at build time:

```bash
flutter run --dart-define=BACKEND_URL=https://your-server.com
```

Or edit [`lib/config/app_config.dart`](lib/config/app_config.dart) directly.

### 3 — Run on Android

```bash
# With an emulator or USB-connected device:
flutter run

# Release APK:
flutter build apk --release
```

### 4 — Location permission (Android)

The `AndroidManifest.xml` already includes `ACCESS_FINE_LOCATION`. On first launch the app will request permission at runtime.

---

## Backend API Contract

The app expects the following endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/weather/current?latitude=&longitude=` | Current weather snapshot |
| `GET` | `/api/weather/future?latitude=&longitude=&targetIso=` | Future weather at a time |
| `POST` | `/api/weather/future/batch` | Batch future weather for a list of checkpoints |
| `GET` | `/api/route?...` (proxied OSRM) | Driving route between two points |

---

## Commit History (improvement sprint)

| # | Commit | Description |
|---|--------|-------------|
| 1 | `feat: app-wide design system & theme` | AppColors, AppTheme (light/dark), google_fonts |
| 2 | `feat: splash screen` | Animated branded splash with auto location+weather load |
| 3 | `fix: auto-fetch weather on location load` | Weather fetched immediately after GPS resolves |
| 4 | `feat: redesigned Home Screen` | Hero card, shimmer loader, pull-to-refresh, CTA |
| 5 | `feat: redesigned Weather Card` | Gradient bg, animated temperature, compact mode |
| 6 | `feat: redesigned Warning Banner` | Severity levels, slide-in animation, dismissible |
| 7 | `feat: Route Planner layout & map overhaul` | Full-screen map, Stack layout, locate-me button |
| 8 | `feat: search bar with address display` | Human-readable addresses, two search fields |
| 9 | `feat: smarter route weather checkpoints` | 5 evenly-spaced checkpoints with time offsets |
| 10 | `feat: route results bottom sheet & weather timeline` | DraggableScrollableSheet, WeatherTimeline |
| 11 | `fix: error handling & connectivity feedback` | ErrorHandler util, graceful degradation |
| 12 | `feat: app config & environment setup` | AppConfig, configurable backend URL |
| 13 | `chore: code cleanup & lint fixes` | Zero warnings, const constructors, unused imports |
| 14 | `docs: update README` | This file |

---

## License

Private — All rights reserved.
