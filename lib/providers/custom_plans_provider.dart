import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/app_database.dart';
import '../domain/models/custom_workout_plan.dart';

class CustomPlansNotifier extends Notifier<List<CustomWorkoutPlan>> {
  @override
  List<CustomWorkoutPlan> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final db = AppDatabase.instance;
    final plans = await db.getCustomPlans();
    state = plans;
  }

  Future<void> refresh() async {
    await _load();
  }

  Future<void> setActivePlan(String? planId) async {
    final db = AppDatabase.instance;
    await db.setActivePlan(planId);
    await refresh();
  }

  Future<void> deletePlan(String id) async {
    final db = AppDatabase.instance;
    await db.deleteCustomPlan(id);
    await refresh();
  }
}

final customPlansProvider =
    NotifierProvider<CustomPlansNotifier, List<CustomWorkoutPlan>>(
  CustomPlansNotifier.new,
);

final activePlanProvider = FutureProvider<CustomWorkoutPlan?>((ref) async {
  ref.watch(customPlansProvider);
  final db = AppDatabase.instance;
  return db.getActivePlan();
});
