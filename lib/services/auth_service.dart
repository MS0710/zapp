import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:zapp/services/fcm_service.dart';

class AuthService {
  AuthService();

  final SupabaseClient _supabase = Supabase.instance.client;
  final RxBool isGuestMode = false.obs;

  /// =============================
  /// 註冊（不需 Email 驗證）
  /// =============================
  Future<User> signUp({
    required String email,
    required String password,
  }) async
  {
    final AuthResponse res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // ❗後端已關閉 Email 驗證 → 成功時 user 一定存在
    final user = res.user;
    if (user == null) {
      throw Exception('註冊失敗');
    }

    return user;
  }

  /// =============================
  /// 登入
  /// =============================
  Future<User> signIn({
    required String email,
    required String password,
  }) async
  {
    final AuthResponse res =
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;
    if (user == null) {
      throw Exception('登入失敗');
    }

    isGuestMode.value = false;
    if (Get.isRegistered<FCMService>()) {
      await Get.find<FCMService>().registerFcmToken();
    }
    return user;
  }

  void continueAsGuest() {
    isGuestMode.value = true;
  }

  /// =============================
  /// 登出
  /// =============================
  Future<void> signOut() async {
    isGuestMode.value = false;
    if (Get.isRegistered<FCMService>()) {
      await Get.find<FCMService>().clearOnLogout();
    }
    await _supabase.auth.signOut();
  }

  /// =============================
  /// 目前登入者
  /// =============================
  User? get currentUser => _supabase.auth.currentUser;

  /// =============================
  /// 是否已登入
  /// =============================
  bool get isLoggedIn => currentUser != null;

  bool get isGuest => isGuestMode.value;
}
