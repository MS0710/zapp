import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/my_activity.dart';
import 'profile_logic.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileLogic controller = Get.put(ProfileLogic());
  static const Color bg = Color(0xFF2C2C40);
  static const Color cardBg = Color(0xFF1C1C28);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 上方個人資訊區 =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 設定
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: controller.onTapSettings,
                        child: Image.asset(
                          'assets/images/setting.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // 暱稱 + 簡介 + 頭像
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Obx(
                              () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                controller.nickname.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                                minFontSize: 10,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              AutoSizeText(
                                controller.intro.value,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                                minFontSize: 5,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Obx(() {
                          final avatarUrl = controller.avatarUrl.value;
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white10,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: ClipOval(
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        return Image.asset(
                                          'assets/images/account_circle.png',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/account_circle.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // tabs
            _buildTabs(),

            Container(height: 1, color: cardBg),
            const SizedBox(height: 12),

            // 內容區
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  switch (controller.selectedTab.value) {
                    case 0:
                      return _buildMyActivityList();
                    case 1:
                    case 2:
                    case 3:
                      return const Center(
                        child: Text('尚無資料', style: TextStyle(color: Colors.white70)),
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['活動', '參加', 'VIP', '評分'];

    return Obx(
          () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = controller.selectedTab.value == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTab(index),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: AutoSizeText(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18,
                    ),
                    minFontSize: 5,
                    maxLines: 1,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// ✅ 活動列表：改成跟 MatchListPage 同款卡片
  Widget _buildMyActivityList() {
    return Obx(() {
      if (controller.loadingMyActivities.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final err = controller.myActivitiesError.value.trim();
      if (err.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(err, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: controller.onRefreshMyActivities,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '重試',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final list = controller.myActivities;
      if (list.isEmpty) {
        return const Center(
          child: Text('尚無活動', style: TextStyle(color: Colors.white70)),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.onRefreshMyActivities,
        child: ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _buildActivityCard(list[i]),
        ),
      );
    });
  }

  Widget _buildActivityCard(MyActivityItem item) {
    final joined = item.joinedCount;
    final pending = item.pendingCount;
    final imageUrl = item.imageUrl;

    return GestureDetector(
      onTap: () => controller.onTapMyActivity(item),
      onLongPress: () => controller.onLongPressMyActivity(item),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                color: Colors.grey.shade500,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildCardImagePlaceholder(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return _buildCardImagePlaceholder(isLoading: true);
                        },
                      )
                    : _buildCardImagePlaceholder(),
              ),
            ),
            const SizedBox(width: 12),

            // 中間
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    minFontSize: 5,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    '$joined/${item.maxParticipants} (待審 $pending)',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    minFontSize: 5,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            // 右側
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  item.location,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  minFontSize: 5,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  _formatDateTime(item.startTime),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime? d) {
    if (d == null) return '';
    final local = d.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y/$m/$day $hh:$mm';
  }

  Widget _buildCardImagePlaceholder({bool isLoading = false}) {
    return Container(
      color: Colors.grey.shade500,
      child: Center(
        child: Icon(
          isLoading ? Icons.downloading_rounded : Icons.image_outlined,
          color: Colors.white70,
          size: 20,
        ),
      ),
    );
  }
}
