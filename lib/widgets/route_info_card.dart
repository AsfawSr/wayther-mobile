import 'package:flutter/material.dart';
import '../models/route.dart';
import '../theme/app_colors.dart';

/// Card showing route summary: distance, duration, ETA, and traffic hint.
class RouteInfoCard extends StatelessWidget {
  final OsrmRouteResponse route;

  const RouteInfoCard({super.key, required this.route});

  String get _eta {
    final arrival = DateTime.now().add(Duration(seconds: route.totalDuration));
    final h = arrival.hour.toString().padLeft(2, '0');
    final m = arrival.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Color _trafficColor(OsrmRouteResponse r) {
    // Heuristic: if average speed < 30 km/h, flag as slow
    final km = r.totalDistance / 1000;
    final hours = r.totalDuration / 3600;
    if (hours == 0) return AppColors.success;
    final avgSpeed = km / hours;
    if (avgSpeed < 30) return AppColors.routeDanger;
    if (avgSpeed < 60) return AppColors.routeCaution;
    return AppColors.routeSafe;
  }

  @override
  Widget build(BuildContext context) {
    final trafficColor = _trafficColor(route);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.route_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Route Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              // Traffic indicator pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trafficColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: trafficColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trafficColor == AppColors.routeSafe
                          ? 'Clear'
                          : trafficColor == AppColors.routeCaution
                              ? 'Moderate'
                              : 'Slow',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: trafficColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RouteStatItem(
                icon: Icons.straighten_rounded,
                label: 'Distance',
                value: route.formattedDistance,
                color: AppColors.primary,
              ),
              _Divider(),
              _RouteStatItem(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: route.formattedDuration,
                color: AppColors.accent,
              ),
              _Divider(),
              _RouteStatItem(
                icon: Icons.schedule_rounded,
                label: 'Arrival',
                value: _eta,
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}

class _RouteStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RouteStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

