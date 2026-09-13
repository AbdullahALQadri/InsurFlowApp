import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';
import 'package:insurflow/features/claims/presentation/widgets/document_illustration.dart';

class DocumentPreviewArgs {
  const DocumentPreviewArgs({
    required this.claimId,
    required this.type,
    this.source,
    this.imagePath,
  });

  final String claimId;
  final ClaimDocumentType type;
  final DocumentSource? source;
  final String? imagePath;
}

class DocumentPreviewScreen extends StatefulWidget {
  const DocumentPreviewScreen({
    super.key,
    required this.args,
    this.preview,
    this.onConfirm,
    this.onRetake,
  });

  final DocumentPreviewArgs args;
  final Widget? preview;
  final VoidCallback? onConfirm;
  final VoidCallback? onRetake;

  static const savedHold = Duration(milliseconds: 1100);

  static Future<dynamic> open(
    BuildContext context, {
    required String claimId,
    required ClaimDocumentType type,
    DocumentSource? source,
    String? imagePath,
  }) {
    return context.pushNamed(
      Routes.documentPreviewScreen,
      arguments: DocumentPreviewArgs(
        claimId: claimId,
        type: type,
        source: source,
        imagePath: imagePath,
      ),
    );
  }

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  var _saved = false;

  Future<void> _confirm() async {
    if (_saved) return;
    setState(() => _saved = true);
    widget.onConfirm?.call();
    if (widget.onConfirm != null) return;
    await Future<void>.delayed(DocumentPreviewScreen.savedHold);
    if (!mounted) return;
    // TODO(api): Waiting for the Backend document upload endpoint.
    // Confirming only stores the document locally until Postman
    // exposes a reliable multipart contract.
    Navigator.of(context).pop(true);
  }

  void _retake() {
    if (_saved) return;
    if (widget.onRetake != null) {
      widget.onRetake!();
      return;
    }
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final type = widget.args.type;
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
        key: ValueKey('${widget.args.claimId}-${type.name}'),
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          foregroundColor: colors.textPrimaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: _saved ? null : () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: strings.cancel,
          ),
          title: Text(
            strings.reviewDocument,
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
                Text(
                  strings.claimDocumentLabel(type),
                  textAlign: TextAlign.center,
                  style: context.font22Bold?.copyWith(
                    color: colors.textPrimaryColor,
                    fontWeight: FontWeightHelper.semiBold,
                    height: 1.2,
                  ),
                ),
                if (!_saved) ...[
                  context.addVerticalSpace(8),
                  const _ReadyBadge(),
                ],
                context.addVerticalSpace(14),
                Expanded(
                  child: _DocumentStage(
                    type: type,
                    imagePath: widget.args.imagePath,
                    preview: widget.preview,
                    saved: _saved,
                    savedLabel: strings.documentSaved(type),
                  ),
                ),
                if (!_saved) ...[
                  context.addVerticalSpace(10),
                  Text(
                    strings.capturedToday,
                    textAlign: TextAlign.center,
                    style: context.font14Regular?.copyWith(
                      color: colors.textSecondaryColor,
                      fontWeight: FontWeightHelper.medium,
                    ),
                  ),
                  context.addVerticalSpace(14),
                  AppOutlinedButton(
                    key: const Key('document-retake'),
                    label: strings.retake,
                    onPressed: _retake,
                  ),
                  context.addVerticalSpace(10),
                  AppPrimaryButton(
                    key: const Key('document-confirm'),
                    label: strings.confirm,
                    prominent: true,
                    onPressed: _confirm,
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

class _ReadyBadge extends StatelessWidget {
  const _ReadyBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Align(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primaryColor.changeOpacity(0.12),
          borderRadius: context.circularRadius(100),
          border: Border.all(color: colors.primaryColor.changeOpacity(0.28)),
        ),
        child: Padding(
          padding: context.spaceSymmetric(vertical: 4, horizontal: 12),
          child: Text(
            strings.readyToSave,
            style: context.font14Bold?.copyWith(
              color: colors.primaryColor,
              fontWeight: FontWeightHelper.semiBold,
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentStage extends StatelessWidget {
  const _DocumentStage({
    required this.type,
    required this.saved,
    required this.savedLabel,
    this.imagePath,
    this.preview,
  });

  final ClaimDocumentType type;
  final String? imagePath;
  final Widget? preview;
  final bool saved;
  final String savedLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: context.circularRadius(20),
        border: Border.all(color: colors.borderColor.changeOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimaryColor.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: Offset(0, context.height(6)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: context.circularRadius(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              key: const Key('document-preview-zoom'),
              minScale: 1,
              maxScale: 4.2,
              panEnabled: true,
              child: SizedBox.expand(
                child:
                    preview ?? _CapturedDocument(type: type, path: imagePath),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              switchInCurve: Curves.easeOutCubic,
              child: saved
                  ? ColoredBox(
                      key: const ValueKey('document-saved'),
                      color: colors.backgroundColor.changeOpacity(0.72),
                      child: _SavedMark(label: savedLabel),
                    )
                  : const SizedBox.expand(key: ValueKey('document-live')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapturedDocument extends StatelessWidget {
  const _CapturedDocument({required this.type, this.path});

  final ClaimDocumentType type;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final filePath = path;
    if (filePath != null && filePath.isNotEmpty) {
      return Image.file(
        File(filePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _Placeholder(type: type);
        },
      );
    }
    return _Placeholder(type: type);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.type});

  final ClaimDocumentType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ColoredBox(
      color: colors.iconBackgroundColor,
      child: Padding(
        padding: context.spaceSymmetric(vertical: 36, horizontal: 28),
        child: DocumentIllustration(
          type: type,
          accent: colors.primaryColor,
          muted: colors.borderColor,
          fill: colors.cardColor,
          surface: colors.backgroundColor,
        ),
      ),
    );
  }
}

class _SavedMark extends StatelessWidget {
  const _SavedMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final success = ClaimStatusColors.submitted;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
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
                BoxShadow(color: success.changeOpacity(0.28), blurRadius: 18),
              ],
            ),
            child: Padding(
              padding: context.spaceSymmetric(vertical: 14, horizontal: 14),
              child: Icon(
                Icons.check_rounded,
                color: colors.cardColor,
                size: context.width(32),
              ),
            ),
          ),
          context.addVerticalSpace(14),
          Padding(
            padding: context.spaceHorizontal(16),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.font18Bold?.copyWith(
                color: colors.textPrimaryColor,
                fontWeight: FontWeightHelper.semiBold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
