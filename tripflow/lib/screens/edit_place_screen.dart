import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/plan_list_provider.dart';
import '../models/schedule_item.dart';
import '../services/place_search_service.dart';

class EditPlaceArgs {
  final String planId;
  final int dayIndex;
  final String? itemId;
  const EditPlaceArgs(
      {required this.planId, required this.dayIndex, this.itemId});
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

  List<PlaceSearchResult> searchResults = [];
  bool isSearching = false;
  String? selectedPlaceTitle;
  String? selectedPlaceAddress;
  double? selectedLatitude;
  double? selectedLongitude;

  @override
  void initState() {
    super.initState();
    placeController = TextEditingController();
    timeController = TextEditingController(text: '09:00');
    budgetController = TextEditingController();
    noteController = TextEditingController();

    // 기존 일정 수정 모드인 경우 데이터 로드
    if (widget.args.itemId != null) {
      _loadExistingItem();
    }
  }

  void _loadExistingItem() {
    final plan = ref
        .read(planListProvider)
        .firstWhere((p) => p.id == widget.args.planId);
    final day = plan.days[widget.args.dayIndex];
    final item = day.items.firstWhere((i) => i.id == widget.args.itemId);

    placeController.text = item.placeName;
    timeController.text =
        '${item.time.hour.toString().padLeft(2, '0')}:${item.time.minute.toString().padLeft(2, '0')}';
    budgetController.text = item.estimatedBudget?.toString() ?? '';
    noteController.text = item.note ?? '';

    // 기존 장소 정보가 있다면 선택된 상태로 설정
    selectedPlaceTitle = item.placeName;
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      // 개발용 더미 데이터 사용 (실제 API 연동 시 PlaceSearchService.searchPlaces 사용)
      final results = await PlaceSearchService.searchPlacesDummy(query);

      setState(() {
        searchResults = results;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
    }
  }

  void _selectPlace(PlaceSearchResult place) {
    setState(() {
      selectedPlaceTitle = place.title;
      selectedPlaceAddress = place.address;
      selectedLatitude = place.latitude;
      selectedLongitude = place.longitude;
      searchResults = [];
    });

    placeController.text = place.title;
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
        title: Text(widget.args.itemId != null ? '일정 수정' : '일정 추가'),
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
              // 장소 검색 필드
              TextFormField(
                controller: placeController,
                decoration: InputDecoration(
                  labelText: '장소명',
                  hintText: '장소를 검색하세요 (예: 도쿄 스카이트리)',
                  suffixIcon: isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.search),
                ),
                validator: (v) => v == null || v.isEmpty ? '장소명을 입력하세요' : null,
                onChanged: (value) {
                  // 디바운싱을 위해 타이머 사용 (실제 구현에서는 더 정교한 디바운싱 필요)
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (placeController.text == value) {
                      _searchPlaces(value);
                    }
                  });
                },
              ),

              // 검색 결과 표시
              if (searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final place = searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.place, color: Colors.blue),
                        title: Text(place.title),
                        subtitle: Text(place.address),
                        onTap: () => _selectPlace(place),
                      );
                    },
                  ),
                ),

              // 선택된 장소 정보 표시
              if (selectedPlaceTitle != null && selectedPlaceAddress != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedPlaceTitle!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              selectedPlaceAddress!,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedPlaceTitle = null;
                            selectedPlaceAddress = null;
                            selectedLatitude = null;
                            selectedLongitude = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final now = TimeOfDay.now();
                  final picked =
                      await showTimePicker(context: context, initialTime: now);
                  if (picked != null) {
                    timeController.text = picked.format(context);
                  }
                },
                child: IgnorePointer(
                  child: TextFormField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: '시간 (HH:MM)'),
                    validator: (v) =>
                        v == null || !RegExp(r'^\d{1,2}:\d{2}').hasMatch(v)
                            ? '시간을 입력하세요'
                            : null,
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
    final parts = timeController.text.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;
    final dayDate = ref
        .read(planListProvider)
        .firstWhere((p) => p.id == widget.args.planId)
        .days[widget.args.dayIndex]
        .date;
    final time =
        DateTime(dayDate.year, dayDate.month, dayDate.day, hour, minute);

    final item = ScheduleItem(
      id: widget.args.itemId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      time: time,
      placeName: placeController.text,
      estimatedBudget: int.tryParse(budgetController.text),
      note: noteController.text.isEmpty ? null : noteController.text,
      latitude: selectedLatitude,
      longitude: selectedLongitude,
    );

    if (widget.args.itemId != null) {
      // 수정 모드
      refState.updateScheduleItem(
        planId: widget.args.planId,
        dayIndex: widget.args.dayIndex,
        itemId: widget.args.itemId!,
        transform: (existingItem) => item,
      );
    } else {
      // 추가 모드
      refState.addScheduleItem(
          planId: widget.args.planId,
          dayIndex: widget.args.dayIndex,
          item: item);
    }

    Navigator.of(context).pop();
  }
}
