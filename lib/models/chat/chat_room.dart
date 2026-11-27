class ChatRoom {
  final int id;
  final String activityType;
  final int activityId;
  final String title;
  final String? merchantId;
  final String createdBy;
  final DateTime? roomCloseAt;
  final DateTime? createdAt;
  final bool isClosed;
  final String? lastMessage;
  final String? lastMessagePreview;
  final String? lastMessageType;
  final DateTime? lastMessageAt;
  final String? lastSenderId;
  final String? displayName;
  final String? displayAvatarUrl;
  final int unreadCount;
  final bool pinned;
  final bool muted;
  final DateTime? updatedAt;
  final DateTime? lastReadAt;

  const ChatRoom({
    required this.id,
    required this.activityType,
    required this.activityId,
    required this.title,
    required this.merchantId,
    required this.createdBy,
    required this.roomCloseAt,
    required this.createdAt,
    required this.isClosed,
    required this.lastMessage,
    required this.lastMessagePreview,
    required this.lastMessageType,
    required this.lastMessageAt,
    required this.lastSenderId,
    required this.displayName,
    required this.displayAvatarUrl,
    required this.unreadCount,
    required this.pinned,
    required this.muted,
    required this.updatedAt,
    required this.lastReadAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: _toInt(json['id']),
      activityType: (json['activity_type'] ?? '').toString(),
      activityId: _toInt(json['activity_id']),
      title: (json['title'] ?? '').toString(),
      merchantId: _toNullableString(json['merchant_id']),
      createdBy: (json['created_by'] ?? '').toString(),
      roomCloseAt: _toDateTime(json['room_close_at']),
      createdAt: _toDateTime(json['created_at']),
      isClosed: _toBool(json['is_closed']),
      lastMessage: _toNullableString(json['last_message']),
      lastMessagePreview: _toNullableString(json['last_message_preview']),
      lastMessageType: _toNullableString(json['last_message_type']),
      lastMessageAt: _toDateTime(json['last_message_at']),
      lastSenderId: _toNullableString(json['last_sender_id']),
      displayName: _toNullableString(json['display_name']),
      displayAvatarUrl: _toNullableString(json['display_avatar_url']),
      unreadCount: _toInt(json['unread_count']),
      pinned: _toBool(json['pinned']),
      muted: _toBool(json['muted']),
      updatedAt: _toDateTime(json['updated_at']),
      lastReadAt: _toDateTime(json['last_read_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_type': activityType,
      'activity_id': activityId,
      'title': title,
      'merchant_id': merchantId,
      'created_by': createdBy,
      'room_close_at': roomCloseAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'is_closed': isClosed,
      'last_message': lastMessage,
      'last_message_preview': lastMessagePreview,
      'last_message_type': lastMessageType,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_sender_id': lastSenderId,
      'display_name': displayName,
      'display_avatar_url': displayAvatarUrl,
      'unread_count': unreadCount,
      'pinned': pinned,
      'muted': muted,
      'updated_at': updatedAt?.toIso8601String(),
      'last_read_at': lastReadAt?.toIso8601String(),
    };
  }

  ChatRoom copyWith({
    int? id,
    String? activityType,
    int? activityId,
    String? title,
    String? merchantId,
    String? createdBy,
    DateTime? roomCloseAt,
    DateTime? createdAt,
    bool? isClosed,
    String? lastMessage,
    String? lastMessagePreview,
    String? lastMessageType,
    DateTime? lastMessageAt,
    String? lastSenderId,
    String? displayName,
    String? displayAvatarUrl,
    int? unreadCount,
    bool? pinned,
    bool? muted,
    DateTime? updatedAt,
    DateTime? lastReadAt,
    bool clearMerchantId = false,
    bool clearRoomCloseAt = false,
    bool clearCreatedAt = false,
    bool clearLastMessage = false,
    bool clearLastMessagePreview = false,
    bool clearLastMessageType = false,
    bool clearLastMessageAt = false,
    bool clearLastSenderId = false,
    bool clearDisplayName = false,
    bool clearDisplayAvatarUrl = false,
    bool clearUpdatedAt = false,
    bool clearLastReadAt = false,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      activityId: activityId ?? this.activityId,
      title: title ?? this.title,
      merchantId: clearMerchantId ? null : (merchantId ?? this.merchantId),
      createdBy: createdBy ?? this.createdBy,
      roomCloseAt: clearRoomCloseAt ? null : (roomCloseAt ?? this.roomCloseAt),
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
      isClosed: isClosed ?? this.isClosed,
      lastMessage: clearLastMessage ? null : (lastMessage ?? this.lastMessage),
      lastMessagePreview:
          clearLastMessagePreview
              ? null
              : (lastMessagePreview ?? this.lastMessagePreview),
      lastMessageType:
          clearLastMessageType
              ? null
              : (lastMessageType ?? this.lastMessageType),
      lastMessageAt:
          clearLastMessageAt ? null : (lastMessageAt ?? this.lastMessageAt),
      lastSenderId:
          clearLastSenderId ? null : (lastSenderId ?? this.lastSenderId),
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      displayAvatarUrl:
          clearDisplayAvatarUrl
              ? null
              : (displayAvatarUrl ?? this.displayAvatarUrl),
      unreadCount: unreadCount ?? this.unreadCount,
      pinned: pinned ?? this.pinned,
      muted: muted ?? this.muted,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
      lastReadAt: clearLastReadAt ? null : (lastReadAt ?? this.lastReadAt),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    final text = (value ?? '').toString().toLowerCase().trim();
    return text == 'true' || text == '1';
  }

  static DateTime? _toDateTime(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
