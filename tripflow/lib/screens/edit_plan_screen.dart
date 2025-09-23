import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/plan_list_provider.dart';
import '../models/plan.dart';
import '../models/day_plan.dart';

class EditPlanScreen extends ConsumerStatefulWidget {
  static const routeName = '/edit-plan';
  final String planId;
  const EditPlanScreen({super.key, required this.planId});

  @override
  ConsumerState<EditPlanScreen> createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends ConsumerState<EditPlanScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late DateTime startDate;
  late DateTime endDate;
  late Plan originalPlan;

  @override
  void initState() {
    super.initState();
    final plan = ref.read(planListProvider).firstWhere((p) => p.id == widget.planId);
    originalPlan = plan;
    titleController = TextEditingController(text: plan.title);
    startDate = plan.startDate;
    endDate = plan.endDate;
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
        title: const Text('여행 계획 수정'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
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
                      if (_getDaysBetween(startDate, endDate) != originalPlan.days.length)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '⚠️ 날짜 변경 시 기존 일정이 삭제될 수 있습니다.',
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                        ),
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
    
    // 날짜가 변경된 경우 새로운 DayPlan 생성
    List<DayPlan> newDays;
    if (_getDaysBetween(startDate, endDate) != originalPlan.days.length) {
      newDays = <DayPlan>[];
      for (int i = 0; i < _getDaysBetween(startDate, endDate); i++) {
        final date = startDate.add(Duration(days: i));
        newDays.add(DayPlan(
          date: date,
          items: [],
        ));
      }
    } else {
      // 날짜가 같으면 기존 일정 유지하면서 날짜만 업데이트
      newDays = originalPlan.days.map((day) {
        final dayIndex = originalPlan.days.indexOf(day);
        final newDate = startDate.add(Duration(days: dayIndex));
        return day.copyWith(date: newDate);
      }).toList();
    }

    final updatedPlan = originalPlan.copyWith(
      title: titleController.text,
      startDate: startDate,
      endDate: endDate,
      days: newDays,
    );

    ref.read(planListProvider.notifier).updatePlan(updatedPlan);
    Navigator.of(context).pop();
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('여행 계획 삭제'),
        content: const Text('이 여행 계획을 삭제하시겠습니까?\n삭제된 계획은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(planListProvider.notifier).removePlan(widget.planId);
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).pop(); // 편집 화면 닫기
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
