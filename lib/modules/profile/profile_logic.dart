import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/routes/app_routes.dart';

import '../../models/my_activity.dart';
import '../../services/activity_service.dart';
import '../../utils/log_utils.dart';
import '../../widgets/activity_applicants_dialog.dart';

class ProfileLogic extends GetxController {
  final ActivityService _service = Get.find<ActivityService>();

  /// 目前選擇的 tab index（0: 活動, 1: 參加, 2: VIP, 3: 評分）
  final RxInt selectedTab = 0.obs;

  /// 暱稱 / 簡介（先維持你的寫死，之後再接 profile API）
  final RxString nickname = '暱稱'.obs;
  final RxString intro = '這邊可以打個人簡介'.obs;
  final RxnString avatarUrl = RxnString();

  /// 我的活動（主揪發布的）
  final RxList<MyActivityItem> myActivities = <MyActivityItem>[].obs;

  final RxBool loadingMyActivities = false.obs;
  final RxString myActivitiesError = ''.obs;

  bool _loadedOnce = false;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentProfile();
    // Profile 一進來先載入一次
    _loadMyActivities();
  }

  void _loadCurrentProfile() {
    final user = Supabase.instance.client.auth.currentUser;
    final data = user?.userMetadata ?? const <String, dynamic>{};
    final nick = (data['nickname'] ?? '').toString().trim();
    final avatar = (data['avatar_url'] ?? '').toString().trim();

    if (nick.isNotEmpty) {
      nickname.value = nick;
    }
    avatarUrl.value = avatar.isEmpty ? null : avatar;
  }

  void changeTab(int index) {
    selectedTab.value = index;

    // 只在第一次切到「活動」時載入（避免每切 tab 重讀）
    if (index == 0 && !_loadedOnce) {
      _loadMyActivities();
    }
  }

  void onTapSettings() {
    Get.toNamed(AppRoutes.Settings);
  }

  Future<void> onRefreshMyActivities() async {
    await _loadMyActivities(force: true);
  }

  Future<void> _loadMyActivities({bool force = false}) async {
    if (_loadedOnce && !force) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      myActivities.clear();
      myActivitiesError.value = '尚未登入，無法讀取我的活動';
      return;
    }

    loadingMyActivities.value = true;
    myActivitiesError.value = '';

    try {
      final res = await _service.getMyActivities(userId: userId, page: 1);
      myActivities.assignAll(res.data);

      _loadedOnce = true;

      logger.logDebug('[Profile] getMyActivities ok: total=${res.total}');
      for (final a in res.data) {
        logger.logDebug(
          '[Profile] MyActivity: id=${a.id}, title=${a.title}, joined=${a.joinedCount}, pending=${a.pendingCount}',
        );
      }
    } catch (e, st) {
      logger.logError('[Profile] getMyActivities failed: $e');
      logger.logError(st.toString());
      myActivitiesError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      loadingMyActivities.value = false;
    }
  }

  /// 點卡片：打開報名名單（主揪用）
  void onTapMyActivity(MyActivityItem item) {
    Get.generalDialog(
      barrierLabel: 'applicants',
      barrierDismissible: true,
      barrierColor: Get.theme.scaffoldBackgroundColor.withOpacity(0.18),
      pageBuilder: (_, __, ___) => ActivityApplicantsDialog(
        activityId: item.id,
        title: item.title,
      ),
      transitionBuilder: (_, anim, __, child) {
        return Transform.scale(
          scale: 0.95 + 0.05 * anim.value,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 180),
    );
  }

  /// 長按：底部滑出選單（編輯活動）
  void onLongPressMyActivity(MyActivityItem item) {
    Get.bottomSheet(
      _EditSheet(
        title: item.title,
        onEdit: () {
          Get.back(); // close sheet
          Get.toNamed(
            AppRoutes.CreateActivity,
            arguments: {
              'mode': 'edit',
              'id': item.id,
            },
          );
        },
      ),
      isScrollControlled: false,
      backgroundColor: const Color(0xFF1C1C28),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
    );
  }
}

class _EditSheet extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;

  const _EditSheet({
    required this.title,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),

            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    '編輯活動',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    '取消',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
