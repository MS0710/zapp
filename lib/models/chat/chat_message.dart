class ChatMessage {
  final int id;
  final int roomId;
  final String senderId;
  final String? senderName;
  final String? senderAvatarUrl;
  final String message;
  final String messageType;
  final String? imageUrl;
  final bool isDeleted;
  final bool isRecalled;
  final DateTime? deletedAt;
  final String status;
  final DateTime? readAt;
  final int? replyToMessageId;
  final DateTime? createdAt;
  final bool isPending;
  final bool hasSendError;
  final String? clientId;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.senderName,
    this.senderAvatarUrl,
    required this.message,
    this.messageType = 'text',
    this.imageUrl,
    required this.isDeleted,
    this.isRecalled = false,
    this.deletedAt,
    this.status = 'sent',
    this.readAt,
    this.replyToMessageId,
    required this.createdAt,
    this.isPending = false,
    this.hasSendError = false,
    this.clientId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _toInt(json['id']),
      roomId: _toInt(json['room_id']),
      senderId: (json['sender_id'] ?? '').toString(),
      senderName: _toNullableString(json['sender_name']),
      senderAvatarUrl: _toNullableString(json['sender_avatar_url']),
      message: (json['message'] ?? '').toString(),
      messageType: (json['message_type'] ?? 'text').toString(),
      imageUrl: _toNullableString(json['image_url']),
      isDeleted: _toBool(json['is_deleted']),
      isRecalled: _toBool(json['is_recalled']),
      deletedAt: _toDateTime(json['deleted_at']),
      status: (json['status'] ?? 'sent').toString(),
      readAt: _toDateTime(json['read_at']),
      replyToMessageId:
          json['reply_to_message_id'] == null
              ? null
              : _toInt(json['reply_to_message_id']),
      createdAt: _toDateTime(json['created_at']),
      isPending: _toBool(json['is_pending']),
      hasSendError: _toBool(json['has_send_error']),
      clientId: _toNullableString(json['client_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar_url': senderAvatarUrl,
      'message': message,
      'message_type': messageType,
      'image_url': imageUrl,
      'is_deleted': isDeleted,
      'is_recalled': isRecalled,
      'deleted_at': deletedAt?.toIso8601String(),
      'status': status,
      'read_at': readAt?.toIso8601String(),
      'reply_to_message_id': replyToMessageId,
      'created_at': createdAt?.toIso8601String(),
      'is_pending': isPending,
      'has_send_error': hasSendError,
      'client_id': clientId,
    };
  }

  ChatMessage copyWith({
    int? id,
    int? roomId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? message,
    String? messageType,
    String? imageUrl,
    bool? isDeleted,
    bool? isRecalled,
    DateTime? deletedAt,
    String? status,
    DateTime? readAt,
    int? replyToMessageId,
    DateTime? createdAt,
    bool? isPending,
    bool? hasSendError,
    String? clientId,
    bool clearCreatedAt = false,
    bool clearClientId = false,
    bool clearSenderName = false,
    bool clearSenderAvatarUrl = false,
    bool clearImageUrl = false,
    bool clearDeletedAt = false,
    bool clearReadAt = false,
    bool clearReplyToMessageId = false,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: clearSenderName ? null : (senderName ?? this.senderName),
      senderAvatarUrl:
          clearSenderAvatarUrl
              ? null
              : (senderAvatarUrl ?? this.senderAvatarUrl),
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      isDeleted: isDeleted ?? this.isDeleted,
      isRecalled: isRecalled ?? this.isRecalled,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      status: status ?? this.status,
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
      replyToMessageId:
          clearReplyToMessageId
              ? null
              : (replyToMessageId ?? this.replyToMessageId),
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
      isPending: isPending ?? this.isPending,
      hasSendError: hasSendError ?? this.hasSendError,
      clientId: clearClientId ? null : (clientId ?? this.clientId),
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
