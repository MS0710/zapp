import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zapp/routes/app_routes.dart';

class PhoneLoginLogic extends GetxController {
  // 國碼 & 手機
  final countryCode = '+886'.obs;
  final phoneCtrl = TextEditingController();

  // 狀態
  final isValid = false.obs;

  final _digitsOnly = FilteringTextInputFormatter.digitsOnly;

  // 允許的國碼（你可再擴充）
  List<String> get supportedCodes => const ['+886', '+81', '+82', '+852', '+1'];

  // 只驗證台灣規則（+886，9 碼行動電話）
  bool _validateTW(String digits) => RegExp(r'^[0-9]{9}$').hasMatch(digits);

  void onPhoneChanged(String value) {
    final trimmed = value.replaceAll(' ', '');
    if (countryCode.value == '+886') {
      isValid.value = _validateTW(trimmed);
    } else {
      // 其他國碼給個寬鬆版（6~12 碼），可依需求調整
      isValid.value = RegExp(r'^[0-9]{6,12}$').hasMatch(trimmed);
    }
  }

  List<TextInputFormatter> get inputFormatters => [_digitsOnly];

  void onCodeChanged(String code) {
    countryCode.value = code;
    onPhoneChanged(phoneCtrl.text);
  }

  Future<void> submit() async {
    if (!isValid.value) return;
    final number = '$countryCode ${phoneCtrl.text.trim()}';
    // TODO: 串接你的手機登入流程（發送 OTP 或進入下一步）
    Get.snackbar('OK', '準備驗證：$number',
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
    Get.toNamed(AppRoutes.VerifyCode);
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    super.onClose();
  }

}
