import 'package:flutter/material.dart';

extension AppSizes on BuildContext {
  /// Returns the current screen width.
  /// Useful when you need the available width of the device.
  double get getWidth => MediaQuery.sizeOf(this).width;

  /// Returns the current screen height.
  /// Useful when you need the available height of the device.
  double get getHeight => MediaQuery.sizeOf(this).height;

  /// Returns the available screen height after subtracting
  /// the AppBar and status bar heights.
  /// Useful for layouts that need to fill the remaining screen space.
  double get availableHeight {
    final appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(this).padding.top;
    return MediaQuery.of(this).size.height - appBarHeight - statusBarHeight;
  }

  /// Returns true when the device has a relatively small screen height.
  /// Useful for adapting UI spacing or layout on smaller devices.
  bool get isSmallScreen => MediaQuery.sizeOf(this).height < 690;

  /// Creates horizontal spacing relative to a 360px design width.
  /// Example: context.addHorizontalSpace(16).
  SizedBox addHorizontalSpace(double value) {
    return SizedBox(width: MediaQuery.sizeOf(this).width * (value / 360));
  }

  /// Creates vertical spacing relative to an 800px design height.
  /// Example: context.addVerticalSpace(16).
  SizedBox addVerticalSpace(double value) {
    return SizedBox(height: MediaQuery.sizeOf(this).height * (value / 800));
  }

  /// Converts a design width value into a responsive screen width.
  /// Uses 360px as the reference design width.
  /// Example: context.width(120).
  double width(double value) {
    return MediaQuery.sizeOf(this).width * (value / 360);
  }

  /// Converts a design height value into a responsive screen height.
  /// Uses 800px as the reference design height.
  /// Example: context.height(100).
  double height(double value) {
    return MediaQuery.sizeOf(this).height * (value / 800);
  }

  /// Creates equal padding on all sides.
  /// Example: context.spaceAroundAll(16).
  EdgeInsets spaceAroundAll(double value) {
    return EdgeInsets.all(value);
  }

  /// Creates responsive horizontal padding.
  /// The value is scaled based on the 360px reference width.
  /// Example: context.spaceHorizontal(16).
  EdgeInsets spaceHorizontal(double value) {
    return EdgeInsets.symmetric(
      horizontal: MediaQuery.sizeOf(this).width * (value / 360),
    );
  }

  /// Creates responsive vertical padding.
  /// The value is scaled based on the 800px reference height.
  /// Example: context.spaceVertical(16).
  EdgeInsets spaceVertical(double value) {
    return EdgeInsets.symmetric(
      vertical: MediaQuery.sizeOf(this).height * (value / 800),
    );
  }

  /// Creates responsive padding for both vertical and horizontal sides.
  /// Example: context.spaceSymmetric(vertical: 16, horizontal: 20).
  EdgeInsets spaceSymmetric({
    required double vertical,
    required double horizontal,
  }) {
    return EdgeInsets.symmetric(
      horizontal: MediaQuery.sizeOf(this).width * (horizontal / 360),
      vertical: MediaQuery.sizeOf(this).height * (vertical / 800),
    );
  }
  EdgeInsets fromLTRB({
    required double left,
    required double top,
    required double right,
    required double bottom,
  }) {
    return EdgeInsets.fromLTRB(
      MediaQuery.sizeOf(this).width * (left / 360),
      MediaQuery.sizeOf(this).height * (top / 800),
      MediaQuery.sizeOf(this).width * (right / 360),
      MediaQuery.sizeOf(this).height * (bottom / 800),


    );
  }

  /// Creates responsive padding for the top side.
  /// Useful for adding spacing above a widget.
  /// Example: context.spaceTop(16).
  EdgeInsetsDirectional spaceTop(double value) {
    return EdgeInsetsDirectional.only(
      top: MediaQuery.sizeOf(this).height * (value / 800),
    );
  }

  /// Creates responsive padding for the bottom side.
  /// Useful for adding spacing below a widget.
  /// Example: context.spaceBottom(16).
  EdgeInsetsDirectional spaceBottom(double value) {
    return EdgeInsetsDirectional.only(
      bottom: MediaQuery.sizeOf(this).height * (value / 800),
    );
  }

  /// Creates responsive padding for the start side.
  /// RTL-safe: start refers to left in LTR and right in RTL.
  /// Example: context.spaceStart(16).
  EdgeInsetsDirectional spaceStart(double value) {
    return EdgeInsetsDirectional.only(
      start: MediaQuery.sizeOf(this).width * (value / 360),
    );
  }

  /// Creates responsive padding for the end side.
  /// RTL-safe: end refers to right in LTR and left in RTL.
  /// Example: context.spaceEnd(16).
  EdgeInsetsDirectional spaceEnd(double value) {
    return EdgeInsetsDirectional.only(
      end: MediaQuery.sizeOf(this).width * (value / 360),
    );
  }

  /// Creates a circular BorderRadius.
  /// Useful for applying a consistent corner radius to widgets.
  /// Example: borderRadius: context.circularRadius(12).
  BorderRadius circularRadius(double value) {
    return BorderRadius.circular(value);
  }

  /// Returns true when the device is currently in landscape orientation.
  /// Useful for adapting layouts for landscape mode.
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;
}

extension LayoutExtensions on Widget {
  /// Adds equal padding around the widget.
  /// Example: Text('Hello').pad(16).
  Widget pad([double value = 8.0]) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Adds padding to the top of the widget.
  /// Example: Text('Hello').padTop(16).
  Widget padTop([double value = 8.0]) => Padding(
    padding: EdgeInsets.only(top: value),
    child: this,
  );

  /// Adds padding to the start/left side of the widget.
  /// Prefer padStart for RTL-safe layouts.
  /// Example: Text('Hello').padStart(16).
  Widget padStart([double value = 8.0]) => Padding(
    padding: EdgeInsets.only(left: value),
    child: this,
  );

  /// Adds padding to the end/right side of the widget.
  /// Prefer padEnd for RTL-safe layouts.
  /// Example: Text('Hello').padEnd(16).
  Widget padEnd([double value = 20]) => Padding(
    padding: EdgeInsets.only(right: value),
    child: this,
  );

  /// Adds padding to the bottom of the widget.
  /// Example: Text('Hello').padBottom(16).
  Widget padBottom([double value = 8.0]) => Padding(
    padding: EdgeInsets.only(bottom: value),
    child: this,
  );

  /// Centers the widget inside its parent.
  /// Example: Text('Hello').center().
  Widget center() => Center(child: this);

  /// Wraps the widget inside a red Container.
  /// Mainly useful for temporary debugging and visualizing widget bounds.
  /// Do not use in production UI.
  Widget contains() => Container(color: Colors.red, child: this);

  /// Adds horizontal padding to both start and end sides.
  /// Uses EdgeInsetsDirectional, making it RTL-friendly.
  /// Example: Text('Hello').padSymmetricHoriz(16).
  Widget padSymmetricHoriz(double value) => Padding(
    padding: EdgeInsetsDirectional.symmetric(horizontal: value),
    child: this,
  );

  /// Adds vertical padding to both top and bottom sides.
  /// Example: Text('Hello').padSymmetricVert(16).
  Widget padSymmetricVert(double value) => Padding(
    padding: EdgeInsetsDirectional.symmetric(vertical: value),
    child: this,
  );
}