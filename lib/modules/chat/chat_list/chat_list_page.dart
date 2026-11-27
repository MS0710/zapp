import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zapp/models/ads/ad.dart';

import 'chat_list_logic.dart';

class ChatListPage extends StatefulWidget {
  ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatListLogic controller = Get.put(ChatListLogic());
  final PageController _adPageController = PageController();
  Timer? _adTimer;

  static const Color bg = Color(0xFF2C2C40);
  static const Color barDark = Color(0xFF15151E);
  static const Color rowDark = Color(0xFF2B2B3C);
  static const Color searchBg = Color(0xFF22222A);
  static const Color cardBg = Color(0xFF1C1C28);

  String _formatChatListTime(DateTime? time) {
    if (time == null) return '';

    final local = time.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(local.year, local.month, local.day);
    final diffDays = today.difference(targetDay).inDays;

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    if (diffDays == 0) {
      return '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
    }
    if (diffDays == 1) {
      return '昨天';
    }
    if (diffDays > 1 && diffDays < 7) {
      const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
      return '週${weekdays[local.weekday - 1]}';
    }
    return '${local.month}/${local.day}';
  }

  @override
  void initState() {
    super.initState();
    _startAdAutoPlay();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adPageController.dispose();
    super.dispose();
  }

  void _startAdAutoPlay() {
    _adTimer?.cancel();
    _adTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;

      final ads = controller.ads;
      if (ads.length <= 1 || !_adPageController.hasClients) {
        return;
      }

      final next = (controller.currentAdIndex.value + 1) % ads.length;
      _adPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _openAd(AdItem ad) async {
    final rawUrl = ad.targetUrl;
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return;
    }

    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildTitle(),
            const SizedBox(height: 8),
            Container(height: 2, color: cardBg),
            const SizedBox(height: 8),
            _buildSearchBar(),
            const SizedBox(height: 8),
            _buildAdBar(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AutoSizeText(
        '聊天',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
        minFontSize: 10,
        maxLines: 1,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: controller.onTapSearchBar,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: searchBg,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '搜尋聊天對象',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              GestureDetector(
                onTap: controller.onTapPeople,
                child: Image.asset(
                  'assets/images/join.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdBar() {
    return Obx(() {
      final ads = controller.ads;
      final currentIndex = controller.currentAdIndex.value;

      if (ads.isEmpty) {
        return Container(
          height: 100,
          width: double.infinity,
          color: barDark,
          alignment: Alignment.center,
          child: const AutoSizeText(
            '廣告商',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
            minFontSize: 10,
            maxLines: 1,
          ),
        );
      }

      return SizedBox(
        height: 120,
        child: PageView.builder(
          controller: _adPageController,
          itemCount: ads.length,
          onPageChanged: controller.onAdPageChanged,
          itemBuilder: (_, index) {
            final ad = ads[index];

            return GestureDetector(
              onTap: () => _openAd(ad),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: barDark),
                  if (ad.imageUrl != null && ad.imageUrl!.isNotEmpty)
                    Image.network(
                      ad.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: barDark),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.08),
                          Colors.black.withOpacity(0.42),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          ad.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(ads.length, (dotIndex) {
                            final active = dotIndex == currentIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: active ? Colors.white : Colors.white38,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildList() {
    return Obx(() {
      final items = controller.items;
      final isLoading = controller.isLoading.value;
      final errorMessage = controller.errorMessage.value;

      if (isLoading && items.length <= 2) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      if (errorMessage != null && items.length <= 2) {
        return RefreshIndicator(
          onRefresh: controller.loadMyRooms,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: Get.height * 0.45,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '聊天室載入失敗\n$errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (items.length <= 2) {
        return RefreshIndicator(
          onRefresh: controller.loadMyRooms,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(
                height: 420,
                child: Center(
                  child: Text(
                    '目前還沒有聊天室',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadMyRooms,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (_, index) {
            final item = items[index];

            Widget row;
            switch (item.type) {
              case ChatListItemType.feature:
                row = _buildFeatureRow(item);
                break;
              case ChatListItemType.chat:
                row = _buildChatRow(item);
                break;
            }

            return Column(children: [row, Container(height: 1, color: cardBg)]);
          },
        ),
      );
    });
  }

  Widget _buildFeatureRow(ChatListItem item) {
    return GestureDetector(
      onTap: () => controller.onTapItem(item),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: rowDark,
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            AutoSizeText(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              minFontSize: 5,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRow(ChatListItem item) {
    return GestureDetector(
      onTap: () => controller.onTapItem(item),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: rowDark,
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage:
                  item.avatarUrl != null ? NetworkImage(item.avatarUrl!) : null,
              child:
                  item.avatarUrl == null
                      ? const Icon(
                        Icons.person,
                        color: Colors.black87,
                        size: 24,
                      )
                      : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          minFontSize: 5,
                          maxLines: 1,
                        ),
                      ),
                      if (item.pinned) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.push_pin,
                          color: Colors.white54,
                          size: 14,
                        ),
                      ],
                      if (item.muted) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.notifications_off,
                          color: Colors.white54,
                          size: 14,
                        ),
                      ],
                      if ((item.lastMessageAt) != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatChatListTime(item.lastMessageAt),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.subtitle != null)
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            item.subtitle!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            minFontSize: 5,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.all(
                                Radius.circular(99),
                              ),
                            ),
                            child: Text(
                              item.unreadCount > 99
                                  ? '99+'
                                  : '${item.unreadCount}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
