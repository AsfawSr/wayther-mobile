import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

/// Maps exceptions to user-friendly messages and shows snack bars.
abstract final class ErrorHandler {
  static String messageFor(Object error) {
    if (error is ApiException) {
      if (error.isNetworkError) {
        return 'No internet connection. Please check your network and try again.';
      }
      switch (error.statusCode) {
        case 422:
          return 'Location is outside the coverage area.';
        case 502:
        case 503:
          return 'The weather service is temporarily unavailable. Try again shortly.';
        case 408:
          return 'Request timed out. Check your connection and retry.';
        default:
          return error.message;
      }
    }
    final msg = error.toString();
    if (msg.contains('Location permission denied')) {
      return 'Location permission is required. Please enable it in Settings.';
    }
    if (msg.contains('Location service is disabled')) {
      return 'Location services are turned off. Please enable GPS.';
    }
    if (msg.contains('timed out') || msg.contains('TimeoutException')) {
      return 'Connection timed out. Please retry.';
    }
    return msg;
  }

  static void showError(BuildContext context, Object error) {
    final message = messageFor(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white.withValues(alpha: 0.8),
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

