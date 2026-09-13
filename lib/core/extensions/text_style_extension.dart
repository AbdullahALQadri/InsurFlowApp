import 'package:flutter/material.dart';

extension TextStyleExtension on BuildContext {
  TextTheme get _textTheme => Theme.of(this).textTheme;

  TextStyle? get font34Bold => _textTheme.displayLarge;
  TextStyle? get font34Regular => _textTheme.displayMedium;

  TextStyle? get font28Bold => _textTheme.displaySmall;
  TextStyle? get font28Regular => _textTheme.headlineLarge;

  TextStyle? get font26Bold => _textTheme.headlineMedium;
  TextStyle? get font26Regular => _textTheme.headlineSmall;

  TextStyle? get font22Bold => _textTheme.titleLarge;
  TextStyle? get font22Regular => _textTheme.titleMedium;

  TextStyle? get font18Bold => _textTheme.titleSmall;
  TextStyle? get font18Regular => _textTheme.bodyLarge;

  TextStyle? get font16Bold => _textTheme.bodyMedium;
  TextStyle? get font16Regular => _textTheme.bodySmall;

  TextStyle? get font14Bold => _textTheme.labelLarge;
  TextStyle? get font14Regular => _textTheme.labelMedium;
}
