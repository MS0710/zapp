import 'activity.dart';

class MyActivityItem extends ActivityItem {
  final int joinedCount;
  final int pendingCount;

  MyActivityItem({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.startTime,
    required super.location,
    required super.maxParticipants,
    required super.participantCount,
    required super.status,
    required super.remarks,
    required super.host,
    required this.joinedCount,
    required this.pendingCount,
  });

  factory MyActivityItem.fromJson(Map<String, dynamic> j) {
    // 先用 ActivityItem 的 fromJson 把共用欄位解析出來
    final base = ActivityItem.fromJson(j);

    return MyActivityItem(
      id: base.id,
      title: base.title,
      description: base.description,
      imageUrl: base.imageUrl,
      startTime: base.startTime,
      location: base.location,
      maxParticipants: base.maxParticipants,
      participantCount: base.participantCount,
      status: base.status,
      remarks: base.remarks,
      host: base.host,
      joinedCount: (j['joined_count'] as num?)?.toInt() ?? 0,
      pendingCount: (j['pending_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class MyActivityListResponse {
  final List<MyActivityItem> data;
  final int total;

  MyActivityListResponse({
    required this.data,
    required this.total,
  });

  factory MyActivityListResponse.fromJson(Map<String, dynamic> j) {
    final list = (j['data'] as List? ?? [])
        .whereType<Map>()
        .map((e) => MyActivityItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return MyActivityListResponse(
      data: list,
      total: (j['total'] as num?)?.toInt() ?? list.length,
    );
  }
}
