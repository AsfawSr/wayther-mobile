import 'package:flutter/material.dart';
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
  State<RoutePlannerScreenState> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final _originLatController = TextEditingController();
  final _originLonController = TextEditingController();
  final _destLatController = TextEditingController();
  final _destLonController = TextEditingController();

  // For map interaction
  LatLng? _originPoint;
  LatLng? _destPoint;
  bool _isSettingOrigin = true; // true = setting origin, false = setting destination

  @override
  void initState() {
    super.initState();
    _prefillCurrentLocation();
    _setupControllers();
  }

  void _prefillCurrentLocation() {
    final locationProvider = context.read<LocationProvider>();
    if (locationProvider.hasLocation) {
      final lat = locationProvider.latitude!.toStringAsFixed(4);
      final lon = locationProvider.longitude!.toStringAsFixed(4);
      _originLatController.text = lat;
      _originLonController.text = lon;
      _originPoint = LatLng(locationProvider.latitude!, locationProvider.longitude!);
    }
  }

  void _setupControllers() {
    _originLatController.addListener(_updateOriginFromFields);
    _originLonController.addListener(_updateOriginFromFields);
    _destLatController.addListener(_updateDestinationFromFields);
    _destLonController.addListener(_updateDestinationFromFields);
  }

  void _updateOriginFromFields() {
    final lat = double.tryParse(_originLatController.text);
    final lon = double.tryParse(_originLonController.text);
    if (lat != null && lon != null) {
      setState(() {
        _originPoint = LatLng(lat, lon);
      });
    }
  }

  void _updateDestinationFromFields() {
    final lat = double.tryParse(_destLatController.text);
    final lon = double.tryParse(_destLonController.text);
    if (lat != null && lon != null) {
      setState(() {
        _destPoint = LatLng(lat, lon);
      });
    }
  }

  void _onMapTapped(LatLng point) {
    setState(() {
      if (_isSettingOrigin) {
        _originPoint = point;
        _originLatController.text = point.latitude.toStringAsFixed(4);
        _originLonController.text = point.longitude.toStringAsFixed(4);
      } else {
        _destPoint = point;
        _destLatController.text = point.latitude.toStringAsFixed(4);
        _destLonController.text = point.longitude.toStringAsFixed(4);
      }
    });
  }

  void _planRoute() {
    final originLat = double.tryParse(_originLatController.text);
    final originLon = double.tryParse(_originLonController.text);
    final destLat = double.tryParse(_destLatController.text);
    final destLon = double.tryParse(_destLonController.text);

    if (originLat == null ||
        originLon == null ||
        destLat == null ||
        destLon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid coordinates')),
      );
      return;
    }

    final routeProvider = context.read<RouteProvider>();
    routeProvider.fetchRoute(
      originLat: originLat,
      originLon: originLon,
      destLat: destLat,
      destLon: destLon,
    );
  }

  void _fetchWeatherAlongRoute(OsrmRouteResponse route) {
    final weatherProvider = context.read<WeatherProvider>();

    // Create checkpoints at 15, 30, 60 minutes along route
    List<FutureWeatherCheckpoint> checkpoints = [
      FutureWeatherCheckpoint(
        latitude: double.parse(_originLatController.text),
        longitude: double.parse(_originLonController.text),
        targetIso: DateTime.now().add(const Duration(minutes: 15)),
      ),
      FutureWeatherCheckpoint(
        latitude: double.parse(_destLatController.text),
        longitude: double.parse(_destLonController.text),
        targetIso: DateTime.now().add(const Duration(minutes: 30)),
      ),
    ];

    weatherProvider.fetchBatchWeather(checkpoints);
  }

  @override
  void dispose() {
    _originLatController.removeListener(_updateOriginFromFields);
    _originLonController.removeListener(_updateOriginFromFields);
    _destLatController.removeListener(_updateDestinationFromFields);
    _destLonController.removeListener(_updateDestinationFromFields);
    _originLatController.dispose();
    _originLonController.dispose();
    _destLatController.dispose();
    _destLonController.dispose();
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
            Text(
              'Origin',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _originLatController,
              decoration: InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: '9.03',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _originLonController,
              decoration: InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: '38.74',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Text(
              'Destination',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destLatController,
              decoration: InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: '9.08',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destLonController,
              decoration: InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: '38.79',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isSettingOrigin = true;
                    });
                  },
                  icon: const Icon(Icons.edit_location),
                  label: const Text('Set Origin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSettingOrigin ? Colors.blue[700] : Colors.blue[200],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isSettingOrigin = false;
                    });
                  },
                  icon: const Icon(Icons.edit_location),
                  label: const Text('Set Destination'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isSettingOrigin ? Colors.blue[700] : Colors.blue[200],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            MapWidget(
              initialLat: _originPoint?.latitude ?? 9.03,
              initialLon: _originPoint?.longitude ?? 38.74,
              route: _getRoutePoints(),
              origin: _originPoint,
              destination: _destPoint,
              onTap: _onMapTapped,
              label: 'Select Origin and Destination',
            ),
            const SizedBox(height: 16),
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