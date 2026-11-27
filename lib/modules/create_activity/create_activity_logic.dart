import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/activity_detail.dart';
import '../../services/activity_service.dart';
import '../../services/chat_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/login_required_guard_service.dart';
import '../../utils/log_utils.dart';

class CreateActivityLogic extends GetxController {
  final ActivityService _service = Get.find<ActivityService>();
  final ChatService _chatService = ChatService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final LoginRequiredGuardService _loginGuard =
      Get.find<LoginRequiredGuardService>();
  final ImagePicker _imagePicker = ImagePicker();

  // ===== Mode =====
  // create / edit
  late String mode;
  int? editId;

  bool get isEdit => mode == 'edit';

  // ===== Form =====
  final formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final maxCtrl = TextEditingController();

  // ===== DateTime =====
  final Rx<DateTime?> startTime = Rx<DateTime?>(null);

  // ===== Cover (先佔位) =====
  final RxBool hasCover = false.obs;
  final RxBool isUploadingCover = false.obs;
  final RxnString coverLocalPath = RxnString();
  final RxnString coverImageUrl = RxnString();

  // ===== UI state =====
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingDetail = false.obs;

  ActivityDetail? detail; // edit 模式拿到的 detail，可留著用

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    final m = (args is Map && args['mode'] is String) ? args['mode'] as String : 'create';
    mode = (m == 'edit') ? 'edit' : 'create';

    editId = (args is Map && args['id'] is int) ? args['id'] as int : null;

    if (isEdit) {
      if (editId == null) {
        logger.logError('[CreateActivity] edit mode but id is null -> fallback to create');
        // fallback：避免卡死
        mode = 'create';
      } else {
        _loadDetailAndPrefill(editId!);
      }
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    remarksCtrl.dispose();
    maxCtrl.dispose();
    _chatService.dispose();
    _imageUploadService.dispose();
    super.onClose();
  }

  Future<void> _loadDetailAndPrefill(int id) async {
    isLoadingDetail.value = true;
    try {
      final res = await _service.getActivityDetail(id: id);
      detail = res.data;

      final d = detail!;
      // ✅ prefill 表單
      titleCtrl.text = d.title ?? '';
      descCtrl.text = d.description ?? '';
      locationCtrl.text = d.location ?? '';
      remarksCtrl.text = (d.remarks ?? '');
      maxCtrl.text = (d.maxParticipants ?? 4).toString();
      startTime.value = d.startTime;

      // cover：之後有 imageUrl 再接
      // hasCover.value = (d.imageUrl ?? '').isNotEmpty;

      logger.logDebug('[CreateActivity] prefill ok: id=$id, title=${titleCtrl.text}');
    } catch (e, st) {
      logger.logError('[CreateActivity] load detail failed: $e');
      logger.logError(st.toString());
      Get.snackbar(
        '讀取活動失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> onTapPickCover() async {
    if (isUploadingCover.value) return;

    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        return;
      }

      isUploadingCover.value = true;
      final compressedFile = await _compressToWebp(File(picked.path));

      coverLocalPath.value = compressedFile.path;
      coverImageUrl.value = null;
      hasCover.value = true;

      Get.snackbar(
        '圖片已選擇',
        '送出建立活動時才會上傳活動圖',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, st) {
      logger.logError('[CreateActivity] pick/upload cover failed: $e');
      logger.logError(st.toString());
      coverLocalPath.value = null;
      coverImageUrl.value = null;
      hasCover.value = false;
      Get.snackbar(
        '圖片處理失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingCover.value = false;
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    final now = DateTime.now();
    final initial = startTime.value ?? now.add(const Duration(hours: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    startTime.value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String startTimeText(DateTime? dt) {
    if (dt == null) return '請選擇時間';
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y/$m/$d $hh:$mm';
  }

  Future<void> submit() async {
    final canUseFeature = await _loginGuard.ensureLoggedIn(
      featureName: isEdit ? '編輯活動' : '建立活動',
      message: isEdit ? '編輯活動需要先登入帳號。' : '建立活動需要先登入帳號。',
    );
    if (!canUseFeature) return;

    if (isSubmitting.value) return;

    // edit mode：detail 還在 loading 時不要送
    if (isEdit && isLoadingDetail.value) return;
    if (isUploadingCover.value) {
      Get.snackbar('請稍候', '活動圖仍在上傳中', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final ok = formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final dt = startTime.value;
    if (dt == null) {
      Get.snackbar('資料不完整', '請選擇活動時間', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final max = int.tryParse(maxCtrl.text.trim()) ?? 0;
    if (max <= 0) {
      Get.snackbar('資料不正確', '人數上限需為正整數', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;
    try {
      final imageUrl = await _uploadCoverIfNeeded();

      if (!isEdit) {
        // ===== Create =====
        final created = await _service.createActivity(
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          startTime: dt,
          location: locationCtrl.text.trim(),
          maxParticipants: max,
          imageUrl: imageUrl,
          remarks: remarksCtrl.text.trim().isEmpty ? null : remarksCtrl.text.trim(),
        );

        try {
          await _chatService.createOrGetRoom(
            activityType: 'activity',
            activityId: created.id,
            title: created.title,
          );
        } catch (e, st) {
          logger.logError('[CreateActivity] create chat room failed: $e');
          logger.logError(st.toString());
        }

        Get.back(result: created);
        Get.snackbar('建立成功', '已建立：${created.title}', snackPosition: SnackPosition.BOTTOM);
      } else {
        // ===== Edit =====
        final id = editId;
        if (id == null) throw Exception('editId 為空，無法更新');

        final updated = await _service.updateActivity(
          activityId: id,
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          startTime: dt,
          location: locationCtrl.text.trim(),
          maxParticipants: max,
          imageUrl: imageUrl,
          remarks: remarksCtrl.text.trim().isEmpty ? null : remarksCtrl.text.trim(),
          // userId: 不用傳（service 會用 currentUser）
        );

        Get.back(result: updated);
        Get.snackbar('更新成功', '已更新：${updated.title}', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e, st) {
      logger.logError('[CreateActivity] submit failed: $e');
      logger.logError(st.toString());
      Get.snackbar(
        isEdit ? '更新失敗' : '建立失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<String?> _uploadCoverIfNeeded() async {
    final localPath = coverLocalPath.value;
    if (localPath == null || localPath.trim().isEmpty) {
      return coverImageUrl.value;
    }

    isUploadingCover.value = true;
    try {
      final uploadResp = await _imageUploadService.uploadImage(
        filePath: localPath,
        folder: 'activities',
      );
      coverImageUrl.value = uploadResp.url;
      logger.logDebug('[CreateActivity] cover uploaded on submit: ${uploadResp.url}');
      return uploadResp.url;
    } finally {
      isUploadingCover.value = false;
    }
  }

  Future<File> _compressToWebp(File file) async {
    final tempDir = await getTemporaryDirectory();
    final baseName = p.basenameWithoutExtension(file.path);
    final targetPath = p.join(
      tempDir.path,
      '${baseName}_${DateTime.now().millisecondsSinceEpoch}.webp',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      format: CompressFormat.webp,
      quality: 80,
      minWidth: 1200,
      minHeight: 800,
    );

    if (result == null) {
      throw Exception('圖片壓縮失敗');
    }

    return File(result.path);
  }
}
