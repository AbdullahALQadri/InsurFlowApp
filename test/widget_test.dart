import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/network/token_store.dart';
import 'package:insurflow/features/splash/presentation/screens/splash_screen.dart';
import 'package:insurflow/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppDependencies.reset();
    AppDependencies.init(tokenStore: InMemoryTokenStore());
  });

  tearDown(AppDependencies.reset);

  testWidgets('Splash screen is the initial route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsurFlowApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('InsurFlow'), findsOneWidget);
    expect(find.text('Field Claims. Simplified.'), findsOneWidget);
    expect(find.text('Secure  •  Fast  •  Accurate'), findsOneWidget);
  });
}
