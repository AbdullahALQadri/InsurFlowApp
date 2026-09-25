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
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/presentation/screens/customer_signature_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/evidence_camera_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/evidence_complete_view.dart';
import 'package:insurflow/features/claims/presentation/widgets/evidence_photo_card.dart';
import 'package:insurflow/features/claims/presentation/widgets/inspection_step_track.dart';

class VehicleEvidenceArgs {
  const VehicleEvidenceArgs({required this.claimId});

  final String claimId;
}

class VehicleEvidenceScreen extends StatefulWidget {
  const VehicleEvidenceScreen({
    super.key,
    required this.args,
    this.initial,
    this.onAddPhoto,
    this.onContinue,
  });

  final VehicleEvidenceArgs args;
  final VehicleEvidence? initial;
  final ValueChanged<EvidenceCategory>? onAddPhoto;
  final ValueChanged<VehicleEvidence>? onContinue;

  static const evidenceWorkStep = 4;

  static Future<dynamic> open(BuildContext context, {required String claimId}) {
    return context.pushNamed(
      Routes.vehicleEvidenceScreen,
      arguments: VehicleEvidenceArgs(claimId: claimId),
    );
  }

  @override
  State<VehicleEvidenceScreen> createState() => _VehicleEvidenceScreenState();
}

class _VehicleEvidenceScreenState extends State<VehicleEvidenceScreen> {
  late VehicleEvidence _evidence;

  @override
  void initState() {
    super.initState();
    _evidence =
        widget.initial ??
        VehicleEvidence.checklist(claimId: widget.args.claimId);
  }

  Future<void> _addPhoto(EvidenceCategory category) async {
    if (widget.onAddPhoto != null) {
      widget.onAddPhoto!(category);
      setState(() => _evidence = _evidence.withCaptured(category));
      return;
    }

    final captured = await EvidenceCameraScreen.open(
      context,
      claimId: widget.args.claimId,
      category: category,
    );
    if (!mounted || captured != true) return;
    setState(() => _evidence = _evidence.withCaptured(category));
  }

  void _continue() {
    if (!_evidence.canContinue) return;
    if (widget.onContinue != null) {
      widget.onContinue!(_evidence);
      return;
    }
    InspectionProgress.complete(widget.args.claimId, InspectionStepId.evidence);
    // Documents had no backend endpoint, so evidence now leads
    // straight to the customer signature.
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
            strings.vehicleEvidence,
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _evidence.canContinue
                        ? _CompleteBody(
                            key: const Key('evidence-complete'),
                            evidence: _evidence,
                          )
                        : _CollectionBody(
                            key: const Key('evidence-collection'),
                            evidence: _evidence,
                            onAddPhoto: _addPhoto,
                          ),
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
                    key: const Key('evidence-continue'),
                    label: _evidence.canContinue
                        ? strings.continueToDocuments
                        : strings.continueAction,
                    prominent: true,
                    onPressed: _evidence.canContinue ? _continue : null,
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

class _CollectionBody extends StatelessWidget {
  const _CollectionBody({
    super.key,
    required this.evidence,
    required this.onAddPhoto,
  });

  final VehicleEvidence evidence;
  final ValueChanged<EvidenceCategory> onAddPhoto;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              context.addVerticalSpace(4),
              Text(
                strings.inspectionStepIndicator(
                  VehicleEvidenceScreen.evidenceWorkStep,
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
                step: VehicleEvidenceScreen.evidenceWorkStep,
              ),
              context.addVerticalSpace(14),
              Text(
                strings.vehicleEvidenceSubtitle,
                style: context.font16Regular?.copyWith(
                  color: colors.textSecondaryColor,
                  height: 1.4,
                ),
              ),
              context.addVerticalSpace(16),
              _EvidenceProgress(
                completed: evidence.completedCount,
                total: evidence.totalCount,
                remaining: evidence.remainingRequiredCount,
              ),
              context.addVerticalSpace(16),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: _EvidenceGrid(evidence: evidence, onAddPhoto: onAddPhoto),
        ),
        SliverToBoxAdapter(child: context.addVerticalSpace(16)),
      ],
    );
  }
}

class _CompleteBody extends StatelessWidget {
  const _CompleteBody({super.key, required this.evidence});

  final VehicleEvidence evidence;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              context.addVerticalSpace(4),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  strings.inspectionStepIndicator(
                    VehicleEvidenceScreen.evidenceWorkStep,
                    InspectionProgress.totalCount,
                  ),
                  style: context.font14Regular?.copyWith(
                    color: colors.primaryColor,
                    fontWeight: FontWeightHelper.medium,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              context.addVerticalSpace(6),
              const InspectionStepTrack(
                step: VehicleEvidenceScreen.evidenceWorkStep,
              ),
              context.addVerticalSpace(20),
              EvidenceCompleteView(evidence: evidence),
              context.addVerticalSpace(16),
            ],
          ),
        ),
      ],
    );
  }
}

class _EvidenceProgress extends StatelessWidget {
  const _EvidenceProgress({
    required this.completed,
    required this.total,
    required this.remaining,
  });

  final int completed;
  final int total;
  final int remaining;

  static const _trackHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final factor = total == 0 ? 0.0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.fact_check_outlined,
              size: context.width(18),
              color: colors.primaryColor,
            ),
            context.addHorizontalSpace(8),
            Expanded(
              child: Text(
                strings.evidenceProgressCount(completed, total),
                style: context.font16Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                ),
              ),
            ),
          ],
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
        context.addVerticalSpace(8),
        Text(
          remaining == 0
              ? strings.allRequiredPhotosCaptured
              : strings.requiredPhotosRemaining(remaining),
          style: context.font14Regular?.copyWith(
            color: colors.textSecondaryColor,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _EvidenceGrid extends StatelessWidget {
  const _EvidenceGrid({required this.evidence, required this.onAddPhoto});

  final VehicleEvidence evidence;
  final ValueChanged<EvidenceCategory> onAddPhoto;

  @override
  Widget build(BuildContext context) {
    final slots = evidence.slots;
    final cardHeight = context.isSmallScreen
        ? context.height(188)
        : context.height(204);
    final sceneHeight = context.isSmallScreen
        ? context.height(176)
        : context.height(188);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = context.width(12);
        final tileWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: context.height(12),
          children: [
            for (var i = 0; i < slots.length; i++)
              SizedBox(
                width: i == slots.length - 1 ? constraints.maxWidth : tileWidth,
                height: i == slots.length - 1 ? sceneHeight : cardHeight,
                child: EvidencePhotoCard(
                  slot: slots[i],
                  wide: i == slots.length - 1,
                  onAddPhoto: () => onAddPhoto(slots[i].category),
                ),
              ),
          ],
        );
      },
    );
  }
}
