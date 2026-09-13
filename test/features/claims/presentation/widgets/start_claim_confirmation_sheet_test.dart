import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/presentation/bloc/claim_details_bloc.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_status_transition_badge.dart';
import 'package:insurflow/features/claims/presentation/widgets/start_claim_confirmation_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockClaimDetailsBloc
    extends MockBloc<ClaimDetailsEvent, ClaimDetailsState>
    implements ClaimDetailsBloc {}

void main() {
  late _MockClaimDetailsBloc bloc;

  setUp(() {
    bloc = _MockClaimDetailsBloc();
    whenListen(
      bloc,
      const Stream<ClaimDetailsState>.empty(),
      initialState: ClaimDetailsLoadSuccess(testClaim()),
    );
  });

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        AppStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: BlocProvider<ClaimDetailsBloc>.value(
        value: bloc,
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('confirmation sheet shows inspection copy and claim details', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const StartClaimConfirmationSheet(
          claimNumber: 'CLM-0001',
          vehicle: 'Toyota Corolla',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Start Field Inspection?'), findsOneWidget);
    expect(find.text('Claim'), findsOneWidget);
    expect(find.text('CLM-0001'), findsOneWidget);
    expect(find.text('Vehicle'), findsOneWidget);
    expect(find.text('Toyota Corolla'), findsOneWidget);
    expect(
      find.text(
        "Once you start, you'll begin documenting the vehicle, accident, location and evidence.",
      ),
      findsOneWidget,
    );
    expect(find.text('Start Inspection'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Start Inspection requests claim start', (tester) async {
    await tester.pumpWidget(
      wrap(
        const StartClaimConfirmationSheet(
          claimNumber: 'CLM-0001',
          vehicle: 'Toyota Corolla',
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Start Inspection'));
    await tester.pump();

    verify(() => bloc.add(const ClaimStartRequested())).called(1);
  });

  testWidgets('status badge hands off from ASSIGNED to IN PROGRESS', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const ClaimStatusTransitionBadge(status: ClaimStatus.assigned)),
    );
    await tester.pump();
    expect(find.text('ASSIGNED'), findsOneWidget);

    await tester.pumpWidget(
      wrap(const ClaimStatusTransitionBadge(status: ClaimStatus.inProgress)),
    );
    await tester.pump();

    expect(find.text('ASSIGNED'), findsOneWidget);
    expect(find.text('IN PROGRESS'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();

    expect(find.text('ASSIGNED'), findsNothing);
    expect(find.text('IN PROGRESS'), findsOneWidget);
  });
}
