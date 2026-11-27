import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/activity.dart';
import '../../widgets/activity_summary_card.dart';
import 'match_list_logic.dart';

class MatchListPage extends StatelessWidget {
  MatchListPage({super.key});

  final MatchListLogic controller = Get.put(MatchListLogic());

  // 顏色更新
  static const Color bg = Color(0xFF2C2C40); // 整體背景
  static const Color cardBg = Color(0xFF1C1C28); // 卡片背景
  static const Color bottomBarBg = Color(0xFF23232A); // 下方 bar 背景

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== 標題 =====
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AutoSizeText(
              '缺一不可',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              minFontSize: 5,
              maxLines: 1,
            ),
          ),

          Container(height: 2, color: cardBg),

          // ===== 搜尋 / 揪團 按鈕列（靠右）=====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildTopPillButton(
                  icon: Icons.search,
                  label: '搜尋',
                  onTap: controller.onTapSearch,
                ),
                const SizedBox(width: 12),
                _buildTopPillButton(
                  icon: Icons.sports_kabaddi,
                  label: '揪團',
                  onTap: controller.onTapCreateGroup,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ===== 活動列表 =====
          Expanded(
            child: Obx(() {
              final list = controller.activities;

              return RefreshIndicator(
                onRefresh: controller.refreshActivities,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildActivityCard(item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityItem item) {
    return ActivitySummaryCard(
      title: item.title,
      imageUrl: item.imageUrl,
      location: item.location,
      startTime: item.startTime,
      maxParticipants: item.maxParticipants,
      participantCount: item.participantCount,
      backgroundColor: cardBg,
      onTap: () => controller.onTapActivity(item),
    );
  }

  // ===== 膠囊按鈕 =====
  Widget _buildTopPillButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
