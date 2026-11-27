DateTime? _parseDateTime(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _toNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

class SearchActivityItem {
  final int id;
  final String type;
  final String? hostId;
  final String? merchantId;
  final String title;
  final String description;
  final String? imageUrl;
  final String location;
  final dynamic mapData;
  final DateTime? startTime;
  final int maxParticipants;
  final String status;
  final String? remarks;
  final DateTime? createdAt;

  const SearchActivityItem({
    required this.id,
    required this.type,
    required this.hostId,
    required this.merchantId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.mapData,
    required this.startTime,
    required this.maxParticipants,
    required this.status,
    required this.remarks,
    required this.createdAt,
  });

  factory SearchActivityItem.fromJson(Map<String, dynamic> json) {
    return SearchActivityItem(
      id: _toInt(json['id']),
      type: (json['type'] ?? 'activity').toString(),
      hostId: _toNullableString(json['host_id']),
      merchantId: _toNullableString(json['merchant_id']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: _toNullableString(json['image_url']),
      location: (json['location'] ?? '').toString(),
      mapData: json['map_data'],
      startTime: _parseDateTime(json['start_time']),
      maxParticipants: _toInt(json['max_participants']),
      status: (json['status'] ?? '').toString(),
      remarks: _toNullableString(json['remarks']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }
}

class SearchActivityListResponse {
  final List<SearchActivityItem> data;
  final int? total;
  final int? page;
  final int? limit;

  const SearchActivityListResponse({
    required this.data,
    this.total,
    this.page,
    this.limit,
  });

  factory SearchActivityListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is! List) {
      throw Exception('SearchActivityListResponse 解析失敗：data 不是陣列');
    }

    return SearchActivityListResponse(
      data:
          raw.map((item) {
            if (item is! Map<String, dynamic>) {
              throw Exception('SearchActivityListResponse 解析失敗：data 內含非物件項目');
            }
            return SearchActivityItem.fromJson(Map<String, dynamic>.from(item));
          }).toList(),
      total: json['total'] == null ? null : _toInt(json['total']),
      page: json['page'] == null ? null : _toInt(json['page']),
      limit: json['limit'] == null ? null : _toInt(json['limit']),
    );
  }
}
