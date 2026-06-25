import 'package:flutter/material.dart';

/// Central color palette for the Wayther app.
abstract final class AppColors {
  // ── Primary palette ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A6EFF); // vivid sky blue
  static const Color primaryDark = Color(0xFF0B4FC2);
  static const Color primaryLight = Color(0xFF5B9AFF);

  // ── Accent ───────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF38BFFF); // cyan-sky

  // ── Background & Surface ─────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF0F4FF);
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF162035);
  static const Color surfaceVariantLight = Color(0xFFE6EEFF);
  static const Color surfaceVariantDark = Color(0xFF1F2E47);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF0D1B3E);
  static const Color textSecondaryLight = Color(0xFF5A6A8A);
  static const Color textPrimaryDark = Color(0xFFE8F0FF);
  static const Color textSecondaryDark = Color(0xFF8A9EC4);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFFAB40); // amber
  static const Color warningStrong = Color(0xFFFF6B35); // orange-red
  static const Color danger = Color(0xFFE53935); // red
  static const Color info = Color(0xFF29B6F6); // light blue

  // ── Weather condition gradients ───────────────────────────────────────────
  static const List<Color> sunnyGradient = [Color(0xFFFFAF00), Color(0xFFFF6B00)];
  static const List<Color> clearNightGradient = [Color(0xFF1A237E), Color(0xFF283593)];
  static const List<Color> cloudyGradient = [Color(0xFF607D8B), Color(0xFF455A64)];
  static const List<Color> rainyGradient = [Color(0xFF1565C0), Color(0xFF0D47A1)];
  static const List<Color> snowyGradient = [Color(0xFF80DEEA), Color(0xFF26C6DA)];
  static const List<Color> foggyGradient = [Color(0xFF90A4AE), Color(0xFF78909C)];
  static const List<Color> thunderGradient = [Color(0xFF4A148C), Color(0xFF311B92)];
  static const List<Color> defaultGradient = [Color(0xFF1A6EFF), Color(0xFF0B4FC2)];

  // ── Map overlay ──────────────────────────────────────────────────────────
  static const Color routeSafe = Color(0xFF1A6EFF);
  static const Color routeCaution = Color(0xFFFFAB40);
  static const Color routeDanger = Color(0xFFE53935);

  // ── Glassmorphism ────────────────────────────────────────────────────────
  static const Color glass = Color(0x33FFFFFF); // 20% white
  static const Color glassBorder = Color(0x55FFFFFF); // 33% white
}

