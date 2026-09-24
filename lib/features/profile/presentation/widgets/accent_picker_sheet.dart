import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_color_schemes.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';
import 'package:insurflow/features/profile/presentation/cubit/app_preferences_cubit.dart';

/// Lets the user switch the app onto a custom accent.
///
/// Picking a swatch puts the app on the custom theme; "Default" returns
/// it to the brand colour. Light and dark still follow the Theme
/// setting, so a custom accent works in both — see
/// [AppColorSchemes.custom], which also keeps the chosen colour legible
/// against the surface it lands on.
class AccentPickerSheet extends StatelessWidget {
  const AccentPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<AppPreferencesCubit>();
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const AccentPickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return BlocBuilder<AppPreferencesCubit, AppPreferences>(
      builder: (context, preferences) {
        final selected = preferences.accent;

        return SafeArea(
          child: Padding(
            padding: context.spaceSymmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.accentLabel,
                  style: context.font18Bold?.copyWith(
                    color: colors.textPrimaryColor,
                    fontWeight: FontWeightHelper.semiBold,
                  ),
                ),
                context.addVerticalSpace(6),
                Text(
                  strings.accentHint,
                  style: context.font14Regular?.copyWith(
                    color: colors.textSecondaryColor,
                    height: 1.45,
                  ),
                ),
                context.addVerticalSpace(18),
                Wrap(
                  spacing: context.width(14),
                  runSpacing: context.height(14),
                  children: [
                    _Swatch(
                      key: const Key('accent-default'),
                      // Null restores the brand colour.
                      color: null,
                      isSelected: selected == null,
                      onTap: () => _apply(context, null),
                    ),
                    for (final accent in AppColorSchemes.presetAccents)
                      _Swatch(
                        key: ValueKey('accent-${accent.toARGB32()}'),
                        color: accent,
                        isSelected:
                            selected?.toARGB32() == accent.toARGB32(),
                        onTap: () => _apply(context, accent),
                      ),
                  ],
                ),
                context.addVerticalSpace(8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _apply(BuildContext context, Color? accent) {
    context.read<AppPreferencesCubit>().setAccent(accent);
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  /// Null renders the "default" option.
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final size = context.width(46);
    final swatch = color;

    return Semantics(
      label: swatch == null ? strings.accentDefault : strings.accentCustom,
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: swatch ?? colors.cardColor,
            border: Border.all(
              color: isSelected ? colors.textPrimaryColor : colors.borderColor,
              width: isSelected ? 2.4 : 1,
            ),
          ),
          child: Center(
            child: swatch == null
                // The default option shows a crossed-out circle rather
                // than a colour, so it cannot be mistaken for one.
                ? Icon(
                    Icons.format_color_reset_outlined,
                    size: context.width(20),
                    color: colors.textSecondaryColor,
                  )
                : isSelected
                ? Icon(
                    Icons.check_rounded,
                    size: context.width(22),
                    // Guaranteed legible on whatever swatch was picked.
                    color: AppColorSchemes.onColorFor(swatch),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
