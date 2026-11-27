import 'chat_room.dart';

class ChatRoomResponse {
  final ChatRoom data;

  const ChatRoomResponse({
    required this.data,
  });

  factory ChatRoomResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is! Map<String, dynamic>) {
      throw Exception('ChatRoomResponse 解析失敗：data 不是物件');
    }

    return ChatRoomResponse(
      data: ChatRoom.fromJson(Map<String, dynamic>.from(rawData)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}