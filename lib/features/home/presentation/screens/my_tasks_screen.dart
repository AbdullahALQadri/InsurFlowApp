import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/home/data/home_mock_data.dart';
import 'package:insurflow/features/home/presentation/widgets/claim_list_card.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tasks = HomeMockData.claims(DateTime.now())
        .where((claim) => claim.status != ClaimStatus.submitted)
        .toList();

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: context.spaceSymmetric(vertical: 16, horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Tasks',
                      style: context.font26Bold?.copyWith(
                        color: AppSplashColors.navy,
                        fontWeight: FontWeightHelper.bold,
                      ),
                    ),
                    context.addVerticalSpace(6),
                    Text(
                      '${tasks.length} assignments on your plate.',
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
                  return ClaimListCard(
                    claim: claim,
                    onViewClaim: () {},
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: context.addVerticalSpace(24)),
          ],
        ),
      ),
    );
  }
}
