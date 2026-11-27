import 'package:get/get.dart';

import 'login_help_logic.dart';

class LoginHelpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginHelpLogic());
  }
}
