class UploadImageResponse {
  final String message;
  final String url;
  final String path;

  const UploadImageResponse({
    required this.message,
    required this.url,
    required this.path,
  });

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) {
    final message = (json['message'] ?? '').toString().trim();
    final url = (json['url'] ?? '').toString().trim();
    final path = (json['path'] ?? '').toString().trim();

    if (url.isEmpty) {
      throw Exception('UploadImageResponse 解析失敗：url 為空');
    }

    if (path.isEmpty) {
      throw Exception('UploadImageResponse 解析失敗：path 為空');
    }

    return UploadImageResponse(
      message: message,
      url: url,
      path: path,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'url': url,
      'path': path,
    };
  }
}
