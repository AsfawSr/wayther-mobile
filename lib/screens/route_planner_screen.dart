import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';
import '../providers/weather_provider.dart';
import '../models/checkpoint.dart';
import '../models/route.dart';
import '../widgets/warning_banner.dart';
import '../widgets/weather_card.dart';
import '../widgets/route_info_card.dart';
import '../widgets/map_widget.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  // For map interaction - stores the currently selected location from map tap
  LatLng? _selectedLocation;

  // Origin and destination points
  LatLng? _originPoint;
  LatLng? _destPoint;

  // Controller for search field
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillCurrentLocation();
    _setupSearchController();
  }

  void _prefillCurrentLocation() {
    final locationProvider = context.read<LocationProvider>();
    if (locationProvider.hasLocation) {
      _selectedLocation = LatLng(locationProvider.latitude!, locationProvider.longitude!);
    }
  }

  void _setupSearchController() {
    _searchController.addListener(() {
      // We don't need to store the query separately since we use the controller directly
    });
  }

  void _onSearchSubmitted(String value) {
    // For now, just show a snackbar - in a real app this would trigger geocoding
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Search for "$value" - functionality coming soon')),
    );
    // Clear the search field after submitting
    _searchController.clear();
  }

  void _onMapTapped(LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
  }

  void _setAsOrigin() {
    if (_selectedLocation != null) {
      setState(() {
        _originPoint = _selectedLocation;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap on the map to select a location first')),
      );
    }
  }

  void _setAsDestination() {
    if (_selectedLocation != null) {
      setState(() {
        _destPoint = _selectedLocation;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap on the map to select a location first')),
      );
    }
  }

  void _planRoute() {
    if (_originPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set an origin location')),
      );
      return;
    }

    if (_destPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a destination location')),
      );
      return;
    }

    final routeProvider = context.read<RouteProvider>();
    routeProvider.fetchRoute(
      originLat: _originPoint!.latitude,
      originLon: _originPoint!.longitude,
      destLat: _destPoint!.latitude,
      destLon: _destPoint!.longitude,
    );
  }

  void _fetchWeatherAlongRoute(OsrmRouteResponse route) {
    final weatherProvider = context.read<WeatherProvider>();

    // Create checkpoints at 15, 30, 60 minutes along route
    List<FutureWeatherCheckpoint> checkpoints = [
      FutureWeatherCheckpoint(
        latitude: _originPoint!.latitude,
        longitude: _originPoint!.longitude,
        targetIso: DateTime.now().add(const Duration(minutes: 15)),
      ),
      FutureWeatherCheckpoint(
        latitude: _destPoint!.latitude,
        longitude: _destPoint!.longitude,
        targetIso: DateTime.now().add(const Duration(minutes: 30)),
      ),
    ];

    weatherProvider.fetchBatchWeather(checkpoints);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Route'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location (e.g., "New York", "Eiffel Tower")',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onSubmitted: _onSearchSubmitted,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),

            // Map Widget
            MapWidget(
              initialLat: _selectedLocation?.latitude ?? 9.03,
              initialLon: _selectedLocation?.longitude ?? 38.74,
              route: _getRoutePoints(),
              origin: _originPoint,
              destination: _destPoint,
              onTap: _onMapTapped,
              label: 'Tap on map to select a location',
            ),
            const SizedBox(height: 12),

            // Selected location info
            if (_selectedLocation != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Selected Location: Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                  style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                ),
              ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _setAsOrigin,
                  icon: const Icon(Icons.edit_location),
                  label: const Text('Set as Origin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _originPoint == null ? Colors.blue[700] : Colors.green[700],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _setAsDestination,
                  icon: const Icon(Icons.edit_location),
                  label: const Text('Set as Destination'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _destPoint == null ? Colors.blue[700] : Colors.green[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Origin/Destination Info
            if (_originPoint != null || _destPoint != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_originPoint != null)
                    Text(
                      'Origin: Lat: ${_originPoint!.latitude.toStringAsFixed(4)}, Lon: ${_originPoint!.longitude.toStringAsFixed(4)}',
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                  if (_destPoint != null)
                    Text(
                      'Destination: Lat: ${_destPoint!.latitude.toStringAsFixed(4)}, Lon: ${_destPoint!.longitude.toStringAsFixed(4)}',
                      style: TextStyle(fontSize: 12, color: Colors.red[700]),
                    ),
                ],
              ),

            const SizedBox(height: 16),

            // Error Message
            Consumer<RouteProvider>(
              builder: (context, routeProvider, _) {
                if (routeProvider.error != null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error: ${routeProvider.error}',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 16),

            // Plan Route Button
            SizedBox(
              width: double.infinity,
              child: Consumer<RouteProvider>(
                builder: (context, routeProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: routeProvider.isLoading ? null : _planRoute,
                    icon: routeProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.navigation),
                    label: Text(
                      routeProvider.isLoading ? 'Planning...' : 'Plan Route',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue[700],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Route Information
            Consumer<RouteProvider>(
              builder: (context, routeProvider, _) {
                if (routeProvider.route != null && routeProvider.route!.isSuccess) {
                  return Column(
                    children: [
                      RouteInfoCard(route: routeProvider.route!),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _fetchWeatherAlongRoute(routeProvider.route!);
                        },
                        icon: const Icon(Icons.cloud),
                        label: const Text('Check Weather on Route'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: Colors.amber[700],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 16),

            // Weather Along Route
            Consumer<WeatherProvider>(
              builder: (context, weatherProvider, _) {
                if (weatherProvider.batchWeather.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather Along Route',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...weatherProvider.batchWeather.map((weather) {
                        return Column(
                          children: [
                            WarningBanner(weather: weather),
                            WeatherCard(weather: weather),
                          ],
                        );
                      }),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  List<LatLng>? _getRoutePoints() {
    final routeProvider = context.read<RouteProvider>();
    if (routeProvider.route != null && routeProvider.route!.isSuccess) {
      return routeProvider.route!.routePoints;
    }
    return null;
  }
}