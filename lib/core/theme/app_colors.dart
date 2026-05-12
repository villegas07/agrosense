import 'package:flutter/material.dart';

/// Paleta de colores centralizada de AgroSense.
/// Todos los widgets deben usar estas constantes en lugar de colores en línea.
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2E7D32); // Verde agrícola

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F6F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2EE);

  // ── Borders & Dividers ───────────────────────────────────────────────────
  static const Color divider = Color(0xFFE2E8E2);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A2A1A);
  static const Color textSecondary = Color(0xFF4D6050);
  static const Color textTertiary = Color(0xFF8FA890);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color optimal = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);
  static const Color liveRed = Color(0xFFE53935);

  // ── Charts ───────────────────────────────────────────────────────────────
  static const Color tempAmbient = Color(0xFFEF6C00);
  static const Color tempSoil = Color(0xFF6D4C41);
  static const Color chartAmbient = Color(0xFFEF6C00);
  static const Color chartSoil = Color(0xFF6D4C41);
  static const Color chartBar = Color(0xFF1E88E5);

  // ── Heatmap ──────────────────────────────────────────────────────────────
  static const Color heatLow = Color(0xFF66BB6A);
  static const Color heatMid = Color(0xFFFFB300);
  static const Color heatHigh = Color(0xFFE53935);
}
