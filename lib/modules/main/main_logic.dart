import 'package:get/get.dart';

import '../../services/login_required_guard_service.dart';

class MainLogic extends GetxController {
  /// 目前底欄索引（0: 揪團, 1: 主頁, 2: 聊天, 3: 個人）
  final RxInt currentIndex = 1.obs;
  final LoginRequiredGuardService _loginGuard =
      Get.find<LoginRequiredGuardService>();

  Future<void> setIndex(int i) async {
    if (i == 2) {
      final ok = await _loginGuard.ensureLoggedIn(
        featureName: '聊天功能',
        message: '查看聊天室與傳送訊息需要先登入帳號。',
      );
      if (!ok) return;
    }

    if (i == 3) {
      final ok = await _loginGuard.ensureLoggedIn(
        featureName: '個人功能',
        message: '查看個人頁、設定與我的活動需要先登入帳號。',
      );
      if (!ok) return;
    }

    currentIndex.value = i;
  }
}
