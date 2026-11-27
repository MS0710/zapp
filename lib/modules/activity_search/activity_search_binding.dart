import 'package:get/get.dart';

import 'activity_search_logic.dart';

class ActivitySearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ActivitySearchLogic());
  }
}
