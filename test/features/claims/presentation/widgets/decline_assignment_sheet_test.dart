import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/widgets/decline_assignment_sheet.dart';

void main() {
  Widget wrap(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  Future<String?> openSheet(WidgetTester tester, {Locale? locale}) async {
    String? result;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await DeclineAssignmentSheet.show(context);
            },
            child: const Text('open'),
          ),
        ),
        locale: locale ?? const Locale('en'),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('an empty reason is rejected and the sheet stays open', (
    tester,
  ) async {
    await openSheet(tester);

    await tester.tap(find.byKey(const Key('decline-submit')));
    await tester.pumpAndSettle();

    // The backend answers 400 without a reason, so the request is never
    // spent: the sheet is still up and the field reports the problem.
    expect(find.byKey(const Key('decline-reason-field')), findsOneWidget);
    expect(find.text('Please enter a reason.'), findsOneWidget);
  });

  testWidgets('whitespace alone does not count as a reason', (tester) async {
    await openSheet(tester);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('decline-reason-field')),
        matching: find.byType(TextField),
      ),
      '    ',
    );
    await tester.tap(find.byKey(const Key('decline-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('decline-reason-field')), findsOneWidget);
  });

  testWidgets('a typed reason is returned to the caller verbatim', (
    tester,
  ) async {
    const reason = 'Outside my current operational sector or vehicle issue';
    String? returned;

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              returned = await DeclineAssignmentSheet.show(context);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('decline-reason-field')),
        matching: find.byType(TextField),
      ),
      reason,
    );
    await tester.tap(find.byKey(const Key('decline-submit')));
    await tester.pumpAndSettle();

    // The reason is the adjuster's own words, sent unchanged.
    expect(returned, reason);
    expect(find.byKey(const Key('decline-reason-field')), findsNothing);
  });

  testWidgets('dismissing returns null, so no request is made', (
    tester,
  ) async {
    String? returned;
    var completed = false;

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              returned = await DeclineAssignmentSheet.show(context);
              completed = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('decline-reason-field')), findsOneWidget);

    // Drag the sheet away, as an adjuster backing out would.
    await tester.drag(
      find.byKey(const Key('decline-reason-field')),
      const Offset(0, 600),
    );
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(returned, isNull);
    expect(find.byKey(const Key('decline-reason-field')), findsNothing);
  });

  testWidgets('renders in Arabic, right to left', (tester) async {
    await openSheet(tester, locale: const Locale('ar'));

    final direction = Directionality.of(
      tester.element(find.byKey(const Key('decline-submit'))),
    );
    expect(direction, TextDirection.rtl);
  });
}
