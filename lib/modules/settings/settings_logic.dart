import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zapp/routes/app_routes.dart';

import '../../services/auth_service.dart';

class SettingsLogic extends GetxController {
  final auth = Get.find<AuthService>();
  final appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  void onBack() => Get.back();

  Future<void> _loadAppVersion() async {
    try {
      final pubspec = await rootBundle.loadString('pubspec.yaml');
      final match = RegExp(r'^version:\s*(.+)$', multiLine: true).firstMatch(pubspec);
      appVersion.value = match?.group(1)?.trim() ?? '';
    } catch (_) {
      appVersion.value = '';
    }
  }

  void onEditProfile() {
    Get.toNamed(
      AppRoutes.ProfileForm,
      arguments: {'mode': 'edit'},
    );
  }

  void onPerks() {
    // TODO: 各式優惠
  }

  void onPrivacySettings() {
    // TODO: 隱私設定
  }

  void onContactUs() {
    // TODO: 聯絡我們
  }

  void onRestorePurchase() {
    // TODO: 恢復購買
  }

  void onPrivacyPolicy() {
    Get.toNamed(AppRoutes.PrivacyPolicy);
  }

  void onTerms() {
    Get.toNamed(AppRoutes.Terms);
  }

  void onLogout() {
    Get.defaultDialog(
      title: '登出帳號',
      middleText: '確定要登出嗎？',
      textCancel: '取消',
      textConfirm: '登出',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // 關 dialog

        try {
          await auth.signOut();
          Get.offAllNamed(AppRoutes.Login);
        } catch (e) {
          Get.snackbar(
            '登出失敗',
            '$e',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
          );
        }
      },
    );
  }


  void onDeleteAccount() {
    Get.defaultDialog(
      title: '刪除帳號',
      middleText:
      '刪除後資料將不可復原，確定要刪除嗎？',
      textCancel: '取消',
      textConfirm: '刪除',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        // TODO: 呼叫刪除帳號 API
      },
    );
  }

}
