import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'settings_logic.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final SettingsLogic controller = Get.put(SettingsLogic());
  static const Color bg = Color(0xFF2C2C40);
  static const Color divider = Color(0xFF1C1C28);
  static const double hp = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // 顯示「< 設定」的頂部列
            Padding(
              padding: const EdgeInsets.fromLTRB(hp, 12, hp, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: controller.onBack,
                    child: Row(
                      children: const [
                        Icon(Icons.chevron_left, color: Colors.white, size: 28),
                        SizedBox(width: 2),
                        Text(
                          '設定',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 分隔線
            Container(height: 2, color: divider),

            // 內容
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: hp),
                      children: [
                        const SizedBox(height: 12),
                        _SettingTile(
                          icon: Icons.account_circle_outlined,
                          text: '個人檔案編輯',
                          onTap: controller.onEditProfile,
                        ),
                        _SettingTile(
                          icon: Icons.headset_mic_outlined,
                          text: '聯絡我們',
                          onTap: controller.onContactUs,
                        ),
                        _SettingTile(
                          icon: Icons.privacy_tip_outlined,
                          text: '隱私權協議',
                          onTap: controller.onPrivacyPolicy,
                        ),
                        _SettingTile(
                          icon: Icons.article_outlined,
                          text: '服務協議',
                          onTap: controller.onTerms,
                        ),
                        const SizedBox(height: 12),
                        Container(height: 2, color: divider),
                        const SizedBox(height: 12),
                        _SettingTile(
                          icon: Icons.logout,
                          text: '登出帳號',
                          onTap: controller.onLogout,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  Container(height: 2, color: divider),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(hp, 12, hp, 20),
                    child: Column(
                      children: [
                        _SettingTile(
                          icon: Icons.delete_outline,
                          text: '刪除帳號',
                          onTap: controller.onDeleteAccount,
                          isDestructive: true,
                        ),
                        const SizedBox(height: 4),
                        Obx(() {
                          final version = controller.appVersion.value;
                          if (version.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Text(
                            version,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 單列元件
// ===== 可重用設定列元件 =====
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isDestructive; // 🔥 是否為紅色警示項

  const _SettingTile({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDestructive ? Colors.redAccent : Colors.white;
    final Color iconColor = isDestructive ? Colors.redAccent : Colors.white;

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor),
      title: AutoSizeText(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: isDestructive ? FontWeight.w600 : FontWeight.normal,
        ),
        minFontSize: 5,
        maxLines: 1,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      horizontalTitleGap: 12,
      dense: true,
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }
}
