import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zapp/widgets/common_back_button.dart';
import 'package:zapp/widgets/common_primary_button.dart';

import 'email_verify_logic.dart';

class EmailVerifyPage extends StatelessWidget {
  EmailVerifyPage({Key? key}) : super(key: key);

  final EmailVerifyLogic controller = Get.put(EmailVerifyLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(), // 點空白收起鍵盤
        child: SafeArea(
          child: Column(
            children: [
              const CommonBackButton(size: 60),
              const SizedBox(height: 12),

              // 標題
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: AutoSizeText(
                  '請輸入電子郵件地址',
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

              // 輸入框（白底圓角 + 邊框 + 陰影）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black26, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 6,
                        offset: Offset(0, 3),
                        color: Color(0x33000000),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      controller: controller.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onChanged: controller.onEmailChanged,
                      decoration: const InputDecoration(
                        hintText: '',
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      onSubmitted: (_) => controller.submit(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 灰字說明
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: AutoSizeText(
                  '別失去帳號的存取權限，請立即驗證您的電子郵件',
                  style: TextStyle(color: Colors.black45, fontSize: 14),
                  minFontSize: 5,
                  maxLines: 2,
                ),
              ),

              const Spacer(),

              // 底部「繼續」按鈕（共用元件）
              Obx(() {
                return CommonPrimaryButton(
                  label: '繼續',
                  enabled: controller.isValid.value && !controller.isLoading.value,
                  isLoading: controller.isLoading.value,
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
