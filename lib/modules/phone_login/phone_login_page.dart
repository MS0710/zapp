import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zapp/widgets/common_back_button.dart';
import 'package:zapp/widgets/common_primary_button.dart';

import 'phone_login_logic.dart';

class PhoneLoginPage extends StatelessWidget {
  PhoneLoginPage({super.key});

  final PhoneLoginLogic controller = Get.put(PhoneLoginLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent, // 讓點擊透明區域也有效
        onTap: () => FocusScope.of(context).unfocus(), // 收起鍵盤
        child: SafeArea(
          child: Column(
            children: [
              // ---- 上方返回 + 小 logo ----
              const CommonBackButton(size: 60),
              const SizedBox(height: 12),

              // ---- 標題 ----
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: AutoSizeText(
                  '請輸入您的電話號碼',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 40),

              // ---- 國碼 + 手機輸入框（白底、陰影、圓角）----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 6,
                          offset: Offset(0, 3),
                          color: Color(0x33000000),
                        ),
                      ],
                      border: Border.all(color: Colors.black26, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 52,
                    child: Row(
                      children: [
                        // 國碼下拉
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.countryCode.value,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: controller.supportedCodes
                                .map(
                                  (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) controller.onCodeChanged(v);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const VerticalDivider(width: 1, thickness: 1),
                        const SizedBox(width: 8),

                        // 手機輸入框
                        Expanded(
                          child: TextField(
                            controller: controller.phoneCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: controller.inputFormatters,
                            onChanged: controller.onPhoneChanged,
                            decoration: const InputDecoration(
                              hintText: '987654321',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                            ),
                            style: const TextStyle(
                              letterSpacing: 1.0,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            onSubmitted: (_) => controller.submit(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const Spacer(),

              // ---- 繼續 按鈕 ----
              Obx(() {
                return CommonPrimaryButton(
                  label: '繼續',
                  enabled: controller.isValid.value,
                  isLoading: false, // 若之後加載狀態可改成 controller.isLoading.value
                  onPressed: controller.submit,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
