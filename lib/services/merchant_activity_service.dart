import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/merchant_activity.dart';
import '../utils/log_utils.dart';

class MerchantActivityService {
  MerchantActivityService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  // 跟文件一樣的 Base URL
  static const String _baseUrl =
      'https://qxauaoytegxmrmtxdjqk.supabase.co/functions/v1';

  // ⚠ 這裡直接寫 anon key，之後你可以抽到共用 config
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4YXVhb3l0ZWd4bXJtdHhkanFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5NjEzNTIsImV4cCI6MjA4MjUzNzM1Mn0.nN7Qx-W2P7Hox6e7VB9hMyrLwQ99udR7hhpOKbK9P1c';

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_anonKey',
  };

  /// =============================
  /// 取得商家活動列表
  /// GET /functions/v1/get-merchant-activities
  /// 若帶 merchantId → 只回該商家活動
  /// 若不帶 → 回所有商家的活動
  /// =============================
  Future<List<MerchantActivity>> getMerchantActivities({
    String? merchantId,
  }) async {
    final uri = Uri.parse('$_baseUrl/get-merchant-activities').replace(
      queryParameters: {
        if (merchantId != null && merchantId.trim().isNotEmpty)
          'merchant_id': merchantId.trim(),
      },
    );

    logger.logDebug('[getMerchantActivities] GET $uri');

    http.Response resp;
    try {
      resp = await _client.get(uri, headers: _headers);
    } catch (e, st) {
      logger.logError('[getMerchantActivities] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    logger.logDebug('[getMerchantActivities] status = ${resp.statusCode}');
    logger.logDebug('[getMerchantActivities] resp.body = ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception(
        'get-merchant-activities 失敗(${resp.statusCode}): ${resp.body}',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (e) {
      throw Exception(
        'get-merchant-activities JSON parse 失敗: $e, body=${resp.body}',
      );
    }

    if (decoded is! List) {
      throw Exception(
        'get-merchant-activities 應回傳陣列，但實際為: ${resp.body}',
      );
    }

    return decoded
        .map((e) => MerchantActivity.fromJson(
      Map<String, dynamic>.from(e as Map),
    ))
        .toList();
  }

  void dispose() {
    _client.close();
  }
}