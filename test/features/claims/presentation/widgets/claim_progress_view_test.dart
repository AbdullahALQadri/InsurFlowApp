import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/inspection_progress_store.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_progress_view.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  setUp(() {
    InspectionProgressStore.instance.reset();
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
      home: Scaffold(body: child),
    );
  }

  testWidgets('shows claim progress, current step, and remaining work', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(ClaimProgressView(claim: testClaim(status: ClaimStatus.inProgress))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('CLM-0001'), findsOneWidget);
    expect(find.text('IN PROGRESS'), findsOneWidget);
    expect(
      find.text('Start with vehicle identification to continue.'),
      findsOneWidget,
    );
    expect(find.text('0 of 7 completed'), findsOneWidget);

    expect(find.text('Vehicle'), findsOneWidget);
    expect(find.text('Accident'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Evidence'), findsOneWidget);
    expect(find.text('Signature'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Submission'), findsOneWidget);

    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Assignment'), findsNothing);
  });
}
