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

  OsrmRouteResponse({
    required this.code,
    required this.routes,
    required this.waypoints,
  });

  factory OsrmRouteResponse.fromJson(Map<String, dynamic> json) {
    return OsrmRouteResponse(
      code: json['code'] as String,
      routes: json['routes'] as List<dynamic>,
      waypoints: json['waypoints'] as List<dynamic>,
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
