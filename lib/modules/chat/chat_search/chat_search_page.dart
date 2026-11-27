import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/chat/chat_room.dart';
import '../../../models/chat/chat_user.dart';
import 'chat_search_logic.dart';

class ChatSearchPage extends StatelessWidget {
  ChatSearchPage({super.key});

  final ChatSearchLogic controller = Get.find<ChatSearchLogic>();

  static const Color bg = Color(0xFF2C2C40);
  static const Color panelBg = Color(0xFF1C1C28);
  static const Color searchBg = Color(0xFF22222A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white,
              ),
              const Expanded(
                child: Text(
                  '搜尋聊天',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: searchBg,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: controller.submitSearch,
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    autofocus: true,
                    onChanged: controller.onQueryChanged,
                    onSubmitted: (_) => controller.submitSearch(),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: '搜尋聊天室或聊天對象',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                Obx(() {
                  if (controller.query.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: controller.clearSearch,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Obx(() {
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: panelBg,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _tab('聊天室', ChatSearchTab.rooms),
              _tab('使用者', ChatSearchTab.users),
            ],
          ),
        );
      }),
    );
  }

  Widget _tab(String label, ChatSearchTab tab) {
    final selected = controller.activeTab.value == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onTapTab(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF1A1021) : Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.query.value.isEmpty) {
        return _empty('輸入關鍵字後按搜尋');
      }
      if (!controller.hasSearched.value) {
        return _empty('按搜尋查看結果');
      }
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
      final error = controller.errorMessage.value;
      if (error != null) return _empty(error);

      if (controller.activeTab.value == ChatSearchTab.rooms) {
        if (controller.rooms.isEmpty) return _empty('找不到聊天室');
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          itemCount: controller.rooms.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) => _roomTile(controller.rooms[index]),
        );
      }

      if (controller.users.isEmpty) return _empty('找不到使用者');
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        itemCount: controller.users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) => _userTile(controller.users[index]),
      );
    });
  }

  Widget _roomTile(ChatRoom room) {
    return _baseTile(
      title: room.displayName ?? room.title,
      subtitle: room.lastMessagePreview ?? room.lastMessage ?? '尚無訊息',
      avatarUrl: room.displayAvatarUrl,
      onTap: () => controller.onTapRoom(room),
    );
  }

  Widget _userTile(ChatUser user) {
    return _baseTile(
      title: user.displayName,
      subtitle: user.nickname ?? user.fullName ?? user.role,
      avatarUrl: user.avatarUrl,
      onTap: () => controller.onTapUser(user),
    );
  }

  Widget _baseTile({
    required String title,
    required String subtitle,
    required String? avatarUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: panelBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: Colors.white,
              backgroundImage:
                  avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
              child:
                  avatarUrl == null || avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.black87)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 15),
      ),
    );
  }
}
