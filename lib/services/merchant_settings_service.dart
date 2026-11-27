import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/merchant_settings.dart';
import '../utils/log_utils.dart';

class MerchantSettingsService {
  MerchantSettingsService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  SupabaseClient get _supabase => Supabase.instance.client;
  String get _anonKey => Get.find<String>(tag: 'supabaseAnon');
  static const String _baseUrl =
      'https://qxauaoytegxmrmtxdjqk.supabase.co/functions/v1';
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_anonKey',
  };

  /// 取得所有商家 (不帶 id)
  Future<List<MerchantSettings>> getAllMerchants() async {
    final uri = Uri.parse('$_baseUrl/get-merchant-settings');
    logger.logDebug('[getAllMerchants] GET $uri');

    http.Response resp;
    try {
      resp = await _client.get(uri, headers: _headers);
    } catch (e, st) {
      logger.logError('[getAllMerchants] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[getAllMerchants] status = ${resp.statusCode}');
    logger.logDebug('[getAllMerchants] resp.body = ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception(
        'get-merchant-settings 失敗(${resp.statusCode}): ${resp.body}',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (e) {
      throw Exception(
        'get-merchant-settings JSON parse 失敗: $e, body=${resp.body}',
      );
    }

    if (decoded is! List) {
      throw Exception(
        'get-merchant-settings 應該回傳陣列，但實際為: ${resp.body}',
      );
    }

    return decoded
        .map((e) => MerchantSettings.fromJson(
      Map<String, dynamic>.from(e as Map),
    ))
        .toList();
  }

  /// 依 id 取得單一商家
  Future<MerchantSettings> getMerchantById(String id) async {
    final uri = Uri.parse('$_baseUrl/get-merchant-settings').replace(
      queryParameters: {'id': id},
    );
    logger.logDebug('[getMerchantById] GET $uri');

    http.Response resp;
    try {
      resp = await _client.get(uri, headers: _headers);
    } catch (e, st) {
      logger.logError('[getMerchantById] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[getMerchantById] status = ${resp.statusCode}');
    logger.logDebug('[getMerchantById] resp.body = ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception(
        'get-merchant-settings(單筆) 失敗(${resp.statusCode}): ${resp.body}',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (e) {
      throw Exception(
        'get-merchant-settings(單筆) JSON parse 失敗: $e, body=${resp.body}',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'get-merchant-settings(單筆) 回傳格式錯誤: ${resp.body}',
      );
    }

    return MerchantSettings.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  void dispose() {
    _client.close();
  }
}
