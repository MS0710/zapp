import 'package:get/get.dart';

import 'create_activity_logic.dart';

class CreateActivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateActivityLogic());
  }
}
