import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:momentumfit/app.dart';
import 'package:momentumfit/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows onboarding for new users', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MomentumFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MomentumFit'), findsOneWidget);
    expect(find.text('Who’s training?'), findsOneWidget);
  });
}
