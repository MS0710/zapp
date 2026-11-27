import 'package:get/get.dart';
import 'package:zapp/models/ads/ad.dart';
import 'package:zapp/routes/app_routes.dart';
import 'package:zapp/services/ads_service.dart';
import 'package:zapp/services/chat_service.dart';
import 'package:zapp/utils/log_utils.dart';

class ChatListItem {
  final ChatListItemType type;
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final int? roomId;
  final bool isClosed;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool pinned;
  final bool muted;

  ChatListItem({
    required this.type,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.roomId,
    this.isClosed = false,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.pinned = false,
    this.muted = false,
  });
}

enum ChatListItemType {
  feature, // 本週活動 / 已參加私揪
  chat, // 一般聊天對象
}

class ChatListLogic extends GetxController {
  ChatListLogic({ChatService? chatService, AdsService? adsService})
    : _chatService = chatService ?? ChatService(),
      _adsService = adsService ?? AdsService();

  final ChatService _chatService;
  final AdsService _adsService;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final ads = <AdItem>[].obs;
  final currentAdIndex = 0.obs;

  final items =
      <ChatListItem>[
        ChatListItem(type: ChatListItemType.feature, title: '本週活動'),
        ChatListItem(type: ChatListItemType.feature, title: '已參加私揪'),
      ].obs;

  @override
  void onInit() {
    super.onInit();
    loadMyRooms();
    loadAds();
  }

  Future<void> loadAds() async {
    try {
      final AdListResponse resp = await _adsService.getAds();
      ads.assignAll(resp.data);
      if (currentAdIndex.value >= ads.length) {
        currentAdIndex.value = 0;
      }
      logger.logDebug('[ChatList] getAds count = ${resp.data.length}');
      logger.logPretty('[ChatList] getAds data', resp.toJson());
    } catch (e, st) {
      logger.logError('[ChatList] getAds failed: $e');
      logger.logError(st.toString());
    }
  }

  void onAdPageChanged(int index) {
    currentAdIndex.value = index;
  }

  Future<void> loadMyRooms() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final rooms = await _chatService.getMyRooms();

      items.assignAll([
        ChatListItem(type: ChatListItemType.feature, title: '本週活動'),
        ChatListItem(type: ChatListItemType.feature, title: '已參加私揪'),
        ...rooms.map(
          (room) => ChatListItem(
            type: ChatListItemType.chat,
            title: room.displayName ?? room.title,
            subtitle:
                room.lastMessagePreview ??
                room.lastMessage ??
                (room.isClosed ? '聊天室已關閉' : '尚無訊息'),
            avatarUrl: room.displayAvatarUrl,
            roomId: room.id,
            isClosed: room.isClosed,
            lastMessageAt: room.lastMessageAt ?? room.updatedAt,
            unreadCount: room.unreadCount,
            pinned: room.pinned,
            muted: room.muted,
          ),
        ),
      ]);

      // 假資料：之後若要回退本地測試，可暫時改回這段
      // items.assignAll([
      //   ChatListItem(type: ChatListItemType.feature, title: '本週活動'),
      //   ChatListItem(type: ChatListItemType.feature, title: '已參加私揪'),
      //   ChatListItem(type: ChatListItemType.chat, title: '聊天', subtitle: '這裡可以放最後一則訊息'),
      //   ChatListItem(type: ChatListItemType.chat, title: '使用者 A', subtitle: 'Hi～今晚有空嗎？'),
      //   ChatListItem(type: ChatListItemType.chat, title: '使用者 B', subtitle: '已讀不回 QQ'),
      //   ChatListItem(type: ChatListItemType.chat, title: '使用者 C'),
      // ]);
    } catch (e) {
      errorMessage.value = e.toString();
      items.assignAll([
        ChatListItem(type: ChatListItemType.feature, title: '本週活動'),
        ChatListItem(type: ChatListItemType.feature, title: '已參加私揪'),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  void onTapSearchBar() {
    Get.toNamed(AppRoutes.ChatSearch);
  }

  void onTapPeople() {
    Get.toNamed(AppRoutes.ChatSearch, arguments: {'tab': 'users'});
  }

  Future<void> onTapItem(ChatListItem item) async {
    if (item.type == ChatListItemType.feature) {
      return;
    }

    // 從聊天室返回後，立即重抓聊天室列表，更新最後訊息與時間
    await Get.toNamed(
      AppRoutes.ChatRoom,
      arguments: {
        'title': item.title,
        'roomId': item.roomId,
        'isClosed': item.isClosed,
      },
    );

    await loadMyRooms();
  }

  @override
  void onClose() {
    _chatService.dispose();
    _adsService.dispose();
    super.onClose();
  }
}
