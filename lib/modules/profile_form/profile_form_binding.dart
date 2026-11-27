import 'package:get/get.dart';

import 'profile_form_logic.dart';

class ProfileFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileFormLogic());
  }
}
