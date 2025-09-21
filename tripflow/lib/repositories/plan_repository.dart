import '../models/plan.dart';

abstract class PlanRepository {
  List<Plan> getAll();
  void overwriteAll(List<Plan> plans);
}
