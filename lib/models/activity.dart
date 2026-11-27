// models/activity.dart
DateTime? _safeParseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is! String) return null;
  final s = v.trim();
  if (s.isEmpty) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}

class ActivityHost {
  final String nickname;
  final String? avatarUrl;

  ActivityHost({
    required this.nickname,
    required this.avatarUrl,
  });

  factory ActivityHost.fromJson(Map<String, dynamic> j) => ActivityHost(
    nickname: (j['nickname'] as String?) ?? '',
    avatarUrl: j['avatar_url'] as String?,
  );
}

class ActivityItem {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime? startTime;
  final String location;
  final int maxParticipants;
  final String status;
  final String remarks;
  final ActivityHost? host;
  final int participantCount;

  ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startTime,
    required this.location,
    required this.maxParticipants,
    required this.status,
    required this.remarks,
    required this.host,
    required this.participantCount,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> j) => ActivityItem(
    id: (j['id'] as num?)?.toInt() ?? 0,
    title: (j['title'] as String?) ?? '',
    description: (j['description'] as String?) ?? '',
    imageUrl: (j['image_url'] as String?)?.trim(),
    startTime: _safeParseDateTime(j['start_time']),
    location: (j['location'] as String?) ?? '',
    maxParticipants: (j['max_participants'] as num?)?.toInt() ?? 0,
    status: (j['status'] as String?) ?? '',
    remarks: (j['remarks'] as String?) ?? '',
    host: j['host'] is Map<String, dynamic>
        ? ActivityHost.fromJson(j['host'] as Map<String, dynamic>)
        : null,
    participantCount: (j['participant_count'] as num?)?.toInt() ?? 0,
  );
}

class ActivityListResponse {
  final List<ActivityItem> data;
  final int total;

  ActivityListResponse({
    required this.data,
    required this.total,
  });

  factory ActivityListResponse.fromJson(Map<String, dynamic> j) {
    final list = (j['data'] as List?) ?? const [];
    return ActivityListResponse(
      data: list
          .whereType<Map<String, dynamic>>()
          .map(ActivityItem.fromJson)
          .toList(),
      total: (j['total'] as num?)?.toInt() ?? 0,
    );
  }
}
