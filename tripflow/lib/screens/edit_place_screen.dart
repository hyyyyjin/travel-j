import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/plan_list_provider.dart';
import '../models/schedule_item.dart';

class EditPlaceArgs {
  final String planId;
  final int dayIndex;
  final String? itemId;
  const EditPlaceArgs({required this.planId, required this.dayIndex, this.itemId});
}

class EditPlaceScreen extends ConsumerStatefulWidget {
  static const routeName = '/edit';
  final EditPlaceArgs args;
  const EditPlaceScreen({super.key, required this.args});

  @override
  ConsumerState<EditPlaceScreen> createState() => _EditPlaceScreenState();
}

class _EditPlaceScreenState extends ConsumerState<EditPlaceScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController placeController;
  late TextEditingController timeController;
  late TextEditingController budgetController;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    placeController = TextEditingController();
    timeController = TextEditingController(text: '09:00');
    budgetController = TextEditingController();
    noteController = TextEditingController();
  }

  @override
  void dispose() {
    placeController.dispose();
    timeController.dispose();
    budgetController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 추가'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: placeController,
                decoration: const InputDecoration(labelText: '장소명'),
                validator: (v) => v == null || v.isEmpty ? '장소명을 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final now = TimeOfDay.now();
                  final picked = await showTimePicker(context: context, initialTime: now);
                  if (picked != null) {
                    timeController.text = picked.format(context);
                  }
                },
                child: IgnorePointer(
                  child: TextFormField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: '시간 (HH:MM)'),
                    validator: (v) => v == null || !RegExp(r'^\d{1,2}:\d{2}').hasMatch(v) ? '시간을 입력하세요' : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: budgetController,
                decoration: const InputDecoration(labelText: '예산 (원)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: '메모'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;
    final refState = ref.read(planListProvider.notifier);
    final now = DateTime.now();
    final parts = timeController.text.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;
    final dayDate = ref.read(planListProvider).firstWhere((p) => p.id == widget.args.planId).days[widget.args.dayIndex].date;
    final time = DateTime(dayDate.year, dayDate.month, dayDate.day, hour, minute);

    final item = ScheduleItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: time,
      placeName: placeController.text,
      estimatedBudget: int.tryParse(budgetController.text),
      note: noteController.text.isEmpty ? null : noteController.text,
    );
    refState.addScheduleItem(planId: widget.args.planId, dayIndex: widget.args.dayIndex, item: item);
    Navigator.of(context).pop();
  }
}
