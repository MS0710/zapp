import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'create_activity_logic.dart';

class CreateActivityPage extends StatelessWidget {
  CreateActivityPage({super.key});

  final CreateActivityLogic controller = Get.put(CreateActivityLogic());
  static const Color bg = Color(0xFF2C2C40);
  static const Color cardBg = Color(0xFF1C1C28);

  OutlineInputBorder _border(Color color, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: w),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          controller.isEdit ? '編輯活動' : '建立活動',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          Obx(() {
            final submitting = controller.isSubmitting.value;
            final loadingDetail = controller.isEdit && controller.isLoadingDetail.value;
            final uploadingCover = controller.isUploadingCover.value;

            final disabled = submitting || loadingDetail || uploadingCover;

            final label = uploadingCover
                ? '圖片上傳中…'
                : submitting
                ? (controller.isEdit ? '更新中…' : '建立中…')
                : (controller.isEdit ? '更新' : '建立');

            return TextButton(
              onPressed: disabled ? null : controller.submit,
              child: Text(
                label,
                style: TextStyle(
                  color: disabled ? Colors.white54 : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }),
        ],
      ),

      // 下方固定按鈕
      bottomNavigationBar: SafeArea(
        top: false,
        child: Obx(() {
          final submitting = controller.isSubmitting.value;
          final loadingDetail = controller.isEdit && controller.isLoadingDetail.value;
          final uploadingCover = controller.isUploadingCover.value;

          final disabled = submitting || loadingDetail || uploadingCover;

          final label = uploadingCover
              ? '圖片上傳中…'
              : submitting
              ? (controller.isEdit ? '更新中…' : '建立中…')
              : (controller.isEdit ? '更新活動' : '建立活動');

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: GestureDetector(
              onTap: disabled ? null : controller.submit,
              child: Opacity(
                opacity: disabled ? 0.6 : 1,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),

      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 活動圖（先佔位）=====
                    Obx(() {
                      final has = controller.hasCover.value;
                      final localPath = controller.coverLocalPath.value;
                      final uploading = controller.isUploadingCover.value;

                      return GestureDetector(
                        onTap: controller.onTapPickCover,
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.10)),
                          ),
                          child: Stack(
                            children: [
                              if (has && localPath != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(localPath),
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.06),
                                              Colors.black.withOpacity(0.42),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        has ? Icons.image : Icons.add_photo_alternate_outlined,
                                        color: Colors.white70,
                                        size: 34,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        has ? '活動圖已選擇' : '新增活動圖',
                                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              if (uploading)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(color: Colors.white),
                                          SizedBox(height: 12),
                                          Text(
                                            '正在處理圖片...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (has && !uploading)
                                Positioned(
                                  left: 12,
                                  bottom: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                                    ),
                                    child: const Text(
                                      '送出時上傳',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                                  ),
                                  child: Text(
                                    uploading ? '上傳中' : (has ? '更換' : '選擇'),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 14),

                    _sectionTitle('基本資料'),
                    const SizedBox(height: 10),

                    _fieldCard(
                      child: Column(
                        children: [
                          _textField(
                            controller: controller.titleCtrl,
                            label: '活動名稱',
                            hint: '例如：週五下班小酌',
                            validator: (v) => (v == null || v.trim().isEmpty) ? '請輸入活動名稱' : null,
                            border: _border(Colors.white.withOpacity(0.14)),
                          ),
                          const SizedBox(height: 10),
                          _textField(
                            controller: controller.descCtrl,
                            label: '活動說明',
                            hint: '簡單描述活動內容、注意事項',
                            maxLines: 3,
                            validator: (v) => (v == null || v.trim().isEmpty) ? '請輸入活動說明' : null,
                            border: _border(Colors.white.withOpacity(0.14)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _sectionTitle('時間與地點'),
                    const SizedBox(height: 10),

                    _fieldCard(
                      child: Column(
                        children: [
                          Obx(() {
                            final txt = controller.startTimeText(controller.startTime.value);
                            final picked = controller.startTime.value != null;
                            return GestureDetector(
                              onTap: () => controller.pickStartTime(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.schedule, color: Colors.white70),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        txt,
                                        style: TextStyle(
                                          color: picked ? Colors.white : Colors.white60,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.white54),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
                          _textField(
                            controller: controller.locationCtrl,
                            label: '地點',
                            hint: '例如：台北市信義區某酒吧',
                            validator: (v) => (v == null || v.trim().isEmpty) ? '請輸入地點' : null,
                            border: _border(Colors.white.withOpacity(0.14)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _sectionTitle('人數與備註'),
                    const SizedBox(height: 10),

                    _fieldCard(
                      child: Column(
                        children: [
                          _textField(
                            controller: controller.maxCtrl,
                            label: '人數上限',
                            hint: '例如：6',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final n = int.tryParse((v ?? '').trim());
                              if (n == null || n <= 0) return '請輸入正整數';
                              if (n > 999) return '人數太大';
                              return null;
                            },
                            border: _border(Colors.white.withOpacity(0.14)),
                          ),
                          const SizedBox(height: 10),
                          _textField(
                            controller: controller.remarksCtrl,
                            label: '備註（選填）',
                            hint: '例如：低消 500、自備飲料…',
                            maxLines: 2,
                            validator: (_) => null,
                            border: _border(Colors.white.withOpacity(0.14)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // ===== 編輯模式載入 detail 的遮罩=====
          Obx(() {
            //先無條件讀一次 Rx，避免 create mode 時 Obx 裡沒有 Rx
            final loadingDetail = controller.isLoadingDetail.value;

            final show = controller.isEdit && loadingDetail;
            if (!show) return const SizedBox.shrink();

            return Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _fieldCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: child,
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required OutlineInputBorder border,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: cardBg,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.35), width: 1),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }

}
