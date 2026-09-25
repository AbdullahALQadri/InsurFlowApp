import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/customer_signature.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_review_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/customer_signature_pad.dart';
import 'package:insurflow/features/claims/presentation/widgets/inspection_step_track.dart';
import 'package:insurflow/features/claims/presentation/widgets/signature_pen_illustration.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/features/claims/domain/signature_image_encoder.dart';

class CustomerSignatureArgs {
  const CustomerSignatureArgs({required this.claimId});

  final String claimId;
}

class CustomerSignatureScreen extends StatefulWidget {
  const CustomerSignatureScreen({
    super.key,
    required this.args,
    this.onConfirm,
    this.onClear,
  });

  final CustomerSignatureArgs args;
  final ValueChanged<CustomerSignature>? onConfirm;
  final VoidCallback? onClear;

  static const signatureWorkStep = 6;

  static Future<dynamic> open(BuildContext context, {required String claimId}) {
    return context.pushNamed(
      Routes.customerSignatureScreen,
      arguments: CustomerSignatureArgs(claimId: claimId),
    );
  }

  @override
  State<CustomerSignatureScreen> createState() =>
      _CustomerSignatureScreenState();
}

class _CustomerSignatureScreenState extends State<CustomerSignatureScreen> {
  final _strokes = <List<Offset>>[];
  final _padKey = GlobalKey();
  var _isUploading = false;

  bool get _hasInk => _strokes.any((stroke) => stroke.length >= 2);

  void _startStroke(Offset point) {
    setState(() => _strokes.add([point]));
  }

  void _updateStroke(Offset point) {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.last.add(point));
  }

  void _endStroke() {
    if (_strokes.isEmpty) return;
    if (_strokes.last.length < 2) {
      setState(() => _strokes.removeLast());
    }
  }

  void _clear() {
    widget.onClear?.call();
    setState(() => _strokes.clear());
  }

  /// Renders what the customer actually drew and uploads it.
  ///
  /// `POST /claims/{id}/signature` takes a single multipart `file`, so
  /// the strokes are rasterised to a PNG first. The step is only marked
  /// complete once the backend has stored it.
  Future<void> _confirm() async {
    if (!_hasInk || _isUploading) return;

    final signature = CustomerSignature(
      claimId: widget.args.claimId,
    ).captured();
    if (widget.onConfirm != null) {
      widget.onConfirm!(signature);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final strings = AppStrings.of(context);
    final size = _padKey.currentContext?.size;
    if (size == null) return;

    setState(() => _isUploading = true);

    final path = await const SignatureImageEncoder().encodeToFile(
      strokes: _strokes,
      size: size,
      claimId: widget.args.claimId,
    );
    if (!mounted) return;

    if (path == null) {
      setState(() => _isUploading = false);
      messenger.showSnackBar(
        SnackBar(content: Text(strings.signatureUploadFailed)),
      );
      return;
    }

    final result = await AppDependencies.instance.uploadClaimSignatureUseCase(
      claimId: widget.args.claimId,
      filePath: path,
    );
    if (!mounted) return;
    setState(() => _isUploading = false);

    result.fold(
      (failure) => messenger.showSnackBar(
        SnackBar(content: Text(strings.messageFor(failure))),
      ),
      (_) {
        InspectionProgress.complete(
          widget.args.claimId,
          InspectionStepId.signature,
        );
        ClaimReviewScreen.open(context, claimId: widget.args.claimId);
      },
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
    final illustrationSize = context.isSmallScreen
        ? context.height(44)
        : context.height(52);

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
            strings.customerConfirmation,
            style: context.font18Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.semiBold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: context.spaceHorizontal(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      context.addVerticalSpace(4),
                      Text(
                        strings.inspectionStepIndicator(
                          CustomerSignatureScreen.signatureWorkStep,
                          InspectionProgress.totalCount,
                        ),
                        style: context.font14Regular?.copyWith(
                          color: colors.primaryColor,
                          fontWeight: FontWeightHelper.medium,
                          letterSpacing: 0.2,
                        ),
                      ),
                      context.addVerticalSpace(6),
                      const InspectionStepTrack(
                        step: CustomerSignatureScreen.signatureWorkStep,
                      ),
                      context.addVerticalSpace(12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: illustrationSize,
                            height: illustrationSize,
                            child: const SignaturePenIllustration(),
                          ),
                          context.addHorizontalSpace(12),
                          Expanded(
                            child: Text(
                              strings.customerSignatureSubtitle,
                              style: context.font16Regular?.copyWith(
                                color: colors.textSecondaryColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      context.addVerticalSpace(16),
                      Expanded(
                        child: CustomerSignaturePad(
                          key: _padKey,
                          strokes: List.unmodifiable(_strokes),
                          onStartStroke: _startStroke,
                          onUpdateStroke: _updateStroke,
                          onEndStroke: _endStroke,
                        ),
                      ),
                      context.addVerticalSpace(12),
                      Text(
                        strings.signatureConsent,
                        style: context.font14Regular?.copyWith(
                          color: colors.textSecondaryColor,
                          height: 1.4,
                        ),
                      ),
                      context.addVerticalSpace(8),
                    ],
                  ),
                ),
              ),
              Material(
                color: colors.cardColor,
                elevation: 8,
                shadowColor: colors.textPrimaryColor.withValues(alpha: 0.08),
                child: Padding(
                  padding: context.spaceSymmetric(vertical: 12, horizontal: 20),
                  child: Column(
                    children: [
                      AppOutlinedButton(
                        key: const Key('signature-clear'),
                        label: strings.clearSignature,
                        onPressed: (_hasInk && !_isUploading) ? _clear : null,
                      ),
                      context.addVerticalSpace(10),
                      AppPrimaryButton(
                        key: const Key('signature-confirm'),
                        label: strings.confirmSignature,
                        prominent: true,
                        isLoading: _isUploading,
                        onPressed: (_hasInk && !_isUploading) ? _confirm : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
