import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 通用返回按鈕（圖片版）
/// - 預設使用 assets/images/back_icon.png
/// - 可調整大小與外層 padding
/// - 預設動作為 Get.back()
class CommonBackButton extends StatelessWidget {
  const CommonBackButton({
    super.key,
    this.size = 60,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.alignment = Alignment.centerLeft,
    this.assetPath = 'assets/images/back_icon.png',
    this.color,
    this.onPressed,
    this.semanticLabel = '返回',
  });

  /// 圖片顯示大小（寬高）
  final double size;

  /// 外層 Padding（通常放在頁面最上方）
  final EdgeInsets padding;

  /// 對齊方向（一般靠左）
  final Alignment alignment;

  /// 圖片路徑
  final String assetPath;

  /// 圖片顏色
  final Color? color;

  /// 點擊事件（預設：Get.back()）
  final VoidCallback? onPressed;

  /// 無障礙朗讀用
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child: Semantics(
          button: true,
          label: semanticLabel,
          child: IconButton(
            onPressed: onPressed ?? () => Get.back(),
            // 讓可點擊區域至少 44x44，符合人機介面建議
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
            icon: Image.asset(
              assetPath,
              width: size,
              height: size,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
