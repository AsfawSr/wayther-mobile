import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/warning_banner.dart';
import 'route_planner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentLocation();
    });
  }

  void _loadCurrentLocation() {
    final locationProvider = context.read<LocationProvider>();
    locationProvider.fetchCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wayther - Weather Pathfinder'),
        elevation: 0,
        backgroundColor: Colors.blue[700],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, _) {
          if (locationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (locationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Location Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      locationProvider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadCurrentLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoutePlannerScreen(),
                        ),
                      );
                    },
                    child: const Text('Plan Route Manually'),
                  ),
                ],
              ),
            );
          }

          if (!locationProvider.hasLocation) {
            return const Center(
              child: Text('No location available'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Column(
                    children: [
                      Text(
                        'Current Location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lat: ${locationProvider.latitude?.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Lon: ${locationProvider.longitude?.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Consumer<WeatherProvider>(
                  builder: (context, weatherProvider, _) {
                    if (weatherProvider.currentWeather != null) {
                      return Column(
                        children: [
                          WarningBanner(
                            weather: weatherProvider.currentWeather!,
                          ),
                          WeatherCard(
                            weather: weatherProvider.currentWeather!,
                          ),
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Weather data not available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoutePlannerScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.route),
                    label: const Text('Plan Route'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
