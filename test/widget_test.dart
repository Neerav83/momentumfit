import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:momentumfit/app.dart';
import 'package:momentumfit/data/local/local_app_store.dart';
import 'package:momentumfit/l10n/app_localizations.dart';
import 'package:momentumfit/providers/app_providers.dart';
import 'package:momentumfit/providers/locale_provider.dart';

class _FixedEnglishLocale extends LocaleNotifier {
  @override
  Locale? build() => const Locale('en');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows onboarding for new users', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = LocalAppStore.forTesting(prefs);
    await store.initialize();

    final l10n = lookupAppLocalizations(const Locale('en'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localAppStoreProvider.overrideWithValue(store),
          localeProvider.overrideWith(_FixedEnglishLocale.new),
        ],
        child: const MomentumFitApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(l10n.appName), findsOneWidget);
    expect(find.text(l10n.whoIsTraining), findsOneWidget);
  });
}
