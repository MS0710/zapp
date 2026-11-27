import 'package:get/get.dart';

import 'chat_list_logic.dart';

class ChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatListLogic());
  }
}
