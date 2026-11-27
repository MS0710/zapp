import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../models/upload_image_response.dart';
import '../utils/log_utils.dart';

class ImageUploadService {
  ImageUploadService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String get _anonKey => Get.find<String>(tag: 'supabaseAnon');

  static const String _baseUrl =
      'https://qxauaoytegxmrmtxdjqk.supabase.co/functions/v1';

  Future<UploadImageResponse> uploadImage({
    required String filePath,
    String folder = 'uploads',
  }) async {
    final trimmedPath = filePath.trim();
    if (trimmedPath.isEmpty) {
      throw Exception('upload-image 缺少檔案路徑');
    }

    final file = File(trimmedPath);
    if (!await file.exists()) {
      throw Exception('upload-image 找不到檔案: $trimmedPath');
    }

    final uri = Uri.parse('$_baseUrl/upload-image');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $_anonKey';

    final safeFolder = folder.trim().isEmpty ? 'uploads' : folder.trim();
    final contentType = _detectImageContentType(trimmedPath);
    if (contentType == null) {
      throw Exception('upload-image 僅支援圖片檔案');
    }

    request.fields['folder'] = safeFolder;
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        trimmedPath,
        filename: p.basename(trimmedPath),
        contentType: contentType,
      ),
    );

    logger.logDebug('[uploadImage] POST $uri');
    logger.logDebug('[uploadImage] filePath = $trimmedPath');
    logger.logDebug('[uploadImage] folder = $safeFolder');
    logger.logDebug('[uploadImage] token = ${_anonKey.substring(0, 20)}...');
    logger.logDebug('[uploadImage] contentType = ${contentType.type}/${contentType.subtype}');

    http.StreamedResponse streamedResp;
    try {
      streamedResp = await _client.send(request);
    } catch (e, st) {
      logger.logError('[uploadImage] network error: $e');
      logger.logError(st.toString());
      rethrow;
    }

    final resp = await http.Response.fromStream(streamedResp);

    logger.logDebug('[uploadImage] status = ${resp.statusCode}');
    logger.logDebug('[uploadImage] resp.body = ${resp.body}');

    dynamic decoded;
    try {
      decoded = jsonDecode(resp.body);
    } catch (e) {
      throw Exception('upload-image JSON parse 失敗: $e, body=${resp.body}');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('upload-image 回傳格式錯誤: ${resp.body}');
    }

    if (decoded['error'] != null &&
        decoded['error'].toString().trim().isNotEmpty) {
      throw Exception(decoded['error'].toString());
    }

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('upload-image 失敗(${resp.statusCode}): ${resp.body}');
    }

    return UploadImageResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

  void dispose() {
    _client.close();
  }

  MediaType? _detectImageContentType(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.webp':
        return MediaType('image', 'webp');
      case '.gif':
        return MediaType('image', 'gif');
      case '.heic':
        return MediaType('image', 'heic');
      default:
        return null;
    }
  }
}
