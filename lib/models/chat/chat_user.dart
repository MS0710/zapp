class ChatUser {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? fullName;
  final String? nickname;
  final String role;
  final int vipLevel;

  const ChatUser({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.fullName,
    required this.nickname,
    required this.role,
    required this.vipLevel,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: (json['id'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      avatarUrl: _toNullableString(json['avatar_url']),
      fullName: _toNullableString(json['full_name']),
      nickname: _toNullableString(json['nickname']),
      role: (json['role'] ?? '').toString(),
      vipLevel: _toInt(json['vip_level']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
