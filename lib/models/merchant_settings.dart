class MerchantSettings {
  final String id;
  final String storeName;
  final String? coverPhoto;
  final String? description;
  final List<Map<String, dynamic>>? homepageContent;
  final List<MenuItem> menuItems;
  final String? address;
  final String? phone;
  final String? businessHours;
  final String? website;
  final DateTime? updatedAt;

  MerchantSettings({
    required this.id,
    required this.storeName,
    this.coverPhoto,
    this.description,
    this.homepageContent,
    required this.menuItems,
    this.address,
    this.phone,
    this.businessHours,
    this.website,
    this.updatedAt,
  });

  factory MerchantSettings.fromJson(Map<String, dynamic> j) {
    // menu_items
    final items = (j['menu_items'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => MenuItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // homepage_content: List<Map>
    final homepage = (j['homepage_content'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return MerchantSettings(
      id: j['id']?.toString() ?? '',
      storeName: j['store_name']?.toString() ?? '',
      coverPhoto: j['cover_photo'] as String?,
      description: j['description'] as String?,
      homepageContent: homepage.isEmpty ? null : homepage,
      menuItems: items,
      address: j['address'] as String?,
      phone: j['phone'] as String?,
      businessHours: j['business_hours'] as String?,
      website: j['website'] as String?,
      updatedAt: DateTime.tryParse((j['updated_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'store_name': storeName,
    'cover_photo': coverPhoto,
    'description': description,
    'homepage_content': homepageContent,
    'menu_items': menuItems.map((e) => e.toJson()).toList(),
    'address': address,
    'phone': phone,
    'business_hours': businessHours,
    'website': website,
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class MenuItem {
  final String name;
  final String price; // API 是 "600" 字串
  final String imageUrl; // 對應 image_url
  final String? description;

  MenuItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description,
  });

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
    name: (j['name'] ?? '').toString(),
    price: (j['price'] ?? '').toString(),
    imageUrl: (j['image_url'] ?? '').toString(),
    description: j['description'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'description': description,
  };
}
