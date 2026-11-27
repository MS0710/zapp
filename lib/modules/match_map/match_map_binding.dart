import 'package:get/get.dart';

import 'match_map_logic.dart';

class MatchMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MatchMapLogic());
  }
}
