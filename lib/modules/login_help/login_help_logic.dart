import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginHelpLogic extends GetxController {
  final emailCtrl = TextEditingController();

  // 狀態
  final isValid = false.obs;       // Email 是否有效
  final showError = false.obs;     // 是否顯示錯誤文字
  final isLoading = false.obs;

  final _emailReg = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

  void onEmailChanged(String v) {
    final trimmed = v.trim();
    final valid = _emailReg.hasMatch(trimmed);
    isValid.value = valid;
    showError.value = trimmed.isNotEmpty && !valid; // 只有有輸入且不合法時才顯示
  }

  Future<void> sendHelpRequest() async {
    if (!isValid.value) return;
    isLoading.value = true;
    try {
      final email = emailCtrl.text.trim();
      // TODO: 串接實際流程，例如：
      // await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      Get.snackbar(
        '已寄出', '我們已寄送協助信件至：$email',
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12),
      );
      // Get.back(); // 若寄出後要返回，可打開
    } catch (e) {
      Get.snackbar(
        '發送失敗', '$e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.red.shade600, colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}
