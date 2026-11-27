// lib/services/geocoding_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:zapp/utils/log_utils.dart';

class GeocodingService {
  // 🔹 static 專用的 Logger 實例
  static final Logger _logger = Logger('GeocodingService');

  static Future<LatLng?> geocode(String address) async {
    try {
      if (address.trim().isEmpty) return null;

      // 把「臺」換成「台」，提升命中率
      final normalized = address.replaceAll('臺', '台');

      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': normalized,
        'format': 'json',
        'addressdetails': '1',
        'limit': '1',
        'accept-language': 'zh-TW',
      });

      // ✅ 這裡用 _logger，就不是 instance 成員了
      _logger.logDebug('[Geocode] url = $uri');

      final resp = await http.get(
        uri,
        headers: {
          'User-Agent': 'zapp/1.0 (https://your-domain.com/contact)',
        },
      );

      _logger.logDebug(
        '[Geocode] status = ${resp.statusCode}, body = ${resp.body}',
      );

      if (resp.statusCode != 200) {
        _logger.logError(
          '[Geocode] HTTP error status=${resp.statusCode}, body=${resp.body}',
        );
        return null;
      }

      final data = jsonDecode(resp.body);

      if (data is! List || data.isEmpty) {
        _logger.logError('[Geocode] empty result for "$normalized"');
        return null;
      }

      final first = data[0];
      final latStr = first['lat']?.toString();
      final lonStr = first['lon']?.toString();

      if (latStr == null || lonStr == null) {
        _logger.logError('[Geocode] lat/lon missing in response: $first');
        return null;
      }

      final lat = double.tryParse(latStr);
      final lon = double.tryParse(lonStr);

      if (lat == null || lon == null) {
        _logger.logError(
          '[Geocode] lat/lon parse error: lat=$latStr lon=$lonStr',
        );
        return null;
      }

      return LatLng(lat, lon);
    } catch (e, st) {
      _logger.logError('[Geocode] exception: $e');
      _logger.logError(st.toString());
      return null;
    }
  }
}
