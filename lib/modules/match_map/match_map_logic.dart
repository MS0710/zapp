import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../services/activity_service.dart';
import '../../models/merchant_activity.dart';
import '../../routes/app_routes.dart';
import '../../services/here_geocoding_service.dart';
import '../../services/merchant_activity_service.dart';
import '../../services/merchant_settings_service.dart';
import '../../utils/log_utils.dart';

class MerchantMapItem {
  final String id;
  final String name;
  final String address;
  final LatLng position;
  final String? coverPhoto;
  final int openActivityCount;

  MerchantMapItem({
    required this.id,
    required this.name,
    required this.address,
    required this.position,
    this.coverPhoto,
    this.openActivityCount = 0,
  });
}

class ActivityMarkerItem {
  final int id;
  final String merchantId;
  final String title;
  final String location;
  final LatLng position;

  ActivityMarkerItem({
    required this.id,
    required this.merchantId,
    required this.title,
    required this.location,
    required this.position,
  });
}

class MatchMapLogic extends GetxController {
  final ActivityService activityService = Get.find<ActivityService>();
  final MerchantSettingsService merchantApi =
      Get.find<MerchantSettingsService>();
  final MerchantActivityService merchantActivityApi =
      Get.find<MerchantActivityService>();
  final HereGeocodingService hereGeo = Get.find<HereGeocodingService>();
  final Distance _distance = const Distance();

  // 地圖狀態
  final RxBool isLoading = false.obs;
  final RxString errorText = ''.obs;

  /// 地圖上要畫的商家列表（已經有經緯度）
  final RxList<MerchantMapItem> merchantsForMap = <MerchantMapItem>[].obs;

  /// 地圖上要畫的活動 markers（已轉成經緯度）
  final RxList<ActivityMarkerItem> activityMarkers = <ActivityMarkerItem>[].obs;

  /// 底部活動列表用
  final RxList<MerchantActivity> activities = <MerchantActivity>[].obs;
  final Rxn<LatLng> currentLocation = Rxn<LatLng>();
  final RxBool isDistanceSorting = false.obs;
  final RxMap<int, double> activityDistanceMetersById = <int, double>{}.obs;
  final RxMap<String, double> merchantDistanceMetersById =
      <String, double>{}.obs;

  final Map<String, LatLng?> _activityLocationCache = <String, LatLng?>{};
  final List<MerchantActivity> _allActivities = <MerchantActivity>[];

  @override
  void onInit() {
    super.onInit();
    bootstrap();
  }

  /// 一次把商家 + 活動都載好
  Future<void> bootstrap() async {
    try {
      isLoading.value = true;
      errorText.value = '';

      await logActivityMapsApi();
      await loadMerchantActivities(); // 活動列表
      await loadMerchantsForMap(); // 地址→座標（HERE）
      await loadActivityMarkers(); // 活動地址→座標（HERE）

      logger.logDebug('[MatchMapLogic] bootstrap DONE');
    } catch (e, st) {
      logger.logError('[MatchMapLogic] bootstrap error: $e');
      logger.logError(st.toString());
      errorText.value = '載入資料失敗，請稍後再試';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadActivityMarkers() async {
    logger.logDebug('[MatchMapLogic] loadActivityMarkers START');

    try {
      final List<ActivityMarkerItem> result = [];

      for (final activity in activities) {
        final isOpen = (activity.status ?? '').toLowerCase() == 'open';
        final location = (activity.location ?? '').trim();
        if (!isOpen || location.isEmpty) {
          continue;
        }

        final pos = await _resolveActivityLatLng(location);

        if (pos == null) {
          logger.logError(
            '[MatchMapLogic] activity geocode failed: ${activity.id} / $location',
          );
          continue;
        }

        result.add(
          ActivityMarkerItem(
            id: activity.id,
            merchantId: activity.merchantId,
            title: activity.title,
            location: location,
            position: pos,
          ),
        );
      }

      activityMarkers.assignAll(result);
      logger.logDebug(
        '[MatchMapLogic] activityMarkers ready = ${activityMarkers.length}',
      );
      logger.logDebug('[MatchMapLogic] loadActivityMarkers DONE');
    } catch (e, st) {
      logger.logError('[MatchMapLogic] loadActivityMarkers error: $e');
      logger.logError(st.toString());
      rethrow;
    }
  }

  Future<void> logActivityMapsApi() async {
    logger.logDebug('[MatchMapLogic] getActivityMaps START');

    try {
      final response = await activityService.getActivityMaps();
      logger.logDebug(
        '[MatchMapLogic] getActivityMaps count = ${response.data.length}',
      );

      for (final item in response.data) {
        logger.logPretty('[MatchMapLogic] getActivityMaps item', item.toJson());
      }

      logger.logDebug('[MatchMapLogic] getActivityMaps DONE');
    } catch (e, st) {
      logger.logError('[MatchMapLogic] getActivityMaps failed: $e');
      logger.logError(st.toString());
    }
  }

  /// 正式版：抓所有商家 → 用 HERE 地址轉座標 → 給地圖使用
  Future<void> loadMerchantsForMap() async {
    logger.logDebug('[MatchMapLogic] loadMerchantsForMap START');

    try {
      final merchants = await merchantApi.getAllMerchants();
      final openActivityCountByMerchantId = <String, int>{};

      for (final activity in activities) {
        final merchantId = activity.merchantId.trim();
        final isOpen = (activity.status ?? '').toLowerCase() == 'open';
        if (merchantId.isEmpty || !isOpen) continue;
        openActivityCountByMerchantId.update(
          merchantId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      logger.logDebug('[MatchMapLogic] merchants count = ${merchants.length}');

      // 🔹 每筆商家先印一下（方便你檢查欄位）
      for (final m in merchants) {
        logger.logDebug(
          '[MatchMapLogic] merchant basic = ${m.id} / ${m.storeName}',
        );
        logger.logPretty('[MatchMapLogic] merchant full json', m.toJson());
      }

      final List<MerchantMapItem> result = [];

      for (final m in merchants) {
        final addr = (m.address ?? '').trim();
        if (addr.isEmpty) {
          logger.logDebug('[MatchMapLogic] skip: ${m.id} no address');
          continue;
        }

        logger.logDebug(
          '[MatchMapLogic] HERE geocode: ${m.id} / ${m.storeName} / $addr',
        );

        // HERE 地址轉座標
        final pos = await hereGeo.geocodeLatLng(addr);

        if (pos == null) {
          logger.logError('[MatchMapLogic] geocode failed: ${m.id} / $addr');
          continue;
        }

        logger.logDebug(
          '[MatchMapLogic] geocode OK: ${m.id} lat=${pos.latitude}, lng=${pos.longitude}',
        );

        result.add(
          MerchantMapItem(
            id: m.id,
            name: m.storeName,
            address: addr,
            position: pos,
            coverPhoto: m.coverPhoto,
            openActivityCount: openActivityCountByMerchantId[m.id] ?? 0,
          ),
        );

        // 禮貌 delay（避免連打太快）
        await Future.delayed(const Duration(milliseconds: 250));
      }

      final locationForSorting = currentLocation.value;
      if (locationForSorting != null) {
        _sortMerchantMapItemsByDistance(result, locationForSorting);
      }

      merchantsForMap.assignAll(result);
      logger.logDebug(
        '[MatchMapLogic] merchantsForMap ready = ${merchantsForMap.length}',
      );
      logger.logDebug(
        '[MatchMapLogic] merchants with open activity badge = ${result.where((m) => m.openActivityCount > 0).length}',
      );
      logger.logDebug('[MatchMapLogic] loadMerchantsForMap DONE');
    } catch (e, st) {
      logger.logError('[MatchMapLogic] loadMerchantsForMap error: $e');
      logger.logError(st.toString());
      rethrow;
    }
  }

  /// 活動：抓全部活動 → 排序 → assignAll
  Future<void> loadMerchantActivities() async {
    logger.logDebug('[MatchMapLogic] loadMerchantActivities START');

    try {
      final all = await merchantActivityApi.getMerchantActivities();

      logger.logDebug('[MatchMapLogic] activities(all) count = ${all.length}');
      for (final a in all) {
        logger.logPretty('[MatchMapLogic] activity(all) full json', a.toJson());
      }

      // 依 startTime 排序（新的在前）
      all.sort((a, b) {
        final sa = a.startTime ?? '';
        final sb = b.startTime ?? '';
        return sb.compareTo(sa); // 新的在前
      });

      _allActivities
        ..clear()
        ..addAll(all);

      final locationForSorting = currentLocation.value;
      if (locationForSorting != null) {
        await sortActivitiesByDistance(locationForSorting);
        logger.logDebug(
          '[MatchMapLogic] loadMerchantActivities DONE with distance sort',
        );
        return;
      }

      activities.assignAll(all);
      logger.logDebug('[MatchMapLogic] loadMerchantActivities DONE');
    } catch (e, st) {
      logger.logError('[MatchMapLogic] loadMerchantActivities error: $e');
      logger.logError(st.toString());
      rethrow;
    }
  }

  /// 只抓某個 merchantId 的活動（給你之後 PlaceDetail 用）
  Future<List<MerchantActivity>> loadMerchantActivitiesByMerchantId(
    String merchantId,
  ) async {
    logger.logDebug(
      '[MatchMapLogic] loadMerchantActivitiesByMerchantId START id=$merchantId',
    );

    try {
      final byMerchant = await merchantActivityApi.getMerchantActivities(
        merchantId: merchantId,
      );

      logger.logDebug(
        '[MatchMapLogic] activities(byMerchant) count = ${byMerchant.length}',
      );
      for (final a in byMerchant) {
        logger.logPretty(
          '[MatchMapLogic] activity(byMerchant) full json',
          a.toJson(),
        );
      }

      return byMerchant;
    } catch (e, st) {
      logger.logError(
        '[MatchMapLogic] loadMerchantActivitiesByMerchantId error: $e',
      );
      logger.logError(st.toString());
      return <MerchantActivity>[];
    } finally {
      logger.logDebug('[MatchMapLogic] loadMerchantActivitiesByMerchantId END');
    }
  }

  Future<void> sortActivitiesByDistance(LatLng currentLocation) async {
    logger.logDebug('[MatchMapLogic] sortActivitiesByDistance START');
    this.currentLocation.value = currentLocation;
    isDistanceSorting.value = true;

    try {
      if (merchantsForMap.isNotEmpty) {
        final sortedMerchants = merchantsForMap.toList();
        _sortMerchantMapItemsByDistance(sortedMerchants, currentLocation);
        merchantsForMap.assignAll(sortedMerchants);
      }

      final List<_ActivityWithDistance> sortable = [];
      final distanceById = <int, double>{};

      for (final activity in _allActivities) {
        final location = (activity.location ?? '').trim();
        if (location.isEmpty) {
          sortable.add(
            _ActivityWithDistance(
              activity: activity,
              distanceInMeters: double.infinity,
            ),
          );
          continue;
        }

        final pos = await _resolveActivityLatLng(location);
        final distanceInMeters =
            pos == null
                ? double.infinity
                : _distance.as(LengthUnit.Meter, currentLocation, pos);
        distanceById[activity.id] = distanceInMeters;

        sortable.add(
          _ActivityWithDistance(
            activity: activity,
            distanceInMeters: distanceInMeters,
          ),
        );
      }

      sortable.sort((a, b) {
        final distanceCompare = a.distanceInMeters.compareTo(
          b.distanceInMeters,
        );
        if (distanceCompare != 0) return distanceCompare;

        final aTime = a.activity.startTime ?? '';
        final bTime = b.activity.startTime ?? '';
        return bTime.compareTo(aTime);
      });

      activities.assignAll(sortable.map((item) => item.activity));
      activityDistanceMetersById.assignAll(distanceById);
      logger.logDebug('[MatchMapLogic] sortActivitiesByDistance DONE');
    } catch (e, st) {
      logger.logError('[MatchMapLogic] sortActivitiesByDistance error: $e');
      logger.logError(st.toString());
    } finally {
      isDistanceSorting.value = false;
    }
  }

  String? distanceLabelForActivity(int activityId) {
    final meters = activityDistanceMetersById[activityId];
    return _formatDistanceLabel(meters);
  }

  String? distanceLabelForMerchant(String merchantId) {
    final meters = merchantDistanceMetersById[merchantId];
    return _formatDistanceLabel(meters);
  }

  void _sortMerchantMapItemsByDistance(
    List<MerchantMapItem> items,
    LatLng currentLocation,
  ) {
    final distanceById = <String, double>{};
    items.sort((a, b) {
      final da = _distance.as(LengthUnit.Meter, currentLocation, a.position);
      final db = _distance.as(LengthUnit.Meter, currentLocation, b.position);
      distanceById[a.id] = da;
      distanceById[b.id] = db;
      return da.compareTo(db);
    });
    merchantDistanceMetersById.assignAll(distanceById);
  }

  String? _formatDistanceLabel(double? meters) {
    if (meters == null || meters.isInfinite) return null;
    if (meters > 100000) return '距離較遠';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(meters < 10000 ? 1 : 0)} km';
  }

  Future<LatLng?> _resolveActivityLatLng(String location) async {
    if (_activityLocationCache.containsKey(location)) {
      return _activityLocationCache[location];
    }

    logger.logDebug('[MatchMapLogic] activity HERE geocode: $location');
    final pos = await hereGeo.geocodeLatLng(location);
    _activityLocationCache[location] = pos;
    await Future.delayed(const Duration(milliseconds: 250));
    return pos;
  }

  // ===== UI callbacks（你原本那些）=====
  void onTapSearchBar() {
    Get.toNamed(AppRoutes.ActivitySearch, arguments: {'mode': 'allActivities'});
  }

  void onTapPeople() {}
  void onTapMenu() {}
  void onTapBottomInfo() {}
}

class _ActivityWithDistance {
  final MerchantActivity activity;
  final double distanceInMeters;

  const _ActivityWithDistance({
    required this.activity,
    required this.distanceInMeters,
  });
}
