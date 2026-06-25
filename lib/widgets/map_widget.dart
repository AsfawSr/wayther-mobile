import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';

/// Interactive Flutter Map widget with route, markers, current location dot,
/// and a "locate me" button overlay.
class MapWidget extends StatefulWidget {
  final double initialLat;
  final double initialLon;
  final List<LatLng>? route;
  final LatLng? origin;
  final LatLng? destination;
  final LatLng? currentLocation;
  final Function(LatLng) onTap;
  final VoidCallback? onLocateMe;

  const MapWidget({
    super.key,
    required this.initialLat,
    required this.initialLon,
    this.route,
    this.origin,
    this.destination,
    this.currentLocation,
    required this.onTap,
    this.onLocateMe,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback(_updateMapPosition);
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_updateMapPosition);
  }

  void _updateMapPosition(_) {
    if (!mounted) return;

    if (widget.origin != null && widget.destination != null) {
      final bounds = LatLngBounds(widget.origin!, widget.destination!);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );
    } else if (widget.origin != null) {
      _mapController.move(widget.origin!, 14.0);
    } else if (widget.destination != null) {
      _mapController.move(widget.destination!, 14.0);
    } else if (widget.currentLocation != null) {
      _mapController.move(widget.currentLocation!, 14.0);
    } else {
      _mapController.move(LatLng(widget.initialLat, widget.initialLon), 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Map ────────────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onTap: (tapPosition, latLng) => widget.onTap(latLng),
            ),
            children: [
              // Tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.wayther',
                maxNativeZoom: 19,
              ),

              // Route polyline
              if (widget.route != null && widget.route!.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.route!,
                      color: AppColors.primary,
                      strokeWidth: 5.0,
                      borderColor: AppColors.primary.withValues(alpha: 0.3),
                      borderStrokeWidth: 10.0,
                    ),
                  ],
                ),

              // Current location pulsing dot
              if (widget.currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.currentLocation!,
                      width: 24,
                      height: 24,
                      child: _PulsingDot(),
                    ),
                  ],
                ),

              // Origin marker
              if (widget.origin != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.origin!,
                      width: 40,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: _PinMarker(
                        color: AppColors.success,
                        icon: Icons.trip_origin_rounded,
                      ),
                    ),
                  ],
                ),

              // Destination marker
              if (widget.destination != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.destination!,
                      width: 40,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: _PinMarker(
                        color: AppColors.danger,
                        icon: Icons.location_on_rounded,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // ── Map attribution (required by OSM) ──────────────────────────────
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '© OpenStreetMap contributors',
              style: TextStyle(fontSize: 9, color: Colors.black54),
            ),
          ),
        ),

        // ── Locate-me button ───────────────────────────────────────────────
        if (widget.onLocateMe != null)
          Positioned(
            bottom: 16,
            left: 16,
            child: _LocateMeButton(onTap: widget.onLocateMe!),
          ),
      ],
    );
  }
}

// ── Pulsing current-location dot ─────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          Container(
            width: 24 * _pulse.value,
            height: 24 * _pulse.value,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
          ),
          // Inner dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pin marker ────────────────────────────────────────────────────────────────
class _PinMarker extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _PinMarker({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        // Pin tail
        Container(
          width: 3,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ── Locate-me FAB ─────────────────────────────────────────────────────────────
class _LocateMeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LocateMeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.my_location_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
