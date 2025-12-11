import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:twinkle/pages/forgot_password_page.dart';
import 'package:twinkle/pages/match_page.dart';
import 'package:twinkle/routes/app_routes.dart';

import 'package:twinkle/pages/splash_page.dart';

import 'package:twinkle/pages/chat_page.dart';
import 'package:twinkle/pages/chat_list_page.dart';
import 'package:twinkle/pages/home_page.dart';
import 'package:twinkle/pages/login_page.dart';
import 'package:twinkle/pages/register_page.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage(),),
    GetPage(name: AppRoutes.login, page: () => const LoginPage(),),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage(),),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordPage(),),
    GetPage(name: AppRoutes.home, page: () => HomePage(),),

    GetPage(name: AppRoutes.match, page: () => MatchPage(),),
    GetPage(name: AppRoutes.chatList, page: () => ChatListPage(),),
    GetPage(name: AppRoutes.chat, page: () => ChatPage(),),


  ];
}
