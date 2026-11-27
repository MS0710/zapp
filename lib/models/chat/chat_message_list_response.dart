import 'chat_message.dart';

class ChatMessageListResponse {
  final List<ChatMessage> data;

  const ChatMessageListResponse({
    required this.data,
  });

  factory ChatMessageListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is! List) {
      throw Exception('ChatMessageListResponse 解析失敗：data 不是陣列');
    }

    return ChatMessageListResponse(
      data: rawData.map((e) {
        if (e is! Map<String, dynamic>) {
          throw Exception('ChatMessageListResponse 解析失敗：data 內含非物件項目');
        }
        return ChatMessage.fromJson(Map<String, dynamic>.from(e));
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}