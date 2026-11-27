import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zapp/widgets/common_back_button.dart';
import 'package:zapp/widgets/common_primary_button.dart';

import 'verify_code_logic.dart';

class VerifyCodePage extends StatelessWidget {
  VerifyCodePage({super.key});

  final VerifyCodeLogic controller = Get.put(VerifyCodeLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent, // 點擊透明區域也能觸發
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              const CommonBackButton(size: 60),
              const SizedBox(height: 12),

              // 標題
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: AutoSizeText(
                  '請輸入驗證碼',
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
                      controller: controller.codeCtrl,
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.done,
                      inputFormatters: controller.inputFormatters,
                      onChanged: controller.onCodeChanged,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      ),
                      style: const TextStyle(
                        letterSpacing: 4,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      onSubmitted: (_) => controller.submit(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 已發送到哪裡
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AutoSizeText(
                  '已發送驗證碼至 ${controller.countryCode} ${controller.phone}',
                  style: const TextStyle(color: Colors.black45, fontSize: 16),
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 16),

              // 倒數／重新獲得
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: controller.canResend.value
                      ? GestureDetector(
                    onTap: controller.resend,
                    child: const AutoSizeText(
                      '重新獲得',
                      style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      minFontSize: 5,
                      maxLines: 1,
                    ),
                  )
                      : AutoSizeText(
                    '重新獲得  ${controller.secondsLeft.value}s',
                    style: const TextStyle(color: Colors.black45, fontSize: 16),
                    minFontSize: 5,
                    maxLines: 1,
                  ),
                );
              }),

              const Spacer(),

              // 底部「繼續」
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
