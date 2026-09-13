import 'package:flutter/material.dart';

// Extension to easily change the opacity of a color
extension OpacityExtension on Color {
  Color changeOpacity(double opacity) => withValues(alpha: opacity);
}

// Extension to create a ColorFilter from a Color
extension ColorFilterExtension on Color {
  ColorFilter toColorFilter() {
    return ColorFilter.mode(this, BlendMode.srcIn);
  }
}
