import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/routes/app_routes.dart';
import 'package:zapp/services/auth_service.dart';

class SplashGatePage extends StatelessWidget {
  const SplashGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 進來立刻判斷一次
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = Supabase.instance.client.auth.currentSession;
      final authService = Get.find<AuthService>();

      if (session != null || authService.isGuest) {
        Get.offAllNamed(AppRoutes.Main);
      } else {
        Get.offAllNamed(AppRoutes.Login);
      }
    });

    // 可換成你的品牌畫面
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
