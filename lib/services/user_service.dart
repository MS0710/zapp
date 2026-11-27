// services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/utils/log_utils.dart';

class UserService {
  UserService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  SupabaseClient get _supabase => Supabase.instance.client;

  // 文件給的 Base URL（跟 ActivityService 一樣）
  static const String _baseUrl =
      'https://qxauaoytegxmrmtxdjqk.supabase.co/functions/v1';

  /// =============================
  /// 完成註冊（補填資料）
  /// POST /functions/v1/complete-registration
  /// 需要登入（Bearer token）
  ///
  /// Request Body（依文件）
  /// {
  ///   "email": "user@example.com",
  ///   "password": "newpassword",
  ///   "full_name": "王小明",
  ///   "nickname": "小明",
  ///   "birthday": "1990-01-01",
  ///   "gender": "male"
  /// }
  ///
  /// Response(成功):
  /// { "message": "Registration completed successfully" }
  /// Response(失敗):
  /// { "error": "..." }
  /// =============================
  Future<String> completeRegistration({
    required String email,
    required String password,
    required String fullName,
    required String nickname,
    required DateTime birthday,
    required String gender, // "male" | "female" | ... 依你後端規則
  }) async {
    final uri = Uri.parse('$_baseUrl/complete-registration');

    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('complete-registration 需要登入，但目前沒有 session token');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // birthday 文件是 "YYYY-MM-DD"
    final bday = _formatYyyyMmDd(birthday);

    final body = <String, dynamic>{
      'email': email.trim(),
      'password': password, // 通常不 trim，避免意外改密碼
      'full_name': fullName.trim(),
      'nickname': nickname.trim(),
      'birthday': bday,
      'gender': gender.trim(),
    };

    logger.logDebug('[completeRegistration] POST $uri');
    logger.logDebug('[completeRegistration] body = $body');
    logger.logDebug('[completeRegistration] token = ${token.substring(0, 20)}...');

    http.Response resp;
    try {
      resp = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e, st) {
      logger.logError('[completeRegistration] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[completeRegistration] status = ${resp.statusCode}');
    logger.logDebug('[completeRegistration] resp.body = ${resp.body}');

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (_) {
      throw Exception('complete-registration 失敗(${resp.statusCode}): ${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('complete-registration 回傳格式錯誤: ${resp.body}');
    }

    // 後端錯誤格式：{ "error": "..." }
    if (decoded['error'] != null) {
      throw Exception(decoded['error'].toString());
    }

    // 成功格式：{ "message": "..." }
    final msg = decoded['message']?.toString();
    if (resp.statusCode == 200 && msg != null) return msg;

    throw Exception('complete-registration 失敗(${resp.statusCode}): ${resp.body}');
  }

  // ========= helpers =========

  String _formatYyyyMmDd(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void dispose() {
    _client.close();
  }
}
