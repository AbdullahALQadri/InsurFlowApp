import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/api_state_views.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:insurflow/features/claims/domain/claim_preview.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/presentation/bloc/claims_bloc.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_details_screen.dart';
import 'package:insurflow/features/home/presentation/widgets/active_inspection_card.dart';
import 'package:insurflow/features/home/presentation/widgets/claim_filter_bar.dart';
import 'package:insurflow/features/home/presentation/widgets/claim_list_card.dart';
import 'package:insurflow/features/home/presentation/widgets/home_header.dart';
import 'package:insurflow/features/home/presentation/widgets/needs_attention_card.dart';
import 'package:insurflow/features/home/presentation/widgets/new_assignment_banner.dart';
import 'package:insurflow/features/home/presentation/widgets/today_task_metrics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onAvatarTap});

  final VoidCallback? onAvatarTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ClaimStatus? _filter;

  String _greeting(AppStrings strings) {
    final hour = DateTime.now().hour;
    if (hour < 12) return strings.goodMorning;
    if (hour < 17) return strings.goodAfternoon;
    return strings.goodEvening;
  }

  List<Claim> _claimsOf(ClaimsState state) {
    return switch (state) {
      ClaimsLoadSuccess(:final claims) => claims,
      ClaimsRefreshInProgress(:final claims) => claims,
      _ => const <Claim>[],
    };
  }

  int _count(List<Claim> claims, ClaimStatus status) =>
      claims.where((claim) => claim.status == status).length;

  ClaimPreview? _attentionClaim(List<Claim> claims) {
    try {
      return claims
          .firstWhere((claim) => claim.status == ClaimStatus.correctionRequired)
          .toPreview();
    } catch (_) {
      return null;
    }
  }

  List<ClaimPreview> _filteredClaims(List<Claim> claims) {
    final attentionId = _attentionClaim(claims)?.id;
    return claims
        .where((claim) {
          if (_filter == null && claim.id == attentionId) {
            return false;
          }
          if (_filter == null) return true;
          return claim.status == _filter;
        })
        .map((claim) => claim.toPreview())
        .toList();
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<ClaimsBloc>();
    bloc.add(const ClaimsRefreshed());
    await bloc.stream.firstWhere(
      (state) =>
          state is ClaimsLoadSuccess ||
          state is ClaimsLoadEmpty ||
          state is ClaimsLoadFailure,
    );
  }

  Future<void> _openClaim(ClaimPreview claim) async {
    await ClaimDetailsScreen.open(context, claimId: claim.id);
    if (!mounted) return;
    context.read<ClaimsBloc>().add(const ClaimsRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final overlay = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.backgroundColor,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        body: SafeArea(
          child: BlocBuilder<ClaimsBloc, ClaimsState>(
            builder: (context, state) {
              if (state is ClaimsLoadInProgress || state is ClaimsInitial) {
                return ApiLoadingView(message: strings.loadingAssignments);
              }
              if (state is ClaimsLoadFailure) {
                return ApiErrorView(
                  message: strings.messageFor(state.failure),
                  onRetry: () =>
                      context.read<ClaimsBloc>().add(const ClaimsRequested()),
                );
              }

              final claims = _claimsOf(state);
              final attention = _attentionClaim(claims);
              final newAssignment = claims.cast<Claim?>().firstWhere(
                (c) => c?.status == ClaimStatus.assigned,
                orElse: () => null,
              );
              final activeInspection = claims.cast<Claim?>().firstWhere(
                (c) => c?.status == ClaimStatus.inProgress,
                orElse: () => null,
              );
              final filtered = _filteredClaims(claims);
              final authState = context.watch<AuthBloc>().state;
              final adjusterName = authState is AuthAuthenticated
                  ? authState.session.greetingName(
                      fallback: strings.fieldAdjuster,
                    )
                  : strings.fieldAdjuster;

              return RefreshIndicator(
                color: colors.primaryColor,
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: context.spaceSymmetric(
                        vertical: 8,
                        horizontal: 20,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: HomeHeader(
                          greeting: _greeting(strings),
                          adjusterName: adjusterName,
                          subtitle: strings.homeSubtitle,
                          onAvatarTap: widget.onAvatarTap,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: context.spaceSymmetric(
                        vertical: 8,
                        horizontal: 20,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: TodayTaskMetrics(
                          assigned: _count(claims, ClaimStatus.assigned),
                          inProgress: _count(claims, ClaimStatus.inProgress),
                          correctionRequired: _count(
                            claims,
                            ClaimStatus.correctionRequired,
                          ),
                          submitted: _count(claims, ClaimStatus.submitted),
                          onMetricTap: (status) {
                            setState(() => _filter = status);
                          },
                        ),
                      ),
                    ),
                    if (newAssignment != null)
                      SliverPadding(
                        padding: context.spaceSymmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: NewAssignmentBanner(
                            claim: newAssignment,
                            onViewClaim: () => _openClaim(newAssignment.toPreview()),
                          ),
                        ),
                      ),
                    if (activeInspection != null)
                      SliverPadding(
                        padding: context.spaceSymmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: ActiveInspectionCard(
                            claim: activeInspection,
                            onContinue: () => _openClaim(activeInspection.toPreview()),
                          ),
                        ),
                      ),
                    if (attention != null)
                      SliverPadding(
                        padding: context.spaceSymmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: NeedsAttentionCard(
                            claim: attention,
                            onFixClaim: () => _openClaim(attention),
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: context.spaceSymmetric(
                        vertical: 8,
                        horizontal: 20,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.myClaims,
                              style: context.font18Bold?.copyWith(
                                color: colors.textPrimaryColor,
                                fontWeight: FontWeightHelper.semiBold,
                              ),
                            ),
                            context.addVerticalSpace(12),
                            ClaimFilterBar(
                              selected: _filter,
                              onSelected: (status) {
                                setState(() => _filter = status);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (state is ClaimsLoadEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: ApiEmptyView(message: strings.noAssignments),
                      )
                    else if (filtered.isEmpty)
                      SliverPadding(
                        padding: context.spaceSymmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            strings.noClaimsInStatus,
                            textAlign: TextAlign.center,
                            style: context.font14Regular?.copyWith(
                              color: colors.textSecondaryColor,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: context.spaceHorizontal(20),
                        sliver: SliverList.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              context.addVerticalSpace(12),
                          itemBuilder: (context, index) {
                            final claim = filtered[index];
                            return ClaimListCard(
                              claim: claim,
                              onViewClaim: () => _openClaim(claim),
                            );
                          },
                        ),
                      ),
                    SliverToBoxAdapter(child: context.addVerticalSpace(24)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
