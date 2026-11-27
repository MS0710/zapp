import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/routes/app_routes.dart';
import 'package:zapp/utils/log_utils.dart';

import '../profile/profile_logic.dart';
import '../../services/image_upload_service.dart';
import '../../services/user_service.dart';

enum Gender { male, female, other }

class ProfileFormLogic extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final ImagePicker _imagePicker = ImagePicker();
  // 欄位控制器
  final nameCtrl = TextEditingController();
  final nickCtrl = TextEditingController();
  final birthCtrl = TextEditingController(); // 只顯示用（不可編直接彈日期）

  // 狀態
  final gender = Rx<Gender?>(null);
  final isValid = false.obs;
  final isLoading = false.obs;
  final selectedImagePath = RxnString();
  final avatarUrl = RxnString();

  DateTime? birthday;
  bool get isEditMode {
    final args = Get.arguments;
    return args is Map && args['mode'] == 'edit';
  }

  @override
  void onInit() {
    super.onInit();
    if (isEditMode) {
      _prefillFromCurrentUser();
    }
  }

  void onChanged() {
    // 你想要的必填規則：姓名 + 性別 + 生日
    isValid.value = nameCtrl.text.trim().isNotEmpty &&
        gender.value != null &&
        birthday != null;
  }

  Future<void> pickBirthday(BuildContext context) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 100, 1, 1);
    final last = now;
    final picked = await showDatePicker(
      context: context,
      initialDate: birthday ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      birthday = picked;
      birthCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
      onChanged();
    }
  }

  void selectGender(Gender g) {
    gender.value = g;
    onChanged();
  }

  void _prefillFromCurrentUser() {
    final user = Supabase.instance.client.auth.currentUser;
    final data = user?.userMetadata ?? const <String, dynamic>{};

    nameCtrl.text = (data['full_name'] ?? '').toString();
    nickCtrl.text = (data['nickname'] ?? '').toString();
    avatarUrl.value = (data['avatar_url'] ?? '').toString().trim().isEmpty
        ? null
        : (data['avatar_url'] ?? '').toString().trim();

    final birthdayText = (data['birthday'] ?? '').toString().trim();
    if (birthdayText.isNotEmpty) {
      final parsed = DateTime.tryParse(birthdayText);
      if (parsed != null) {
        birthday = parsed;
        birthCtrl.text =
            "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      }
    }

    final genderText = (data['gender'] ?? '').toString().trim().toLowerCase();
    switch (genderText) {
      case 'male':
        gender.value = Gender.male;
        break;
      case 'female':
        gender.value = Gender.female;
        break;
      case 'other':
        gender.value = Gender.other;
        break;
    }

    onChanged();
  }

  Future<void> pickProfileImage() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;

      selectedImagePath.value = file.path;
      logger.logDebug('[ProfileForm] selected image: ${file.path}');
    } catch (e) {
      logger.logError('[ProfileForm] pick image failed: $e');
      Get.snackbar(
        '失敗',
        '選取圖片失敗',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  Future<void> submit() async {
    if (!isValid.value || isLoading.value) return;
    isLoading.value = true;

    try {
      final fullName = nameCtrl.text.trim();
      final nickname =
      nickCtrl.text.trim().isEmpty ? fullName : nickCtrl.text.trim();

      final bday = birthday;
      if (bday == null) throw Exception('請選擇生日');

      final g = gender.value;
      if (g == null) throw Exception('請選擇性別');

      String genderStr;
      switch (g) {
        case Gender.male:
          genderStr = 'male';
          break;
        case Gender.female:
          genderStr = 'female';
          break;
        case Gender.other:
          genderStr = 'other';
          break;
      }

      // email 從目前登入者取得
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null || email.isEmpty) {
        throw Exception('找不到登入者 email，請重新登入後再試');
      }

      String? uploadedAvatarUrl = avatarUrl.value;
      final imagePath = selectedImagePath.value;
      if (imagePath != null && imagePath.trim().isNotEmpty) {
        logger.logDebug('[ProfileForm] avatar upload START');
        final uploadResp = await _imageUploadService.uploadImage(
          filePath: imagePath,
          folder: 'avatars',
        );
        uploadedAvatarUrl = uploadResp.url;
        logger.logDebug('[ProfileForm] avatar upload SUCCESS');
        logger.logPretty('[ProfileForm] avatar upload response', uploadResp.toJson());
      }

      if (isEditMode) {
        logger.logDebug('[ProfileForm] edit submit START');
        logger.logPretty('[ProfileForm] edit submit payload', <String, dynamic>{
          'full_name': fullName,
          'nickname': nickname,
          'birthday': _formatYyyyMmDd(bday),
          'gender': genderStr,
          'avatar_url': uploadedAvatarUrl,
        });

        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: <String, dynamic>{
              'full_name': fullName,
              'nickname': nickname,
              'birthday': _formatYyyyMmDd(bday),
              'gender': genderStr,
              if (uploadedAvatarUrl != null && uploadedAvatarUrl.isNotEmpty)
                'avatar_url': uploadedAvatarUrl,
            },
          ),
        );

        if (Get.isRegistered<ProfileLogic>()) {
          final profileLogic = Get.find<ProfileLogic>();
          profileLogic.nickname.value = nickname;
          profileLogic.avatarUrl.value = uploadedAvatarUrl;
        }
        avatarUrl.value = uploadedAvatarUrl;
        selectedImagePath.value = null;

        logger.logDebug('[ProfileForm] edit submit SUCCESS');
        logger.logPretty(
          '[ProfileForm] updated user metadata',
          Supabase.instance.client.auth.currentUser?.userMetadata,
        );

        Get.back();
        return;
      }

      // password 從上一頁帶進來
      String? password;
      final args = Get.arguments;
      if (args is Map && args['password'] is String) {
        password = (args['password'] as String).trim();
      }
      if (password == null || password.isEmpty) {
        throw Exception('缺少 password（請從註冊頁用 Get.arguments 帶入）');
      }

      await _userService.completeRegistration(
        email: email,
        password: password,
        fullName: fullName,
        nickname: nickname,
        birthday: bday,
        gender: genderStr,
      );

      if (uploadedAvatarUrl != null && uploadedAvatarUrl.isNotEmpty) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: <String, dynamic>{
              'full_name': fullName,
              'nickname': nickname,
              'birthday': _formatYyyyMmDd(bday),
              'gender': genderStr,
              'avatar_url': uploadedAvatarUrl,
            },
          ),
        );
        logger.logDebug('[ProfileForm] registration avatar metadata update SUCCESS');
      }

      logger.logDebug('[ProfileForm] registration submit SUCCESS');

      Get.toNamed(AppRoutes.Main);
    } catch (e) {
      logger.logError('[ProfileForm] submit failed: $e');
      Get.snackbar(
        '失敗',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    nickCtrl.dispose();
    birthCtrl.dispose();
    _imageUploadService.dispose();
    super.onClose();
  }

  String _formatYyyyMmDd(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
