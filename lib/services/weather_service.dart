import '../models/weather.dart';
import '../models/checkpoint.dart';
import 'api_service.dart';

class WeatherService {
  static Future<WeatherSnapshot> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    final response = await ApiService.get(
      '/api/weather/current',
      queryParams: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );
    return WeatherSnapshot.fromJson(response);
  }

  static Future<WeatherSnapshot> getFutureWeather(
    double latitude,
    double longitude,
    DateTime targetIso,
  ) async {
    final response = await ApiService.get(
      '/api/weather/future',
      queryParams: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'targetIso': targetIso.toIso8601String(),
      },
    );
    return WeatherSnapshot.fromJson(response);
  }

  static Future<List<WeatherSnapshot>> getFutureBatch(
    List<FutureWeatherCheckpoint> checkpoints,
  ) async {
    final body = checkpoints.map((c) => c.toJson()).toList();
    final response = await ApiService.post(
      '/api/weather/future/batch',
      body: body,
    );
    return response.map((item) => WeatherSnapshot.fromJson(item as Map<String, dynamic>)).toList();
  }
}
