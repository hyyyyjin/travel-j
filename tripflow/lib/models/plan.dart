import 'package:collection/collection.dart';

import 'day_plan.dart';

class Plan {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<DayPlan> days;

  const Plan({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  int get totalBudget => days.fold(0, (sum, d) => sum + d.totalBudget);

  Plan copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    List<DayPlan>? days,
  }) {
    return Plan(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      days: days ?? this.days,
    );
  }

  DayPlan? dayForDate(DateTime date) {
    return days.firstWhereOrNull(
      (d) => d.date.year == date.year && d.date.month == date.month && d.date.day == date.day,
    );
  }
}
