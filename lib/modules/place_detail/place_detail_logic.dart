import 'package:get/get.dart';

import '../../models/merchant_activity.dart';
import '../../models/merchant_settings.dart';
import '../../services/merchant_activity_service.dart';
import '../../services/merchant_settings_service.dart';
import '../../utils/log_utils.dart';

class PlaceDetailLogic extends GetxController {
  final MerchantSettingsService merchantApi = MerchantSettingsService();
  final MerchantActivityService merchantActivityApi = Get.find<MerchantActivityService>();

  /// Tab index：0: 主頁, 1: 菜單, 2: 活動, 3: 關於
  final RxInt tabIndex = 0.obs;

  late final String placeName;
  late final String title;
  late final String description;

  // ===== 狀態 =====
  final isLoading = false.obs;
  final errorText = ''.obs;

  // ===== route 傳進來的 =====
  late final String merchantId;
  final Rxn<MerchantSettings> merchant = Rxn<MerchantSettings>();
  final activities = <MerchantActivity>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['merchantId'] is String) {
      merchantId = args['merchantId'];
      loadMerchantDetail();
    } else {
      errorText.value = '缺少商家 ID';
      logger.logError('[PlaceDetailLogic] merchantId missing in arguments');
    }
  }

  /// 依 merchantId 取得商家詳細資料
  Future<void> loadMerchantDetail() async {
    try {
      isLoading.value = true;
      errorText.value = '';

      logger.logDebug(
        '[PlaceDetailLogic] loadMerchantDetail START, id=$merchantId',
      );

      final detail = await merchantApi.getMerchantById(merchantId);

      merchant.value = detail;

      logger.logPretty(
        '[PlaceDetailLogic] merchant detail full json',
        detail.toJson(),
      );

      await loadMerchantActivitiesByMerchantId(detail.id);
      logger.logDebug('[PlaceDetailLogic] loadMerchantDetail DONE');
    } catch (e, st) {
      logger.logError('[PlaceDetailLogic] loadMerchantDetail error: $e');
      logger.logError(st.toString());
      errorText.value = '載入商家資料失敗';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMerchantActivitiesByMerchantId(String merchantId) async {
    logger.logDebug('[PlaceDetailLogic] load activities START, merchantId=$merchantId');

    try {
      final acts = await merchantActivityApi.getMerchantActivities(
        merchantId: merchantId,
      );

      logger.logDebug('[PlaceDetailLogic] activities count = ${acts.length}');

      for (final a in acts) {
        logger.logPretty('[PlaceDetailLogic] activity full json', a.toJson());
      }

      // 依時間排序可加（新的在前/或舊的在前你自己選）
      acts.sort((a, b) => (a.startTime ?? '').compareTo(b.startTime ?? ''));
      activities.assignAll(acts);

      logger.logDebug('[PlaceDetailLogic] load activities DONE');
    } catch (e, st) {
      logger.logError('[PlaceDetailLogic] load activities error: $e');
      logger.logError(st.toString());
    }
  }

  String get storeName => merchant.value?.storeName ?? '店名';
  String get desc => merchant.value?.description ?? '—';
  String get cover => merchant.value?.coverPhoto ?? '';
  List<MenuItem> get menuItems => merchant.value?.menuItems ?? const [];
  String get address => merchant.value?.address ?? '';
  String get phone => merchant.value?.phone ?? '';
  String get businessHours => merchant.value?.businessHours ?? '';
  String get website => merchant.value?.website ?? '';
  /*List<String> get homePhotos {
    final url = cover.trim();
    if (url.isEmpty) return const [];
    return [url];
  }*/
  /// 主頁內容（每筆：{url, content}）
  List<Map<String, dynamic>> get homepageItems =>
      merchant.value?.homepageContent ?? const [];

  void changeTab(int i) => tabIndex.value = i;
  void onTapClose() => Get.back();
}
