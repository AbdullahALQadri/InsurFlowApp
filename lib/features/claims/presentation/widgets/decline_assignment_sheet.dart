import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/authentication/presentation/widgets/login_text_field.dart';

/// Collects the reason the adjuster cannot take an assignment.
///
/// `POST /claims/{id}/decline-assignment` requires a non-empty `reason`
/// — it answers 400 without one — so the sheet cannot be submitted
/// empty. Returns the typed reason, or null if the adjuster backed out.
class DeclineAssignmentSheet extends StatefulWidget {
  const DeclineAssignmentSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const DeclineAssignmentSheet(),
    );
  }

  @override
  State<DeclineAssignmentSheet> createState() => _DeclineAssignmentSheetState();
}

class _DeclineAssignmentSheetState extends State<DeclineAssignmentSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _controller.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = AppStrings.of(context).declineReasonRequired);
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Padding(
      // Keeps the field above the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: context.spaceSymmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.declineReasonTitle,
                style: context.font18Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                ),
              ),
              context.addVerticalSpace(6),
              Text(
                strings.declineReasonHint,
                style: context.font14Regular?.copyWith(
                  color: colors.textSecondaryColor,
                  height: 1.45,
                ),
              ),
              context.addVerticalSpace(16),
              LoginTextField(
                key: const Key('decline-reason-field'),
                controller: _controller,
                label: strings.declineReasonTitle,
                hint: strings.declineReasonHint,
                hasError: _error != null,
                errorText: _error,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              context.addVerticalSpace(20),
              AppPrimaryButton(
                key: const Key('decline-submit'),
                label: strings.submitDecline,
                prominent: true,
                onPressed: _submit,
              ),
              context.addVerticalSpace(8),
            ],
          ),
        ),
      ),
    );
  }
}
