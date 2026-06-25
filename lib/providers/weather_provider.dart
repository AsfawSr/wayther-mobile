import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../models/checkpoint.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherSnapshot? currentWeather;
  WeatherSnapshot? futureWeather;
  List<WeatherSnapshot> batchWeather = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchCurrentWeather(double latitude, double longitude) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      currentWeather = await WeatherService.getCurrentWeather(latitude, longitude);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFutureWeather(
    double latitude,
    double longitude,
    DateTime targetIso,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      futureWeather = await WeatherService.getFutureWeather(
        latitude,
        longitude,
        targetIso,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBatchWeather(List<FutureWeatherCheckpoint> checkpoints) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      batchWeather = await WeatherService.getFutureBatch(checkpoints);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}

