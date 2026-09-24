import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/api_state_views.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/presentation/bloc/claims_bloc.dart';
import 'package:insurflow/features/home/presentation/widgets/claim_list_card.dart';

/// My Tasks renders the adjuster's assignments from `GET /claims`
/// through [ClaimsBloc] — no local mock list.
class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  List<Claim> _claimsOf(ClaimsState state) {
    return switch (state) {
      ClaimsLoadSuccess(:final claims) => claims,
      ClaimsRefreshInProgress(:final claims) => claims,
      _ => const <Claim>[],
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Scaffold(
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

            final tasks = _claimsOf(state)
                .where((claim) => claim.status != ClaimStatus.submitted)
                .map((claim) => claim.toPreview())
                .toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: context.spaceSymmetric(vertical: 16, horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.myTasks,
                          style: context.font26Bold?.copyWith(
                            color: AppSplashColors.navy,
                            fontWeight: FontWeightHelper.bold,
                          ),
                        ),
                        context.addVerticalSpace(6),
                        Text(
                          strings.myTasksSubtitle(tasks.length),
                          style: context.font14Regular?.copyWith(
                            color: colors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: context.spaceHorizontal(20),
                  sliver: SliverList.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => context.addVerticalSpace(12),
                    itemBuilder: (context, index) {
                      final claim = tasks[index];
                      return ClaimListCard(claim: claim, onViewClaim: () {});
                    },
                  ),
                ),
                SliverToBoxAdapter(child: context.addVerticalSpace(24)),
              ],
            );
          },
        ),
      ),
    );
  }
}
