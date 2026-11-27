import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zapp/routes/app_routes.dart';

class EmailVerifyLogic extends GetxController {
  final emailCtrl = TextEditingController();

  final isValid   = false.obs;
  final isLoading = false.obs;

  final _emailReg =
  RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$'); // 簡潔穩定的 email 驗證

  void onEmailChanged(String v) {
    isValid.value = _emailReg.hasMatch(v.trim());
  }

  Future<void> submit() async {
    if (!isValid.value || isLoading.value) return;
    isLoading.value = true;
    try {
      final email = emailCtrl.text.trim();
      // TODO: 串接後端／Firebase：寄送驗證信或發送 magic link
      Get.toNamed(AppRoutes.ProfileForm);
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

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }

}
