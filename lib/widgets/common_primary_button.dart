import 'package:flutter/material.dart';

/// 底部用的主按鈕（可重用）
/// - 外部用 Obx 計算 enabled/isLoading，傳進來即可
/// - 預設寬度撐滿、固定高度、黑底白字、禁用時灰色
class CommonPrimaryButton extends StatelessWidget {
  const CommonPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.margin = const EdgeInsets.fromLTRB(24, 0, 24, 24),
    this.height = 48,
    this.radius = 12,
    this.enabledColor = Colors.black,
    this.disabledColor = Colors.black26,
    this.textColor = Colors.white,
    this.progressSize = 22,
    this.fontWeight = FontWeight.w800,
    this.fontSize = 16,
    this.elevationWhenEnabled = 2,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;

  // 外觀參數
  final EdgeInsets margin;
  final double height;
  final double radius;
  final Color enabledColor;
  final Color disabledColor;
  final Color textColor;
  final double progressSize;
  final FontWeight fontWeight;
  final double fontSize;
  final double elevationWhenEnabled;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = enabled && !isLoading;

    return Padding(
      padding: margin,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: effectiveEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? enabledColor : disabledColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            elevation: enabled ? elevationWhenEnabled : 0,
          ),
          child: isLoading
              ? SizedBox(
            width: progressSize,
            height: progressSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(
            label,
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
