class WeatherSnapshot {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String condition;
  final double temperature;
  final double windSpeed;
  final double precipitationProbability;
  final String weatherIcon;

  WeatherSnapshot({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.condition,
    required this.temperature,
    required this.windSpeed,
    required this.precipitationProbability,
    required this.weatherIcon,
  });

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      condition: json['condition'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      precipitationProbability: (json['precipitationProbability'] as num).toDouble(),
      weatherIcon: json['weatherIcon'] as String,
    );
  }

  bool hasWeatherWarning() {
    return precipitationProbability >= 40;
  }

  String getWarningMessage() {
    if (condition.toLowerCase().contains('rain')) {
      return 'Rain warning: ${precipitationProbability.toInt()}% risk';
    } else if (condition.toLowerCase().contains('snow')) {
      return 'Snow warning: ${precipitationProbability.toInt()}% risk';
    } else if (condition.toLowerCase().contains('fog')) {
      return 'Fog warning: Low visibility';
    }
    return '';
  }
}

