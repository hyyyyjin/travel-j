import '../models/day_plan.dart';
import '../models/plan.dart';
import '../models/schedule_item.dart';
import 'plan_repository.dart';

class MemoryPlanRepository implements PlanRepository {
  List<Plan> _plans;

  MemoryPlanRepository() : _plans = _seed();

  @override
  List<Plan> getAll() => List<Plan>.unmodifiable(_plans);

  @override
  void overwriteAll(List<Plan> plans) {
    _plans = List<Plan>.from(plans);
  }

  static List<Plan> _seed() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final samplePlan = Plan(
      id: 'plan_1',
      title: '도쿄 3박 4일',
      startDate: today,
      endDate: today.add(const Duration(days: 3)),
      days: [
        DayPlan(
          date: today,
          items: [
            ScheduleItem(id: '1', time: today.add(const Duration(hours: 9)), placeName: '호텔 체크인', estimatedBudget: 0),
            ScheduleItem(id: '2', time: today.add(const Duration(hours: 11)), placeName: '스카이트리', estimatedBudget: 30000, latitude: 35.7101, longitude: 139.8107),
            ScheduleItem(id: '3', time: today.add(const Duration(hours: 14)), placeName: '스시집', estimatedBudget: 20000),
          ],
        ),
        DayPlan(date: today.add(const Duration(days: 1)), items: const []),
      ],
    );
    return [samplePlan];
  }
}
