import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat/chat_message.dart';
import '../models/chat/chat_message_list_response.dart';
import '../models/chat/chat_room.dart';
import '../models/chat/chat_room_response.dart';
import '../models/chat/chat_user.dart';
import '../utils/log_utils.dart';

class ChatService {
  ChatService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Chat API 統一走 Supabase Edge Functions
  static const String _chatBaseUrl =
      'https://qxauaoytegxmrmtxdjqk.supabase.co/functions/v1';

  final Map<int, RealtimeChannel> _roomChannels = {};

  Map<String, String> _buildHeaders({bool requireAuth = false}) {
    final token = _supabase.auth.currentSession?.accessToken;

    if (requireAuth && (token == null || token.isEmpty)) {
      throw Exception('此操作需要登入，但目前沒有 session token');
    }

    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _validateActivityType(String value) {
    if (value != 'activity' && value != 'merchant_activity') {
      throw Exception('activityType 只能是 activity 或 merchant_activity');
    }
  }

  Map<String, dynamic> _decodeJsonMap(
    String body, {
    required String errorPrefix,
    required int statusCode,
  }) {
    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (e) {
      throw Exception('$errorPrefix JSON parse 失敗: $e, body=$body');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('$errorPrefix 回傳格式錯誤($statusCode): $body');
    }

    return Map<String, dynamic>.from(decoded);
  }

  void _throwIfErrorFieldExists(
    Map<String, dynamic> decoded, {
    required String defaultMessage,
  }) {
    final error = decoded['error'];
    if (error != null && error.toString().trim().isNotEmpty) {
      throw Exception(error.toString());
    }

    final message = decoded['message'];
    final success = decoded['success'];

    if (success == false && message != null) {
      throw Exception(message.toString());
    }

    if (success == false) {
      throw Exception(defaultMessage);
    }
  }

  void _logToken(String tag) {
    final token = _supabase.auth.currentSession?.accessToken;
    if (token != null && token.isNotEmpty) {
      final preview = token.length > 20 ? token.substring(0, 20) : token;
      logger.logDebug('[$tag] token = $preview...');
    } else {
      logger.logDebug('[$tag] token = <empty>');
    }
  }

  /// =============================
  /// 1. 建立或取得聊天室
  /// POST /chat-rooms
  /// body:
  /// {
  ///   "activity_type": "activity",
  ///   "activity_id": 123
  /// }
  /// =============================
  Future<ChatRoom> createOrGetRoom({
    required String activityType,
    required int activityId,
    String? title,
    String? merchantId,
  }) async {
    _validateActivityType(activityType);

    final uri = Uri.parse('$_chatBaseUrl/chat-rooms');
    final headers = _buildHeaders(requireAuth: true);

    final body = <String, dynamic>{
      'activity_type': activityType,
      'activity_id': activityId,
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      if (merchantId != null && merchantId.trim().isNotEmpty)
        'merchant_id': merchantId.trim(),
    };

    logger.logDebug('[createOrGetRoom] POST $uri');
    logger.logDebug('[createOrGetRoom] body = $body');
    _logToken('createOrGetRoom');

    http.Response resp;
    try {
      resp = await _client.post(uri, headers: headers, body: jsonEncode(body));
    } catch (e, st) {
      logger.logError('[createOrGetRoom] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[createOrGetRoom] status = ${resp.statusCode}');
    logger.logDebug('[createOrGetRoom] resp.body = ${resp.body}');

    final decoded = _decodeJsonMap(
      resp.body,
      errorPrefix: 'createOrGetRoom',
      statusCode: resp.statusCode,
    );

    _throwIfErrorFieldExists(
      decoded,
      defaultMessage: 'createOrGetRoom 失敗(${resp.statusCode})',
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('createOrGetRoom 失敗(${resp.statusCode}): ${resp.body}');
    }

    return ChatRoomResponse.fromJson(decoded).data;
  }

  /// =============================
  /// 2. 用活動查聊天室
  /// GET /chat-rooms?activity_type=activity&activity_id=123
  ///
  /// 文件格式：
  /// {
  ///   "data": [ ... ]
  /// }
  /// 同一活動只會對到一個聊天室，因此這裡回傳第一筆
  /// 若查無資料則丟錯
  /// =============================
  Future<ChatRoom> getRoom({
    required String activityType,
    required int activityId,
  }) async {
    _validateActivityType(activityType);

    final uri = Uri.parse(
      '$_chatBaseUrl/chat-rooms?activity_type=$activityType&activity_id=$activityId',
    );
    final headers = _buildHeaders(requireAuth: true);

    logger.logDebug('[getRoom] GET $uri');
    _logToken('getRoom');

    http.Response resp;
    try {
      resp = await _client.get(uri, headers: headers);
    } catch (e, st) {
      logger.logError('[getRoom] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[getRoom] status = ${resp.statusCode}');
    logger.logDebug('[getRoom] resp.body = ${resp.body}');

    final decoded = _decodeJsonMap(
      resp.body,
      errorPrefix: 'getRoom',
      statusCode: resp.statusCode,
    );

    _throwIfErrorFieldExists(
      decoded,
      defaultMessage: 'getRoom 失敗(${resp.statusCode})',
    );

    if (resp.statusCode != 200) {
      throw Exception('getRoom 失敗(${resp.statusCode}): ${resp.body}');
    }

    final data = decoded['data'];
    if (data is! List) {
      throw Exception('getRoom 回傳格式錯誤: data 不是 List');
    }

    if (data.isEmpty) {
      throw Exception('找不到對應聊天室');
    }

    final first = data.first;
    if (first is! Map<String, dynamic>) {
      throw Exception('getRoom 回傳格式錯誤: data[0] 不是物件');
    }

    return ChatRoom.fromJson(Map<String, dynamic>.from(first));
  }

  /// =============================
  /// 3. 取得我的聊天清單
  /// GET /get-my-chat-rooms
  /// =============================
  Future<List<ChatRoom>> getMyRooms() async {
    final uri = Uri.parse('$_chatBaseUrl/get-my-chat-rooms');
    final headers = _buildHeaders(requireAuth: true);

    logger.logDebug('[getMyRooms] GET $uri');
    _logToken('getMyRooms');

    http.Response resp;
    try {
      resp = await _client.get(uri, headers: headers);
    } catch (e, st) {
      logger.logError('[getMyRooms] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[getMyRooms] status = ${resp.statusCode}');
    logger.logDebug('[getMyRooms] resp.body = ${resp.body}');

    final decoded = _decodeJsonMap(
      resp.body,
      errorPrefix: 'getMyRooms',
      statusCode: resp.statusCode,
    );

    _throwIfErrorFieldExists(
      decoded,
      defaultMessage: 'getMyRooms 失敗(${resp.statusCode})',
    );

    if (resp.statusCode != 200) {
      throw Exception('getMyRooms 失敗(${resp.statusCode}): ${resp.body}');
    }

    final data = decoded['data'];
    if (data is! List) {
      throw Exception('getMyRooms 回傳格式錯誤: data 不是 List');
    }

    return data.map((e) {
      if (e is! Map<String, dynamic>) {
        throw Exception('getMyRooms 回傳格式錯誤: data 內含非物件項目');
      }
      return ChatRoom.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  }

  /// =============================
  /// 4. 取得聊天室歷史訊息
  /// GET /chat-messages?room_id=1&limit=50
  ///
  /// 文件：
  /// - room_id 必填
  /// - limit 預設 50，最大 200
  /// - 回傳依 created_at 升冪（最舊到最新）
  /// =============================
  Future<ChatMessageListResponse> getMessages({
    required int roomId,
    int limit = 50,
    int? beforeMessageId,
  }) async {
    final safeLimit = limit <= 0 ? 50 : (limit > 200 ? 200 : limit);

    final uri = Uri.parse('$_chatBaseUrl/chat-messages').replace(
      queryParameters: <String, String>{
        'room_id': '$roomId',
        'limit': '$safeLimit',
        if (beforeMessageId != null && beforeMessageId > 0)
          'before_message_id': '$beforeMessageId',
      },
    );
    final headers = _buildHeaders(requireAuth: true);

    logger.logDebug('[getMessages] GET $uri');
    _logToken('getMessages');

    http.Response resp;
    try {
      resp = await _client.get(uri, headers: headers);
    } catch (e, st) {
      logger.logError('[getMessages] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[getMessages] status = ${resp.statusCode}');
    logger.logDebug('[getMessages] resp.body = ${resp.body}');

    final decoded = _decodeJsonMap(
      resp.body,
      errorPrefix: 'getMessages',
      statusCode: resp.statusCode,
    );

    logger.logPretty('[getMessages] decoded', decoded);

    _throwIfErrorFieldExists(
      decoded,
      defaultMessage: 'getMessages 失敗(${resp.statusCode})',
    );

    if (resp.statusCode != 200) {
      throw Exception('getMessages 失敗(${resp.statusCode}): ${resp.body}');
    }

    final data = decoded['data'];
    if (data is List) {
      logger.logDebug('[getMessages] message count = ${data.length}');
      if (data.isNotEmpty) {
        final first = data.first;
        if (first is Map<String, dynamic>) {
          logger.logPretty('[getMessages] first message raw', first);
          logger.logDebug(
            '[getMessages] first message has nickname=${first.containsKey('nickname')}, '
            'full_name=${first.containsKey('full_name')}, '
            'avatar_url=${first.containsKey('avatar_url')}',
          );
        } else {
          logger.logDebug(
            '[getMessages] first message raw type = ${first.runtimeType}',
          );
        }
      }
    } else {
      logger.logDebug(
        '[getMessages] decoded data is not a List: ${data.runtimeType}',
      );
    }

    return ChatMessageListResponse.fromJson(decoded);
  }

  /// =============================
  /// 5. 發送訊息
  /// POST /chat-messages
  /// body:
  /// {
  ///   "room_id": 1,
  ///   "message": "我到了"
  /// }
  ///
  /// 文件成功格式：
  /// {
  ///   "data": { ...chat_message... }
  /// }
  /// =============================
  Future<ChatMessage> sendMessage({
    required int roomId,
    String? message,
    String messageType = 'text',
    String? imageUrl,
    String? clientId,
  }) async {
    final normalizedType =
        messageType.trim().isEmpty ? 'text' : messageType.trim();
    final trimmed = (message ?? '').trim();
    final safeImageUrl = imageUrl?.trim();

    if (normalizedType == 'text' && trimmed.isEmpty) {
      throw Exception('訊息內容不可為空');
    }

    if (normalizedType == 'image' &&
        (safeImageUrl == null || safeImageUrl.isEmpty)) {
      throw Exception('圖片訊息缺少 imageUrl');
    }

    final uri = Uri.parse('$_chatBaseUrl/chat-messages');
    final headers = _buildHeaders(requireAuth: true);

    final body = <String, dynamic>{
      'room_id': roomId,
      if (trimmed.isNotEmpty) 'message': trimmed,
      'message_type': normalizedType,
      if (safeImageUrl != null && safeImageUrl.isNotEmpty)
        'image_url': safeImageUrl,
      if (clientId != null && clientId.trim().isNotEmpty)
        'client_id': clientId.trim(),
    };

    logger.logDebug('[sendMessage] POST $uri');
    logger.logDebug('[sendMessage] body = $body');
    _logToken('sendMessage');

    http.Response resp;
    try {
      resp = await _client.post(uri, headers: headers, body: jsonEncode(body));
    } catch (e, st) {
      logger.logError('[sendMessage] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[sendMessage] status = ${resp.statusCode}');
    logger.logDebug('[sendMessage] resp.body = ${resp.body}');

    final decoded = _decodeJsonMap(
      resp.body,
      errorPrefix: 'sendMessage',
      statusCode: resp.statusCode,
    );

    _throwIfErrorFieldExists(
      decoded,
      defaultMessage: 'sendMessage 失敗(${resp.statusCode})',
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('sendMessage 失敗(${resp.statusCode}): ${resp.body}');
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('sendMessage 回傳格式錯誤: data 不是物件');
    }

    return ChatMessage.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> markRoomRead({
    required int roomId,
    required int lastReadMessageId,
  }) async {
    final uri = Uri.parse('$_chatBaseUrl/chat-rooms/read');
    final headers = _buildHeaders(requireAuth: true);
    final body = <String, dynamic>{
      'room_id': roomId,
      'last_read_message_id': lastReadMessageId,
    };

    logger.logDebug('[markRoomRead] POST $uri');
    logger.logDebug('[markRoomRead] body = $body');

    final resp = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    logger.logDebug('[markRoomRead] status = ${resp.statusCode}');
    logger.logDebug('[markRoomRead] resp.body = ${resp.body}');

    final decoded = _decodeJsonMap(
      resp.body,
      errorPrefix: 'markRoomRead',
      statusCode: resp.statusCode,
    );
    _throwIfErrorFieldExists(
      decoded,
      defaultMessage: 'markRoomRead 失敗(${resp.statusCode})',
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('markRoomRead 失敗(${resp.statusCode}): ${resp.body}');
    }
  }

  Future<List<ChatRoom>> searchChatRooms({required String query}) async {
    final uri = Uri.parse(
      '$_chatBaseUrl/search-chat-rooms',
    ).replace(queryParameters: <String, String>{'q': query.trim()});
    final decoded = await _getJson(uri, logTag: 'searchChatRooms');
    final data = decoded['data'];
    if (data is! List) {
      throw Exception('searchChatRooms 回傳格式錯誤: data 不是 List');
    }
    return data.map((e) {
      if (e is! Map<String, dynamic>) {
        throw Exception('searchChatRooms 回傳格式錯誤: data 內含非物件項目');
      }
      return ChatRoom.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  }

  Future<List<ChatMessage>> searchChatMessages({
    required int roomId,
    required String query,
    int limit = 50,
    int? beforeMessageId,
  }) async {
    final safeLimit = limit <= 0 ? 50 : (limit > 100 ? 100 : limit);
    final uri = Uri.parse('$_chatBaseUrl/search-chat-messages').replace(
      queryParameters: <String, String>{
        'room_id': '$roomId',
        'q': query.trim(),
        'limit': '$safeLimit',
        if (beforeMessageId != null && beforeMessageId > 0)
          'before_message_id': '$beforeMessageId',
      },
    );
    final decoded = await _getJson(uri, logTag: 'searchChatMessages');
    return ChatMessageListResponse.fromJson(decoded).data;
  }

  Future<List<ChatUser>> searchChatUsers({
    required String query,
    int limit = 20,
  }) async {
    final safeLimit = limit <= 0 ? 20 : (limit > 100 ? 100 : limit);
    final uri = Uri.parse('$_chatBaseUrl/search-chat-users').replace(
      queryParameters: <String, String>{
        'q': query.trim(),
        'limit': '$safeLimit',
      },
    );
    final decoded = await _getJson(uri, logTag: 'searchChatUsers');
    final data = decoded['data'];
    if (data is! List) {
      throw Exception('searchChatUsers 回傳格式錯誤: data 不是 List');
    }
    return data.map((e) {
      if (e is! Map<String, dynamic>) {
        throw Exception('searchChatUsers 回傳格式錯誤: data 內含非物件項目');
      }
      return ChatUser.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  }

  Future<Map<String, dynamic>> _getJson(
    Uri uri, {
    required String logTag,
  }) async {
    final headers = _buildHeaders(requireAuth: true);
    logger.logDebug('[$logTag] GET $uri');

    final resp = await _client.get(uri, headers: headers);
    logger.logDebug('[$logTag] status = ${resp.statusCode}');
    logger.logDebug('[$logTag] resp.body = ${resp.body}');

    final decoded = _decodeJsonMap(
      resp.body,
      errorPrefix: logTag,
      statusCode: resp.statusCode,
    );
    _throwIfErrorFieldExists(
      decoded,
      defaultMessage: '$logTag 失敗(${resp.statusCode})',
    );

    if (resp.statusCode != 200) {
      throw Exception('$logTag 失敗(${resp.statusCode}): ${resp.body}');
    }

    return decoded;
  }

  /// =============================
  /// Realtime：訂閱聊天室訊息
  /// 只訂閱 INSERT
  /// filter: room_id=eq.{roomId}
  /// =============================
  RealtimeChannel subscribeRoomMessages({
    required int roomId,
    required void Function(ChatMessage message) onInsert,
    void Function(Object error)? onError,
    void Function(RealtimeSubscribeStatus status)? onStatus,
  }) {
    final old = _roomChannels[roomId];
    if (old != null) {
      logger.logDebug(
        '[subscribeRoomMessages] remove old channel for roomId=$roomId',
      );
      _supabase.removeChannel(old);
      _roomChannels.remove(roomId);
    }

    final channel = _supabase.channel('chat-room-$roomId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'chat_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'room_id',
        value: roomId.toString(),
      ),
      callback: (payload) {
        try {
          final record = payload.newRecord;
          final msg = ChatMessage.fromJson(record);
          logger.logDebug(
            '[subscribeRoomMessages] INSERT received: ${msg.toJson()}',
          );
          onInsert(msg);
        } catch (e, st) {
          logger.logError('[subscribeRoomMessages] parse error: $e');
          logger.logError(st.toString());
          onError?.call(e);
        }
      },
    );

    channel.subscribe((status, [error]) {
      logger.logDebug(
        '[subscribeRoomMessages] roomId=$roomId status=$status error=$error',
      );
      onStatus?.call(status);
      if (error != null) {
        onError?.call(error);
      }
    });

    _roomChannels[roomId] = channel;
    return channel;
  }

  /// 取消單一聊天室訂閱
  Future<void> unsubscribeRoomMessages(int roomId) async {
    final channel = _roomChannels.remove(roomId);
    if (channel == null) return;

    logger.logDebug('[unsubscribeRoomMessages] roomId=$roomId');
    await _supabase.removeChannel(channel);
  }

  /// 取消所有聊天室訂閱
  Future<void> unsubscribeAllRoomMessages() async {
    final entries = _roomChannels.entries.toList();
    _roomChannels.clear();

    for (final entry in entries) {
      logger.logDebug('[unsubscribeAllRoomMessages] roomId=${entry.key}');
      await _supabase.removeChannel(entry.value);
    }
  }

  Future<void> dispose() async {
    await unsubscribeAllRoomMessages();
    _client.close();
  }
}
