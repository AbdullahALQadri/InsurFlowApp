import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/presentation/widgets/evidence_category_preview.dart';

class EvidencePhotoPreviewArgs {
  const EvidencePhotoPreviewArgs({
    required this.claimId,
    required this.category,
    this.imagePath,
  });

  final String claimId;
  final EvidenceCategory category;
  final String? imagePath;
}

class EvidencePhotoPreviewScreen extends StatefulWidget {
  const EvidencePhotoPreviewScreen({
    super.key,
    required this.args,
    this.photo,
    this.onUsePhoto,
    this.onRetake,
  });

  final EvidencePhotoPreviewArgs args;
  final Widget? photo;
  final VoidCallback? onUsePhoto;
  final VoidCallback? onRetake;

  static const savedHold = Duration(milliseconds: 1100);

  static Future<dynamic> open(
    BuildContext context, {
    required String claimId,
    required EvidenceCategory category,
    String? imagePath,
  }) {
    return context.pushNamed(
      Routes.evidencePhotoPreviewScreen,
      arguments: EvidencePhotoPreviewArgs(
        claimId: claimId,
        category: category,
        imagePath: imagePath,
      ),
    );
  }

  @override
  State<EvidencePhotoPreviewScreen> createState() =>
      _EvidencePhotoPreviewScreenState();
}

class _EvidencePhotoPreviewScreenState
    extends State<EvidencePhotoPreviewScreen> {
  var _saved = false;

  Future<void> _usePhoto() async {
    if (_saved) return;
    setState(() => _saved = true);
    widget.onUsePhoto?.call();
    if (widget.onUsePhoto != null) return;
    await Future<void>.delayed(EvidencePhotoPreviewScreen.savedHold);
    if (!mounted) return;
    // TODO(api): Waiting for the Backend evidence upload endpoint.
    // Confirming the photo only stores it locally until Postman
    // exposes a reliable multipart contract.
    Navigator.of(context).pop(true);
  }

  void _retake() {
    if (_saved) return;
    if (widget.onRetake != null) {
      widget.onRetake!();
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final category = widget.args.category;
    const overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppSplashColors.abyss,
      systemNavigationBarIconBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        key: ValueKey('${widget.args.claimId}-${category.name}'),
        backgroundColor: AppSplashColors.abyss,
        body: SafeArea(
          child: Padding(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  title: strings.evidenceCategoryLabel(category),
                  status: strings.readyToSave,
                  saved: _saved,
                  onBack: _saved ? null : () => context.pop(),
                ),
                context.addVerticalSpace(12),
                Expanded(
                  child: _PhotoStage(
                    category: category,
                    imagePath: widget.args.imagePath,
                    photo: widget.photo,
                    saved: _saved,
                    savedLabel: strings.evidencePhotoAdded(category),
                  ),
                ),
                if (!_saved) ...[
                  context.addVerticalSpace(10),
                  Text(
                    strings.capturedJustNow,
                    textAlign: TextAlign.center,
                    style: context.font14Regular?.copyWith(
                      color: AppSplashColors.textMuted,
                      fontWeight: FontWeightHelper.medium,
                    ),
                  ),
                  context.addVerticalSpace(14),
                  AppOutlinedButton(
                    key: const Key('evidence-retake'),
                    label: strings.retake,
                    onPressed: _retake,
                  ),
                  context.addVerticalSpace(10),
                  AppPrimaryButton(
                    key: const Key('evidence-use-photo'),
                    label: strings.usePhoto,
                    prominent: true,
                    onPressed: _usePhoto,
                  ),
                ] else
                  context.addVerticalSpace(24),
                context.addVerticalSpace(8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.status,
    required this.saved,
    required this.onBack,
  });

  final String title;
  final String status;
  final bool saved;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final accent = saved ? ClaimStatusColors.submitted : AppSplashColors.cyan;

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppSplashColors.textPrimary,
          tooltip: strings.cancel,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.font18Bold?.copyWith(
                  color: AppSplashColors.textPrimary,
                  fontWeight: FontWeightHelper.semiBold,
                ),
              ),
              if (!saved) ...[
                context.addVerticalSpace(6),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.changeOpacity(0.16),
                    borderRadius: context.circularRadius(100),
                    border: Border.all(color: accent.changeOpacity(0.35)),
                  ),
                  child: Padding(
                    padding: context.spaceSymmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    child: Text(
                      status,
                      style: context.font14Bold?.copyWith(
                        color: accent,
                        fontWeight: FontWeightHelper.semiBold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: context.width(48)),
      ],
    );
  }
}

class _PhotoStage extends StatelessWidget {
  const _PhotoStage({
    required this.category,
    required this.saved,
    required this.savedLabel,
    this.imagePath,
    this.photo,
  });

  final EvidenceCategory category;
  final String? imagePath;
  final Widget? photo;
  final bool saved;
  final String savedLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: context.circularRadius(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: AppSplashColors.navy,
            child: photo ?? _CapturedImage(path: imagePath, category: category),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutCubic,
            child: saved
                ? ColoredBox(
                    key: const ValueKey('evidence-saved'),
                    color: AppSplashColors.abyss.changeOpacity(0.55),
                    child: _SavedMark(label: savedLabel),
                  )
                : const SizedBox.expand(key: ValueKey('evidence-live')),
          ),
        ],
      ),
    );
  }
}

class _CapturedImage extends StatelessWidget {
  const _CapturedImage({required this.category, this.path});

  final EvidenceCategory category;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final filePath = path;
    if (filePath != null && filePath.isNotEmpty) {
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _Placeholder(category: category);
        },
      );
    }
    return _Placeholder(category: category);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.category});

  final EvidenceCategory category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.spaceSymmetric(vertical: 28, horizontal: 28),
      child: EvidenceCategoryPreview(
        category: category,
        accent: AppSplashColors.cyan,
        muted: AppSplashColors.line,
        fill: AppSplashColors.navy,
        plate: AppSplashColors.textPrimary,
        completed: false,
      ),
    );
  }
}

class _SavedMark extends StatelessWidget {
  const _SavedMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final success = ClaimStatusColors.submitted;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.86, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: success.changeOpacity(0.45), blurRadius: 22),
              ],
            ),
            child: Padding(
              padding: context.spaceSymmetric(vertical: 14, horizontal: 14),
              child: Icon(
                Icons.check_rounded,
                color: AppSplashColors.textPrimary,
                size: context.width(36),
              ),
            ),
          ),
          context.addVerticalSpace(16),
          Padding(
            padding: context.spaceHorizontal(16),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.font18Bold?.copyWith(
                color: AppSplashColors.textPrimary,
                fontWeight: FontWeightHelper.semiBold,
                height: 1.3,
                shadows: const [
                  Shadow(color: Color(0xCC000000), blurRadius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
