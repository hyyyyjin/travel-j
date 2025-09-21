import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/plan_list_provider.dart';
import 'day_schedule_screen.dart';

class PlanDetailScreen extends ConsumerWidget {
  static const routeName = '/plan';
  final String planId;
  const PlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planListProvider).firstWhere((p) => p.id == planId);
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share to read-only web viewer later
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: plan.days.length,
        itemBuilder: (context, index) {
          final day = plan.days[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text('Day ${index + 1}: ${day.date.toLocal().toString().split(' ')[0]}'),
              subtitle: Text('일정 ${day.items.length}개'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(
                context,
                DayScheduleScreen.routeName,
                arguments: DayScheduleArgs(planId: planId, dayIndex: index),
              ),
            ),
          );
        },
      ),
    );
  }
}
