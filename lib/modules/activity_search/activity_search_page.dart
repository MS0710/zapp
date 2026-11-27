import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/search/search_activity_item.dart';
import '../../models/search/search_location_item.dart';
import '../../widgets/activity_summary_card.dart';
import '../../widgets/merchant_activity_card.dart';
import 'activity_search_logic.dart';

class ActivitySearchPage extends StatelessWidget {
  ActivitySearchPage({super.key});

  final ActivitySearchLogic controller = Get.find<ActivitySearchLogic>();

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
            if (controller.showLocationTab) _buildTabs(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white,
              ),
              Expanded(
                child: Text(
                  controller.title,
                  style: const TextStyle(
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
                    decoration: InputDecoration(
                      hintText: controller.hintText,
                      hintStyle: const TextStyle(color: Colors.white54),
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
              _buildTabButton(
                label: '活動',
                tab: ActivitySearchTab.activities,
                selected:
                    controller.activeTab.value == ActivitySearchTab.activities,
              ),
              _buildTabButton(
                label: '地點',
                tab: ActivitySearchTab.locations,
                selected:
                    controller.activeTab.value == ActivitySearchTab.locations,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabButton({
    required String label,
    required ActivitySearchTab tab,
    required bool selected,
  }) {
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
              fontSize: 15,
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
        return _buildEmptyHint(
          icon: Icons.manage_search_rounded,
          text: '輸入關鍵字後按搜尋',
        );
      }

      if (!controller.hasSearched.value) {
        return _buildEmptyHint(
          icon: Icons.manage_search_rounded,
          text: '按搜尋查看結果',
        );
      }

      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      final error = controller.errorMessage.value;
      if (error != null) {
        return _buildEmptyHint(icon: Icons.error_outline_rounded, text: error);
      }

      if (controller.activeTab.value == ActivitySearchTab.locations &&
          controller.showLocationTab) {
        return _buildLocationResults();
      }

      return _buildActivityResults();
    });
  }

  Widget _buildActivityResults() {
    final list = controller.activityResults;
    if (list.isEmpty) {
      return _buildEmptyHint(icon: Icons.search_off_rounded, text: '找不到相關活動');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        return _ActivityResultTile(
          item: list[index],
          onTap: () => controller.onTapActivity(list[index]),
        );
      },
    );
  }

  Widget _buildLocationResults() {
    final list = controller.locationResults;
    if (list.isEmpty) {
      return _buildEmptyHint(
        icon: Icons.location_off_outlined,
        text: '找不到相關地點',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        return _LocationResultTile(
          item: list[index],
          onTap: () => controller.onTapLocation(list[index]),
        );
      },
    );
  }

  Widget _buildEmptyHint({required IconData icon, required String text}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white38, size: 40),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityResultTile extends StatelessWidget {
  const _ActivityResultTile({required this.item, required this.onTap});

  final SearchActivityItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (item.type == 'merchant_activity') {
      return MerchantActivityCard(
        merchantId: item.merchantId ?? '',
        title: item.title,
        imageUrl: item.imageUrl,
        location: item.location.isEmpty ? '未提供地點' : item.location,
        onTap: onTap,
      );
    }

    return ActivitySummaryCard(
      title: item.title,
      imageUrl: item.imageUrl,
      location: item.location.isEmpty ? '未提供地點' : item.location,
      startTime: item.startTime,
      maxParticipants: item.maxParticipants,
      backgroundColor: ActivitySearchPage.panelBg,
      onTap: onTap,
    );
  }
}

class _LocationResultTile extends StatelessWidget {
  const _LocationResultTile({required this.item, required this.onTap});

  final SearchLocationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ActivitySearchPage.panelBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            _ResultImage(imageUrl: item.imageUrl, icon: Icons.place_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultImage extends StatelessWidget {
  const _ResultImage({
    required this.imageUrl,
    this.icon = Icons.event_available_outlined,
  });

  final String? imageUrl;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        color: Colors.white.withValues(alpha: 0.08),
        child:
            imageUrl == null
                ? Icon(icon, color: Colors.white54, size: 28)
                : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Icon(icon, color: Colors.white54, size: 28);
                  },
                ),
      ),
    );
  }
}
