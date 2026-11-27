import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zapp/routes/app_routes.dart';

class VerifyCodeLogic extends GetxController {
  final codeCtrl = TextEditingController();

  // 來自上一頁的資料（顯示用）
  late final String countryCode;
  late final String phone;

  // 狀態
  final secondsLeft = 60.obs;
  final canResend = false.obs;
  final isValid = false.obs;
  final isLoading = false.obs;

  Timer? _timer;

  List<TextInputFormatter> get inputFormatters => [
    LengthLimitingTextInputFormatter(6),
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    countryCode = (args['countryCode'] ?? '+886').toString();
    phone = (args['phone'] ?? '').toString();

    _startTimer();
  }

  void _startTimer() {
    secondsLeft.value = 60;
    canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value <= 1) {
        t.cancel();
        secondsLeft.value = 0;
        canResend.value = true;
      } else {
        secondsLeft.value--;
      }
    });
  }

  void onCodeChanged(String v) {
    isValid.value = v.trim().length == 6;
  }

  Future<void> resend() async {
    if (!canResend.value) return;
    // TODO: 重送 OTP 的 API
    Get.snackbar('已重送', '驗證碼已重新發送到 $countryCode ${_maskPhone(phone)}',
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
    _startTimer();
  }

  Future<void> submit() async {
    if (!isValid.value) return;
    isLoading.value = true;
    try {
      final code = codeCtrl.text.trim();
      // TODO: 驗證 OTP 的 API
      Get.snackbar('驗證中', 'code: $code',
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
      Get.toNamed(AppRoutes.EmailVerify);
      // 驗證通過後導向下一步
      // Get.offAll(() => HomePage());
    } catch (e) {
      Get.snackbar('失敗', '$e',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  String _maskPhone(String p) {
    if (p.length <= 3) return p;
    final visible = p.substring(p.length - 3);
    return '••••••$visible';
  }

  @override
  void onClose() {
    _timer?.cancel();
    codeCtrl.dispose();
    super.onClose();
  }
}
