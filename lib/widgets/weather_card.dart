import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Premium weather card with condition-based gradient and animated temperature.
class WeatherCard extends StatefulWidget {
  final WeatherSnapshot weather;

  /// If true, renders a smaller compact version for use in lists.
  final bool compact;

  const WeatherCard({
    super.key,
    required this.weather,
    this.compact = false,
  });

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _tempAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _tempAnim = Tween<double>(
      begin: 0,
      end: widget.weather.temperature,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateFormat('MMM d').format(now);
    final cardDate = DateFormat('MMM d').format(dt);
    final timeStr = DateFormat('h:mm a').format(dt);
    if (today == cardDate) return 'Today at $timeStr';
    return '$cardDate at $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final gradient = conditionGradient(widget.weather.condition);

    if (widget.compact) {
      return _CompactCard(weather: widget.weather, gradient: gradient);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: temp + icon ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _tempAnim,
                      builder: (_, child) => Text(
                        '${_tempAnim.value.toStringAsFixed(1)}°C',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.weather.condition,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
                // Weather icon in frosted pill
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.glassBorder, width: 1),
                  ),
                  child: Text(
                    widget.weather.weatherIcon,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Divider ─────────────────────────────────────────────────
            Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),

            const SizedBox(height: 20),

            // ── Stats row ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatPill(
                  icon: Icons.air_rounded,
                  label: 'Wind',
                  value: '${widget.weather.windSpeed.toStringAsFixed(1)} m/s',
                ),
                _StatPill(
                  icon: Icons.water_drop_outlined,
                  label: 'Rain',
                  value: '${widget.weather.precipitationProbability.toInt()}%',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Timestamp ─────────────────────────────────────────────────
            Text(
              _formatTime(widget.weather.timestamp),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Compact card for weather timelines ──────────────────────────────────────
class _CompactCard extends StatelessWidget {
  final WeatherSnapshot weather;
  final List<Color> gradient;

  const _CompactCard({required this.weather, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(weather.weatherIcon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            '${weather.temperature.toStringAsFixed(0)}°',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${weather.precipitationProbability.toInt()}% 💧',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

// ── Stat pill ────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

