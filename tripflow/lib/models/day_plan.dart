import 'schedule_item.dart';

class DayPlan {
  final DateTime date;
  final List<ScheduleItem> items;

  const DayPlan({
    required this.date,
    required this.items,
  });

  int get totalBudget => items.fold(0, (sum, it) => sum + (it.estimatedBudget ?? 0));

  DayPlan copyWith({DateTime? date, List<ScheduleItem>? items}) {
    return DayPlan(date: date ?? this.date, items: items ?? this.items);
  }
}
