import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zapp/models/ads/ad.dart';
import 'package:zapp/routes/app_routes.dart';
import 'package:zapp/services/ads_service.dart';
import 'package:zapp/utils/log_utils.dart';
import 'package:zapp/widgets/startup_popup_dialog.dart';

import '../../services/auth_service.dart';

class LoginLogic extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final AdsService _adsService = AdsService();
  bool _startupPopupChecked = false;

  static const String _hiddenDateFileName = 'startup_popup_hidden_date.txt';

  @override
  void onReady() {
    super.onReady();
    _showStartupPopupsIfNeeded();
  }

  void loginApple() {}

  void loginGoogle() {}

  void loginNormal() {
    Get.toNamed(AppRoutes.PhoneLogin);
  }

  void goQA() {
    Get.toNamed(AppRoutes.LoginHelp);
  }

  void continueAsGuest() {
    _authService.continueAsGuest();
    Get.offAllNamed(AppRoutes.Main);
  }

  Future<void> _showStartupPopupsIfNeeded() async {
    if (_startupPopupChecked) return;
    _startupPopupChecked = true;

    try {
      if (await _isStartupPopupHiddenToday()) return;

      final resp = await _adsService.getStartupPopups();
      if (resp.data.isEmpty) return;
      if (Get.isDialogOpen == true) return;

      final result = await Get.dialog<StartupPopupResult>(
        StartupPopupDialog(ads: resp.data),
        barrierDismissible: false,
      );

      if (result?.hideToday == true) {
        await _markStartupPopupHiddenToday();
      }

      final selectedAd = result?.selectedAd;
      if (selectedAd != null) {
        await _openStartupPopupAd(selectedAd);
      }
    } catch (e, st) {
      logger.logError('[Login] startup popups failed: $e');
      logger.logError(st.toString());
    }
  }

  Future<void> _openStartupPopupAd(AdItem ad) async {
    final target = ad.ctaTarget ?? ad.targetUrl;
    if (target == null || target.trim().isEmpty) return;

    final uri = Uri.tryParse(target.trim());
    if (uri == null) return;

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      logger.logError('[Login] open startup popup target failed: $e');
    }
  }

  Future<bool> _isStartupPopupHiddenToday() async {
    final file = await _startupPopupHiddenDateFile();
    if (!await file.exists()) return false;

    final savedDate = (await file.readAsString()).trim();
    return savedDate == _todayKey();
  }

  Future<void> _markStartupPopupHiddenToday() async {
    final file = await _startupPopupHiddenDateFile();
    await file.writeAsString(_todayKey());
  }

  Future<File> _startupPopupHiddenDateFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_hiddenDateFileName');
  }

  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  /*Future<void> testSignUp() async {
    try {
      await _authService.signUp(
        email: 'test@test.com',
        password: '123456',
      );

      Get.snackbar(
        '註冊成功',
        'test@test.com',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 👉 如果你想註冊完直接進首頁，可以加：
      // Get.offAllNamed(AppRoutes.Home);

    } catch (e) {
      Get.snackbar(
        '註冊失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> testSignIn() async {
    try {
      final res = await _authService.signIn(
        email: 'test@gmail.com',
        password: 'test1234',

        //email: 'test@test.com',
        //password: '123456',
      );

      final session = Supabase.instance.client.auth.currentSession;
      logger.logDebug('signIn userId = ${res.id}');
      logger.logDebug('session is null? ${session == null}');
      if (session != null) {
        logger.logDebug('accessToken head = ${session.accessToken.substring(0, 20)}');
        logger.logDebug('expiresAt = ${session.expiresAt}');
      }

      Get.offAllNamed(AppRoutes.Main);
    } catch (e) {
      Get.snackbar('登入失敗', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.BOTTOM);
    }
  }*/
  Future<void> testSignUp() async {
    final input = await _showAuthDialog(title: '測試註冊');
    if (input == null) return; // 使用者取消

    try {
      await _authService.signUp(email: input.email, password: input.password);

      Get.snackbar('註冊成功', input.email, snackPosition: SnackPosition.BOTTOM);

      // ✅ 註冊後通常會有 session（你也可以直接導到 ProfileForm）
      // Get.offAllNamed(AppRoutes.ProfileForm, arguments: {'password': input.password});
    } catch (e) {
      Get.snackbar(
        '註冊失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> testSignIn() async {
    final input = await _showAuthDialog(title: '測試登入');
    if (input == null) return; // 使用者取消

    try {
      final user = await _authService.signIn(
        email: input.email,
        password: input.password,
      );

      final session = Supabase.instance.client.auth.currentSession;
      logger.logDebug('signIn userId = ${user.id}');
      logger.logDebug('session is null? ${session == null}');
      if (session != null) {
        logger.logDebug(
          'accessToken head = ${session.accessToken.substring(0, 20)}',
        );
        logger.logDebug('expiresAt = ${session.expiresAt}');
      }

      Get.offAllNamed(AppRoutes.Main);
    } catch (e) {
      Get.snackbar(
        '登入失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================
  // Dialog helper
  // =========================
  Future<_AuthInput?> _showAuthDialog({required String title}) async {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    // 也可以放你常用的預設值
    //emailCtrl.text = 'test@gmail.com';
    //passCtrl.text = 'test1234';

    final formKey = GlobalKey<FormState>();
    final result = await Get.dialog<_AuthInput>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return '請輸入 Email';
                    if (!s.contains('@')) return 'Email 格式不正確';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = (v ?? '');
                    if (s.isEmpty) return '請輸入密碼';
                    if (s.length < 6) return '至少 6 碼';
                    return null;
                  },
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(), // 回傳 null
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          Get.back(
                            result: _AuthInput(
                              email: emailCtrl.text.trim(),
                              password: passCtrl.text,
                            ),
                          );
                        },
                        child: const Text('確認'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );

    return result;
  }

  @override
  void onClose() {
    _adsService.dispose();
    super.onClose();
  }
}

class _AuthInput {
  final String email;
  final String password;
  const _AuthInput({required this.email, required this.password});
}
