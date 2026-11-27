import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ads/ad.dart';
import '../utils/log_utils.dart';

class AdsService {
  AdsService({http.Client? client}) : _client = client ?? http.Client();

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

  Future<AdListResponse> getAds({String? placement, int limit = 20}) async {
    final safeLimit = limit <= 0 ? 20 : (limit > 100 ? 100 : limit);
    final uri = Uri.parse('$_baseUrl/get-ads').replace(
      queryParameters: <String, String>{
        if (placement != null && placement.trim().isNotEmpty)
          'placement': placement.trim(),
        'limit': '$safeLimit',
      },
    );
    final headers = _buildHeaders();

    logger.logDebug('[getAds] GET $uri');

    http.Response resp;
    try {
      resp = await _client.get(uri, headers: headers);
    } catch (e, st) {
      logger.logError('[getAds] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[getAds] status = ${resp.statusCode}');
    logger.logDebug('[getAds] resp.body = ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('get-ads 失敗(${resp.statusCode}): ${resp.body}');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (e) {
      throw Exception('get-ads JSON parse 失敗: $e, body=${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('get-ads 回傳格式錯誤: ${resp.body}');
    }

    if (decoded['error'] != null) {
      throw Exception(decoded['error'].toString());
    }

    return AdListResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<AdListResponse> getStartupPopups({int limit = 10}) async {
    final safeLimit = limit <= 0 ? 10 : (limit > 20 ? 20 : limit);
    final uri = Uri.parse(
      '$_baseUrl/startup-popups',
    ).replace(queryParameters: <String, String>{'limit': '$safeLimit'});
    final headers = _buildHeaders();

    logger.logDebug('[startup-popups] GET $uri');

    http.Response resp;
    try {
      resp = await _client.get(uri, headers: headers);
    } catch (e, st) {
      logger.logError('[startup-popups] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[startup-popups] status = ${resp.statusCode}');
    logger.logDebug('[startup-popups] resp.body = ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('startup-popups 失敗(${resp.statusCode}): ${resp.body}');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (e) {
      throw Exception('startup-popups JSON parse 失敗: $e, body=${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('startup-popups 回傳格式錯誤: ${resp.body}');
    }

    if (decoded['error'] != null) {
      throw Exception(decoded['error'].toString());
    }

    return AdListResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

  void dispose() {
    _client.close();
  }
}
