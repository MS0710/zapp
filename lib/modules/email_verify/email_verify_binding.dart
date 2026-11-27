import 'package:get/get.dart';

import 'email_verify_logic.dart';

class EmailVerifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmailVerifyLogic());
  }
}
