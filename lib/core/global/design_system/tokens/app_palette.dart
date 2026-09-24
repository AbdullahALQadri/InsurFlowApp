import 'package:flutter/material.dart';

/// The only place in the app where a brand colour is written as a hex
/// literal.
///
/// Everything else reads semantic tokens from `context.colors`
/// ([AppColors]) so a theme change reaches every screen. Values here are
/// raw ingredients, not tokens — widgets must not reference them.
class AppPalette {
  AppPalette._();

  // Brand.
  //
  // `cyan` is nudged one step darker than the original #00A3C4 so it
  // clears a 3:1 contrast ratio against white — the WCAG minimum for a
  // UI component. The difference is imperceptible; the old value came
  // in at 2.98 and failed the check.
  static const Color cyan = Color(0xFF00A1C1);
  static const Color cyanBright = Color(0xFF22C3E0);
  static const Color cyanLight = Color(0xFF3EC6E0);
  static const Color cyanDeep = Color(0xFF0E8CBC);
  static const Color glow = Color(0xFF5EE7FF);
  static const Color line = Color(0xFF4DB8D4);

  // Brand surfaces: the dark navy used by splash, login hero and headers.
  static const Color midnight = Color(0xFF070B16);
  static const Color abyss = Color(0xFF05080F);
  static const Color navy = Color(0xFF0C1628);
  static const Color atmosphere = Color(0xFF12344C);

  // Neutrals, light
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color borderLight = Color(0xFFE3E8F2);
  static const Color iconBackgroundLight = Color(0xFFEFF3FC);
  static const Color inkLight = Color(0xFF181A1B);
  static const Color mutedLight = Color(0xFF64748B);
  static const Color outlineLight = Color(0xFF9CA3AF);

  // Neutrals, dark
  static const Color surfaceDark = Color(0xFF0F1720);
  static const Color cardDark = Color(0xFF17202A);
  static const Color elevatedDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color inkDark = Color(0xFFF8FAFC);
  static const Color mutedDark = Color(0xFF94A3B8);
  static const Color outlineDark = Color(0xFF64748B);

  // Status and feedback
  static const Color success = Color(0xFF0F9D8A);
  static const Color successStrong = Color(0xFF047857);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerStrong = Color(0xFFB91C1C);
  static const Color info = Color(0xFF6366F1);
  static const Color neutral = Color(0xFF64748B);

  // Immersive (camera / scanner) surfaces. These sit over a live camera
  // feed, so they stay dark in every theme. See the immersive tokens on
  // AppColors.
  static const Color immersiveSurface = Color(0xFF05080F);
  static const Color immersivePanel = Color(0xCC141C2A);
  static const Color immersiveInk = Color(0xFFF4F8FB);
  static const Color immersiveMuted = Color(0xFF8AA4B8);
  static const Color immersiveSubtle = Color(0xFF6B8298);
  static const Color immersiveScrim = Color(0xCC000000);

  // A vehicle licence plate is a physical object: it looks the same
  // whatever theme the app is in, so these do not vary by scheme.
  static const Color plateFace = Color(0xFFF4F1E8);
  static const Color plateEdge = Color(0xFF1A2332);
  static const Color plateShadow = Color(0xFF2C3A4F);
  static const Color plateHeader = Color(0xFF12344C);
  static const Color plateInk = Color(0xFF111827);
  static const Color plateInkMuted = Color(0xFF9CA3AF);
  static const Color plateSlot = Color(0xFF6B7280);

  // Sketch-map tones used by the location confirmation card in light
  // mode; the dark equivalents are derived from the active scheme.
  static const Color mapFill = Color(0xFFE7EEF3);
  static const Color mapBlock = Color(0xFFD5E1EA);
  static const Color mapPark = Color(0xFFC9DCD0);
  static const Color mapRoad = Color(0xFFF7FBFD);
}
