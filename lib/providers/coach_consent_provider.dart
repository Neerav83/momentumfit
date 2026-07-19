import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';

final coachAiConsentProvider =
    NotifierProvider<CoachAiConsentNotifier, bool>(CoachAiConsentNotifier.new);

class CoachAiConsentNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(localAppStoreProvider).readCoachAiConsent();
  }

  Future<void> setConsented(bool value) async {
    await ref.read(localAppStoreProvider).writeCoachAiConsent(value);
    await ref.read(localAppStoreProvider).clearCoachNudge();
    state = value;
  }

  void refresh() {
    state = ref.read(localAppStoreProvider).readCoachAiConsent();
  }
}
