class FutureWeatherCheckpoint {
  final double latitude;
  final double longitude;
  final DateTime targetIso;

  FutureWeatherCheckpoint({
    required this.latitude,
    required this.longitude,
    required this.targetIso,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'targetIso': targetIso.toIso8601String(),
    };
  }
}

