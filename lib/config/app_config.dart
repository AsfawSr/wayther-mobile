import 'package:flutter/foundation.dart';

/// Application-wide configuration constants.
abstract final class AppConfig {
  /// Base URL for the Wayther backend API.
  ///
  /// Override at build time with:
  ///   flutter run --dart-define=BACKEND_URL=https://your-server.com
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: kDebugMode ? 'http://10.0.2.2:8080' : 'http://10.0.2.2:8080',
  );

  /// How long to wait for API responses before timing out.
  static const Duration apiTimeout = Duration(seconds: 15);

  /// Number of intermediate weather checkpoints to generate along a route.
  static const int routeCheckpointCount = 5;

  /// Minimum distance filter for location updates (meters).
  static const int locationDistanceFilter = 10;
}

