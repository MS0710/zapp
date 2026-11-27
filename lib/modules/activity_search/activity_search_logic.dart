import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/activity.dart';
import '../../models/activity_detail.dart';
import '../../models/search/search_activity_item.dart';
import '../../models/search/search_location_item.dart';
import '../../routes/app_routes.dart';
import '../../services/activity_service.dart';
import '../../services/activity_search_service.dart';
import '../../services/login_required_guard_service.dart';
import '../../utils/log_utils.dart';
import '../../widgets/group_signup_card.dart';

enum ActivitySearchMode { groupOnly, allActivities }

enum ActivitySearchTab { activities, locations }

class ActivitySearchLogic extends GetxController {
  ActivitySearchLogic({ActivitySearchService? searchService})
    : _searchService = searchService ?? ActivitySearchService();

  final ActivitySearchService _searchService;
  final ActivityService _activityService = Get.find<ActivityService>();
  final LoginRequiredGuardService _loginGuard =
      Get.find<LoginRequiredGuardService>();
  final TextEditingController searchController = TextEditingController();

  late final ActivitySearchMode mode;

  final query = ''.obs;
  final activeTab = ActivitySearchTab.activities.obs;
  final isLoading = false.obs;
  final hasSearched = false.obs;
  final errorMessage = RxnString();
  final activityResults = <SearchActivityItem>[].obs;
  final locationResults = <SearchLocationItem>[].obs;

  bool get isGroupOnly => mode == ActivitySearchMode.groupOnly;
  bool get showLocationTab => mode == ActivitySearchMode.allActivities;

  String get title => isGroupOnly ? '搜尋揪團' : '搜尋活動 / 地點';
  String get hintText => isGroupOnly ? '搜尋揪團、地點或描述' : '搜尋活動或地點';

  @override
  void onInit() {
    super.onInit();
    mode = _parseMode(Get.arguments);
  }

  void onQueryChanged(String value) {
    final composing = searchController.value.composing;
    if (composing.isValid && !composing.isCollapsed) {
      return;
    }

    query.value = value.trim();
  }

  void onTapTab(ActivitySearchTab tab) {
    if (activeTab.value == tab) return;
    activeTab.value = tab;
    hasSearched.value = false;
    errorMessage.value = null;
  }

  Future<void> submitSearch() async {
    final composing = searchController.value.composing;
    if (composing.isValid && !composing.isCollapsed) {
      return;
    }

    query.value = searchController.text.trim();
    hasSearched.value = true;
    await _runSearch();
  }

  void clearSearch() {
    searchController.clear();
    query.value = '';
    hasSearched.value = false;
    errorMessage.value = null;
    activityResults.clear();
    locationResults.clear();
    isLoading.value = false;
  }

  Future<void> _runSearch() async {
    final keyword = query.value.trim();
    errorMessage.value = null;

    if (keyword.isEmpty) {
      activityResults.clear();
      locationResults.clear();
      isLoading.value = false;
      hasSearched.value = false;
      return;
    }

    isLoading.value = true;

    try {
      if (isGroupOnly) {
        final resp = await _searchService.searchGroupActivities(query: keyword);
        activityResults.assignAll(resp.data);
        locationResults.clear();
        return;
      }

      if (activeTab.value == ActivitySearchTab.activities) {
        final resp = await _searchService.searchActivities(query: keyword);
        activityResults.assignAll(resp.data);
      } else {
        final resp = await _searchService.searchLocations(
          query: keyword,
          onlyWithMap: false,
        );
        locationResults.assignAll(resp.data);
      }
    } catch (e, st) {
      logger.logError('[ActivitySearch] search failed: $e');
      logger.logError(st.toString());
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onTapActivity(SearchActivityItem item) async {
    if (item.type == 'merchant_activity') {
      final merchantId = item.merchantId?.trim();
      if (merchantId == null || merchantId.isEmpty) {
        Get.snackbar('商家活動', item.title, snackPosition: SnackPosition.BOTTOM);
        return;
      }

      Get.toNamed(AppRoutes.PlaceDetail, arguments: {'merchantId': merchantId});
      return;
    }

    final activityItem = _toActivityItem(item);

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final detailRes = await _activityService.getActivityDetail(id: item.id);
      if (Get.isDialogOpen == true) Get.back();

      _openJoinDialog(item: activityItem, detail: detailRes.data);
    } catch (e, st) {
      logger.logError('[ActivitySearch] getActivityDetail failed: $e');
      logger.logError(st.toString());
      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        '讀取活動失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );

      _openJoinDialog(item: activityItem, detail: null);
    }
  }

  void onTapLocation(SearchLocationItem item) {
    final merchantId = item.merchantId?.trim();
    if (merchantId != null && merchantId.isNotEmpty) {
      Get.toNamed(AppRoutes.PlaceDetail, arguments: {'merchantId': merchantId});
      return;
    }

    Get.snackbar('地點', '這筆地點目前沒有商家資訊頁', snackPosition: SnackPosition.BOTTOM);
  }

  ActivitySearchMode _parseMode(dynamic arguments) {
    if (arguments is Map) {
      final raw = arguments['mode']?.toString();
      if (raw == 'allActivities') return ActivitySearchMode.allActivities;
    }
    return ActivitySearchMode.groupOnly;
  }

  ActivityItem _toActivityItem(SearchActivityItem item) {
    return ActivityItem(
      id: item.id,
      title: item.title,
      description: item.description,
      imageUrl: item.imageUrl,
      startTime: item.startTime,
      location: item.location,
      maxParticipants: item.maxParticipants,
      status: item.status,
      remarks: item.remarks ?? '',
      host: null,
      participantCount: 0,
    );
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
      barrierColor: Colors.white.withValues(alpha: 0.5),
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

  String _actionLabelFromMyStatus(String? status) {
    switch (status) {
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
      await _runSearch();
    } catch (e, st) {
      logger.logError('[ActivitySearch] joinActivity failed: $e');
      logger.logError(st.toString());
      Get.snackbar(
        '報名失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchService.dispose();
    super.onClose();
  }
}
