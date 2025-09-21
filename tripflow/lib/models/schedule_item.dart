enum TransportMode { walk, public, car }

class ScheduleItem {
  final String id;
  final DateTime time;
  final String placeName;
  final String? note;
  final int? estimatedBudget; // KRW
  final bool visited;
  final double? latitude;
  final double? longitude;

  const ScheduleItem({
    required this.id,
    required this.time,
    required this.placeName,
    this.note,
    this.estimatedBudget,
    this.visited = false,
    this.latitude,
    this.longitude,
  });

  ScheduleItem copyWith({
    String? id,
    DateTime? time,
    String? placeName,
    String? note,
    int? estimatedBudget,
    bool? visited,
    double? latitude,
    double? longitude,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      time: time ?? this.time,
      placeName: placeName ?? this.placeName,
      note: note ?? this.note,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      visited: visited ?? this.visited,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
