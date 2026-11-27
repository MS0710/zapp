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

class SearchLocationItem {
  final String location;
  final dynamic mapData;
  final int firstActivityId;
  final String firstActivityType;
  final String title;
  final DateTime? startTime;
  final String? imageUrl;
  final String? merchantId;

  const SearchLocationItem({
    required this.location,
    required this.mapData,
    required this.firstActivityId,
    required this.firstActivityType,
    required this.title,
    required this.startTime,
    required this.imageUrl,
    required this.merchantId,
  });

  factory SearchLocationItem.fromJson(Map<String, dynamic> json) {
    return SearchLocationItem(
      location: (json['location'] ?? '').toString(),
      mapData: json['map_data'],
      firstActivityId: _toInt(json['first_activity_id']),
      firstActivityType: (json['first_activity_type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      startTime: _parseDateTime(json['start_time']),
      imageUrl: _toNullableString(json['image_url']),
      merchantId: _toNullableString(json['merchant_id']),
    );
  }
}

class SearchLocationListResponse {
  final List<SearchLocationItem> data;

  const SearchLocationListResponse({required this.data});

  factory SearchLocationListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is! List) {
      throw Exception('SearchLocationListResponse 解析失敗：data 不是陣列');
    }

    return SearchLocationListResponse(
      data:
          raw.map((item) {
            if (item is! Map<String, dynamic>) {
              throw Exception('SearchLocationListResponse 解析失敗：data 內含非物件項目');
            }
            return SearchLocationItem.fromJson(Map<String, dynamic>.from(item));
          }).toList(),
    );
  }
}
