import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginLogic controller = Get.find<LoginLogic>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final logoHeight = (screenHeight * 0.40).clamp(180.0, 300.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0014),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0A0014)),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo
                Image.asset(
                  'assets/images/zapp_logo3.png',
                  height: logoHeight,
                  fit: BoxFit.contain,
                ),
                const Spacer(flex: 1),

                // Apple 登入
                _buildLoginButton(
                  icon: const Icon(Icons.apple, color: Colors.black, size: 24),
                  text: '用Apple登入',
                  //onPressed: () => controller.loginApple(),
                  onPressed: () => controller.testSignUp(),
                ),
                const SizedBox(height: 16),

                // Google 登入
                _buildLoginButton(
                  icon: Image.asset(
                    'assets/images/google.png',
                    width: 24,
                    height: 24,
                  ),
                  text: '用Google登入',
                  //onPressed: () => controller.loginGoogle(),
                  //onPressed: () => controller.testSignUp(),
                  onPressed: () => controller.testSignIn(),
                ),
                const SizedBox(height: 16),

                // 手機號碼登入
                _buildLoginButton(
                  icon: const Icon(
                    Icons.phone_iphone,
                    color: Colors.black,
                    size: 22,
                  ),
                  text: '手機號碼登入',
                  onPressed: () => controller.loginNormal(),
                ),
                const SizedBox(height: 14),

                GestureDetector(
                  onTap: controller.continueAsGuest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const AutoSizeText(
                      '先以訪客身分看看',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      minFontSize: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 登入問題
                GestureDetector(
                  onTap: () => controller.goQA(),
                  child: AutoSizeText(
                    '登入遇到問題？',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    minFontSize: 5,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required Widget icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 260,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1021),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'word',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
