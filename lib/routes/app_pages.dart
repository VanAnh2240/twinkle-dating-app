import 'package:get/get.dart';
import 'package:twinkle/pages/chatlist_page.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/controllers/chat_controller.dart';
import 'package:twinkle/controllers/chatlist_controller.dart';
import 'package:twinkle/controllers/main_controller.dart';
import 'package:twinkle/controllers/match_controller.dart';
import 'package:twinkle/controllers/notification_controller.dart';
import 'package:twinkle/pages/chat_page.dart';
import 'package:twinkle/pages/login_register/register/forgot_password_page.dart';
import 'package:twinkle/pages/home_page.dart';
import 'package:twinkle/pages/main_page.dart';
import 'package:twinkle/pages/match_page.dart';
import 'package:twinkle/pages/notification_page.dart';
import 'package:twinkle/pages/login_register/register/splash_page.dart';
import 'package:twinkle/pages/login_register/register/login_page.dart';
import 'package:twinkle/pages/login_register/register/register_page.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage(),),
    GetPage(name: AppRoutes.login, page: () => const LoginPage(),),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage(),),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordPage(),),
    GetPage(name: AppRoutes.home, page: () => HomePage(),),

    GetPage(
      name: AppRoutes.main, 
      page: () => MainPage(),
      binding: BindingsBuilder(() {
        Get.put(MainController());
      })
    ),

    GetPage(
      name: AppRoutes.match, 
      page: () => MatchPage(),
      binding: BindingsBuilder(() {
        Get.put(MatchController());
      })),
    
    GetPage(
      name: AppRoutes.chatList, 
      page: () => ChatListPage(),
      binding: BindingsBuilder(() {
        Get.put(ChatListController());
      })
    ),

    GetPage(
      name: AppRoutes.chat, 
      page: () => ChatPage(),
      binding: BindingsBuilder(() {
        Get.put(ChatController());
      })
    ),

    GetPage(
      name: AppRoutes.notification, 
      page: () => NotificationPage(),
      binding: BindingsBuilder(() {
        Get.put(NotificationController());
      })
    ),
    

  ];
}
