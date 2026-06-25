import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable animated search field with debounce support.
class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final Color? iconColor;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Duration debounceDuration;
  final bool isLoading;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon = Icons.search_rounded,
    this.iconColor,
    this.onSubmitted,
    this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 450),
    this.isLoading = false,
    this.onClear,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _debounce;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      if (widget.onChanged != null && mounted) {
        widget.onChanged!(widget.controller.text);
      }
    });
    setState(() {}); // Rebuild to show/hide clear button
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? AppColors.primary;
    final hasText = widget.controller.text.isNotEmpty;

    return Focus(
      onFocusChange: (focused) => setState(() => _hasFocus = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: _hasFocus
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          onSubmitted: widget.onSubmitted,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(widget.prefixIcon, color: iconColor, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 50),
            suffixIcon: _buildSuffix(hasText),
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffix(bool hasText) {
    if (widget.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }
    if (hasText) {
      return IconButton(
        onPressed: () {
          widget.controller.clear();
          widget.onClear?.call();
        },
        icon: const Icon(Icons.close_rounded, size: 18),
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      );
    }
    return null;
  }
}

