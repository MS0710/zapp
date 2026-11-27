class HereGeocodeResult {
  final double lat;
  final double lng;
  final String? label; // 可選：HERE 回傳的地址 label

  HereGeocodeResult({
    required this.lat,
    required this.lng,
    this.label,
  });
}
