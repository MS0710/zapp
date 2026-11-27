import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:zapp/routes/app_routes.dart';
import 'package:zapp/widgets/merchant_activity_card.dart';

import 'match_map_logic.dart';

class MatchMapPage extends StatefulWidget {
  const MatchMapPage({super.key});

  @override
  State<MatchMapPage> createState() => _MatchMapPageState();
}

class _MatchMapPageState extends State<MatchMapPage> {
  final MatchMapLogic controller = Get.put(MatchMapLogic());

  // 顏色（可依你專案的 Constants 調整）
  static const Color bg = Color(0xFF2C2C40);
  static const Color searchBg = Color(0xFF000000);
  static const Color ticketYellow = Color(0xFFFFC52C);

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  bool _isExpanded = false;
  late double _collapsedSize;
  static const double _maxSheetSize = 0.89;
  late double _screenHeight;
  late double _midSheetSize;

  bool _isListMode = false; // false = 地圖模式, true = 清單模式

  final MapController _mapController = MapController();
  LatLng? _myLocation;

  // marker 旁浮動資訊框
  MerchantMapItem? _selectedMerchant;
  Offset? _selectedMerchantPx; // 螢幕座標 (for Positioned)
  ActivityMarkerItem? _selectedActivity;
  Offset? _selectedActivityPx;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToMyLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;

    const double collapsedHeaderHeightPx = 72;
    _collapsedSize = collapsedHeaderHeightPx / _screenHeight;
    _midSheetSize = _collapsedSize + (_maxSheetSize - _collapsedSize) * 0.7;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        color: bg,
        child:
            _isListMode
                ? SafeArea(bottom: false, child: _buildListLayout())
                : _buildMapLayout(),
      ),
    );
  }

  Widget _buildMapLayout() {
    return Stack(
      children: [
        Positioned.fill(child: _buildMapView()),
        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const SizedBox(height: 16), _buildTopSearchBar()],
          ),
        ),
        _buildModeToggleOverlayButton(),

        Positioned(
          right: 16,
          bottom: 120,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _moveToMyLocation,
            child: const Icon(Icons.my_location, color: Colors.black87),
          ),
        ),
        _buildBottomSheet(context),
      ],
    );
  }

  // ======== 真實地圖區（OSM + flutter_map）========
  Widget _buildMapView() {
    return Obx(() {
      final items = controller.merchantsForMap;
      final activityItems = controller.activityMarkers;

      final LatLng center =
          _myLocation ??
          (items.isNotEmpty
              ? items.first.position
              : activityItems.isNotEmpty
              ? activityItems.first.position
              : const LatLng(25.0330, 121.5654));

      final List<Marker> markers =
          items.map((m) {
            return Marker(
              point: m.position,
              width: 88,
              height: 88,
              child: GestureDetector(
                onTap: () => _selectMerchant(m),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 34,
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            );
          }).toList();

      markers.addAll(
        activityItems.map((activity) {
          return Marker(
            point: activity.position,
            width: 20,
            height: 20,
            child: GestureDetector(
              onTap: () => _selectActivity(activity),
              child: Container(
                decoration: BoxDecoration(
                  color: ticketYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_activity,
                  size: 12,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }),
      );

      if (_myLocation != null) {
        markers.add(
          Marker(
            point: _myLocation!,
            width: 20,
            height: 20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.9),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        );
      }

      return Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
              // 點地圖空白就關閉浮動框
              onTap: (_, __) => _clearSelections(),
              // 地圖移動/縮放時，浮動框跟著 marker 跑
              onPositionChanged: (_, __) {
                if (_selectedMerchant != null) {
                  _updateSelectedMerchantPixel();
                }
                if (_selectedActivity != null) {
                  _updateSelectedActivityPixel();
                }
              },
            ),
            children: [
              TileLayer(
                //urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                urlTemplate:
                    'https://maps.hereapi.com/v3/base/mc/{z}/{x}/{y}/png8?apiKey=JOetgrL7YRNN6WzsN3Hpvqt5jKyde8JCcUzCDkMvFxk',
                userAgentPackageName: 'com.zapp.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // marker 旁邊的浮動資訊框
          if (_selectedMerchant != null && _selectedMerchantPx != null)
            Positioned(
              left: _selectedMerchantPx!.dx - 120, // 卡片寬 240 → 置中
              top: _selectedMerchantPx!.dy - 120, // 放在 marker 上方
              child: _buildMarkerInfoCard(_selectedMerchant!),
            ),
          if (_selectedActivity != null && _selectedActivityPx != null)
            Positioned(
              left: _selectedActivityPx!.dx - 120,
              top: _selectedActivityPx!.dy - 120,
              child: _buildActivityMarkerInfoCard(_selectedActivity!),
            ),

          if (controller.isLoading.value)
            const Positioned(top: 118, right: 16, child: _MapLoadingBadge()),

          if (controller.errorText.isNotEmpty &&
              items.isEmpty &&
              activityItems.isEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 190,
              child: _MapMessageBadge(message: controller.errorText.value),
            ),
        ],
      );
    });
  }

  Widget _buildActivityMarkerInfoCard(ActivityMarkerItem activity) {
    const double cardW = 250;
    const double radius = 16;

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: cardW,
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7D6),
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 10),
                  color: Colors.black26,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.local_activity,
                        size: 16,
                        color: Color(0xFF8B6B00),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        activity.location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7280),
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.PlaceDetail,
                        arguments: {'merchantId': activity.merchantId},
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '前往',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: cardW / 2 - 10,
            bottom: -8,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF7D6),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      offset: Offset(0, 6),
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 清單模式的版面
  Widget _buildListLayout() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorText.isNotEmpty) {
        return Center(
          child: Text(
            controller.errorText.value,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }

      final items = controller.merchantsForMap;
      if (items.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTopSearchBar(),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(
                child: Text(
                  '目前沒有可顯示的商家',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }

      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTopSearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final m = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 70),
                      child: _buildEventCard(
                        merchantId: m.id,
                        storeName: m.name,
                        coverPhoto: m.coverPhoto,
                        address: m.address,
                        distanceLabel: controller.distanceLabelForMerchant(
                          m.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          _buildModeToggleOverlayButton(useSafeAreaInset: false),
        ],
      );
    });
  }

  // ===== 上方搜尋列 =====
  Widget _buildTopSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
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
                      '搜尋活動 / 地點',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: controller.onTapPeople,
                    child: Image.asset(
                      'assets/images/join.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggleOverlayButton({bool useSafeAreaInset = true}) {
    final topInset = MediaQuery.of(context).padding.top;
    final isListMode = _isListMode;

    return Positioned(
      right: 16,
      // topInset(狀態列) + 16(上方留白) + 48(搜尋框高度) + 16(搜尋框下方間距)
      top: (useSafeAreaInset ? topInset : 0) + 16 + 48 + 16,
      child: GestureDetector(
        onTap: () {
          setState(() => _isListMode = !_isListMode);
          if (!_isListMode) {
            _collapseSheet();
          }
          // 切模式時也關掉浮動框，避免狀態殘留
          _clearSelections();
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isListMode ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow:
                isListMode
                    ? const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]
                    : null,
          ),
          padding: EdgeInsets.all(isListMode ? 10 : 0),
          child:
              isListMode
                  ? const Icon(
                    Icons.location_on_rounded,
                    color: Colors.black87,
                    size: 28,
                  )
                  : Image.asset('assets/images/han.png'),
        ),
      ),
    );
  }

  // ===== 底部可拖曳 Sheet =====
  Widget _buildBottomSheet(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _collapsedSize,
      minChildSize: _collapsedSize,
      maxChildSize: _maxSheetSize,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleSheet,
                  onVerticalDragUpdate: (details) {
                    final delta = details.primaryDelta ?? 0;
                    if (delta == 0) return;

                    final deltaFraction = -delta / _screenHeight;
                    double newSize = _sheetController.size + deltaFraction;
                    if (newSize < _collapsedSize) newSize = _collapsedSize;
                    if (newSize > _maxSheetSize) newSize = _maxSheetSize;
                    _sheetController.jumpTo(newSize);
                  },
                  onVerticalDragEnd: (details) {
                    final current = _sheetController.size;
                    final velocity = details.primaryVelocity ?? 0;

                    if (velocity > 300) {
                      _collapseSheet();
                      return;
                    }
                    if (velocity < -300) {
                      _expandSheet();
                      return;
                    }

                    if (current >= _midSheetSize) {
                      _expandSheet();
                    } else {
                      _collapseSheet();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Obx(
                            () => Row(
                              children: [
                                const Text(
                                  '附近最新活動資訊',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (controller.isDistanceSorting.value)
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white70,
                                    ),
                                  ),
                                const Spacer(),
                                Icon(
                                  _isExpanded
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_up,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    final acts = controller.activities;

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      children: [
                        if (controller.isDistanceSorting.value) ...[
                          _buildActivityUpdateStatus(),
                          const SizedBox(height: 12),
                        ],
                        _buildOfficialCard(
                          title: '最新官方活動照片',
                          subtitle: '最新官方活動資訊',
                        ),
                        const SizedBox(height: 60),
                        if (acts.isEmpty)
                          const Text(
                            '目前沒有活動',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          )
                        else
                          for (final a in acts)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 50,
                              ),
                              child: _buildActivityCard(
                                merchantId: a.merchantId,
                                title: a.title,
                                imageUrl: a.imageUrl,
                                location: a.location ?? '',
                                distanceLabel: controller
                                    .distanceLabelForActivity(a.id),
                              ),
                            ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _expandSheet() {
    _sheetController.animateTo(
      _maxSheetSize,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
    setState(() => _isExpanded = true);
  }

  void _collapseSheet() {
    _sheetController.animateTo(
      _collapsedSize,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
    setState(() => _isExpanded = false);
  }

  void _toggleSheet() {
    if (_isExpanded) {
      _collapseSheet();
    } else {
      _expandSheet();
    }
  }

  Widget _buildActivityUpdateStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '正在更新附近活動',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===== 卡片樣式 =====
  Widget _buildOfficialCard({required String title, required String subtitle}) {
    const double radius = 20.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () {
          Get.toNamed(
            AppRoutes.PlaceDetail,
            arguments: {
              'placeName': title,
              'title': subtitle,
              'description': '這邊可以打店家簡介',
            },
          );
        },
        child: SizedBox(
          height: 195,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: -50,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  alignment: Alignment.bottomLeft,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9FA7B6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(radius),
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String merchantId,
    required String storeName,
    required String? coverPhoto,
    required String address,
    String? distanceLabel,
  }) {
    const double radius = 20.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () {
          Get.toNamed(
            AppRoutes.PlaceDetail,
            arguments: {'merchantId': merchantId},
          );
        },
        child: SizedBox(
          height: 195,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: -50,
                child: Container(
                  height: 88,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF9FA7B6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (distanceLabel != null &&
                              distanceLabel.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                distanceLabel,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B27),
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child:
                      coverPhoto != null && coverPhoto.isNotEmpty
                          ? Image.network(
                            coverPhoto,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (_, __, ___) => _buildFallbackTitle(storeName),
                          )
                          : _buildFallbackTitle(storeName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackTitle(String storeName) {
    return Center(
      child: Text(
        storeName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActivityCard({
    required String merchantId,
    required String title,
    required String? imageUrl,
    required String location,
    String? distanceLabel,
  }) {
    return MerchantActivityCard(
      merchantId: merchantId,
      title: title,
      imageUrl: imageUrl,
      location: location,
      distanceLabel: distanceLabel,
    );
  }

  // ===== marker 浮動資訊框（含前往按鈕）=====
  Widget _buildMarkerInfoCard(MerchantMapItem m) {
    const double cardW = 250;
    const double radius = 16;

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 主卡片
          Container(
            width: cardW,
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 10),
                  color: Colors.black26,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 店名
                Text(
                  m.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),

                // 地址（左側小 icon + 兩行）
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.place_rounded,
                        size: 16,
                        color: Color(0xFF6B7280), // 灰
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        m.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7280),
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 右下角小「前往」按鈕
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.PlaceDetail,
                        arguments: {'merchantId': m.id},
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '前往',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 小尖角（指向 marker）
          Positioned(
            left: cardW / 2 - 10,
            bottom: -8,
            child: Transform.rotate(
              angle: 0.785398, // 45°
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      offset: Offset(0, 6),
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== marker 選取/關閉/更新位置 =====
  void _selectMerchant(MerchantMapItem m) {
    setState(() {
      _selectedActivity = null;
      _selectedActivityPx = null;
      _selectedMerchant = m;
    });
    _updateSelectedMerchantPixel();
  }

  void _selectActivity(ActivityMarkerItem activity) {
    setState(() {
      _selectedMerchant = null;
      _selectedMerchantPx = null;
      _selectedActivity = activity;
    });
    _updateSelectedActivityPixel();
  }

  void _clearSelections() {
    if (_selectedMerchant == null &&
        _selectedMerchantPx == null &&
        _selectedActivity == null &&
        _selectedActivityPx == null) {
      return;
    }
    setState(() {
      _selectedMerchant = null;
      _selectedMerchantPx = null;
      _selectedActivity = null;
      _selectedActivityPx = null;
    });
  }

  void _updateSelectedMerchantPixel() {
    final m = _selectedMerchant;
    if (m == null) return;

    final offset = _latLngToOffset(m.position);
    if (offset == null) return;

    setState(() {
      _selectedMerchantPx = offset;
    });
  }

  void _updateSelectedActivityPixel() {
    final activity = _selectedActivity;
    if (activity == null) return;

    final offset = _latLngToOffset(activity.position);
    if (offset == null) return;

    setState(() {
      _selectedActivityPx = offset;
    });
  }

  /// 兼容不同 flutter_map 版本：把 LatLng 轉成螢幕座標 Offset
  Offset? _latLngToOffset(LatLng ll) {
    try {
      // flutter_map 6+ 常見：mapController.camera.latLngToScreenPoint
      final p = (_mapController as dynamic).camera.latLngToScreenPoint(ll);
      if (p != null) {
        return Offset((p.x as num).toDouble(), (p.y as num).toDouble());
      }
    } catch (_) {}

    try {
      // 較舊版本：mapController.latLngToScreenPoint
      final p = (_mapController as dynamic).latLngToScreenPoint(ll);
      if (p != null) {
        return Offset((p.x as num).toDouble(), (p.y as num).toDouble());
      }
    } catch (_) {}

    return null;
  }

  Future<void> _moveToMyLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        '定位服務未開啟',
        '請先在系統設定中開啟定位服務',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar(
        '定位權限被拒絕',
        '請到系統設定開啟定位權限，才能使用「定位到我」功能',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final last = await Geolocator.getLastKnownPosition();
    if (last != null) {
      final quickLatLng = LatLng(last.latitude, last.longitude);
      setState(() {
        _myLocation = quickLatLng;
      });
      _mapController.move(quickLatLng, 16);
      await controller.sortActivitiesByDistance(quickLatLng);
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 8),
      );

      final freshLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _myLocation = freshLatLng;
      });
      _mapController.move(freshLatLng, 16);
      await controller.sortActivitiesByDistance(freshLatLng);
    } catch (_) {
      // timeout -> keep last
    }
  }
}

class _MapLoadingBadge extends StatelessWidget {
  const _MapLoadingBadge();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              '載入地點中',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapMessageBadge extends StatelessWidget {
  const _MapMessageBadge({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}
