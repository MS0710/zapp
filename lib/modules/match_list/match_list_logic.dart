import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zapp/utils/log_utils.dart';
import 'package:zapp/widgets/group_signup_card.dart';

import '../../models/activity.dart';
import '../../models/activity_detail.dart';
import '../../routes/app_routes.dart';
import '../../services/activity_service.dart';
import '../../services/login_required_guard_service.dart';
import '../../services/merchant_activity_service.dart';
import '../../services/merchant_settings_service.dart';

class MatchListLogic extends GetxController {
  final ActivityService _activityService = Get.find<ActivityService>();
  final LoginRequiredGuardService _loginGuard =
      Get.find<LoginRequiredGuardService>();
  final MerchantSettingsService merchantApi = MerchantSettingsService();
  final MerchantActivityService merchantActivityApi =
      Get.find<MerchantActivityService>();
  // 全部活動
  final RxList<ActivityItem> activities = <ActivityItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    logger.logDebug("MatchListLogic onInit");
    refreshActivities();
  }

  Future<void> refreshActivities() async {
    try {
      final res = await _activityService.getActivities(page: 1);
      activities.assignAll(res.data);

      logger.logDebug('getActivities ok: total=${res.total}');
    } catch (e, stack) {
      logger.logError('getActivities failed: $e');
      logger.logError(stack.toString());
    }
  }

  void onTapSearch() {
    Get.toNamed(AppRoutes.ActivitySearch, arguments: {'mode': 'groupOnly'});
  }

  Future<void> onTapCreateGroup() async {
    final ok = await _loginGuard.ensureLoggedIn(
      featureName: '建立活動',
      message: '建立揪團與活動需要先登入帳號。',
    );
    if (!ok) return;

    Get.toNamed(AppRoutes.CreateActivity, arguments: {'mode': 'create'});
  }

  /// 點活動：先拉 detail 再開 dialog（保留你原本流程）
  Future<void> onTapActivity(ActivityItem item) async {
    if (item.id <= 0) {
      // 你現在移除假資料後，理論上不會進來了；保留防呆
      return;
    }

    // loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final detailRes = await _activityService.getActivityDetail(id: item.id);
      if (Get.isDialogOpen == true) Get.back(); // 關 loading

      _openJoinDialog(item: item, detail: detailRes.data);
    } catch (e, st) {
      logger.logError('getActivityDetail failed: $e');
      logger.logError(st.toString());
      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        '讀取活動失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );

      _openJoinDialog(item: item, detail: null);
    }
  }

  void _openJoinDialog({
    required ActivityItem item,
    required ActivityDetail? detail,
  }) {
    final myStatus = detail?.myStatus;
    final actionLabel = _actionLabelFromMyStatus(myStatus);
    final canTapAction = (myStatus == null) || (myStatus == 'rejected');

    Get.generalDialog(
      barrierLabel: 'group',
      barrierDismissible: true,
      barrierColor: Colors.white.withOpacity(0.5),
      pageBuilder:
          (_, __, ___) => GroupSignupCard(
            item: item,
            actionLabel: actionLabel,
            onActionTap: canTapAction ? () => _joinAndRefresh(item) : null,
            detail: detail,
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

  String _actionLabelFromMyStatus(String? s) {
    switch (s) {
      case 'pending':
        return '等待審核';
      case 'joined':
        return '已加入';
      case 'rejected':
        return '被拒絕';
      default:
        return '參加';
    }
  }

  Future<void> _joinAndRefresh(ActivityItem item) async {
    final ok = await _loginGuard.ensureLoggedIn(
      featureName: '參加活動',
      message: '報名參加活動需要先登入帳號。',
    );
    if (!ok) return;

    try {
      final msg = await _activityService.joinActivity(activityId: item.id);

      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar('已送出報名', msg, snackPosition: SnackPosition.BOTTOM);

      // 報名後刷新列表
      await refreshActivities();
    } catch (e, stack) {
      logger.logError('joinActivity failed: $e');
      logger.logError(stack.toString());
      Get.snackbar(
        '報名失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
