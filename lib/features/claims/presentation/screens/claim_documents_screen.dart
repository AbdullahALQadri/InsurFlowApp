import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/presentation/screens/customer_signature_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/document_preview_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_document_card.dart';
import 'package:insurflow/features/claims/presentation/widgets/document_source_sheet.dart';
import 'package:insurflow/features/claims/presentation/widgets/inspection_step_track.dart';

class ClaimDocumentsArgs {
  const ClaimDocumentsArgs({required this.claimId});

  final String claimId;
}

class ClaimDocumentsScreen extends StatefulWidget {
  const ClaimDocumentsScreen({
    super.key,
    required this.args,
    this.initial,
    this.onUpload,
    this.onContinue,
  });

  final ClaimDocumentsArgs args;
  final ClaimDocuments? initial;
  final void Function(ClaimDocumentType type, DocumentSource source)? onUpload;
  final ValueChanged<ClaimDocuments>? onContinue;

  static const documentsWorkStep = 5;

  static Future<dynamic> open(BuildContext context, {required String claimId}) {
    return context.pushNamed(
      Routes.claimDocumentsScreen,
      arguments: ClaimDocumentsArgs(claimId: claimId),
    );
  }

  @override
  State<ClaimDocumentsScreen> createState() => _ClaimDocumentsScreenState();
}

class _ClaimDocumentsScreenState extends State<ClaimDocumentsScreen> {
  late ClaimDocuments _documents;

  @override
  void initState() {
    super.initState();
    _documents =
        widget.initial ??
        ClaimDocuments.checklist(claimId: widget.args.claimId);
  }

  Future<void> _upload(ClaimDocumentType type) async {
    if (widget.onUpload != null) {
      widget.onUpload!(type, DocumentSource.files);
      setState(() => _documents = _documents.withUploaded(type));
      return;
    }

    while (mounted) {
      final source = await DocumentSourceSheet.show(context, type: type);
      if (!mounted || source == null) return;

      final confirmed = await DocumentPreviewScreen.open(
        context,
        claimId: widget.args.claimId,
        type: type,
        source: source,
      );
      if (!mounted) return;
      if (confirmed == true) {
        // TODO(api): Waiting for the Backend document upload endpoint.
        // Confirming only stores the document locally until Postman
        // exposes a reliable multipart contract. Do not invent an upload route.
        setState(
          () => _documents = _documents.withUploaded(type, source: source),
        );
        return;
      }
      if (confirmed != false) return;
    }
  }

  void _continue() {
    if (!_documents.canContinue) return;
    if (widget.onContinue != null) {
      widget.onContinue!(_documents);
      return;
    }
    InspectionProgress.complete(
      widget.args.claimId,
      InspectionStepId.documents,
    );
    CustomerSignatureScreen.open(context, claimId: widget.args.claimId);
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
            strings.documentsTitle,
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
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            context.addVerticalSpace(4),
                            Text(
                              strings.inspectionStepIndicator(
                                ClaimDocumentsScreen.documentsWorkStep,
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
                              step: ClaimDocumentsScreen.documentsWorkStep,
                            ),
                            context.addVerticalSpace(14),
                            Text(
                              strings.documentsSubtitle,
                              style: context.font16Regular?.copyWith(
                                color: colors.textSecondaryColor,
                                height: 1.4,
                              ),
                            ),
                            context.addVerticalSpace(16),
                            _DocumentsProgress(
                              completed: _documents.requiredUploadedCount,
                              total: _documents.requiredTotalCount,
                            ),
                            context.addVerticalSpace(16),
                          ],
                        ),
                      ),
                      SliverList.separated(
                        itemCount: _documents.slots.length,
                        separatorBuilder: (context, index) =>
                            context.addVerticalSpace(12),
                        itemBuilder: (context, index) {
                          final slot = _documents.slots[index];
                          return ClaimDocumentCard(
                            slot: slot,
                            onUpload: () => _upload(slot.type),
                          );
                        },
                      ),
                      SliverToBoxAdapter(child: context.addVerticalSpace(16)),
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
                  child: AppPrimaryButton(
                    key: const Key('documents-continue'),
                    label: strings.continueAction,
                    prominent: true,
                    onPressed: _documents.canContinue ? _continue : null,
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

class _DocumentsProgress extends StatelessWidget {
  const _DocumentsProgress({required this.completed, required this.total});

  final int completed;
  final int total;

  static const _trackHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final factor = total == 0 ? 0.0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.requiredDocumentsProgress(completed, total),
          style: context.font16Bold?.copyWith(
            color: colors.textPrimaryColor,
            fontWeight: FontWeightHelper.semiBold,
          ),
        ),
        context.addVerticalSpace(8),
        ClipRRect(
          borderRadius: context.circularRadius(100),
          child: SizedBox(
            width: double.infinity,
            height: context.height(_trackHeight),
            child: ColoredBox(
              color: colors.borderColor,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: factor),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: value.clamp(0, 1),
                    heightFactor: 1,
                    child: ColoredBox(color: colors.primaryColor),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
