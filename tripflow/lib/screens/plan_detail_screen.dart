import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/plan_list_provider.dart';
import '../models/schedule_item.dart';
import '../services/directions_service.dart';
import 'edit_place_screen.dart';
import 'edit_plan_screen.dart';

class PlanDetailScreen extends ConsumerStatefulWidget {
  static const routeName = '/plan';
  final String planId;
  const PlanDetailScreen({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  final Map<int, bool> expandedDays = {};

  @override
  Widget build(BuildContext context) {
    final plan =
        ref.watch(planListProvider).firstWhere((p) => p.id == widget.planId);
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              EditPlanScreen.routeName,
              arguments: widget.planId,
            ),
          ),
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
          final isExpanded = expandedDays[index] ?? false;
          return _ExpandableDayCard(
            day: day,
            dayIndex: index,
            planId: widget.planId,
            isExpanded: isExpanded,
            onToggle: () => setState(() => expandedDays[index] = !isExpanded),
          );
        },
      ),
    );
  }
}

class _ExpandableDayCard extends StatelessWidget {
  final dynamic day;
  final int dayIndex;
  final String planId;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ExpandableDayCard({
    required this.day,
    required this.dayIndex,
    required this.planId,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
                'Day ${dayIndex + 1}: ${day.date.toLocal().toString().split(' ')[0]}'),
            subtitle: Text('일정 ${day.items.length}개'),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: onToggle,
          ),
          if (isExpanded)
            _DayScheduleList(day: day, dayIndex: dayIndex, planId: planId),
        ],
      ),
    );
  }
}

class _DayScheduleList extends StatelessWidget {
  final dynamic day;
  final int dayIndex;
  final String planId;

  const _DayScheduleList({
    required this.day,
    required this.dayIndex,
    required this.planId,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('HH:mm');
    return Column(
      children: [
        ...day.items.map((item) {
          return _ScheduleItemCard(
            item: item,
            timeLabel: formatter.format(item.time),
            onDirections: () => _openDirections(item),
            onEdit: () => Navigator.pushNamed(
              context,
              EditPlaceScreen.routeName,
              arguments: EditPlaceArgs(
                  planId: planId, dayIndex: dayIndex, itemId: item.id),
            ),
            onDelete: () =>
                _showDeleteItemDialog(context, item.id, item.placeName),
          );
        }),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.small(
            onPressed: () => Navigator.pushNamed(
              context,
              EditPlaceScreen.routeName,
              arguments: EditPlaceArgs(planId: planId, dayIndex: dayIndex),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
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

  void _showDeleteItemDialog(
      BuildContext context, String itemId, String placeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: Text('"$placeName" 일정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // ConsumerWidget에서 ref 접근을 위해 Builder 사용
              final ref = ProviderScope.containerOf(context)
                  .read(planListProvider.notifier);
              ref.removeScheduleItem(
                planId: planId,
                dayIndex: dayIndex,
                itemId: itemId,
              );
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

class _ScheduleItemCard extends StatelessWidget {
  final ScheduleItem item;
  final String timeLabel;
  final VoidCallback onDirections;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleItemCard({
    required this.item,
    required this.timeLabel,
    required this.onDirections,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Text(timeLabel),
        title: Text(item.placeName),
        subtitle: item.estimatedBudget != null
            ? Text('예산: ${item.estimatedBudget}원')
            : null,
        trailing: Wrap(spacing: 4, children: [
          IconButton(
              icon: const Icon(Icons.directions_walk), onPressed: onDirections),
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ]),
      ),
    );
  }
}
