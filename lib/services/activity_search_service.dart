import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/search/search_activity_item.dart';
import '../models/search/search_location_item.dart';
import '../utils/log_utils.dart';

class ActivitySearchService {
  ActivitySearchService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  SupabaseClient get _supabase => Supabase.instance.client;

  static const String _baseUrl =
      'https://qxauaoytegxmrmtxdjqk.supabase.co/functions/v1';

  Map<String, String> _buildHeaders() {
    final token = _supabase.auth.currentSession?.accessToken;

    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<SearchActivityListResponse> searchGroupActivities({
    required String query,
    int limit = 20,
    int page = 1,
    bool includeClosed = false,
  }) async {
    final uri = Uri.parse('$_baseUrl/search-group-activities').replace(
      queryParameters: <String, String>{
        'q': query.trim(),
        'limit': '${_clampLimit(limit)}',
        'page': '${page <= 0 ? 1 : page}',
        if (includeClosed) 'include_closed': 'true',
      },
    );

    final decoded = await _getJson(uri, logTag: 'search-group-activities');
    return SearchActivityListResponse.fromJson(decoded);
  }

  Future<SearchActivityListResponse> searchActivities({
    required String query,
    String? type,
    int limit = 20,
    bool includeClosed = false,
  }) async {
    final uri = Uri.parse('$_baseUrl/search-activities').replace(
      queryParameters: <String, String>{
        'q': query.trim(),
        'limit': '${_clampLimit(limit)}',
        if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
        if (includeClosed) 'include_closed': 'true',
      },
    );

    final decoded = await _getJson(uri, logTag: 'search-activities');
    return SearchActivityListResponse.fromJson(decoded);
  }

  Future<SearchLocationListResponse> searchLocations({
    required String query,
    String? type,
    int limit = 20,
    bool includeClosed = false,
    bool onlyWithMap = true,
  }) async {
    final uri = Uri.parse('$_baseUrl/search-locations').replace(
      queryParameters: <String, String>{
        'q': query.trim(),
        'limit': '${_clampLimit(limit)}',
        if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
        if (includeClosed) 'include_closed': 'true',
        if (onlyWithMap) 'only_with_map': 'true',
      },
    );

    final decoded = await _getJson(uri, logTag: 'search-locations');
    return SearchLocationListResponse.fromJson(decoded);
  }

  Future<Map<String, dynamic>> _getJson(
    Uri uri, {
    required String logTag,
  }) async {
    logger.logDebug('[$logTag] GET $uri');

    http.Response resp;
    try {
      resp = await _client.get(uri, headers: _buildHeaders());
    } catch (e, st) {
      logger.logError('[$logTag] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[$logTag] status = ${resp.statusCode}');
    logger.logDebug('[$logTag] resp.body = ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('$logTag 失敗(${resp.statusCode}): ${resp.body}');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (e) {
      throw Exception('$logTag JSON parse 失敗: $e, body=${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('$logTag 回傳格式錯誤: ${resp.body}');
    }

    if (decoded['error'] != null) {
      throw Exception(decoded['error'].toString());
    }

    return Map<String, dynamic>.from(decoded);
  }

  int _clampLimit(int limit) {
    if (limit <= 0) return 20;
    if (limit > 100) return 100;
    return limit;
  }

  void dispose() {
    _client.close();
  }
}
