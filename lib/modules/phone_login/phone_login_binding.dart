import 'package:get/get.dart';

import 'phone_login_logic.dart';

class PhoneLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PhoneLoginLogic());
  }
}
