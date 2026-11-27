import 'package:get/get.dart';
import 'package:zapp/modules/activity_search/activity_search_binding.dart';
import 'package:zapp/modules/activity_search/activity_search_page.dart';
import 'package:zapp/modules/create_activity/create_activity_binding.dart';
import 'package:zapp/modules/email_verify/email_verify_binding.dart';
import 'package:zapp/modules/email_verify/email_verify_page.dart';
import 'package:zapp/modules/login/login_binding.dart';
import 'package:zapp/modules/login/login_page.dart';
import 'package:zapp/modules/login_help/login_help_binding.dart';
import 'package:zapp/modules/login_help/login_help_page.dart';
import 'package:zapp/modules/main/main_binding.dart';
import 'package:zapp/modules/main/main_page.dart';
import 'package:zapp/modules/match_list/match_list_binding.dart';
import 'package:zapp/modules/match_list/match_list_page.dart';
import 'package:zapp/modules/match_map/match_map_binding.dart';
import 'package:zapp/modules/match_map/match_map_page.dart';
import 'package:zapp/modules/phone_login/phone_login_binding.dart';
import 'package:zapp/modules/phone_login/phone_login_page.dart';
import 'package:zapp/modules/place_detail/place_detail_binding.dart';
import 'package:zapp/modules/place_detail/place_detail_page.dart';
import 'package:zapp/modules/profile/profile_binding.dart';
import 'package:zapp/modules/profile/profile_page.dart';
import 'package:zapp/modules/profile_form/profile_form_binding.dart';
import 'package:zapp/modules/profile_form/profile_form_page.dart';
import 'package:zapp/modules/settings/settings_binding.dart';
import 'package:zapp/modules/settings/privacy_policy_page.dart';
import 'package:zapp/modules/settings/settings_page.dart';
import 'package:zapp/modules/settings/terms_page.dart';
import 'package:zapp/modules/verify_code/verify_code_binding.dart';
import 'package:zapp/modules/verify_code/verify_code_page.dart';
import 'package:zapp/modules/create_activity/create_activity_page.dart';
import 'package:zapp/routes/app_routes.dart';

import '../modules/chat/chat_list/chat_list_binding.dart';
import '../modules/chat/chat_list/chat_list_page.dart';
import '../modules/chat/chat_room/chat_room_binding.dart';
import '../modules/chat/chat_room/chat_room_page.dart';
import '../modules/chat/chat_search/chat_search_binding.dart';
import '../modules/chat/chat_search/chat_search_page.dart';
import '../modules/splash_gate_page.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.SplashGate, page: () => const SplashGatePage()),
    GetPage(
      name: AppRoutes.Login,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.Main,
      page: () => MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.LoginHelp,
      page: () => LoginHelpPage(),
      binding: LoginHelpBinding(),
    ),
    GetPage(
      name: AppRoutes.PhoneLogin,
      page: () => PhoneLoginPage(),
      binding: PhoneLoginBinding(),
    ),
    GetPage(
      name: AppRoutes.VerifyCode,
      page: () => VerifyCodePage(),
      binding: VerifyCodeBinding(),
    ),
    GetPage(
      name: AppRoutes.EmailVerify,
      page: () => EmailVerifyPage(),
      binding: EmailVerifyBinding(),
    ),
    GetPage(
      name: AppRoutes.ProfileForm,
      page: () => ProfileFormPage(),
      binding: ProfileFormBinding(),
    ),
    GetPage(
      name: AppRoutes.MatchList,
      page: () => MatchListPage(),
      binding: MatchListBinding(),
    ),
    GetPage(
      name: AppRoutes.Profile,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.Settings,
      page: () => SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.PrivacyPolicy,
      page: () => const PrivacyPolicyPage(),
    ),
    GetPage(name: AppRoutes.Terms, page: () => const TermsPage()),
    GetPage(
      name: AppRoutes.MatchMap,
      page: () => MatchMapPage(),
      binding: MatchMapBinding(),
    ),
    GetPage(
      name: AppRoutes.PlaceDetail,
      page: () => PlaceDetailPage(),
      binding: PlaceDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.ChatList,
      page: () => ChatListPage(),
      binding: ChatListBinding(),
    ),
    GetPage(
      name: AppRoutes.ChatRoom,
      page: () => ChatRoomPage(),
      binding: ChatRoomBinding(),
    ),
    GetPage(
      name: AppRoutes.ChatSearch,
      page: () => ChatSearchPage(),
      binding: ChatSearchBinding(),
    ),
    GetPage(
      name: AppRoutes.CreateActivity,
      page: () => CreateActivityPage(),
      binding: CreateActivityBinding(),
    ),
    GetPage(
      name: AppRoutes.ActivitySearch,
      page: () => ActivitySearchPage(),
      binding: ActivitySearchBinding(),
    ),
  ];
}
