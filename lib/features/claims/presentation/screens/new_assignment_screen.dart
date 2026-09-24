import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/api_state_views.dart';
import 'package:insurflow/core/global/design_system/widgets/app_outlined_button.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/presentation/bloc/claim_details_bloc.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_details_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/assignment_header.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_detail_sections.dart';

class NewAssignmentScreen extends StatelessWidget {
  const NewAssignmentScreen({super.key, required this.claimId});

  final String claimId;

  static Future<dynamic> open(BuildContext context, {required String claimId}) {
    return context.pushNamed(Routes.newAssignmentScreen, arguments: claimId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AppDependencies.instance.createClaimDetailsBloc()
            ..add(ClaimDetailsRequested(claimId)),
      child: const _NewAssignmentView(),
    );
  }
}

class _NewAssignmentView extends StatelessWidget {
  const _NewAssignmentView();

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
        backgroundColor: colors.backgroundColor,
        body: BlocBuilder<ClaimDetailsBloc, ClaimDetailsState>(
          builder: (context, state) {
            if (state is ClaimDetailsLoadInProgress ||
                state is ClaimDetailsInitial) {
              return ApiLoadingView(message: strings.loadingAssignments);
            }
            if (state is ClaimDetailsLoadFailure) {
              return ApiErrorView(
                message: strings.messageFor(state.failure),
                onRetry: () => context.read<ClaimDetailsBloc>().add(
                  ClaimDetailsRequested(
                    (context
                            .findAncestorWidgetOfExactType<
                              NewAssignmentScreen
                            >())!
                        .claimId,
                  ),
                ),
              );
            }

            final claim = switch (state) {
              ClaimDetailsLoadSuccess(:final claim) => claim,
              ClaimDetailsStarted(:final claim) => claim,
              _ => null,
            };
            if (claim == null) {
              return ApiEmptyView(message: strings.noAssignments);
            }
            return _AssignmentBody(claim: claim);
          },
        ),
      ),
    );
  }
}

class _AssignmentBody extends StatelessWidget {
  const _AssignmentBody({required this.claim});

  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AssignmentHeader(claim: claim),
                Padding(
                  padding: context.spaceSymmetric(vertical: 20, horizontal: 20),
                  child: ClaimDetailSections(claim: claim),
                ),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.cardColor,
            border: Border(top: BorderSide(color: colors.borderColor)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: context.spaceSymmetric(vertical: 12, horizontal: 20),
              child: Column(
                children: [
                  AppPrimaryButton(
                    label: strings.viewClaim,
                    onPressed: () {
                      ClaimDetailsScreen.open(context, claimId: claim.id);
                    },
                  ),
                  context.addVerticalSpace(8),
                  AppOutlinedButton(
                    label: strings.later,
                    onPressed: () {
                      if (Navigator.of(context).canPop()) context.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
