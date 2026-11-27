import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zapp/widgets/common_back_button.dart';

import 'login_help_logic.dart';

class LoginHelpPage extends StatelessWidget {
  LoginHelpPage({super.key});

  final LoginHelpLogic controller = Get.put(LoginHelpLogic());

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final logoHeight = (screenHeight * 0.40).clamp(180.0, 300.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0014),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A0014),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (ctx, cons) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: cons.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32),
                            Center(
                              child: Image.asset(
                                'assets/images/zapp_logo3.png',
                                height: logoHeight,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),
                            AutoSizeText(
                              '請輸入電子郵件地址',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                              ),
                              maxLines: 1,
                              minFontSize: 12,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Obx(() {
                              return TextField(
                                controller: controller.emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                onChanged: controller.onEmailChanged,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'example@mail.com',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorText: controller.showError.value
                                      ? '請輸入有效的 Email'
                                      : null,
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                            Obx(() {
                              final enabled =
                                  controller.isValid.value &&
                                  !controller.isLoading.value;
                              return SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed:
                                      enabled ? controller.sendHelpRequest : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1A1021),
                                    disabledBackgroundColor: const Color(
                                      0xFF4A4252,
                                    ),
                                    disabledForegroundColor: Colors.white70,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          '寄送協助信件',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                            const AutoSizeText(
                              '我們會傳送連結您，協助您重新登入。',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              minFontSize: 5,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Positioned(
                  top: 0,
                  left: 0,
                  child: CommonBackButton(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
