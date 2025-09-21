import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/plan_repository.dart';
import '../repositories/memory_plan_repository.dart';

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return MemoryPlanRepository();
});
