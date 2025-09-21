import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/plan_list_provider.dart';
import 'plan_detail_screen.dart';

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
              trailing: const Icon(Icons.chevron_right),
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
        onPressed: () {
          // TODO: Implement add new plan flow
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
