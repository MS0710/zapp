import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/firebase_options.dart';
import 'package:zapp/routes/app_pages.dart';
import 'package:zapp/services/activity_service.dart';
import 'package:zapp/services/auth_service.dart';
import 'package:zapp/services/chat_service.dart';
import 'package:zapp/services/fcm_service.dart';
import 'package:zapp/services/geocoding_service.dart';
import 'package:zapp/services/here_geocoding_service.dart';
import 'package:zapp/services/login_required_guard_service.dart';
import 'package:zapp/services/merchant_activity_service.dart';
import 'package:zapp/services/merchant_settings_service.dart';
import 'package:zapp/services/user_service.dart';

import 'routes/app_routes.dart';
import 'utils/log_utils.dart';

Future<void> main() async {
  /*
  Level.ALL → 全部都會輸出（包含 FINE、INFO、WARNING、SEVERE）
  Level.FINE → 只輸出 FINE 以上（debug + info + warning + severe）
  Level.INFO → 只輸出 INFO 以上（info + warning + severe）
  Level.WARNING → 只輸出 WARNING + SEVERE
  Level.SEVERE → 只輸出錯誤訊息
  Level.OFF → 全部不輸出
  */
  // 设定LOG最低要输出的等级
  initLogging(level: Level.FINE);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // 螢幕方向設定（你原本的）
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Supabase 初始化（放在 runApp 前）
  /*await Supabase.initialize(
    url: 'https://qxauaoytegxmrmtxdjqk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4YXVhb3l0ZWd4bXJtdHhkanFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5NjEzNTIsImV4cCI6MjA4MjUzNzM1Mn0.nN7Qx-W2P7Hox6e7VB9hMyrLwQ99udR7hhpOKbK9P1c',
  );*/

  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4YXVhb3l0ZWd4bXJtdHhkanFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5NjEzNTIsImV4cCI6MjA4MjUzNzM1Mn0.nN7Qx-W2P7Hox6e7VB9hMyrLwQ99udR7hhpOKbK9P1c';

  await Supabase.initialize(
    url: 'https://qxauaoytegxmrmtxdjqk.supabase.co',
    anonKey: supabaseAnonKey,
  );

  Get.put<String>(supabaseAnonKey, tag: 'supabaseAnon');

  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<LoginRequiredGuardService>(LoginRequiredGuardService(), permanent: true);
  Get.put<GeocodingService>(GeocodingService(), permanent: true);
  Get.put<HereGeocodingService>(
    HereGeocodingService(apiKey: "JOetgrL7YRNN6WzsN3Hpvqt5jKyde8JCcUzCDkMvFxk"),
    permanent: true,
  );
  Get.put<ActivityService>(ActivityService(), permanent: true);
  Get.put<UserService>(UserService(), permanent: true);
  Get.put<MerchantSettingsService>(MerchantSettingsService(), permanent: true);
  Get.put<MerchantActivityService>(MerchantActivityService(), permanent: true);
  Get.put<ChatService>(ChatService(), permanent: true);
  Get.put<FCMService>(FCMService(), permanent: true);

  runApp(const MyApp());

  Get.find<FCMService>().initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ZAPP',
      debugShowCheckedModeBanner: false,
      //translations: AppTranslations(),     // 註冊翻譯
      locale: const Locale('zh', 'TW'),
      // 預設繁體中文
      fallbackLocale: const Locale('zh', 'TW'),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(centerTitle: true),
        fontFamily: 'word',
      ),
      initialRoute: AppRoutes.SplashGate,
      //initialRoute: AppRoutes.LoginHelp,
      getPages: AppPages.pages,
    );
  }
}
