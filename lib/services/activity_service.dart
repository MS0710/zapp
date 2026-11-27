// services/activity_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/utils/log_utils.dart';

import '../models/activity.dart';
import '../models/activity_applicant.dart';
import '../models/activity_detail.dart';
import '../models/activity_map.dart';
import '../models/my_activity.dart';

class ActivityService {
  ActivityService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static bool _didLogFullGetActivitiesToken = false;

  SupabaseClient get _supabase => Supabase.instance.client;

  // 文件給的 Base URL
  static const String _baseUrl =
      'https://qxauaoytegxmrmtxdjqk.supabase.co/functions/v1';
  static const String _apiBaseUrl =
      'https://qxauaoytegxmrmtxdjqk.supabase.co/api';

  /// =============================
  /// 取得活動列表（HTTP 版）
  /// POST /functions/v1/get-activities
  /// =============================
  Future<ActivityListResponse> getActivities({
    int page = 1,
    String? keyword,
  }) async
  {
    final uri = Uri.parse('$_baseUrl/get-activities');
    logger.logDebug("[getActivities] uri = $uri");

    final session = _supabase.auth.currentSession;
    final token = session?.accessToken;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{
      'page': page,
      if (keyword != null && keyword.trim().isNotEmpty)
        'keyword': keyword.trim(),
    };

    // ===== Debug log（請求）=====
    logger.logDebug('[getActivities] POST $uri');
    logger.logDebug('[getActivities] body = $body');
    logger.logDebug(
      '[getActivities] token = ${token == null ? 'null' : '${token.substring(0, 20)}...'}',
    );
    if (!_didLogFullGetActivitiesToken && token != null && token.isNotEmpty) {
      _didLogFullGetActivitiesToken = true;
      logger.logDebug('[getActivities] full token = $token');
    }

    http.Response resp;
    try {
      resp = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e, st) {
      logger.logError('[getActivities] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    // ===== Debug log（回應）=====
    logger.logDebug('[getActivities] status = ${resp.statusCode}');
    logger.logDebug('[getActivities] resp.body = ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('get-activities 失敗(${resp.statusCode}): ${resp.body}');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (e) {
      throw Exception('get-activities JSON parse 失敗: $e, body=${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('get-activities 回傳格式錯誤: ${resp.body}');
    }

    return ActivityListResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

  /// =============================
  /// 取得活動詳情
  /// POST /functions/v1/get-activity-detail
  /// body: { "id": 2 }
  /// 不需要登入，但若有登入會顯示 is_joined / my_status
  /// =============================
  Future<ActivityDetailResponse> getActivityDetail({
    required int id,
  }) async
  {
    final uri = Uri.parse('$_baseUrl/get-activity-detail');
    logger.logDebug('[getActivityDetail] uri = $uri');

    final token = _supabase.auth.currentSession?.accessToken;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{'id': id};

    logger.logDebug('[getActivityDetail] POST $uri');
    logger.logDebug('[getActivityDetail] body = $body');
    logger.logDebug(
      '[getActivityDetail] token = ${token == null ? 'null' : '${token.substring(0, 20)}...'}',
    );

    http.Response resp;
    try {
      resp = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e, st) {
      logger.logError('[getActivityDetail] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[getActivityDetail] status = ${resp.statusCode}');
    logger.logDebug('[getActivityDetail] resp.body = ${resp.body}');

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (e) {
      throw Exception('get-activity-detail JSON parse 失敗: $e, body=${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('get-activity-detail 回傳格式錯誤: ${resp.body}');
    }

    // 後端若用 { "error": "..." } 回錯
    if (decoded['error'] != null) {
      throw Exception(decoded['error'].toString());
    }

    if (resp.statusCode != 200) {
      throw Exception('get-activity-detail 失敗(${resp.statusCode}): ${resp.body}');
    }

    return ActivityDetailResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

  /// =============================
  /// 建立活動（HTTP 版）
  /// POST /functions/v1/create-activity
  /// 需要登入（會帶 Bearer token）
  /// =============================
  Future<ActivityItem> createActivity({
    required String title,
    required String description,
    required DateTime startTime,
    required String location,
    required int maxParticipants,
    String? imageUrl,
    String? remarks,
  }) async
  {
    final uri = Uri.parse('$_baseUrl/create-activity');

    final session = _supabase.auth.currentSession;
    final token = session?.accessToken;

    if (token == null || token.isEmpty) {
      throw Exception('create-activity 需要登入，但目前沒有 session token');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{
      'title': title,
      'description': description,
      // 文件格式：2026-01-15T14:00:00+08:00
      // Dart 的 toIso8601String() 可能是 Z / 或 +00:00
      // 先用 toIso8601String，後端若需要 +08:00 再調整
      'start_time': startTime.toIso8601String(),
      'location': location,
      'max_participants': maxParticipants,
      'remarks': remarks ?? '',
      if (imageUrl != null && imageUrl.trim().isNotEmpty)
        'image_url': imageUrl.trim(),
    };

    logger.logDebug('[createActivity] POST $uri');
    logger.logDebug('[createActivity] body = $body');
    logger.logDebug('[createActivity] token = ${token.substring(0, 20)}...');

    final resp = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    logger.logDebug('[createActivity] status = ${resp.statusCode}');
    logger.logDebug('[createActivity] resp.body = ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('create-activity 失敗(${resp.statusCode}): ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('create-activity 回傳格式錯誤: ${resp.body}');
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('create-activity 回傳缺少 data: ${resp.body}');
    }

    return ActivityItem.fromJson(Map<String, dynamic>.from(data));
  }

  /// =============================
  /// 加入活動（報名）
  /// POST /functions/v1/join-activity
  /// 需要登入
  /// body: { "activity_id": 2 }
  /// success: { "message": "Join request sent, waiting for approval" }
  /// error:   { "error": "Activity is full" / ... }
  /// =============================
  Future<String> joinActivity({
    required int activityId,
  }) async
  {
    final uri = Uri.parse('$_baseUrl/join-activity');

    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('join-activity 需要登入，但目前沒有 session token');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{
      'activity_id': activityId,
    };

    // ===== Debug log（請求）=====
    logger.logDebug('[joinActivity] POST $uri');
    logger.logDebug('[joinActivity] body = $body');
    logger.logDebug('[joinActivity] token = ${token.substring(0, 20)}...');

    final resp = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    // ===== Debug log（回應）=====
    logger.logDebug('[joinActivity] status = ${resp.statusCode}');
    logger.logDebug('[joinActivity] resp.body = ${resp.body}');

    // 不是 200 也可能會回 JSON error，先解析看看
    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (_) {
      // 若後端不是 JSON，直接丟原文
      throw Exception('join-activity 失敗(${resp.statusCode}): ${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('join-activity 回傳格式錯誤: ${resp.body}');
    }

    if (decoded['error'] != null) {
      throw Exception(decoded['error'].toString());
    }

    final msg = decoded['message']?.toString();
    if (resp.statusCode == 200 && msg != null) return msg;

    // 其他狀況保底
    throw Exception('join-activity 失敗(${resp.statusCode}): ${resp.body}');
  }

  /// =============================
  /// 取得活動地圖資料
  /// GET /functions/v1/get-activity-maps
  /// =============================
  Future<ActivityMapListResponse> getActivityMaps({
    String? type,
    String? merchantId,
    bool includeClosed = false,
    bool onlyWithMap = true,
  }) async
  {
    if (type != null &&
        type != 'activity' &&
        type != 'merchant_activity') {
      throw Exception('type 只能是 activity 或 merchant_activity');
    }

    final queryParameters = <String, String>{
      if (type != null && type.isNotEmpty) 'type': type,
      if (merchantId != null && merchantId.trim().isNotEmpty)
        'merchant_id': merchantId.trim(),
      if (includeClosed) 'include_closed': 'true',
      if (!onlyWithMap) 'only_with_map': 'false',
    };

    final uri = Uri.parse('$_baseUrl/get-activity-maps').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final token = _supabase.auth.currentSession?.accessToken;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    logger.logDebug('[getActivityMaps] GET $uri');
    logger.logDebug(
      '[getActivityMaps] token = ${token == null ? 'null' : '${token.substring(0, 20)}...'}',
    );

    http.Response resp;
    try {
      resp = await _client.get(uri, headers: headers);
    } catch (e, st) {
      logger.logError('[getActivityMaps] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[getActivityMaps] status = ${resp.statusCode}');
    logger.logDebug('[getActivityMaps] resp.body = ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('activity-maps 失敗(${resp.statusCode}): ${resp.body}');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (e) {
      throw Exception('activity-maps JSON parse 失敗: $e, body=${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('activity-maps 回傳格式錯誤: ${resp.body}');
    }

    if (decoded['error'] != null) {
      throw Exception(decoded['error'].toString());
    }

    return ActivityMapListResponse.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  /// =============================
  /// 取得我發布的活動列表
  /// POST /functions/v1/get-my-activities
  /// body: { "user_id": "<uuid>", "page": 1 }
  /// 回傳每筆多 joined_count / pending_count
  /// =============================
  Future<MyActivityListResponse> getMyActivities({
    required String userId,
    int page = 1,
  }) async
  {
    final uri = Uri.parse('$_baseUrl/get-my-activities');

    final token = _supabase.auth.currentSession?.accessToken;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{
      'user_id': userId,
      'page': page,
    };

    logger.logDebug('[getMyActivities] POST $uri');
    logger.logDebug('[getMyActivities] body = $body');
    if (token != null && token.isNotEmpty) {
      logger.logDebug('[getMyActivities] token head = ${token.substring(0, 20)}...');
    } else {
      logger.logDebug('[getMyActivities] token = <empty>');
    }

    final resp = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    logger.logDebug('[getMyActivities] status = ${resp.statusCode}');
    logger.logDebug('[getMyActivities] resp.body = ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('get-my-activities 失敗(${resp.statusCode}): ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('get-my-activities 回傳格式錯誤: ${resp.body}');
    }

    return MyActivityListResponse.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  /// =============================
  /// 取得活動申請者列表（主揪用）
  /// POST /get-activity-applicants
  /// body: { user_id, activity_id }
  /// =============================
  Future<ActivityApplicantsResponse> getActivityApplicants({
    required int activityId,
    String? userId, // 文件說暫時用 user_id 參數
  }) async
  {
    final uri = Uri.parse('$_baseUrl/get-activity-applicants');

    final token = _supabase.auth.currentSession?.accessToken;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final uid = userId ?? _supabase.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      throw Exception('尚未登入，找不到 user_id');
    }

    final body = {
      'user_id': uid,
      'activity_id': activityId,
    };

    logger.logDebug('[getActivityApplicants] POST $uri');
    logger.logDebug('[getActivityApplicants] body = $body');

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    logger.logDebug('[getActivityApplicants] status=${resp.statusCode}');
    logger.logDebug('[getActivityApplicants] resp.body=${resp.body}');

    if (resp.statusCode != 200) {
      // 後端可能回 {"error":"Only the host can view applicants"}
      throw Exception('get-activity-applicants 失敗(${resp.statusCode}): ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('get-activity-applicants 回傳格式錯誤: ${resp.body}');
    }

    return ActivityApplicantsResponse.fromJson(decoded);
  }

  /// =============================
  /// 審核參與者（主揪專用）
  /// POST /functions/v1/review-participant
  /// body: { "activity_id": 2, "user_id": "<uuid>", "action": "approve" | "reject" }
  /// success: { "message": "Participant approved successfully" / "Participant rejected successfully" }
  /// error:   { "error": "Only the host can review participants" / "Activity is full. Cannot approve more participants." }
  /// =============================
  Future<String> reviewParticipant({
    required int activityId,
    required String userId,
    required String action, // "approve" | "reject"
  }) async
  {
    if (action != 'approve' && action != 'reject') {
      throw Exception('review-participant action 必須是 approve 或 reject');
    }

    final uri = Uri.parse('$_baseUrl/review-participant');

    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('review-participant 需要登入，但目前沒有 session token');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{
      'activity_id': activityId,
      'user_id': userId,
      'action': action,
    };

    // ===== Debug log（請求）=====
    logger.logDebug('[reviewParticipant] POST $uri');
    logger.logDebug('[reviewParticipant] body = $body');
    logger.logDebug('[reviewParticipant] token = ${token.substring(0, 20)}...');

    http.Response resp;
    try {
      resp = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e, st) {
      logger.logError('[reviewParticipant] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    // ===== Debug log（回應）=====
    logger.logDebug('[reviewParticipant] status = ${resp.statusCode}');
    logger.logDebug('[reviewParticipant] resp.body = ${resp.body}');

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (_) {
      throw Exception('review-participant 失敗(${resp.statusCode}): ${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('review-participant 回傳格式錯誤: ${resp.body}');
    }


    if (decoded['error'] != null) {
      throw Exception(decoded['error'].toString());
    }
    
    final msg = decoded['message']?.toString();
    if (resp.statusCode == 200 && msg != null) return msg;

    // 其他狀況保底
    throw Exception('review-participant 失敗(${resp.statusCode}): ${resp.body}');
  }

  /// =============================
  /// 編輯活動（主揪專用）
  /// POST /functions/v1/update-activity
  /// body: {
  ///   "user_id": "<uuid>",
  ///   "activity_id": 5,
  ///   ...只帶要更新的欄位...
  /// }
  /// 可更新欄位：
  /// title, description, location, start_time, max_participants,
  /// image_url, remarks, status(open/closed)
  ///
  /// success: { "data": { ...activity... } }
  /// error:   { "error": "Only the host can update the activity" / "Activity not found" / "No fields to update" }
  /// =============================
  Future<ActivityItem> updateActivity({
    required int activityId,

    // 文件說暫時用 user_id 參數（必須是主辦人）
    String? userId,

    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    int? maxParticipants,
    String? imageUrl,
    String? remarks,
    String? status, // "open" | "closed"
  }) async
  {
    final uri = Uri.parse('$_baseUrl/update-activity');

    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('update-activity 需要登入，但目前沒有 session token');
    }

    final uid = userId ?? _supabase.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      throw Exception('update-activity 缺少 user_id（尚未登入）');
    }

    // 只放「要更新」的欄位，避免覆蓋成空值
    final body = <String, dynamic>{
      'user_id': uid,
      'activity_id': activityId,
    };

    void putIfValid(String key, String? v) {
      if (v == null) return;
      final s = v.trim();
      if (s.isEmpty) return;
      body[key] = s;
    }

    putIfValid('title', title);
    putIfValid('description', description);
    putIfValid('location', location);
    putIfValid('image_url', imageUrl);
    putIfValid('remarks', remarks);

    if (startTime != null) {
      body['start_time'] = startTime.toIso8601String();
    }
    if (maxParticipants != null) {
      body['max_participants'] = maxParticipants;
    }
    if (status != null && status.trim().isNotEmpty) {
      final s = status.trim();
      if (s != 'open' && s != 'closed') {
        throw Exception('update-activity status 只能是 open 或 closed');
      }
      body['status'] = s;
    }

    // 如果除了 user_id / activity_id 沒有任何更新欄位，就直接擋掉
    if (body.length <= 2) {
      throw Exception('update-activity 沒有要更新的欄位（No fields to update）');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // ===== Debug log（請求）=====
    logger.logDebug('[updateActivity] POST $uri');
    logger.logDebug('[updateActivity] body = $body');
    logger.logDebug('[updateActivity] token = ${token.substring(0, 20)}...');

    http.Response resp;
    try {
      resp = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e, st) {
      logger.logError('[updateActivity] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    // ===== Debug log（回應）=====
    logger.logDebug('[updateActivity] status = ${resp.statusCode}');
    logger.logDebug('[updateActivity] resp.body = ${resp.body}');

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (_) {
      throw Exception('update-activity 失敗(${resp.statusCode}): ${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('update-activity 回傳格式錯誤: ${resp.body}');
    }

    // 後端錯誤格式：{ "error": "..." }
    if (decoded['error'] != null) {
      throw Exception(decoded['error'].toString());
    }

    if (resp.statusCode != 200) {
      throw Exception('update-activity 失敗(${resp.statusCode}): ${resp.body}');
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('update-activity 回傳缺少 data: ${resp.body}');
    }

    return ActivityItem.fromJson(Map<String, dynamic>.from(data));
  }

  void dispose() {
    _client.close();
  }
}
