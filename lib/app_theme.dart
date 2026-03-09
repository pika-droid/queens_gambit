import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized design tokens for the Queen's Gambit app.
class AppTheme {
  AppTheme._();

  // ── Colors ──────────────────────────────────────────────────────────

  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color surfaceBorder = Color(0xFF333333);

  static const Color gold = Color(0xFFD4A843);
  static const Color goldLight = Color(0xFFE8C868);
  static const Color goldDim = Color(0xFFB8922E);

  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFF9E9E8A);
  static const Color textTertiary = Color(0xFF6A6A5A);

  static const Color danger = Color(0xFFEF5350);
  static const Color dangerDark = Color(0xFF8B2500);
  static const Color success = Color(0xFF66BB6A);

  static const Color boardDark = Color(0xFF8B6B4A);
  static const Color boardLight = Color(0xFFF5E6C8);
  static const Color boardBorder = Color(0xFF5C3D1E);

  // ── Gradients ───────────────────────────────────────────────────────

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4A843), Color(0xFFE8C868)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFFF7043)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF1E1E1E), Color(0xFF151515)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Text Styles ─────────────────────────────────────────────────────

  static TextStyle get titleStyle => GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 1.2,
  );

  static TextStyle get headingStyle => GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get subtitleStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 3,
  );

  static TextStyle get bodyStyle =>
      GoogleFonts.inter(fontSize: 14, color: textSecondary);

  static TextStyle get labelStyle =>
      GoogleFonts.inter(fontSize: 12, color: textSecondary);

  static TextStyle get statValueStyle =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700);

  static TextStyle get buttonLabelStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get smallLabelStyle =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500);

  // ── Decorations ─────────────────────────────────────────────────────

  static BoxDecoration get glassDecoration => BoxDecoration(
    color: surface.withValues(alpha: 0.6),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration glassDecorationWithGlow(Color glowColor) =>
      BoxDecoration(
        color: surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glowColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get panelDecoration => BoxDecoration(
    gradient: surfaceGradient,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    border: const Border(top: BorderSide(color: Color(0xFF2A2A2A))),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 20,
        offset: const Offset(0, -4),
      ),
    ],
  );

  // ── Theme Data ──────────────────────────────────────────────────────

  static ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      secondary: goldLight,
      surface: surface,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    useMaterial3: true,
    sliderTheme: SliderThemeData(
      activeTrackColor: gold,
      inactiveTrackColor: surfaceBorder,
      thumbColor: gold,
      overlayColor: gold.withValues(alpha: 0.15),
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return gold;
        return const Color(0xFF555555);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return gold.withValues(alpha: 0.3);
        }
        return const Color(0xFF333333);
      }),
    ),
  );
}

/// A frosted glass container widget.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;
  final BorderRadius? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.glowColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.5),
            borderRadius: radius,
            border: Border.all(
              color: (glowColor ?? Colors.white).withValues(alpha: 0.1),
            ),
            boxShadow: [
              if (glowColor != null)
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
