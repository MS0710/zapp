import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/chat/chat_message.dart' as api_chat;
import '../../../services/chat_cache_service.dart';
import '../../../services/chat_service.dart';
import '../../../services/image_upload_service.dart';
import '../../../services/login_required_guard_service.dart';

class ChatRoomLogic extends GetxController {
  ChatRoomLogic({
    ChatService? chatService,
    ChatCacheService? cacheService,
    ImageUploadService? imageUploadService,
    ImagePicker? imagePicker,
  }) : _chatService = chatService ?? ChatService(),
       _cacheService = cacheService ?? ChatCacheService(),
       _imageUploadService = imageUploadService ?? ImageUploadService(),
       _imagePicker = imagePicker ?? ImagePicker();

  final ChatService _chatService;
  final ChatCacheService _cacheService;
  final ImageUploadService _imageUploadService;
  final ImagePicker _imagePicker;
  final LoginRequiredGuardService _loginGuard =
      Get.find<LoginRequiredGuardService>();

  late final String title;
  late final int? roomId;
  final RxBool roomIsClosed = false.obs;

  final messages = <api_chat.ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingOlder = false.obs;
  final RxBool hasOlderMessages = true.obs;
  final RxBool isSending = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isSearchMode = false.obs;
  final RxBool isSearchingMessages = false.obs;
  final RxBool hasMessageSearch = false.obs;
  final RxnString searchErrorMessage = RxnString();
  final searchMessageResults = <api_chat.ChatMessage>[].obs;

  final TextEditingController textController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();
  final FocusNode searchFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;
  int _localMessageSeed = -1;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    title = args?['title'] ?? '聊天室';
    final rawRoomId = args?['roomId'];
    roomId = rawRoomId is int ? rawRoomId : int.tryParse('${rawRoomId ?? ''}');
    roomIsClosed.value = args?['isClosed'] == true;

    if (roomId == null || roomId! <= 0) {
      errorMessage.value = '缺少聊天室 ID';
      return;
    }

    _initRoom();
    scrollController.addListener(_saveScrollOffset);
  }

  @override
  void onClose() {
    textController.dispose();
    searchController.dispose();
    inputFocusNode.dispose();
    searchFocusNode.dispose();
    scrollController.removeListener(_saveScrollOffset);
    scrollController.dispose();
    _imageUploadService.dispose();
    _chatService.dispose();
    super.onClose();
  }

  Future<void> loadMessages() async {
    final currentRoomId = roomId;
    if (currentRoomId == null || currentRoomId <= 0) {
      errorMessage.value = '缺少聊天室 ID';
      return;
    }

    final hasCachedMessages = messages.isNotEmpty;
    if (!hasCachedMessages) {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final response = await _chatService.getMessages(roomId: currentRoomId);
      messages.assignAll(_mergeMessages(messages, response.data));
      hasOlderMessages.value = response.data.length >= 50;
      await _cacheMessages();
      await _markLatestRead();
      _subscribeRealtime(currentRoomId);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (!hasCachedMessages) {
        isLoading.value = false;
      }
    }
  }

  void onTapBack() {
    if (isSearchMode.value) {
      closeMessageSearch();
      return;
    }

    Get.back();
  }

  void onTapMenu() {
    if (isSearchMode.value) {
      closeMessageSearch();
      return;
    }

    isSearchMode.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });
  }

  Future<void> onTapCamera() async {
    await _pickAndSendImage(ImageSource.camera);
  }

  Future<void> onTapGallery() async {
    await _pickAndSendImage(ImageSource.gallery);
  }

  void onTapPeople() {}

  bool isMine(api_chat.ChatMessage message) {
    final me = currentUserId;
    return me != null && me.isNotEmpty && message.senderId == me;
  }

  Future<void> onSend() async {
    final ok = await _loginGuard.ensureLoggedIn(
      featureName: '聊天功能',
      message: '傳送訊息需要先登入帳號。',
    );
    if (!ok) return;

    await _sendTextMessage(textController.text.trim());
  }

  Future<void> submitMessageSearch() async {
    final currentRoomId = roomId;
    if (currentRoomId == null || currentRoomId <= 0) {
      searchErrorMessage.value = '缺少聊天室 ID';
      return;
    }

    final query = searchController.text.trim();
    searchErrorMessage.value = null;
    hasMessageSearch.value = true;
    searchMessageResults.clear();

    if (query.isEmpty) {
      hasMessageSearch.value = false;
      return;
    }

    isSearchingMessages.value = true;
    try {
      final results = await _chatService.searchChatMessages(
        roomId: currentRoomId,
        query: query,
      );
      searchMessageResults.assignAll(results);
    } catch (e) {
      searchErrorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isSearchingMessages.value = false;
    }
  }

  void closeMessageSearch() {
    isSearchMode.value = false;
    hasMessageSearch.value = false;
    searchErrorMessage.value = null;
    searchMessageResults.clear();
    searchController.clear();
    searchFocusNode.unfocus();
  }

  Future<void> retryMessage(api_chat.ChatMessage failedMessage) async {
    final currentRoomId = roomId;
    if (currentRoomId == null || currentRoomId <= 0) {
      Get.snackbar('發送失敗', '缺少聊天室 ID', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!failedMessage.hasSendError) {
      return;
    }

    final index = messages.indexWhere((m) => m.id == failedMessage.id);
    if (index < 0) {
      return;
    }

    messages[index] = failedMessage.copyWith(
      isPending: true,
      hasSendError: false,
      createdAt: DateTime.now(),
    );
    _scrollToBottom(force: true);

    if (failedMessage.messageType == 'image') {
      await _sendImageMessage(
        failedMessage.imageUrl,
        optimisticMessageId: failedMessage.id,
      );
    } else if (failedMessage.message.trim().isNotEmpty) {
      await _sendTextMessage(
        failedMessage.message.trim(),
        optimisticMessageId: failedMessage.id,
        clearComposer: false,
        requestFocus: false,
      );
    }
  }

  Future<void> _sendTextMessage(
    String text, {
    int? optimisticMessageId,
    bool clearComposer = true,
    bool requestFocus = true,
  }) async {
    final currentRoomId = roomId;

    if (currentRoomId == null || currentRoomId <= 0) {
      Get.snackbar('發送失敗', '缺少聊天室 ID', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (roomIsClosed.value) {
      Get.snackbar('聊天室已關閉', '目前只能查看歷史訊息', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (text.isEmpty || isSending.value) {
      return;
    }

    final optimisticId = optimisticMessageId ?? _localMessageSeed--;
    final optimisticMessage = api_chat.ChatMessage(
      id: optimisticId,
      roomId: currentRoomId,
      senderId: currentUserId ?? '',
      message: text,
      isDeleted: false,
      createdAt: DateTime.now(),
      isPending: true,
      clientId: 'local-${DateTime.now().microsecondsSinceEpoch}',
    );

    if (optimisticMessageId == null) {
      messages.add(optimisticMessage);
      if (clearComposer) {
        textController.clear();
      }
      if (requestFocus) {
        inputFocusNode.requestFocus();
      }
      _scrollToBottom(force: true);
    }

    isSending.value = true;

    try {
      final sent = await _chatService.sendMessage(
        roomId: currentRoomId,
        message: text,
        clientId: optimisticMessage.clientId,
      );
      _replaceOptimisticMessage(optimisticId, sent);
    } catch (e) {
      _markOptimisticMessageFailed(optimisticId);
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('403') || msg.contains('聊天室已關閉')) {
        roomIsClosed.value = true;
        Get.snackbar(
          '聊天室已關閉',
          '目前只能查看歷史訊息',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('發送失敗', msg, snackPosition: SnackPosition.BOTTOM);
        if (requestFocus) {
          inputFocusNode.requestFocus();
        }
      }
    } finally {
      isSending.value = false;
    }
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    final ok = await _loginGuard.ensureLoggedIn(
      featureName: '聊天功能',
      message: '傳送圖片需要先登入帳號。',
    );
    if (!ok) return;

    final currentRoomId = roomId;
    if (currentRoomId == null || currentRoomId <= 0) {
      Get.snackbar('發送失敗', '缺少聊天室 ID', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (roomIsClosed.value) {
      Get.snackbar('聊天室已關閉', '目前只能查看歷史訊息', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (isUploadingImage.value) {
      return;
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 88,
      );
      if (picked == null) return;

      final compressed = await _compressChatImage(File(picked.path));
      await _sendImageMessage(compressed.path);
    } catch (e) {
      Get.snackbar(
        '圖片處理失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _sendImageMessage(
    String? localOrRemoteUrl, {
    int? optimisticMessageId,
  }) async {
    final currentRoomId = roomId;
    final imageSource = localOrRemoteUrl?.trim();

    if (currentRoomId == null || currentRoomId <= 0) {
      Get.snackbar('發送失敗', '缺少聊天室 ID', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (imageSource == null || imageSource.isEmpty) {
      Get.snackbar('發送失敗', '缺少圖片', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (roomIsClosed.value) {
      Get.snackbar('聊天室已關閉', '目前只能查看歷史訊息', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final optimisticId = optimisticMessageId ?? _localMessageSeed--;
    final optimisticMessage = api_chat.ChatMessage(
      id: optimisticId,
      roomId: currentRoomId,
      senderId: currentUserId ?? '',
      message: '',
      messageType: 'image',
      imageUrl: imageSource,
      isDeleted: false,
      createdAt: DateTime.now(),
      isPending: true,
      clientId: 'local-${DateTime.now().microsecondsSinceEpoch}',
    );

    if (optimisticMessageId == null) {
      messages.add(optimisticMessage);
      _scrollToBottom(force: true);
    }

    isUploadingImage.value = true;

    try {
      final imageUrl =
          imageSource.startsWith('http://') ||
                  imageSource.startsWith('https://')
              ? imageSource
              : (await _imageUploadService.uploadImage(
                filePath: imageSource,
                folder: 'chat-messages',
              )).url;

      _updateOptimisticImageUrl(optimisticId, imageUrl);

      final sent = await _chatService.sendMessage(
        roomId: currentRoomId,
        messageType: 'image',
        imageUrl: imageUrl,
        clientId: optimisticMessage.clientId,
      );
      _replaceOptimisticMessage(optimisticId, sent);
    } catch (e) {
      _markOptimisticMessageFailed(optimisticId);
      Get.snackbar(
        '圖片發送失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  void dismissKeyboard() {
    inputFocusNode.unfocus();
  }

  void _subscribeRealtime(int roomId) {
    _chatService.subscribeRoomMessages(
      roomId: roomId,
      onInsert: _handleIncomingMessage,
      onError: (error) {
        errorMessage.value = error.toString();
      },
    );
  }

  void _handleIncomingMessage(api_chat.ChatMessage message) {
    final existsIndex = messages.indexWhere((m) => m.id == message.id);
    if (existsIndex >= 0) {
      return;
    }

    final optimisticIndex = messages.indexWhere(
      (m) =>
          m.isPending &&
          m.senderId == message.senderId &&
          m.messageType == message.messageType &&
          (m.clientId == message.clientId ||
              m.message == message.message ||
              m.imageUrl == message.imageUrl),
    );

    if (optimisticIndex >= 0) {
      messages[optimisticIndex] = message;
    } else {
      messages.add(message);
    }

    _cacheMessages();
    _markLatestRead();
    _scrollToBottom(onlyIfNearBottom: true);
  }

  Future<void> loadOlderMessages() async {
    final currentRoomId = roomId;
    if (currentRoomId == null || currentRoomId <= 0) return;
    if (messages.isEmpty || isLoadingOlder.value || !hasOlderMessages.value) {
      return;
    }

    final oldest = messages
        .where((m) => m.id > 0)
        .map((m) => m.id)
        .fold<int?>(null, (prev, id) => prev == null || id < prev ? id : prev);
    if (oldest == null) return;

    isLoadingOlder.value = true;
    try {
      final response = await _chatService.getMessages(
        roomId: currentRoomId,
        beforeMessageId: oldest,
      );
      hasOlderMessages.value = response.data.length >= 50;
      messages.assignAll(_mergeMessages(messages, response.data));
      await _cacheMessages();
    } finally {
      isLoadingOlder.value = false;
    }
  }

  Future<void> _initRoom() async {
    final currentRoomId = roomId;
    if (currentRoomId == null || currentRoomId <= 0) {
      return;
    }

    await _restoreCachedMessages(currentRoomId);
    await loadMessages();
  }

  Future<void> _restoreCachedMessages(int roomId) async {
    final cached = await _cacheService.readRoomMessages(roomId);
    if (cached.isEmpty) {
      return;
    }

    messages.assignAll(cached);
  }

  Future<void> _cacheMessages() async {
    final currentRoomId = roomId;
    if (currentRoomId == null || currentRoomId <= 0) {
      return;
    }

    await _cacheService.writeRoomMessages(currentRoomId, messages.toList());
  }

  Future<void> _markLatestRead() async {
    final currentRoomId = roomId;
    if (currentRoomId == null || currentRoomId <= 0 || messages.isEmpty) {
      return;
    }

    final latest = messages
        .where((m) => m.id > 0)
        .map((m) => m.id)
        .fold<int?>(null, (prev, id) => prev == null || id > prev ? id : prev);
    if (latest == null) return;

    try {
      await _chatService.markRoomRead(
        roomId: currentRoomId,
        lastReadMessageId: latest,
      );
    } catch (_) {
      // 已讀失敗不阻斷聊天體驗，下次進聊天室或列表刷新會再同步。
    }
  }

  void _markOptimisticMessageFailed(int messageId) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) {
      return;
    }

    messages[index] = messages[index].copyWith(
      isPending: false,
      hasSendError: true,
    );
  }

  void _updateOptimisticImageUrl(int messageId, String imageUrl) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) {
      return;
    }

    messages[index] = messages[index].copyWith(imageUrl: imageUrl);
  }

  void _replaceOptimisticMessage(
    int optimisticMessageId,
    api_chat.ChatMessage sent,
  ) {
    final index = messages.indexWhere((m) => m.id == optimisticMessageId);
    if (index >= 0) {
      messages[index] = sent;
    } else if (!messages.any((m) => m.id == sent.id)) {
      messages.add(sent);
    }
    _cacheMessages();
  }

  Future<File> _compressChatImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final baseName = p.basenameWithoutExtension(file.path);
    final targetPath = p.join(
      tempDir.path,
      '${baseName}_chat_${DateTime.now().millisecondsSinceEpoch}.webp',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      format: CompressFormat.webp,
      quality: 82,
      minWidth: 1280,
      minHeight: 1280,
    );

    if (result == null) {
      throw Exception('圖片壓縮失敗');
    }

    return File(result.path);
  }

  List<api_chat.ChatMessage> _mergeMessages(
    List<api_chat.ChatMessage> current,
    List<api_chat.ChatMessage> incoming,
  ) {
    final pending =
        current.where((m) => m.isPending || m.hasSendError).toList();
    final merged = <api_chat.ChatMessage>[...incoming];

    for (final item in pending) {
      final exists = merged.any((m) => m.id == item.id);
      if (!exists) {
        merged.add(item);
      }
    }

    merged.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });
    return merged;
  }

  void _saveScrollOffset() {
    final currentRoomId = roomId;
    if (currentRoomId == null || currentRoomId <= 0) {
      return;
    }
    if (!scrollController.hasClients) {
      return;
    }
    _cacheService.writeScrollOffset(currentRoomId, scrollController.offset);
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 80) {
      loadOlderMessages();
    }
  }

  bool get _isNearBottom {
    if (!scrollController.hasClients) return true;
    final position = scrollController.position;
    return position.pixels < 80;
  }

  void _scrollToBottom({
    bool animated = true,
    bool force = false,
    bool onlyIfNearBottom = false,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      if (!force && onlyIfNearBottom && !_isNearBottom) return;

      const position = 0.0;
      if (animated) {
        scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(position);
      }
    });
  }
}
