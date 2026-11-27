import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/ads/ad.dart';

class StartupPopupResult {
  final bool hideToday;
  final AdItem? selectedAd;

  const StartupPopupResult({required this.hideToday, this.selectedAd});
}

class StartupPopupDialog extends StatefulWidget {
  const StartupPopupDialog({super.key, required this.ads});

  final List<AdItem> ads;

  @override
  State<StartupPopupDialog> createState() => _StartupPopupDialogState();
}

class _StartupPopupDialogState extends State<StartupPopupDialog> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _hideToday = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close({AdItem? selectedAd}) {
    Get.back(
      result: StartupPopupResult(hideToday: _hideToday, selectedAd: selectedAd),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = (screenSize.width - 40).clamp(280.0, 380.0);
    final pageHeight = (dialogWidth * 0.72).clamp(200.0, 280.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: const Color(0xFF14061F),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '最新消息',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: '關閉',
                    onPressed: _close,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: pageHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.ads.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return _StartupPopupPage(ad: widget.ads[index]);
                },
              ),
            ),
            if (widget.ads.length > 1) ...[
              const SizedBox(height: 10),
              _PageDots(count: widget.ads.length, currentIndex: _currentIndex),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: Checkbox(
                      value: _hideToday,
                      activeColor: Colors.white,
                      checkColor: const Color(0xFF14061F),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      onChanged: (value) {
                        setState(() => _hideToday = value ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '今日不再顯示',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupPopupPage extends StatelessWidget {
  const _StartupPopupPage({required this.ad});

  final AdItem ad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child:
            ad.imageUrl == null
                ? Container(
                  color: Colors.white.withValues(alpha: 0.08),
                  child: const Center(
                    child: Icon(
                      Icons.campaign_outlined,
                      color: Colors.white70,
                      size: 42,
                    ),
                  ),
                )
                : Image.network(
                  ad.imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.white.withValues(alpha: 0.08),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white54,
                          size: 36,
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: isActive ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color:
                isActive ? Colors.white : Colors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
