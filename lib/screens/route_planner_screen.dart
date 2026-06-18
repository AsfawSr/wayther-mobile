import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';
import '../providers/weather_provider.dart';
import '../models/checkpoint.dart';
import '../widgets/warning_banner.dart';
import '../widgets/weather_card.dart';
import '../widgets/route_info_card.dart';
import '../widgets/map_widget.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({Key? key}) : super(key: key);

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final _originLatController = TextEditingController();
  final _originLonController = TextEditingController();
  final _destLatController = TextEditingController();
  final _destLonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillCurrentLocation();
  }

  void _prefillCurrentLocation() {
    final locationProvider = context.read<LocationProvider>();
    if (locationProvider.hasLocation) {
      _originLatController.text = locationProvider.latitude!.toStringAsFixed(4);
      _originLonController.text = locationProvider.longitude!.toStringAsFixed(4);
    }
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

  @override
  void dispose() {
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
            const SizedBox(height: 24),
            MapWidget(
              initialLat: double.tryParse(_originLatController.text) ?? 9.03,
              initialLon: double.tryParse(_originLonController.text) ?? 38.74,
              label: 'Select Origin Location',
              onLocationTapped: (lat, lon) {
                setState(() {
                  _originLatController.text = lat.toStringAsFixed(4);
                  _originLonController.text = lon.toStringAsFixed(4);
                });
              },
            ),
            const SizedBox(height: 24),
            MapWidget(
              initialLat: double.tryParse(_destLatController.text) ?? 9.08,
              initialLon: double.tryParse(_destLonController.text) ?? 38.79,
              label: 'Select Destination Location',
              onLocationTapped: (lat, lon) {
                setState(() {
                  _destLatController.text = lat.toStringAsFixed(4);
                  _destLonController.text = lon.toStringAsFixed(4);
                });
              },
            ),
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
                if (routeProvider.route != null) {
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

  void _fetchWeatherAlongRoute(dynamic route) {
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
}
