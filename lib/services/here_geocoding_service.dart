import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../utils/log_utils.dart';

class HereGeocodingService {
  HereGeocodingService({required this.apiKey});

  final String apiKey;

  Future<LatLng?> geocodeLatLng(
      String address, {
        String lang = 'zh-TW',
        int limit = 1,
      }) async {
    final q = address.trim();
    if (q.isEmpty) return null;

    final uri = Uri.https(
      'geocode.search.hereapi.com',
      '/v1/geocode',
      {
        'q': q,
        'limit': '$limit',
        'lang': lang,
        'apiKey': apiKey,
      },
    );

    logger.logDebug('[HERE] GET $uri');

    final resp = await http.get(uri);

    logger.logDebug('[HERE] status=${resp.statusCode}');
    if (resp.statusCode != 200) {
      logger.logError('[HERE] body=${resp.body}');
      return null;
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) return null;

    final items = decoded['items'];
    if (items is! List || items.isEmpty) return null;

    final first = items.first;
    if (first is! Map<String, dynamic>) return null;

    final pos = first['position'];
    if (pos is! Map<String, dynamic>) return null;

    final lat = pos['lat'];
    final lng = pos['lng'];
    if (lat is! num || lng is! num) return null;

    return LatLng(lat.toDouble(), lng.toDouble());
  }
}
