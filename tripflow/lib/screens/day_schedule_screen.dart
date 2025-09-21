import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/plan_list_provider.dart';
import '../models/schedule_item.dart';
import 'edit_place_screen.dart';
import '../services/directions_service.dart';

class DayScheduleArgs {
  final String planId;
  final int dayIndex;
  const DayScheduleArgs({required this.planId, required this.dayIndex});
}

class DayScheduleScreen extends ConsumerWidget {
  static const routeName = '/day';
  final DayScheduleArgs args;
  const DayScheduleScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planListProvider).firstWhere((p) => p.id == args.planId);
    final day = plan.days[args.dayIndex];
    final formatter = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text('${DateFormat('yyyy-MM-dd').format(day.date)} 일정')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: day.items.length * 2 - (day.items.isEmpty ? 0 : 1),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          // Interleave schedule and travel time widgets
          final isSchedule = index % 2 == 0;
          final itemIndex = index ~/ 2;
          if (isSchedule) {
            final item = day.items[itemIndex];
            return _ScheduleCard(
              item: item,
              timeLabel: formatter.format(item.time),
              onTap: () => _openDirections(item),
              onEdit: () => Navigator.pushNamed(
                context,
                EditPlaceScreen.routeName,
                arguments: EditPlaceArgs(planId: args.planId, dayIndex: args.dayIndex, itemId: item.id),
              ),
            );
          } else {
            return _TravelTimeCard();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          EditPlaceScreen.routeName,
          arguments: EditPlaceArgs(planId: args.planId, dayIndex: args.dayIndex),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openDirections(ScheduleItem item) async {
    if (item.latitude == null || item.longitude == null) return;
    await DirectionsService.openWalkingDirections(
      latitude: item.latitude!,
      longitude: item.longitude!,
      placeName: item.placeName,
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  final String timeLabel;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _ScheduleCard({
    required this.item,
    required this.timeLabel,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(timeLabel, style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
        title: Text(item.placeName),
        subtitle: item.estimatedBudget != null ? Text('예산: ${item.estimatedBudget}원') : null,
        trailing: Wrap(spacing: 4, children: [
          IconButton(icon: const Icon(Icons.directions_walk), onPressed: onTap),
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
        ]),
      ),
    );
  }
}

class _TravelTimeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: const ListTile(
        leading: Icon(Icons.timeline),
        title: Text('이동 시간: (예상 값 표시 예정)'),
      ),
    );
  }
}
