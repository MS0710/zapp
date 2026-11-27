import 'package:get/get.dart';

import 'match_list_logic.dart';

class MatchListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MatchListLogic());
  }
}
