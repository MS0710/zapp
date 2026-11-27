import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../widgets/common_login_required_dialog.dart';
import 'auth_service.dart';

class LoginRequiredGuardService {
  final AuthService _authService = Get.find<AuthService>();

  bool get _needsLogin => _authService.isGuest || !_authService.isLoggedIn;

  Future<bool> ensureLoggedIn({
    required String featureName,
    String? message,
  }) async {
    if (!_needsLogin) return true;

    final shouldLogin = await Get.dialog<bool>(
          CommonLoginRequiredDialog(
            message: message ?? '使用$featureName需要先登入帳號。',
          ),
          barrierDismissible: true,
        ) ??
        false;

    if (shouldLogin) {
      Get.offAllNamed(AppRoutes.Login);
    }

    return false;
  }
}
