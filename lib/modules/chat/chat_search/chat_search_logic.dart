import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/chat/chat_room.dart';
import '../../../models/chat/chat_user.dart';
import '../../../routes/app_routes.dart';
import '../../../services/chat_service.dart';

enum ChatSearchTab { rooms, users }

class ChatSearchLogic extends GetxController {
  ChatSearchLogic({ChatService? chatService})
    : _chatService = chatService ?? ChatService();

  final ChatService _chatService;
  final TextEditingController searchController = TextEditingController();

  final activeTab = ChatSearchTab.rooms.obs;
  final query = ''.obs;
  final hasSearched = false.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final rooms = <ChatRoom>[].obs;
  final users = <ChatUser>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'users') {
      activeTab.value = ChatSearchTab.users;
    }
  }

  void onQueryChanged(String value) {
    final composing = searchController.value.composing;
    if (composing.isValid && !composing.isCollapsed) return;
    query.value = value.trim();
  }

  void onTapTab(ChatSearchTab tab) {
    if (activeTab.value == tab) return;
    activeTab.value = tab;
    hasSearched.value = false;
    errorMessage.value = null;
  }

  Future<void> submitSearch() async {
    final composing = searchController.value.composing;
    if (composing.isValid && !composing.isCollapsed) return;

    query.value = searchController.text.trim();
    hasSearched.value = true;
    errorMessage.value = null;
    rooms.clear();
    users.clear();

    if (query.value.isEmpty) {
      hasSearched.value = false;
      return;
    }

    isLoading.value = true;
    try {
      if (activeTab.value == ChatSearchTab.rooms) {
        rooms.assignAll(await _chatService.searchChatRooms(query: query.value));
      } else {
        users.assignAll(await _chatService.searchChatUsers(query: query.value));
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    query.value = '';
    hasSearched.value = false;
    errorMessage.value = null;
    rooms.clear();
    users.clear();
  }

  Future<void> onTapRoom(ChatRoom room) async {
    await Get.toNamed(
      AppRoutes.ChatRoom,
      arguments: {
        'title': room.displayName ?? room.title,
        'roomId': room.id,
        'isClosed': room.isClosed,
      },
    );
  }

  void onTapUser(ChatUser user) {
    Get.snackbar(
      user.displayName,
      '目前後端尚未提供用 user_id 建立一對一聊天室的 API',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    _chatService.dispose();
    super.onClose();
  }
}
