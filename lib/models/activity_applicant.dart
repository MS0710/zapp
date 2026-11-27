// models/activity_applicant.dart
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

class ApplicantProfile {
  final String nickname;
  final String? avatarUrl;
  final String? fullName;
  final String? gender;

  ApplicantProfile({
    required this.nickname,
    required this.avatarUrl,
    required this.fullName,
    required this.gender,
  });

  factory ApplicantProfile.fromJson(Map<String, dynamic> j) => ApplicantProfile(
    nickname: (j['nickname'] as String?) ?? '',
    avatarUrl: j['avatar_url'] as String?,
    fullName: j['full_name'] as String?,
    gender: j['gender'] as String?,
  );
}

class ActivityApplicantItem {
  final String userId;
  final String status; // pending / joined / rejected
  final DateTime? joinedAt;
  final ApplicantProfile? profile;

  ActivityApplicantItem({
    required this.userId,
    required this.status,
    required this.joinedAt,
    required this.profile,
  });

  factory ActivityApplicantItem.fromJson(Map<String, dynamic> j) =>
      ActivityApplicantItem(
        userId: (j['user_id'] as String?) ?? '',
        status: (j['status'] as String?) ?? '',
        joinedAt: _safeParseDateTime(j['joined_at']),
        profile: (j['profile'] is Map<String, dynamic>)
            ? ApplicantProfile.fromJson(Map<String, dynamic>.from(j['profile']))
            : null,
      );
}

class ApplicantSummary {
  final int pending;
  final int joined;
  final int rejected;

  ApplicantSummary({
    required this.pending,
    required this.joined,
    required this.rejected,
  });

  factory ApplicantSummary.fromJson(Map<String, dynamic> j) => ApplicantSummary(
    pending: (j['pending'] as num?)?.toInt() ?? 0,
    joined: (j['joined'] as num?)?.toInt() ?? 0,
    rejected: (j['rejected'] as num?)?.toInt() ?? 0,
  );
}

class ActivityApplicantsResponse {
  final List<ActivityApplicantItem> data;
  final ApplicantSummary? summary;

  ActivityApplicantsResponse({
    required this.data,
    required this.summary,
  });

  factory ActivityApplicantsResponse.fromJson(Map<String, dynamic> j) {
    final list = (j['data'] is List) ? (j['data'] as List) : const [];
    return ActivityApplicantsResponse(
      data: list
          .whereType<Map>()
          .map((e) => ActivityApplicantItem.fromJson(
          Map<String, dynamic>.from(e as Map)))
          .toList(),
      summary: (j['summary'] is Map<String, dynamic>)
          ? ApplicantSummary.fromJson(Map<String, dynamic>.from(j['summary']))
          : null,
    );
  }
}
