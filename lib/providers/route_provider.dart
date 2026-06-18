import 'package:flutter/material.dart';
import '../models/route.dart';
import '../services/route_service.dart';

class RouteProvider extends ChangeNotifier {
  OsrmRouteResponse? route;
  bool isLoading = false;
  String? error;

  Future<void> fetchRoute({
    required double originLat,
    required double originLon,
    required double destLat,
    required double destLon,
    String profile = 'driving',
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      route = await RouteService.getRoute(
        originLat: originLat,
        originLon: originLon,
        destLat: destLat,
        destLon: destLon,
        profile: profile,
      );

      if (!route!.isSuccess) {
        error = 'Route not found';
      }
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

  void reset() {
    route = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}
