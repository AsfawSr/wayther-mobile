import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../theme/app_colors.dart';

/// Severity levels for weather warnings.
enum _WarningSeverity { low, medium, high }

/// Animated, dismissible weather warning banner with severity levels.
class WarningBanner extends StatefulWidget {
  final WeatherSnapshot weather;

  const WarningBanner({super.key, required this.weather});

  @override
  State<WarningBanner> createState() => _WarningBannerState();
}

class _WarningBannerState extends State<WarningBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _dismissed = false;

  _WarningSeverity get _severity {
    final p = widget.weather.precipitationProbability;
    if (p >= 80) return _WarningSeverity.high;
    if (p >= 60) return _WarningSeverity.medium;
    return _WarningSeverity.low;
  }

  Color get _bgColor {
    switch (_severity) {
      case _WarningSeverity.high:
        return AppColors.danger.withValues(alpha: 0.12);
      case _WarningSeverity.medium:
        return AppColors.warningStrong.withValues(alpha: 0.12);
      case _WarningSeverity.low:
        return AppColors.warning.withValues(alpha: 0.12);
    }
  }

  Color get _borderColor {
    switch (_severity) {
      case _WarningSeverity.high:
        return AppColors.danger.withValues(alpha: 0.6);
      case _WarningSeverity.medium:
        return AppColors.warningStrong.withValues(alpha: 0.6);
      case _WarningSeverity.low:
        return AppColors.warning.withValues(alpha: 0.6);
    }
  }

  Color get _iconColor {
    switch (_severity) {
      case _WarningSeverity.high:
        return AppColors.danger;
      case _WarningSeverity.medium:
        return AppColors.warningStrong;
      case _WarningSeverity.low:
        return AppColors.warning;
    }
  }

  IconData get _icon {
    final c = widget.weather.condition.toLowerCase();
    if (c.contains('snow') || c.contains('sleet')) return Icons.ac_unit_rounded;
    if (c.contains('fog') || c.contains('mist')) return Icons.foggy;
    if (c.contains('thunder') || c.contains('storm')) return Icons.thunderstorm_rounded;
    switch (_severity) {
      case _WarningSeverity.high:
        return Icons.dangerous_rounded;
      case _WarningSeverity.medium:
        return Icons.warning_rounded;
      case _WarningSeverity.low:
        return Icons.info_rounded;
    }
  }

  String get _label {
    switch (_severity) {
      case _WarningSeverity.high:
        return 'HIGH RISK';
      case _WarningSeverity.medium:
        return 'CAUTION';
      case _WarningSeverity.low:
        return 'ADVISORY';
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _dismiss() {
    _ctrl.reverse().then((_) {
      if (mounted) setState(() => _dismissed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || !widget.weather.hasWeatherWarning()) {
      return const SizedBox.shrink();
    }

    final message = widget.weather.getWarningMessage();

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          decoration: BoxDecoration(
            color: _bgColor,
            border: Border.all(color: _borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, color: _iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _iconColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                // Dismiss button
                GestureDetector(
                  onTap: _dismiss,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

