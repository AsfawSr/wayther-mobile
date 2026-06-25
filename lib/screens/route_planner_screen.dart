import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import '../config/app_config.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';
import '../providers/weather_provider.dart';
import '../models/checkpoint.dart';
import '../models/route.dart';
import '../widgets/map_widget.dart';
import '../widgets/route_info_card.dart';
import '../widgets/weather_timeline.dart';
import '../widgets/warning_banner.dart';
import '../widgets/search_field.dart';
import '../theme/app_colors.dart';
import '../utils/error_handler.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  // ── Map state ─────────────────────────────────────────────────────────────
  LatLng? _selectedLocation;
  LatLng? _originPoint;
  LatLng? _destPoint;

  // ── Search state ──────────────────────────────────────────────────────────
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  List<Location> _originResults = [];
  List<Location> _destResults = [];
  bool _searchingOrigin = false;
  bool _searchingDest = false;
  bool _originFocused = false;
  bool _destFocused = false;

  // ── Bottom sheet ──────────────────────────────────────────────────────────
  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _prefillCurrentLocation();
  }

  void _prefillCurrentLocation() {
    final loc = context.read<LocationProvider>();
    if (loc.hasLocation) {
      _selectedLocation = LatLng(loc.latitude!, loc.longitude!);
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    _sheetCtrl.dispose();
    super.dispose();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _searchOrigin(String query) async {
    if (query.isEmpty) {
      setState(() => _originResults = []);
      return;
    }
    setState(() => _searchingOrigin = true);
    try {
      final results = await locationFromAddress(query);
      if (mounted) setState(() => _originResults = results);
    } catch (_) {
      if (mounted) setState(() => _originResults = []);
    } finally {
      if (mounted) setState(() => _searchingOrigin = false);
    }
  }

  void _searchDest(String query) async {
    if (query.isEmpty) {
      setState(() => _destResults = []);
      return;
    }
    setState(() => _searchingDest = true);
    try {
      final results = await locationFromAddress(query);
      if (mounted) setState(() => _destResults = results);
    } catch (_) {
      if (mounted) setState(() => _destResults = []);
    } finally {
      if (mounted) setState(() => _searchingDest = false);
    }
  }

  Future<String> _getAddressLabel(Location loc) async {
    try {
      final marks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
      if (marks.isNotEmpty) {
        final m = marks.first;
        final parts = [
          m.name,
          m.locality,
          m.administrativeArea,
          m.country,
        ].where((s) => s != null && s.isNotEmpty).toList();
        if (parts.isNotEmpty) return parts.take(3).join(', ');
      }
    } catch (_) {}
    return 'Lat: ${loc.latitude.toStringAsFixed(4)}, Lon: ${loc.longitude.toStringAsFixed(4)}';
  }

  // ── Map interactions ───────────────────────────────────────────────────────

  void _onMapTapped(LatLng point) {
    setState(() {
      _selectedLocation = point;
      // Auto-fill the focused field
      if (_originFocused || _originPoint == null) {
        _originPoint = point;
        _originController.text =
            'Lat: ${point.latitude.toStringAsFixed(4)}, Lon: ${point.longitude.toStringAsFixed(4)}';
        _originResults = [];
      } else if (_destFocused || _destPoint == null) {
        _destPoint = point;
        _destController.text =
            'Lat: ${point.latitude.toStringAsFixed(4)}, Lon: ${point.longitude.toStringAsFixed(4)}';
        _destResults = [];
      }
    });
  }

  void _useCurrentAsOrigin() {
    final loc = context.read<LocationProvider>();
    if (!loc.hasLocation) {
      ErrorHandler.showInfo(context, 'Unable to get current location');
      return;
    }
    setState(() {
      _originPoint = LatLng(loc.latitude!, loc.longitude!);
      _originController.text = 'My Location';
      _originResults = [];
    });
  }

  // ── Route planning ────────────────────────────────────────────────────────

  void _planRoute() {
    if (_originPoint == null) {
      ErrorHandler.showInfo(context, 'Please set an origin location');
      return;
    }
    if (_destPoint == null) {
      ErrorHandler.showInfo(context, 'Please set a destination location');
      return;
    }

    final routeProvider = context.read<RouteProvider>();
    routeProvider.fetchRoute(
      originLat: _originPoint!.latitude,
      originLon: _originPoint!.longitude,
      destLat: _destPoint!.latitude,
      destLon: _destPoint!.longitude,
    ).then((_) {
      final r = routeProvider.route;
      if (r != null && r.isSuccess) {
        _fetchWeatherAlongRoute(r);
        // Expand the bottom sheet
        _sheetCtrl.animateTo(
          0.45,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      } else if (routeProvider.error != null) {
        if (mounted) ErrorHandler.showError(context, routeProvider.error!);
      }
    });
  }

  void _fetchWeatherAlongRoute(OsrmRouteResponse route) {
    final weatherProvider = context.read<WeatherProvider>();
    final points = route.getIntermediatePoints(AppConfig.routeCheckpointCount);
    if (points.isEmpty) return;

    final checkpoints = <FutureWeatherCheckpoint>[];
    for (int i = 0; i < points.length; i++) {
      final fraction = points.length > 1 ? i / (points.length - 1) : 0.0;
      final offsetSeconds = route.durationAtFraction(fraction);
      checkpoints.add(FutureWeatherCheckpoint(
        latitude: points[i].latitude,
        longitude: points[i].longitude,
        targetIso: DateTime.now().add(Duration(seconds: offsetSeconds)),
      ));
    }
    weatherProvider.fetchBatchWeather(checkpoints);
  }

  List<LatLng>? _getRoutePoints() {
    final r = context.read<RouteProvider>().route;
    if (r != null && r.isSuccess) return r.routePoints;
    return null;
  }

  // ── Search result helpers ─────────────────────────────────────────────────

  Widget _buildSearchDropdown({
    required List<Location> results,
    required bool isOrigin,
  }) {
    if (results.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: results.length,
        separatorBuilder: (_, i) => Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, i) {
          final loc = results[i];
          return FutureBuilder<String>(
            future: _getAddressLabel(loc),
            builder: (context, snap) {
              final label = snap.data ??
                  'Lat: ${loc.latitude.toStringAsFixed(4)}, Lon: ${loc.longitude.toStringAsFixed(4)}';
              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.location_on_rounded,
                  color: isOrigin ? AppColors.success : AppColors.danger,
                  size: 18,
                ),
                title: Text(label, style: Theme.of(context).textTheme.bodySmall),
                onTap: () {
                  final point = LatLng(loc.latitude, loc.longitude);
                  setState(() {
                    if (isOrigin) {
                      _originPoint = point;
                      _originController.text = label;
                      _originResults = [];
                    } else {
                      _destPoint = point;
                      _destController.text = label;
                      _destResults = [];
                    }
                    _selectedLocation = point;
                  });
                  FocusScope.of(context).unfocus();
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen map ────────────────────────────────────────────
          Positioned.fill(
            child: MapWidget(
              initialLat: _selectedLocation?.latitude ?? 9.03,
              initialLon: _selectedLocation?.longitude ?? 38.74,
              route: _getRoutePoints(),
              origin: _originPoint,
              destination: _destPoint,
              currentLocation: loc.hasLocation
                  ? LatLng(loc.latitude!, loc.longitude!)
                  : null,
              onTap: _onMapTapped,
              onLocateMe: _useCurrentAsOrigin,
            ),
          ),

          // ── Top floating panel ─────────────────────────────────────────
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TopPanel(
                  originController: _originController,
                  destController: _destController,
                  searchingOrigin: _searchingOrigin,
                  searchingDest: _searchingDest,
                  onOriginChanged: _searchOrigin,
                  onDestChanged: _searchDest,
                  onOriginFocus: (f) => setState(() => _originFocused = f),
                  onDestFocus: (f) => setState(() => _destFocused = f),
                  onOriginClear: () => setState(() {
                    _originResults = [];
                    _originPoint = null;
                  }),
                  onDestClear: () => setState(() {
                    _destResults = [];
                    _destPoint = null;
                  }),
                  onPlanRoute: _planRoute,
                  originPoint: _originPoint,
                  destPoint: _destPoint,
                ),
                // ── Dropdown results ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildSearchDropdown(
                          results: _originResults, isOrigin: true),
                      if (_originResults.isEmpty)
                        _buildSearchDropdown(
                            results: _destResults, isOrigin: false),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom sheet ───────────────────────────────────────────────
          DraggableScrollableSheet(
            controller: _sheetCtrl,
            initialChildSize: 0.08,
            minChildSize: 0.08,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return _BottomSheet(
                scrollController: scrollController,
                onPlanRoute: _planRoute,
                originPoint: _originPoint,
                destPoint: _destPoint,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Top floating panel ────────────────────────────────────────────────────────
class _TopPanel extends StatelessWidget {
  final TextEditingController originController;
  final TextEditingController destController;
  final bool searchingOrigin;
  final bool searchingDest;
  final ValueChanged<String> onOriginChanged;
  final ValueChanged<String> onDestChanged;
  final ValueChanged<bool> onOriginFocus;
  final ValueChanged<bool> onDestFocus;
  final VoidCallback onOriginClear;
  final VoidCallback onDestClear;
  final VoidCallback onPlanRoute;
  final LatLng? originPoint;
  final LatLng? destPoint;

  const _TopPanel({
    required this.originController,
    required this.destController,
    required this.searchingOrigin,
    required this.searchingDest,
    required this.onOriginChanged,
    required this.onDestChanged,
    required this.onOriginFocus,
    required this.onDestFocus,
    required this.onOriginClear,
    required this.onDestClear,
    required this.onPlanRoute,
    required this.originPoint,
    required this.destPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Back button + title
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Plan a Route',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Origin field
            Focus(
              onFocusChange: onOriginFocus,
              child: SearchField(
                controller: originController,
                hint: 'From — Origin',
                prefixIcon: Icons.trip_origin_rounded,
                iconColor: AppColors.success,
                isLoading: searchingOrigin,
                onChanged: onOriginChanged,
                onSubmitted: onOriginChanged,
                onClear: onOriginClear,
              ),
            ),

            const SizedBox(height: 8),

            // Destination field
            Focus(
              onFocusChange: onDestFocus,
              child: SearchField(
                controller: destController,
                hint: 'To — Destination',
                prefixIcon: Icons.location_on_rounded,
                iconColor: AppColors.danger,
                isLoading: searchingDest,
                onChanged: onDestChanged,
                onSubmitted: onDestChanged,
                onClear: onDestClear,
              ),
            ),

            // Status chips
            if (originPoint != null || destPoint != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (originPoint != null)
                    _StatusChip(
                      label: 'Origin set',
                      color: AppColors.success,
                      icon: Icons.check_circle_rounded,
                    ),
                  if (originPoint != null && destPoint != null)
                    const SizedBox(width: 8),
                  if (destPoint != null)
                    _StatusChip(
                      label: 'Destination set',
                      color: AppColors.danger,
                      icon: Icons.check_circle_rounded,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────
class _BottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onPlanRoute;
  final LatLng? originPoint;
  final LatLng? destPoint;

  const _BottomSheet({
    required this.scrollController,
    required this.onPlanRoute,
    required this.originPoint,
    required this.destPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // ── Handle ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Plan route button ─────────────────────────────────
                Consumer<RouteProvider>(
                  builder: (context, routeProvider, _) {
                    return ElevatedButton.icon(
                      onPressed:
                          routeProvider.isLoading ? null : onPlanRoute,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.5),
                      ),
                      icon: routeProvider.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.navigation_rounded),
                      label: Text(
                        routeProvider.isLoading ? 'Planning…' : 'Plan Route',
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ── Route error ───────────────────────────────────────
                Consumer<RouteProvider>(
                  builder: (context, routeProvider, _) {
                    if (routeProvider.error != null) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.danger, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ErrorHandler.messageFor(
                                    routeProvider.error!),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // ── Route info & weather ──────────────────────────────
                Consumer2<RouteProvider, WeatherProvider>(
                  builder: (context, routeProvider, weatherProvider, _) {
                    final route = routeProvider.route;
                    if (route == null || !route.isSuccess) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RouteInfoCard(route: route),
                        const SizedBox(height: 24),

                        // Weather warnings
                        ...weatherProvider.batchWeather.map((w) {
                          if (!w.hasWeatherWarning()) {
                            return const SizedBox.shrink();
                          }
                          return WarningBanner(weather: w);
                        }),

                        // Weather timeline
                        if (weatherProvider.batchWeather.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          WeatherTimeline(
                            snapshots: weatherProvider.batchWeather,
                            totalDurationSeconds: route.totalDuration,
                          ),
                        ] else if (weatherProvider.isLoading) ...[
                          const SizedBox(height: 16),
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

