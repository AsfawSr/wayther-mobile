import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/warning_banner.dart';
import '../widgets/shimmer_loader.dart';
import '../theme/app_colors.dart';
import 'route_planner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refresh() async {
    final locationProvider = context.read<LocationProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    await locationProvider.fetchCurrentLocation();
    if (locationProvider.hasLocation) {
      await weatherProvider.fetchCurrentWeather(
        locationProvider.latitude!,
        locationProvider.longitude!,
      );
    }
  }

  void _goToRoutePlanner() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (ctx, animation, oldWidget) => const RoutePlannerScreen(),
        transitionsBuilder: (ctx, animation, oldWidget, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: Consumer2<LocationProvider, WeatherProvider>(
          builder: (context, locationProvider, weatherProvider, _) {
            // ── Loading ──────────────────────────────────────────────────
            if (locationProvider.isLoading || weatherProvider.isLoading) {
              return const CustomScrollView(
                slivers: [
                  _WaytherAppBar(cityName: 'Loading…'),
                  SliverFillRemaining(child: HomeScreenSkeleton()),
                ],
              );
            }

            // ── Location Error ────────────────────────────────────────────
            if (locationProvider.error != null) {
              return CustomScrollView(
                slivers: [
                  const _WaytherAppBar(cityName: 'Wayther'),
                  SliverFillRemaining(
                    child: _ErrorState(
                      icon: Icons.location_off_rounded,
                      title: 'Location Unavailable',
                      subtitle: locationProvider.error!,
                      onRetry: _refresh,
                      secondaryAction: TextButton(
                        onPressed: _goToRoutePlanner,
                        child: const Text('Plan Route Manually'),
                      ),
                    ),
                  ),
                ],
              );
            }

            // ── No location yet ───────────────────────────────────────────
            if (!locationProvider.hasLocation) {
              return CustomScrollView(
                slivers: [
                  const _WaytherAppBar(cityName: 'Wayther'),
                  SliverFillRemaining(
                    child: _ErrorState(
                      icon: Icons.my_location_rounded,
                      title: 'No Location Found',
                      subtitle: 'Pull down to try again.',
                      onRetry: _refresh,
                    ),
                  ),
                ],
              );
            }

            final weather = weatherProvider.currentWeather;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const _WaytherAppBar(cityName: 'My Location'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Hero weather card ────────────────────────────
                        if (weather != null) ...[
                          WarningBanner(weather: weather),
                          WeatherCard(weather: weather),
                        ] else if (weatherProvider.error != null) ...[
                          _WeatherErrorCard(
                            error: weatherProvider.error!,
                            onRetry: () {
                              weatherProvider.fetchCurrentWeather(
                                locationProvider.latitude!,
                                locationProvider.longitude!,
                              );
                            },
                          ),
                        ] else ...[
                          // Weather not yet loaded
                          const ShimmerLoader.wide(height: 220, borderRadius: 24),
                        ],

                        const SizedBox(height: 24),

                        // ── Quick info chips ─────────────────────────────
                        if (weather != null)
                          Row(
                            children: [
                              _InfoChip(
                                icon: Icons.thermostat_rounded,
                                label:
                                    '${weather.temperature.toStringAsFixed(1)}°C',
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.air_rounded,
                                label:
                                    '${weather.windSpeed.toStringAsFixed(1)} m/s',
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.water_drop_outlined,
                                label:
                                    '${weather.precipitationProbability.toInt()}% rain',
                              ),
                            ],
                          ),

                        const SizedBox(height: 32),

                        // ── Coordinates row ──────────────────────────────
                        _CoordRow(
                          lat: locationProvider.latitude!,
                          lon: locationProvider.longitude!,
                        ),

                        const SizedBox(height: 32),

                        // ── CTA section ──────────────────────────────────
                        _RouteCTA(onTap: _goToRoutePlanner),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────────
class _WaytherAppBar extends StatelessWidget {
  final String cityName;
  const _WaytherAppBar({required this.cityName});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      toolbarHeight: 72,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🌤️', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wayther',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                cityName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.settings_rounded,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRetry;
  final Widget? secondaryAction;

  const _ErrorState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRetry,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ),
            if (secondaryAction != null) ...[
              const SizedBox(height: 8),
              secondaryAction!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Weather error inline ──────────────────────────────────────────────────────
class _WeatherErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _WeatherErrorCard({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.danger, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather unavailable',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.danger,
                      ),
                ),
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ── Coordinate row ────────────────────────────────────────────────────────────
class _CoordRow extends StatelessWidget {
  final double lat;
  final double lon;

  const _CoordRow({required this.lat, required this.lon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.pin_drop_rounded,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 6),
        Text(
          '${lat.toStringAsFixed(4)}°N, ${lon.toStringAsFixed(4)}°E',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
        ),
      ],
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Route CTA card ────────────────────────────────────────────────────────────
class _RouteCTA extends StatelessWidget {
  final VoidCallback onTap;

  const _RouteCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A6EFF), Color(0xFF0B4FC2)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.route_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan a Route',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Check weather along your journey',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

