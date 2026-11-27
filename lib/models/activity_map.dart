import 'dart:convert';

class ActivityMapItem {
  final int id;
  final String type;
  final String title;
  final String location;
  final String? mapDataRaw;
  final dynamic mapDataParsed;
  final DateTime? startTime;
  final String status;
  final String? imageUrl;
  final DateTime? createdAt;

  const ActivityMapItem({
    required this.id,
    required this.type,
    required this.title,
    required this.location,
    required this.mapDataRaw,
    required this.mapDataParsed,
    required this.startTime,
    required this.status,
    required this.imageUrl,
    required this.createdAt,
  });

  factory ActivityMapItem.fromJson(Map<String, dynamic> json) {
    final rawMapData = _toNullableString(json['map_data']);

    return ActivityMapItem(
      id: _toInt(json['id']),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      mapDataRaw: rawMapData,
      mapDataParsed: parseMapData(rawMapData),
      startTime: _toDateTime(json['start_time']),
      status: (json['status'] ?? '').toString(),
      imageUrl: _toNullableString(json['image_url']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'location': location,
      'map_data': mapDataRaw,
      'start_time': startTime?.toIso8601String(),
      'status': status,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static dynamic parseMapData(String? mapData) {
    if (mapData == null || mapData.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(mapData);
    } catch (_) {
      return mapData;
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? _toDateTime(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}

class ActivityMapListResponse {
  final List<ActivityMapItem> data;

  const ActivityMapListResponse({
    required this.data,
  });

  factory ActivityMapListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is! List) {
      throw Exception('ActivityMapListResponse 解析失敗：data 不是陣列');
    }

    return ActivityMapListResponse(
      data: raw.map((e) {
        if (e is! Map<String, dynamic>) {
          throw Exception('ActivityMapListResponse 解析失敗：data 內含非物件項目');
        }
        return ActivityMapItem.fromJson(Map<String, dynamic>.from(e));
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
