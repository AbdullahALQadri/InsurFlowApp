import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/api_state_views.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_preview.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/presentation/bloc/claims_bloc.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_details_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claims_empty_state.dart';
import 'package:insurflow/features/claims/presentation/widgets/claims_list_card.dart';
import 'package:insurflow/features/claims/presentation/widgets/claims_search_field.dart';
import 'package:insurflow/features/home/presentation/widgets/claim_filter_bar.dart';

class ClaimsListScreen extends StatefulWidget {
  const ClaimsListScreen({super.key});

  @override
  State<ClaimsListScreen> createState() => _ClaimsListScreenState();
}

class _ClaimsListScreenState extends State<ClaimsListScreen> {
  final _searchController = TextEditingController();
  ClaimStatus? _filter;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Claim> _claimsOf(ClaimsState state) {
    return switch (state) {
      ClaimsLoadSuccess(:final claims) => claims,
      ClaimsRefreshInProgress(:final claims) => claims,
      _ => const <Claim>[],
    };
  }

  List<ClaimPreview> _visibleClaims(List<Claim> claims) {
    final query = _query.trim().toLowerCase();
    final results =
        claims.map((claim) => claim.toPreview()).where((claim) {
          final matchesFilter = _filter == null || claim.status == _filter;
          if (!matchesFilter) return false;
          if (query.isEmpty) return true;
          return claim.displayNumber.toLowerCase().contains(query) ||
              claim.id.toLowerCase().contains(query) ||
              claim.vehicle.toLowerCase().contains(query) ||
              claim.licensePlate.toLowerCase().contains(query);
        }).toList()..sort((a, b) {
          final urgency = a.status.urgencyRank.compareTo(b.status.urgencyRank);
          if (urgency != 0) return urgency;
          return b.lastUpdated.compareTo(a.lastUpdated);
        });
    return results;
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
      systemNavigationBarColor: colors.cardColor,
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

              final visible = _visibleClaims(_claimsOf(state));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: context.spaceSymmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.myClaims,
                          style: context.font26Bold?.copyWith(
                            color: colors.textPrimaryColor,
                            fontWeight: FontWeightHelper.bold,
                          ),
                        ),
                        context.addVerticalSpace(6),
                        Text(
                          strings.assignmentsSubtitle,
                          style: context.font14Regular?.copyWith(
                            color: colors.textSecondaryColor,
                            height: 1.35,
                          ),
                        ),
                        context.addVerticalSpace(16),
                        ClaimsSearchField(
                          controller: _searchController,
                          hintText: strings.searchClaimsHint,
                          onChanged: (value) => setState(() => _query = value),
                        ),
                        context.addVerticalSpace(14),
                        ClaimFilterBar(
                          selected: _filter,
                          onSelected: (status) {
                            setState(() => _filter = status);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: colors.primaryColor,
                      onRefresh: _onRefresh,
                      child: state is ClaimsLoadEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: context.height(48)),
                                ClaimsEmptyState(
                                  title: strings.noAssignments,
                                  subtitle: strings.assignmentsSubtitle,
                                ),
                              ],
                            )
                          : visible.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: context.height(48)),
                                ClaimsEmptyState(
                                  title: strings.noClaimsFound,
                                  subtitle: strings.noClaimsFoundHint,
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                context.width(20),
                                context.height(8),
                                context.width(20),
                                context.height(16),
                              ),
                              itemCount: visible.length,
                              separatorBuilder: (_, __) =>
                                  context.addVerticalSpace(12),
                              itemBuilder: (context, index) {
                                final claim = visible[index];
                                return ClaimsListCard(
                                  claim: claim,
                                  onTap: () => _openClaim(claim),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
