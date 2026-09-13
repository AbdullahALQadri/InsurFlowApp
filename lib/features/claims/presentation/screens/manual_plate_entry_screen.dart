import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/license_plate_format.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_lookup_screen.dart';
import 'package:insurflow/features/claims/presentation/utils/license_plate_input_formatter.dart';
import 'package:insurflow/features/claims/presentation/widgets/stylized_license_plate.dart';

class ManualPlateEntryArgs {
  const ManualPlateEntryArgs({required this.claimId, this.initialPlate});

  final String claimId;
  final String? initialPlate;
}

class ManualPlateEntryScreen extends StatefulWidget {
  const ManualPlateEntryScreen({super.key, required this.args, this.onConfirm});

  final ManualPlateEntryArgs args;
  final ValueChanged<String>? onConfirm;

  static Future<dynamic> open(
    BuildContext context, {
    required String claimId,
    String? initialPlate,
  }) {
    return context.pushNamed(
      Routes.manualPlateEntryScreen,
      arguments: ManualPlateEntryArgs(
        claimId: claimId,
        initialPlate: initialPlate,
      ),
    );
  }

  @override
  State<ManualPlateEntryScreen> createState() => _ManualPlateEntryScreenState();
}

class _ManualPlateEntryScreenState extends State<ManualPlateEntryScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  var _submitted = false;

  @override
  void initState() {
    super.initState();
    final initial = LicensePlateFormat.display(widget.args.initialPlate ?? '');
    _controller = TextEditingController(text: initial);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _plate => LicensePlateFormat.display(_controller.text);

  bool get _isValid => LicensePlateFormat.isValid(_plate);

  bool get _showError => _submitted && !_isValid;

  void _onChanged(String _) {
    setState(() {});
  }

  void _confirm() {
    setState(() => _submitted = true);
    if (!_isValid) return;
    final plate = _plate;
    if (widget.onConfirm != null) {
      widget.onConfirm!(plate);
      return;
    }
    VehicleLookupScreen.open(
      context,
      claimId: widget.args.claimId,
      plateNumber: plate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.cardColor,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        key: ValueKey(widget.args.claimId),
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          foregroundColor: colors.textPrimaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            strings.enterLicensePlate,
            style: context.font18Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.semiBold,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                strings.enterLicensePlateSubtitle,
                                textAlign: TextAlign.center,
                                style: context.font16Regular?.copyWith(
                                  color: colors.textSecondaryColor,
                                  height: 1.45,
                                ),
                              ),
                              context.addVerticalSpace(28),
                              StylizedLicensePlate(
                                plateNumber: _plate.isEmpty
                                    ? LicensePlateFormat.example
                                    : _plate,
                                height: context.height(64),
                                muted: _plate.isEmpty,
                              ),
                              context.addVerticalSpace(28),
                              _PlateNumberField(
                                controller: _controller,
                                focusNode: _focusNode,
                                hint: strings.licensePlateHint,
                                isValid: _isValid,
                                hasError: _showError,
                                onChanged: _onChanged,
                                onSubmitted: (_) => _confirm(),
                              ),
                              context.addVerticalSpace(14),
                              _ValidationMessage(
                                isValid: _isValid,
                                showError: _showError,
                                validLabel: strings.validPlateFormat,
                                errorLabel: strings.invalidLicensePlate,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppPrimaryButton(
                  label: strings.confirmPlate,
                  prominent: true,
                  onPressed: _confirm,
                ),
                context.addVerticalSpace(8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlateNumberField extends StatelessWidget {
  const _PlateNumberField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.isValid,
    required this.hasError,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool isValid;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.circularRadius(16);
    final borderColor = hasError
        ? colors.inputErrorBorderColor
        : isValid
        ? ClaimStatusColors.approved
        : colors.inputBorderColor;

    return TextField(
      key: const Key('manual-plate-input'),
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: const [LicensePlateInputFormatter()],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      cursorColor: colors.primaryColor,
      style: context.font28Bold?.copyWith(
        color: colors.textPrimaryColor,
        fontWeight: FontWeightHelper.bold,
        letterSpacing: 4.2,
        height: 1.1,
        fontSize: context.width(28),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.font28Bold?.copyWith(
          color: colors.textSecondaryColor,
          fontWeight: FontWeightHelper.bold,
          letterSpacing: 4.2,
          height: 1.1,
          fontSize: context.width(28),
        ),
        filled: true,
        fillColor: colors.cardColor,
        counterText: '',
        errorText: null,
        contentPadding: context.spaceSymmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: hasError
                ? colors.inputErrorBorderColor
                : isValid
                ? ClaimStatusColors.approved
                : colors.inputFocusedBorderColor,
            width: 1.6,
          ),
        ),
      ),
    );
  }
}

class _ValidationMessage extends StatelessWidget {
  const _ValidationMessage({
    required this.isValid,
    required this.showError,
    required this.validLabel,
    required this.errorLabel,
  });

  final bool isValid;
  final bool showError;
  final String validLabel;
  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isValid) {
      return Text(
        validLabel,
        textAlign: TextAlign.center,
        style: context.font14Bold?.copyWith(
          color: ClaimStatusColors.approved,
          fontWeight: FontWeightHelper.semiBold,
        ),
      );
    }

    if (showError) {
      return Text(
        errorLabel,
        textAlign: TextAlign.center,
        style: context.font14Regular?.copyWith(
          color: colors.inputErrorBorderColor,
          height: 1.35,
        ),
      );
    }

    return SizedBox(height: context.height(20));
  }
}
