import 'package:flutter/material.dart';
import '../models/weather.dart';

class WarningBanner extends StatelessWidget {
  final WeatherSnapshot weather;

  const WarningBanner({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!weather.hasWeatherWarning()) {
      return const SizedBox.shrink();
    }

    final message = weather.getWarningMessage();
    final isSnow = weather.condition.toLowerCase().contains('snow');
    final isFog = weather.condition.toLowerCase().contains('fog');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSnow
            ? Colors.cyan[50]
            : isFog
                ? Colors.grey[100]
                : Colors.orange[50],
        border: Border.all(
          color: isSnow
              ? Colors.cyan[300]!
              : isFog
                  ? Colors.grey[400]!
                  : Colors.orange[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isSnow
                ? Icons.cloud_queue
                : isFog
                    ? Icons.cloud
                    : Icons.warning_amber_rounded,
            color: isSnow
                ? Colors.cyan[700]
                : isFog
                    ? Colors.grey[700]
                    : Colors.orange[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSnow
                    ? Colors.cyan[700]
                    : isFog
                        ? Colors.grey[700]
                        : Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
