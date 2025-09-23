import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/plan_list_provider.dart';
import '../models/plan.dart';
import '../models/day_plan.dart';

class CreatePlanScreen extends ConsumerStatefulWidget {
  static const routeName = '/create-plan';
  const CreatePlanScreen({super.key});

  @override
  ConsumerState<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends ConsumerState<CreatePlanScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, now.day);
    endDate = startDate.add(const Duration(days: 1));
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 여행 계획'),
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
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '여행 제목',
                  hintText: '예: 제주도 3박 4일 여행',
                ),
                validator: (value) => value == null || value.isEmpty ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('시작 날짜'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectStartDate(),
              ),
              ListTile(
                title: const Text('종료 날짜'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectEndDate(),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '여행 일정',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('${_getDaysBetween(startDate, endDate)}일간의 여행'),
                      const SizedBox(height: 4),
                      Text('${DateFormat('yyyy-MM-dd').format(startDate)} ~ ${DateFormat('yyyy-MM-dd').format(endDate)}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        if (endDate.isBefore(startDate)) {
          endDate = startDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  int _getDaysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;
    
    final days = <DayPlan>[];
    for (int i = 0; i < _getDaysBetween(startDate, endDate); i++) {
      final date = startDate.add(Duration(days: i));
      days.add(DayPlan(
        date: date,
        items: [],
      ));
    }

    final plan = Plan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      startDate: startDate,
      endDate: endDate,
      days: days,
    );

    ref.read(planListProvider.notifier).addPlan(plan);
    Navigator.of(context).pop();
  }
}
