import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zapp/widgets/common_back_button.dart';
import 'package:zapp/widgets/common_primary_button.dart';

import 'profile_form_logic.dart';

class ProfileFormPage extends StatelessWidget {
  ProfileFormPage({super.key});

  final ProfileFormLogic controller = Get.put(ProfileFormLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A0014),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      if (controller.isEditMode) ...[
                        const CommonBackButton(
                          size: 44,
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            '個人檔案',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                            minFontSize: 5,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                    const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Obx(() {
                      final localPath = controller.selectedImagePath.value;
                      final remoteUrl = controller.avatarUrl.value;

                      ImageProvider? imageProvider;
                      if (localPath != null && localPath.isNotEmpty) {
                        imageProvider = FileImage(File(localPath));
                      } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
                        imageProvider = NetworkImage(remoteUrl);
                      }

                      return GestureDetector(
                        onTap: controller.pickProfileImage,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 6,
                                offset: Offset(0, 3),
                                color: Color(0x33000000),
                              ),
                            ],
                            image: imageProvider != null
                                ? DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: imageProvider == null
                              ? ClipOval(
                                  child: Image.asset(
                                    'assets/images/account_circle.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('姓名', '(驗證後需透過客服變更)'),
                        const SizedBox(height: 6),
                        _InputBox(
                          child: TextField(
                            controller: controller.nameCtrl,
                            onChanged: (_) => controller.onChanged(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Label('暱稱'),
                        const SizedBox(height: 6),
                        _InputBox(
                          child: TextField(
                            controller: controller.nickCtrl,
                            onChanged: (_) => controller.onChanged(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Label('生日', '(驗證後需透過客服變更)'),
                        const SizedBox(height: 6),
                        _InputBox(
                          child: TextField(
                            controller: controller.birthCtrl,
                            readOnly: true,
                            onTap: () => controller.pickBirthday(context),
                            decoration: const InputDecoration(
                              hintText: '請選擇生日',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const AutoSizeText(
                          '性別',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final g = controller.gender.value;
                          return Row(
                            children: [
                              _GenderChip(
                                label: '男性',
                                icon: Icons.male,
                                selected: g == Gender.male,
                                onTap: () =>
                                    controller.selectGender(Gender.male),
                              ),
                              const SizedBox(width: 10),
                              _GenderChip(
                                label: '女性',
                                icon: Icons.female,
                                selected: g == Gender.female,
                                onTap: () =>
                                    controller.selectGender(Gender.female),
                              ),
                              const SizedBox(width: 10),
                              _GenderChip(
                                label: '多元',
                                icon: Icons.transgender,
                                selected: g == Gender.other,
                                onTap: () =>
                                    controller.selectGender(Gender.other),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                Obx(() {
                  return CommonPrimaryButton(
                    label: controller.isEditMode ? '儲存變更' : '繼續',
                    enabled:
                        controller.isValid.value &&
                        !controller.isLoading.value,
                    isLoading: controller.isLoading.value,
                    enabledColor: Colors.white,
                    disabledColor: Color(0xFF4A4252),
                    textColor: Color(0xFF14061F),
                    onPressed: controller.submit,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.title, [this.hint]);

  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AutoSizeText(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 25,
          ),
          minFontSize: 10,
          maxLines: 1,
        ),
        if (hint != null) ...[
          const SizedBox(width: 4),
          AutoSizeText(
            hint!,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            minFontSize: 5,
            maxLines: 1,
          ),
        ],
      ],
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
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
      child: child,
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFF4E7FF) : Colors.white;
    final fg = selected ? const Color(0xFF14061F) : Colors.black87;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? const Color(0xFFE879F9) : Colors.black26,
              width: selected ? 2 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                offset: Offset(0, 3),
                color: Color(0x33000000),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
