// models/activity_detail.dart
// 取得活動詳情 Response

DateTime? _tryParseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is! String) return null;
  final s = v.trim();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s);
}

class ActivityDetailResponse {
  final ActivityDetail data;

  ActivityDetailResponse({required this.data});

  factory ActivityDetailResponse.fromJson(Map<String, dynamic> j) {
    final d = j['data'];
    if (d is! Map<String, dynamic>) {
      throw Exception('get-activity-detail 回傳缺少 data');
    }
    return ActivityDetailResponse(
      data: ActivityDetail.fromJson(Map<String, dynamic>.from(d)),
    );
  }
}

class ActivityDetail {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime? startTime; // start_time
  final String location;
  final int maxParticipants;
  final String status;
  final String? remarks;

  final ActivityHost host;
  final List<ActivityParticipant> participants;

  /// 只有登入時才有意義（文件：不登入也可能回，但通常會是 false/null）
  final bool? isJoined; // is_joined
  final String? myStatus; // my_status: null/pending/joined/rejected

  ActivityDetail({
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
    required this.participants,
    required this.isJoined,
    required this.myStatus,
  });

  factory ActivityDetail.fromJson(Map<String, dynamic> j) {
    final hostJson = j['host'];
    final participantsJson = j['participants'];

    return ActivityDetail(
      id: (j['id'] as num).toInt(),
      title: (j['title'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      imageUrl: j['image_url']?.toString(),
      startTime: _tryParseDateTime(j['start_time']),
      location: (j['location'] ?? '').toString(),
      maxParticipants: (j['max_participants'] as num?)?.toInt() ?? 0,
      status: (j['status'] ?? '').toString(),
      remarks: j['remarks']?.toString(),

      host: hostJson is Map<String, dynamic>
          ? ActivityHost.fromJson(Map<String, dynamic>.from(hostJson))
          : ActivityHost.empty(),

      participants: participantsJson is List
          ? participantsJson
          .whereType<Map>()
          .map((e) => ActivityParticipant.fromJson(
        Map<String, dynamic>.from(e as Map),
      ))
          .toList()
          : <ActivityParticipant>[],

      isJoined: j['is_joined'] is bool ? j['is_joined'] as bool : null,
      myStatus: j['my_status']?.toString(),
    );
  }
}

class ActivityHost {
  final String id; // uuid
  final String nickname;
  final String? avatarUrl;
  final String? fullName;

  ActivityHost({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
    required this.fullName,
  });

  factory ActivityHost.fromJson(Map<String, dynamic> j) {
    return ActivityHost(
      id: (j['id'] ?? '').toString(),
      nickname: (j['nickname'] ?? '').toString(),
      avatarUrl: j['avatar_url']?.toString(),
      fullName: j['full_name']?.toString(),
    );
  }

  factory ActivityHost.empty() => ActivityHost(
    id: '',
    nickname: '',
    avatarUrl: null,
    fullName: null,
  );
}

class ActivityParticipant {
  final String userId;
  final String status; // joined/pending/...
  final DateTime? joinedAt;
  final ActivityParticipantUser? user;

  ActivityParticipant({
    required this.userId,
    required this.status,
    required this.joinedAt,
    required this.user,
  });

  factory ActivityParticipant.fromJson(Map<String, dynamic> j) {
    final userJson = j['user'];
    return ActivityParticipant(
      userId: (j['user_id'] ?? '').toString(),
      status: (j['status'] ?? '').toString(),
      joinedAt: _tryParseDateTime(j['joined_at']),
      user: userJson is Map<String, dynamic>
          ? ActivityParticipantUser.fromJson(Map<String, dynamic>.from(userJson))
          : null,
    );
  }
}

class ActivityParticipantUser {
  final String nickname;
  final String? avatarUrl;

  ActivityParticipantUser({
    required this.nickname,
    required this.avatarUrl,
  });

  factory ActivityParticipantUser.fromJson(Map<String, dynamic> j) {
    return ActivityParticipantUser(
      nickname: (j['nickname'] ?? '').toString(),
      avatarUrl: j['avatar_url']?.toString(),
    );
  }
}
