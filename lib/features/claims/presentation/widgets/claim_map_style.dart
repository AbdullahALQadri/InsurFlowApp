import 'package:flutter/material.dart';

/// Google Maps JSON styling tuned to the InsurFlow palette.
///
/// Passed to `GoogleMap.style`, so the map follows the app's light and
/// dark themes instead of shipping Google's stock colours. Only hues
/// already used by the design system appear here — the dark style is
/// built from the same surfaces as `AppColorDark` (`#0F1720`
/// background, `#17202A` card, `#334155` border, `#94A3B8` secondary
/// text) and the light style from the neutral greys the app already
/// uses for map-adjacent surfaces.
///
/// Points of interest and transit labels are hidden so the claim marker
/// stays the focus of the card.
class ClaimMapStyle {
  ClaimMapStyle._();

  static String of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static const String light = '''
[
  {"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","elementType":"labels","stylers":[{"visibility":"off"}]},
  {"elementType":"geometry","stylers":[{"color":"#F1F5F9"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#64748B"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#FFFFFF"}]},
  {"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#CBD5E1"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#E9EFF4"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#D8E8DC"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#FFFFFF"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#E2E8F0"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#FFFFFF"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#FDFDFE"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#CBD5E1"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#C6DDE8"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#7D9AA8"}]}
]
''';

  static const String dark = '''
[
  {"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","elementType":"labels","stylers":[{"visibility":"off"}]},
  {"elementType":"geometry","stylers":[{"color":"#0F1720"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#94A3B8"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0F1720"}]},
  {"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#334155"}]},
  {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#CBD5E1"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#131C26"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#16261F"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#17202A"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#0F1720"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8AA4B8"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#1E293B"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#0F1720"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0A121A"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4A6375"}]}
]
''';
}
