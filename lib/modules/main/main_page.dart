import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zapp/modules/match_list/match_list_page.dart';
import 'package:zapp/modules/match_map/match_map_page.dart';
import 'package:zapp/modules/profile/profile_page.dart';

import '../chat/chat_list/chat_list_page.dart';
import 'main_logic.dart';

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);

  final MainLogic controller = Get.put(MainLogic());
  // 與其他頁一致的深色系
  static const Color bg = Color(0xFF2C2C40);
  static const Color bottomBarBg = Color(0xFF23232A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Obx(
            () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            // 0 揪團（保留狀態）
            MatchListPage(),
            // 1 主頁 placeholder
            MatchMapPage(),
            // 2 聊天 placeholder
            ChatListPage(),
            // 3 個人頁
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          backgroundColor: bottomBarBg,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: controller.currentIndex.value,
          onTap: controller.setIndex,
          items: [
            //揪團
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/sports_bar.png',
                width: 20,
                height: 20,
                color: Colors.white70, // 未選中顏色
              ),
              activeIcon: Image.asset(
                'assets/images/sports_bar.png',
                width: 24,
                height: 24,
                color: Colors.white, // 選中顏色
              ),
              label: '揪團',
            ),
            //主頁
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/home.png',
                width: 20,
                height: 20,
                color: Colors.white70, // 未選中顏色
              ),
              activeIcon: Image.asset(
                'assets/images/home.png',
                width: 24,
                height: 24,
                color: Colors.white, // 選中顏色
              ),
              label: '主頁',
            ),
            //聊天
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/message.png',
                width: 20,
                height: 20,
                color: Colors.white70, // 未選中顏色
              ),
              activeIcon: Image.asset(
                'assets/images/message.png',
                width: 24,
                height: 24,
                color: Colors.white, // 選中顏色
              ),
              label: '聊天',
            ),
            //個人頁
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/people.png',
                width: 20,
                height: 20,
                color: Colors.white70, // 未選中顏色
              ),
              activeIcon: Image.asset(
                'assets/images/people.png',
                width: 24,
                height: 24,
                color: Colors.white, // 選中顏色
              ),
              label: '個人',
            ),
          ],
        ),
      ),
    );
  }
}

/// 超輕量置中文字頁（保持背景色一致）
class _SimpleTextPage extends StatelessWidget {
  final String title;
  const _SimpleTextPage({super.key, required this.title});

  static const Color bg = Color(0xFF2C2C40);

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: bg,
      child: Center(
        child: Text('（這裡先放置中示意頁）',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
      ),
    );
  }
}
