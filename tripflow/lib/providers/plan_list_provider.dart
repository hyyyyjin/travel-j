import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../models/plan.dart';
import '../models/day_plan.dart';
import '../models/schedule_item.dart';
import '../repositories/plan_repository.dart';
import 'repository_providers.dart';

final planListProvider = NotifierProvider<PlanListNotifier, List<Plan>>(
  PlanListNotifier.new,
);

class PlanListNotifier extends Notifier<List<Plan>> {
  late final PlanRepository _repository;

  @override
  List<Plan> build() {
    _repository = ref.read(planRepositoryProvider);
    return _repository.getAll();
  }

  void addPlan(Plan plan) {
    state = [...state, plan];
    _repository.overwriteAll(state);
  }

  void removePlan(String planId) {
    state = state.where((p) => p.id != planId).toList();
    _repository.overwriteAll(state);
  }

  void updatePlan(Plan updated) {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
    _repository.overwriteAll(state);
  }

  Plan? getById(String id) => state.firstWhereOrNull((p) => p.id == id);

  void addScheduleItem({required String planId, required int dayIndex, required ScheduleItem item}) {
    final plan = state.firstWhereOrNull((p) => p.id == planId);
    if (plan == null) return;
    final newDays = [...plan.days];
    final day = newDays[dayIndex];
    final newItems = [...day.items, item];
    newItems.sort((a, b) => a.time.compareTo(b.time));
    newDays[dayIndex] = day.copyWith(items: newItems);
    updatePlan(plan.copyWith(days: newDays));
  }

  void updateScheduleItem({required String planId, required int dayIndex, required String itemId, required ScheduleItem Function(ScheduleItem) transform}) {
    final plan = state.firstWhereOrNull((p) => p.id == planId);
    if (plan == null) return;
    final newDays = [...plan.days];
    final day = newDays[dayIndex];
    final newItems = day.items.map((it) => it.id == itemId ? transform(it) : it).toList();
    newItems.sort((a, b) => a.time.compareTo(b.time));
    newDays[dayIndex] = day.copyWith(items: newItems);
    updatePlan(plan.copyWith(days: newDays));
  }

  void toggleVisited({required String planId, required int dayIndex, required String itemId}) {
    updateScheduleItem(
      planId: planId,
      dayIndex: dayIndex,
      itemId: itemId,
      transform: (it) => it.copyWith(visited: !it.visited),
    );
  }
}
