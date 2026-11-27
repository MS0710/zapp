import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'place_detail_logic.dart';

class _HomePhoto {
  final String url;
  final String caption;
  const _HomePhoto({required this.url, required this.caption});
}

class PlaceDetailPage extends StatelessWidget {
  PlaceDetailPage({super.key});

  final PlaceDetailLogic controller = Get.put(PlaceDetailLogic());

  static const Color bg = Color(0xFF242437);
  static const Color coverGrey = Color(0xFFD0D0D0);

  final List<String> _tabs = const ['主頁', '菜單', '活動', '關於'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildCover(),
            _buildHeaderInfo(),
            _buildTabs(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  // ===== 封面區 + 關閉按鈕 =====
  Widget _buildCover() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final url = controller.cover;
              if (url.trim().isEmpty) {
                return _coverPlaceholder();
              }
              return Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _coverPlaceholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _coverPlaceholder(isLoading: true);
                },
              );
            }),
          ),

          // 讓封面文字/按鈕更清楚
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.10),
                    Colors.black.withOpacity(0.40),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            top: 16,
            child: GestureDetector(
              onTap: controller.onTapClose,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder({bool isLoading = false}) {
    return Container(
      color: coverGrey,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLoading ? Icons.downloading_rounded : Icons.image_outlined,
              size: 34,
              color: Colors.black54,
            ),
            const SizedBox(height: 6),
            Text(
              isLoading ? '載入封面中...' : '尚無封面圖片',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== 店名 + 簡介 =====
  Widget _buildHeaderInfo() {
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Obx(() {
        final loading = controller.isLoading.value;
        final err = controller.errorText.value;

        if (loading) {
          return const _HeaderSkeleton();
        }

        if (err.isNotEmpty) {
          return Text(
            err,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.storeName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              controller.desc,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ===== 上方 Tabs：主頁 / 菜單 / 活動 / 關於 =====
  Widget _buildTabs() {
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final current = controller.tabIndex.value;

        return Row(
          children: List.generate(_tabs.length, (i) {
            final selected = i == current;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.changeTab(i),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _tabs[i],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (selected)
                            Container(
                              height: 2,
                              width: 24,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  // ===== 依 tab 切換內容 =====
  Widget _buildBody() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorText.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorText.value,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        final tab = controller.tabIndex.value;

        if (tab == 0) return _buildHomeGrid();
        if (tab == 1) return _buildMenuList();
        if (tab == 2) return _buildActivities();
        if (tab == 3) return _buildAbout();
        // 其他 tab 先放佔位（你之後再換成 homepage_content 等）
        return _buildEmptyTab(tab);
      }),
    );
  }

  Widget _buildHomeGrid() {
    return Obx(() {
      final raw = controller.merchant.value?.homepageContent ?? const <Map<String, dynamic>>[];

      final photos = raw.map((e) => _HomePhoto(
        url: (e['url'] ?? '').toString().trim(),
        caption: (e['content'] ?? '').toString().trim(),
      )).where((p) => p.url.isNotEmpty).toList();

      if (photos.isEmpty) {
        return const Center(
          child: Text('尚無照片', style: TextStyle(color: Colors.white70)),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
        itemCount: photos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, i) {
          final p = photos[i];
          return GestureDetector(
            onTap: () => _openPhotoViewerPager(
              photos: photos,
              initialIndex: i,
              storeName: controller.storeName,
            ),
            child: _igPhotoTile(p.url),
          );
        },
      );
    });
  }

  Widget _igPhotoTile(String url) {
    const bg = Color(0xFF2E2E45);

    return Container(
      color: bg,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: bg,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 22),
          ),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: bg,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openPhotoViewerPager({
    required List<_HomePhoto> photos,
    required int initialIndex,
    required String storeName,
  }) {
    if (photos.isEmpty) return;

    final page = (initialIndex < 0)
        ? 0
        : (initialIndex >= photos.length ? photos.length - 1 : initialIndex);

    final currentIndex = page.obs;
    final pageCtrl = PageController(initialPage: page);

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 10),

              // 上方：左右滑動看大圖
              SizedBox(
                height: Get.height * 0.62,
                width: double.infinity,
                child: PageView.builder(
                  controller: pageCtrl,
                  itemCount: photos.length,
                  onPageChanged: (i) => currentIndex.value = i,
                  itemBuilder: (_, i) {
                    final p = photos[i];
                    return InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          p.url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Text('圖片載入失敗', style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 下方：文案跟著換（IG 風格）
              Obx(() {
                final p = photos[currentIndex.value];

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              storeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${currentIndex.value + 1}/${photos.length}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.caption.isEmpty ? '—' : p.caption,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMenuList() {
    final items = controller.menuItems;

    if (items.isEmpty) {
      return const Center(
        child: Text(
          '目前沒有菜單品項',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final it = items[i];

        final name = it.name.trim().isEmpty ? '未命名品項' : it.name.trim();
        final price = it.price.toString().trim();
        final desc = (it.description ?? '').toString().trim();
        final img = it.imageUrl.trim();

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 左圖
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 78,
                    height: 78,
                    color: const Color(0xFF3A3A55),
                    child: img.isEmpty
                        ? _menuImgPlaceholder()
                        : Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _menuImgPlaceholder(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return _menuImgPlaceholder(isLoading: true);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 右文（UberEats 風格：品名/簡述/價格）
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc.isEmpty ? '—' : desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        price.isEmpty ? '—' : '\$ $price',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAbout() {
    final addr = controller.address.trim();
    final phone = controller.phone.trim();
    final hours = controller.businessHours.trim();
    final web = controller.website.trim();

    final hasAny = addr.isNotEmpty || phone.isNotEmpty || hours.isNotEmpty || web.isNotEmpty;

    if (!hasAny) {
      return const Center(
        child: Text('尚無關於資訊', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        _sectionTitle('關於店家'),
        const SizedBox(height: 10),

        _infoCard(
          children: [
            _infoRow(
              icon: Icons.location_on_outlined,
              label: '地址',
              value: addr.isEmpty ? '—' : addr,
              onTap: addr.isEmpty ? null : () {
                // 先不做導航，你若要：之後可改成開地圖查詢
              },
            ),
            _divider(),
            _infoRow(
              icon: Icons.call_outlined,
              label: '電話',
              value: phone.isEmpty ? '—' : phone,
              onTap: phone.isEmpty ? null : () => _showPhoneSheet(phone),
            ),
            _divider(),
            _infoRow(
              icon: Icons.schedule_outlined,
              label: '營業時間',
              value: hours.isEmpty ? '—' : hours,
            ),
            _divider(),
            _infoRow(
              icon: Icons.language_outlined,
              label: '網站',
              value: web.isEmpty ? '—' : web,
              onTap: web.isEmpty ? null : () => _showWebsiteSheet(web),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 小提示區（可刪）
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: const Text(
            '資訊由店家提供，如有異動請以店家公告為準。',
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _menuImgPlaceholder({bool isLoading = false}) {
    return Center(
      child: Icon(
        isLoading ? Icons.downloading_rounded : Icons.image_outlined,
        color: Colors.white54,
        size: 26,
      ),
    );
  }

  Widget _buildEmptyTab(int tab) {
    final text = switch (tab) {
      0 => '主頁內容（之後可接 homepage_content）',
      2 => '活動內容（尚未提供資料）',
      3 => '關於內容（尚未提供資料）',
      _ => '—',
    };

    return Center(
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => Container(height: 1, color: Colors.white.withOpacity(0.06));

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  })
  {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return row;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: row,
    );
  }

  void _showPhoneSheet(String phone) {
    Get.bottomSheet(
      _actionSheet(
        title: '電話',
        actions: [
          _sheetAction(
            icon: Icons.call,
            text: '撥號 $phone',
            onTap: () async {
              Get.back();
              final uri = Uri.parse('tel:$phone');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                Get.snackbar('無法撥號', '此裝置不支援撥號功能',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
        ],
      ),
      isScrollControlled: true,
    );
  }

  void _showWebsiteSheet(String url) {
    Get.bottomSheet(
      _actionSheet(
        title: '網站',
        actions: [
          _sheetAction(
            icon: Icons.open_in_new,
            text: '前往 $url',
            onTap: () async {
              Get.back();
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                Get.snackbar('無法開啟', '此裝置無法開啟此網址',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
        ],
      ),
      isScrollControlled: true,
    );
  }

  Widget _actionSheet({required String title, required List<Widget> actions}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1F1F2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            ...actions,
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: Get.back,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.white.withOpacity(0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('取消'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetAction({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  })
  {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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

  Widget _buildActivities() {
    return Obx(() {
      final acts = controller.activities;

      if (acts.isEmpty) {
        return const Center(
          child: Text('目前沒有活動', style: TextStyle(color: Colors.white70)),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: acts.length,
        itemBuilder: (_, i) {
          final a = acts[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: _buildActivityCard(
              title: a.title,
              imageUrl: a.imageUrl,         // 你的 model 應該是 imageUrl
              location: a.location ?? '',
            ),
          );
        },
      );
    });
  }

  Widget _buildActivityCard({
    required String title,
    required String? imageUrl,
    required String location,
  })
  {
    const double radius = 20.0;

    return GestureDetector(
      onTap: () {
        // TODO: 之後導到活動詳情頁
        // 目前先不跳
      },
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: -50,
              child: Container(
                height: 95,
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
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.fill,
                  errorBuilder: (_, __, ___) => _buildFallbackTitle(title),
                )
                    : _buildFallbackTitle(title),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackTitle(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}


class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 18,
          width: 160,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}
