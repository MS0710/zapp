import 'package:get/get.dart';

import 'place_detail_logic.dart';

class PlaceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlaceDetailLogic());
  }
}
