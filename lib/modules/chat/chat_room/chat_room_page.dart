import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat_room_logic.dart';

class ChatRoomPage extends StatelessWidget {
  ChatRoomPage({super.key});

  final ChatRoomLogic controller = Get.find<ChatRoomLogic>();
  static const Color topBarBg = Color(0xFF15151E);
  static const Color bodyBg = Color(0xFF242437);
  static const Color bottomBar = Color(0xFF15151E);
  static const Color inputBg = Color(0xFFE5E5E5);
  static const Color myBubbleBg = Color(0xFF4E7BFF);
  static const Color otherBubbleBg = Colors.white;

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatMessageTime(DateTime? time) {
    if (time == null) return '';
    final local = time.toLocal();
    return '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  String _formatDayLabel(DateTime? time) {
    if (time == null) return '未知日期';

    final local = time.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(local.year, local.month, local.day);
    final diffDays = today.difference(targetDay).inDays;

    if (diffDays == 0) return '今天';
    if (diffDays == 1) return '昨天';
    return '${local.year}/${_twoDigits(local.month)}/${_twoDigits(local.day)}';
  }

  bool _shouldShowDateSeparator(dynamic previous, dynamic current) {
    final prevTime = previous?.createdAt?.toLocal();
    final currentTime = current.createdAt?.toLocal();
    if (currentTime == null) {
      return previous == null;
    }
    if (prevTime == null) {
      return true;
    }
    return prevTime.year != currentTime.year ||
        prevTime.month != currentTime.month ||
        prevTime.day != currentTime.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildMessages()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Obx(() {
      final isSearchMode = controller.isSearchMode.value;

      return Container(
        height: 60,
        color: topBarBg,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: controller.onTapBack,
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child:
                  isSearchMode
                      ? TextField(
                        controller: controller.searchController,
                        focusNode: controller.searchFocusNode,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => controller.submitMessageSearch(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: '搜尋聊天室訊息',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      )
                      : AutoSizeText(
                        controller.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                        minFontSize: 5,
                      ),
            ),
            GestureDetector(
              onTap:
                  isSearchMode
                      ? controller.submitMessageSearch
                      : controller.onTapMenu,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  isSearchMode ? Icons.search : Icons.search,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
            if (isSearchMode)
              GestureDetector(
                onTap: controller.closeMessageSearch,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildMessages() {
    return Obx(() {
      final messages = controller.messages;
      final isLoading = controller.isLoading.value;
      final errorMessage = controller.errorMessage.value;
      final isSearchMode = controller.isSearchMode.value;
      final hasMessageSearch = controller.hasMessageSearch.value;
      final searchErrorMessage = controller.searchErrorMessage.value;
      final isSearchingMessages = controller.isSearchingMessages.value;
      final sourceMessages =
          isSearchMode && hasMessageSearch
              ? controller.searchMessageResults
              : messages;
      final displayMessages = sourceMessages.reversed.toList(growable: false);

      if (isSearchMode && isSearchingMessages) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      if (isSearchMode && searchErrorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              searchErrorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
        );
      }

      if (isSearchMode && !hasMessageSearch) {
        return const Center(
          child: Text(
            '輸入關鍵字搜尋訊息',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        );
      }

      if (isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      if (errorMessage != null) {
        return RefreshIndicator(
          onRefresh: controller.loadMessages,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: Get.height * 0.55,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (sourceMessages.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.loadMessages,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 420,
                child: Center(
                  child: Text(
                    isSearchMode ? '找不到符合的訊息' : '目前還沒有訊息',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadMessages,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: controller.dismissKeyboard,
          child: ListView.builder(
            controller: isSearchMode ? null : controller.scrollController,
            reverse: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: displayMessages.length,
            itemBuilder: (_, index) {
              final message = displayMessages[index];
              final previousMessage =
                  index > 0 ? displayMessages[index - 1] : null;
              final isMe = controller.isMine(message);
              final bubbleColor = isMe ? myBubbleBg : otherBubbleBg;
              final textColor = isMe ? Colors.white : const Color(0xFF1E2230);
              final metaColor = isMe ? Colors.white70 : Colors.white60;
              final messageOpacity = message.isPending ? 0.65 : 1.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_shouldShowDateSeparator(previousMessage, message))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _formatDayLabel(message.createdAt),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: IntrinsicWidth(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe) ...[
                              _buildSenderAvatar(message),
                              const SizedBox(width: 6),
                            ],
                            if (isMe) ...[
                              _buildMessageMeta(
                                message: message,
                                metaColor: metaColor,
                                isMe: isMe,
                              ),
                              const SizedBox(width: 6),
                            ],
                            GestureDetector(
                              onTap: () => _onTapMessage(message),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: Get.width * 0.72,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bubbleColor.withValues(
                                      alpha: messageOpacity,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(18),
                                      topRight: const Radius.circular(18),
                                      bottomLeft: Radius.circular(
                                        isMe ? 18 : 4,
                                      ),
                                      bottomRight: Radius.circular(
                                        isMe ? 4 : 18,
                                      ),
                                    ),
                                    border:
                                        message.hasSendError
                                            ? Border.all(
                                              color: Colors.redAccent
                                                  .withValues(alpha: 0.7),
                                            )
                                            : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isMe ? 0.12 : 0.08,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: _buildMessageContent(
                                    message: message,
                                    textColor: textColor,
                                    isMe: isMe,
                                  ),
                                ),
                              ),
                            ),
                            if (!isMe) ...[
                              const SizedBox(width: 6),
                              _buildMessageMeta(
                                message: message,
                                metaColor: metaColor,
                                isMe: isMe,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar() {
    return Obx(() {
      final isSending = controller.isSending.value;
      final isUploadingImage = controller.isUploadingImage.value;
      final isClosed = controller.roomIsClosed.value;
      final canSend = !isClosed && !isSending;
      final canPickImage = !isClosed && !isUploadingImage;

      return Container(
        color: bottomBar,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              if (isClosed)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    '聊天室已關閉，目前只能查看歷史訊息',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 10),
              Container(
                color: bottomBar,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: canPickImage ? controller.onTapCamera : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child:
                            isUploadingImage
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white70,
                                  ),
                                )
                                : Icon(
                                  Icons.add_a_photo_outlined,
                                  color:
                                      canPickImage
                                          ? Colors.white70
                                          : Colors.white30,
                                  size: 24,
                                ),
                      ),
                    ),
                    GestureDetector(
                      onTap: canPickImage ? controller.onTapGallery : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.photo_outlined,
                          color: canPickImage ? Colors.white70 : Colors.white30,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 36),
                        decoration: BoxDecoration(
                          color: isClosed ? Colors.grey.shade400 : inputBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.textController,
                                focusNode: controller.inputFocusNode,
                                readOnly: isClosed,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                minLines: 1,
                                maxLines: 4,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: isClosed ? '聊天室已關閉' : '輸入新訊息',
                                  hintStyle: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: canSend ? controller.onSend : null,
                              child:
                                  isSending
                                      ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                      : Image.asset(
                                        'assets/images/join.png',
                                        color:
                                            canSend
                                                ? Colors.black
                                                : Colors.black38,
                                        width: 22,
                                        height: 22,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMessageMeta({
    required dynamic message,
    required Color metaColor,
    required bool isMe,
  }) {
    final errorColor = isMe ? Colors.red.shade100 : Colors.red.shade400;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 90),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.hasSendError) ...[
            GestureDetector(
              onTap: () => controller.retryMessage(message),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: errorColor),
                ),
                child: Icon(Icons.refresh, color: errorColor, size: 15),
              ),
            ),
            Text(
              '未送出',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: errorColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else if (message.isPending)
            Text(
              '傳送中...',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: metaColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (message.createdAt != null)
            Text(
              _formatMessageTime(message.createdAt),
              style: TextStyle(
                color: metaColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSenderAvatar(dynamic message) {
    final avatarUrl = message.senderAvatarUrl as String?;
    return CircleAvatar(
      radius: 15,
      backgroundColor: Colors.white,
      backgroundImage:
          avatarUrl != null && avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
      child:
          avatarUrl == null || avatarUrl.isEmpty
              ? const Icon(Icons.person, color: Colors.black87, size: 18)
              : null,
    );
  }

  Widget _buildMessageContent({
    required dynamic message,
    required Color textColor,
    required bool isMe,
  }) {
    final senderName = message.senderName as String?;
    final messageType = (message.messageType as String?) ?? 'text';
    final imageUrl = message.imageUrl as String?;

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMe && senderName != null && senderName.isNotEmpty) ...[
          Text(
            senderName,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (message.isRecalled == true)
          Text(
            '訊息已收回',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.65),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          )
        else if (message.isDeleted == true)
          Text(
            '訊息已刪除',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.65),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          )
        else if (messageType == 'image' &&
            imageUrl != null &&
            imageUrl.isNotEmpty)
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildChatImage(
                  imageUrl: imageUrl,
                  textColor: textColor,
                  width: Get.width * 0.52,
                  fit: BoxFit.cover,
                ),
              ),
              if (message.isPending == true)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.38),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          )
        else
          Text(
            message.message,
            softWrap: true,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  void _onTapMessage(dynamic message) {
    if (message.hasSendError == true) {
      controller.retryMessage(message);
      return;
    }

    final messageType = (message.messageType as String?) ?? 'text';
    final imageUrl = message.imageUrl as String?;
    if (messageType != 'image' || imageUrl == null || imageUrl.isEmpty) {
      return;
    }

    _showImagePreview(imageUrl);
  }

  void _showImagePreview(String imageUrl) {
    Get.dialog(
      Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: _buildChatImage(
                    imageUrl: imageUrl,
                    textColor: Colors.white,
                    width: Get.width,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatImage({
    required String imageUrl,
    required Color textColor,
    required double width,
    required BoxFit fit,
  }) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        errorBuilder:
            (_, __, ___) => Text(
              '圖片載入失敗',
              style: TextStyle(color: textColor, fontSize: 14),
            ),
      );
    }

    return Image.file(
      File(imageUrl),
      fit: fit,
      width: width,
      errorBuilder:
          (_, __, ___) =>
              Text('圖片載入失敗', style: TextStyle(color: textColor, fontSize: 14)),
    );
  }
}
