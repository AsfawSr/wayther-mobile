import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../theme/app_colors.dart';
import 'weather_card.dart';

/// Horizontal scrollable weather timeline for route checkpoints.
class WeatherTimeline extends StatelessWidget {
  final List<WeatherSnapshot> snapshots;
  final int totalDurationSeconds;

  const WeatherTimeline({
    super.key,
    required this.snapshots,
    required this.totalDurationSeconds,
  });

  String _timeLabel(int index) {
    if (snapshots.isEmpty) return '';
    final fraction = index / (snapshots.length - 1).clamp(1, snapshots.length);
    final seconds = (totalDurationSeconds * fraction).round();
    final minutes = seconds ~/ 60;
    if (index == 0) return 'Start';
    if (index == snapshots.length - 1) return 'Arrival';
    if (minutes < 60) return 'In ${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  Color _connectorColor(WeatherSnapshot w) {
    final p = w.precipitationProbability;
    if (p >= 80) return AppColors.routeDanger;
    if (p >= 50) return AppColors.routeCaution;
    return AppColors.routeSafe;
  }

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weather Along Route',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            itemCount: snapshots.length,
            separatorBuilder: (_, index) {
              // Colored connector line between cards
              final color = _connectorColor(snapshots[index]);
              return SizedBox(
                width: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              );
            },
            itemBuilder: (context, index) {
              final snap = snapshots[index];
              return Column(
                children: [
                  // Time label
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _timeLabel(index),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Compact weather card
                  WeatherCard(weather: snap, compact: true),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

