class MerchantActivity {
  final int id;
  final String merchantId;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? location;
  final String? startTime; // 先用字串保存 ISO 8601
  final int? maxParticipants;
  final String? status; // open / closed
  final String? remarks;
  final String? createdAt;

  MerchantActivity({
    required this.id,
    required this.merchantId,
    required this.title,
    this.description,
    this.imageUrl,
    this.location,
    this.startTime,
    this.maxParticipants,
    this.status,
    this.remarks,
    this.createdAt,
  });

  factory MerchantActivity.fromJson(Map<String, dynamic> j) {
    return MerchantActivity(
      id: (j['id'] as num).toInt(),
      merchantId: j['merchant_id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      description: j['description'] as String?,
      imageUrl: j['image_url'] as String?,
      location: j['location'] as String?,
      startTime: j['start_time']?.toString(),
      maxParticipants: j['max_participants'] == null
          ? null
          : (j['max_participants'] as num).toInt(),
      status: j['status']?.toString(),
      remarks: j['remarks'] as String?,
      createdAt: j['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchant_id': merchantId,
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'location': location,
    'start_time': startTime,
    'max_participants': maxParticipants,
    'status': status,
    'remarks': remarks,
    'created_at': createdAt,
  };
}