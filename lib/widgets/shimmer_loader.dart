import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated shimmer placeholder for loading states.
class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  /// A shimmer block that fills its parent's width.
  const ShimmerLoader.wide({
    super.key,
    required this.height,
    this.borderRadius = 12,
  }) : width = double.infinity;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;
    final shimmerColor = isDark
        ? const Color(0xFF2E4068)
        : const Color(0xFFD6E0F5);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, shimmerColor, baseColor],
              stops: [
                (_anim.value.clamp(-1.0, 0.0) + 1) / 2,
                (_anim.value.clamp(0.0, 1.0) + 1) / 2,
                (_anim.value.clamp(0.0, 1.0) + 1.3) / 2,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Full skeleton layout for the Home Screen loading state.
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card skeleton
          const ShimmerLoader.wide(height: 220, borderRadius: 24),
          const SizedBox(height: 20),
          // Warning placeholder
          const ShimmerLoader.wide(height: 60, borderRadius: 16),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              const Expanded(child: ShimmerLoader.wide(height: 80, borderRadius: 16)),
              const SizedBox(width: 12),
              const Expanded(child: ShimmerLoader.wide(height: 80, borderRadius: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

