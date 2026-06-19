import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatefulWidget {
  final double initialLat;
  final double initialLon;
  final List<LatLng>? route;
  final LatLng? origin;
  final LatLng? destination;
  final Function(LatLng) onTap;
  final String label;

  const MapWidget({
    super.key,
    required this.initialLat,
    required this.initialLon,
    this.route,
    this.origin,
    this.destination,
    required this.onTap,
    required this.label,
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
    _updateMapPosition();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMapPosition();
  }

  void _updateMapPosition() {
    if (widget.origin != null && widget.destination != null) {
      final bounds = LatLngBounds(
        widget.origin!,
        widget.destination!,
      );
      _mapController.fitBounds(bounds, padding: 50);
    } else if (widget.origin != null) {
      _mapController.move(widget.origin!, 13.0);
    } else if (widget.destination != null) {
      _mapController.move(widget.destination!, 13.0);
    } else {
      _mapController.move(LatLng(widget.initialLat, widget.initialLon), 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap on map to set location',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onTap: (tapPosition, latLng) {
                widget.onTap(latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.wayther',
                maxNativeZoom: 19,
              ),
              if (widget.route != null && widget.route!.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.route!,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              if (widget.origin != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.origin!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              if (widget.destination != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.destination!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}