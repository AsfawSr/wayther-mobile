import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  Position? currentPosition;
  bool isLoading = false;
  String? error;

  Future<void> fetchCurrentLocation() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      currentPosition = await LocationService.getCurrentLocation();
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

  double? get latitude => currentPosition?.latitude;
  double? get longitude => currentPosition?.longitude;

  bool get hasLocation => currentPosition != null;
}
