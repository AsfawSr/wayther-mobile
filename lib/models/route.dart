import 'package:latlong2/latlong.dart';

class RouteStep {
  final double latitude;
  final double longitude;
  final int distanceMeters;
  final int durationSeconds;

  RouteStep({
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class OsrmRouteResponse {
  final String code;
  final List<dynamic> routes;
  final List<dynamic> waypoints;
  final List<LatLng> routePoints;

  OsrmRouteResponse({
    required this.code,
    required this.routes,
    required this.waypoints,
    required this.routePoints,
  });

  factory OsrmRouteResponse.fromJson(Map<String, dynamic> json) {
    List<LatLng> points = [];
    if (json['routes'] != null && json['routes'].isNotEmpty) {
      // Try to extract geometry from the first route
      var route = json['routes'][0];
      if (route.containsKey('geometry')) {
        var geometry = route['geometry'];
        // Handle different geometry formats
        if (geometry is String) {
          // Polyline encoded string - we would need to decode it
          // For now, we'll leave it empty and rely on waypoints or steps
          // TODO: Add polyline decoding if needed
        } else if (geometry is Map<String, dynamic> && geometry.containsKey('coordinates')) {
          // GeoJSON LineString format: { "type": "LineString", "coordinates": [[lon1, lat1], [lon2, lat2], ...] }
          var coords = geometry['coordinates'] as List<dynamic>;
          for (var coord in coords) {
            if (coord is List<dynamic> && coord.length >= 2) {
              // Assuming [lon, lat] format
              points.add(LatLng(coord[1] as double, coord[0] as double));
            }
          }
        }
      }

      // If we didn't get points from geometry, try to get from legs/steps
      if (points.isEmpty && route.containsKey('legs')) {
        var legs = route['legs'] as List<dynamic>;
        for (var leg in legs) {
          if (leg.containsKey('steps')) {
            var steps = leg['steps'] as List<dynamic>;
            for (var step in steps) {
              if (step.containsKey('maneuver') &&
                  step['maneuver'].containsKey('location') &&
                  step['maneuver']['location'] is List<dynamic>) {
                var loc = step['maneuver']['location'] as List<dynamic>;
                if (loc.length >= 2) {
                  // OSRM maneuver location is [lon, lat]
                  points.add(LatLng(loc[1] as double, loc[0] as double));
                }
              }
            }
          }
        }
      }
    }

    return OsrmRouteResponse(
      code: json['code'] as String,
      routes: json['routes'] as List<dynamic>,
      waypoints: json['waypoints'] as List<dynamic>,
      routePoints: points,
    );
  }

  bool get isSuccess => code == 'Ok';

  double get totalDistance {
    if (routes.isEmpty) return 0;
    return (routes[0]['distance'] as num).toDouble();
  }

  int get totalDuration {
    if (routes.isEmpty) return 0;
    return (routes[0]['duration'] as num).toInt();
  }

  String get formattedDistance {
    final km = totalDistance / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    final minutes = totalDuration ~/ 60;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}