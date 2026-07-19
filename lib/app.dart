import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'routing/app_router.dart';

class MomentumFitApp extends ConsumerWidget {
  const MomentumFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final userLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'MomentumFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: userLocale,
      supportedLocales: const [
        Locale('en'),
        Locale('sv'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (userLocale != null) {
          return userLocale;
        }
        
        if (deviceLocale != null) {
          for (final locale in supportedLocales) {
            if (locale.languageCode == deviceLocale.languageCode) {
              return locale;
            }
          }
        }
        
        return const Locale('en');
      },
      routerConfig: router,
    );
  }
}
