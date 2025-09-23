import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/plan_list_provider.dart';
import 'plan_detail_screen.dart';
import 'create_plan_screen.dart';
import 'edit_plan_screen.dart';

class HomeScreen extends ConsumerWidget {
  static const routeName = '/';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(planListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('TripFlow')),
      body: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text(plan.title),
              subtitle: Text('${plan.startDate.toLocal().toString().split(' ')[0]} ~ ${plan.endDate.toLocal().toString().split(' ')[0]}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.pushNamed(
                      context,
                      EditPlanScreen.routeName,
                      arguments: plan.id,
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, plan.id, plan.title);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('수정'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('삭제', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert),
              ),
              onTap: () => Navigator.pushNamed(
                context,
                PlanDetailScreen.routeName,
                arguments: plan.id,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, CreatePlanScreen.routeName),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String planId, String planTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('여행 계획 삭제'),
        content: Text('"$planTitle"을(를) 삭제하시겠습니까?\n삭제된 계획은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // ConsumerWidget에서 ref 접근을 위해 Builder 사용
              final ref = ProviderScope.containerOf(context).read(planListProvider.notifier);
              ref.removePlan(planId);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
