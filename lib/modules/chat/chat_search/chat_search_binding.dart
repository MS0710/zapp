import 'package:get/get.dart';

import 'chat_search_logic.dart';

class ChatSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatSearchLogic());
  }
}
