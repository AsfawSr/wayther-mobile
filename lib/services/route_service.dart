import '../models/route.dart';
import 'api_service.dart';

class RouteService {
  static Future<OsrmRouteResponse> getRoute({
    required double originLat,
    required double originLon,
    required double destLat,
    required double destLon,
    String profile = 'driving',
  }) async {
    final response = await ApiService.get(
      '/api/route',
      queryParams: {
        'profile': profile,
        'originLat': originLat.toString(),
        'originLon': originLon.toString(),
        'destLat': destLat.toString(),
        'destLon': destLon.toString(),
      },
    );
    return OsrmRouteResponse.fromJson(response);
  }
}
