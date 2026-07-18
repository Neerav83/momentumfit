import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/local/local_app_store.dart';
import 'providers/app_providers.dart';
import 'providers/reminder_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = LocalAppStore(prefs);

  await store.initialize();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      localAppStoreProvider.overrideWithValue(store),
    ],
  );

  // Restore local reminder schedule after relaunch (no Apple Push needed).
  await container.read(reminderSettingsProvider.notifier).rescheduleFromDisk();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MomentumFitApp(),
    ),
  );
}
