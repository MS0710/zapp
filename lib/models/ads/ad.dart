class AdItem {
  final int id;
  final String title;
  final String? subtitle;
  final String? content;
  final String? imageUrl;
  final String? targetUrl;
  final String? ctaText;
  final String? ctaAction;
  final String? ctaTarget;
  final String placement;
  final int sortOrder;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? createdAt;

  const AdItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.imageUrl,
    required this.targetUrl,
    required this.ctaText,
    required this.ctaAction,
    required this.ctaTarget,
    required this.placement,
    required this.sortOrder,
    required this.startsAt,
    required this.endsAt,
    required this.createdAt,
  });

  factory AdItem.fromJson(Map<String, dynamic> json) {
    return AdItem(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      subtitle: _toNullableString(json['subtitle']),
      content: _toNullableString(json['content']),
      imageUrl: _toNullableString(json['image_url']),
      targetUrl: _toNullableString(json['target_url']),
      ctaText: _toNullableString(json['cta_text']),
      ctaAction: _toNullableString(json['cta_action']),
      ctaTarget: _toNullableString(json['cta_target']),
      placement: (json['placement'] ?? '').toString(),
      sortOrder: _toInt(json['sort_order']),
      startsAt: _toDateTime(json['starts_at']),
      endsAt: _toDateTime(json['ends_at']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'image_url': imageUrl,
      'target_url': targetUrl,
      'cta_text': ctaText,
      'cta_action': ctaAction,
      'cta_target': ctaTarget,
      'placement': placement,
      'sort_order': sortOrder,
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
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

class AdListResponse {
  final List<AdItem> data;

  const AdListResponse({required this.data});

  factory AdListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    if (raw is! List) {
      throw Exception('AdListResponse 解析失敗：data 不是陣列');
    }

    return AdListResponse(
      data:
          raw.map((e) {
            if (e is! Map<String, dynamic>) {
              throw Exception('AdListResponse 解析失敗：data 內含非物件項目');
            }
            return AdItem.fromJson(Map<String, dynamic>.from(e));
          }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((e) => e.toJson()).toList()};
  }
}
