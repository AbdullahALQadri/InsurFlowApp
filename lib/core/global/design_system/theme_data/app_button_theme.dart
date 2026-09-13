import 'package:flutter/material.dart';

@immutable
class AppButtonTheme extends ThemeExtension<AppButtonTheme> {
// ---------------------------------------------------------------------------
// Filled Button
// ---------------------------------------------------------------------------

final Gradient backgroundGradient;

final Color foregroundColor;
final Color disabledBackgroundColor;
final Color disabledForegroundColor;

// ---------------------------------------------------------------------------
// Outlined Button
// ---------------------------------------------------------------------------

final Color outlinedForegroundColor;
final Color outlinedDisabledForegroundColor;
final Color outlinedBorderColor;
final Color outlinedDisabledBorderColor;
final double outlinedBorderWidth;

// ---------------------------------------------------------------------------
// Common
// ---------------------------------------------------------------------------

final double height;
final double borderRadius;

final EdgeInsetsGeometry padding;

final double iconSize;
final double iconSpacing;

final double loadingIndicatorSize;
final double loadingStrokeWidth;

const AppButtonTheme({
// Filled
required this.backgroundGradient,
required this.foregroundColor,
required this.disabledBackgroundColor,
required this.disabledForegroundColor,

// Outlined
required this.outlinedForegroundColor,
required this.outlinedDisabledForegroundColor,
required this.outlinedBorderColor,
required this.outlinedDisabledBorderColor,
required this.outlinedBorderWidth,

// Common
required this.height,
required this.borderRadius,
required this.padding,
required this.iconSize,
required this.iconSpacing,
required this.loadingIndicatorSize,
required this.loadingStrokeWidth,
});

// ---------------------------------------------------------------------------
// Copy With
// ---------------------------------------------------------------------------

@override
AppButtonTheme copyWith({
// Filled
Gradient? backgroundGradient,
Color? foregroundColor,
Color? disabledBackgroundColor,
Color? disabledForegroundColor,

// Outlined
Color? outlinedForegroundColor,
Color? outlinedDisabledForegroundColor,
Color? outlinedBorderColor,
Color? outlinedDisabledBorderColor,
double? outlinedBorderWidth,

// Common
double? height,
double? borderRadius,
EdgeInsetsGeometry? padding,
double? iconSize,
double? iconSpacing,
double? loadingIndicatorSize,
double? loadingStrokeWidth,
}) {
return AppButtonTheme(
// Filled
backgroundGradient:
backgroundGradient ?? this.backgroundGradient,
foregroundColor:
foregroundColor ?? this.foregroundColor,
disabledBackgroundColor:
disabledBackgroundColor ??
this.disabledBackgroundColor,
disabledForegroundColor:
disabledForegroundColor ??
this.disabledForegroundColor,

// Outlined
outlinedForegroundColor:
outlinedForegroundColor ??
this.outlinedForegroundColor,
outlinedDisabledForegroundColor:
outlinedDisabledForegroundColor ??
this.outlinedDisabledForegroundColor,
outlinedBorderColor:
outlinedBorderColor ??
this.outlinedBorderColor,
outlinedDisabledBorderColor:
outlinedDisabledBorderColor ??
this.outlinedDisabledBorderColor,
outlinedBorderWidth:
outlinedBorderWidth ??
this.outlinedBorderWidth,

// Common
height: height ?? this.height,
borderRadius:
borderRadius ?? this.borderRadius,
padding: padding ?? this.padding,
iconSize: iconSize ?? this.iconSize,
iconSpacing:
iconSpacing ?? this.iconSpacing,
loadingIndicatorSize:
loadingIndicatorSize ??
this.loadingIndicatorSize,
loadingStrokeWidth:
loadingStrokeWidth ??
this.loadingStrokeWidth,
);
}

// ---------------------------------------------------------------------------
// Lerp
// ---------------------------------------------------------------------------

@override
AppButtonTheme lerp(
covariant AppButtonTheme? other,
double t,
) {
if (other == null) {
return this;
}

return AppButtonTheme(
// Filled
backgroundGradient: t < 0.5
? backgroundGradient
    : other.backgroundGradient,

foregroundColor: Color.lerp(
foregroundColor,
other.foregroundColor,
t,
)!,

disabledBackgroundColor: Color.lerp(
disabledBackgroundColor,
other.disabledBackgroundColor,
t,
)!,

disabledForegroundColor: Color.lerp(
disabledForegroundColor,
other.disabledForegroundColor,
t,
)!,

// Outlined
outlinedForegroundColor: Color.lerp(
outlinedForegroundColor,
other.outlinedForegroundColor,
t,
)!,

outlinedDisabledForegroundColor: Color.lerp(
outlinedDisabledForegroundColor,
other.outlinedDisabledForegroundColor,
t,
)!,

outlinedBorderColor: Color.lerp(
outlinedBorderColor,
other.outlinedBorderColor,
t,
)!,

outlinedDisabledBorderColor: Color.lerp(
outlinedDisabledBorderColor,
other.outlinedDisabledBorderColor,
t,
)!,

outlinedBorderWidth:
outlinedBorderWidth +
(other.outlinedBorderWidth -
outlinedBorderWidth) *
t,

// Common
height:
height +
(other.height - height) * t,

borderRadius:
borderRadius +
(other.borderRadius - borderRadius) * t,

padding:
EdgeInsetsGeometry.lerp(
padding,
other.padding,
t,
)!,

iconSize:
iconSize +
(other.iconSize - iconSize) * t,

iconSpacing:
iconSpacing +
(other.iconSpacing - iconSpacing) * t,

loadingIndicatorSize:
loadingIndicatorSize +
(other.loadingIndicatorSize -
loadingIndicatorSize) *
t,

loadingStrokeWidth:
loadingStrokeWidth +
(other.loadingStrokeWidth -
loadingStrokeWidth) *
t,
);
}
}
