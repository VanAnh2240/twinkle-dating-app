import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:twinkle/routes/app_routes.dart';

import 'package:twinkle/pages/splash_page.dart';

import 'package:twinkle/pages/chat_page.dart';
import 'package:twinkle/pages/chatlist_page.dart';
import 'package:twinkle/pages/home_page.dart';
import 'package:twinkle/pages/login_page.dart';
import 'package:twinkle/pages/register_page.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage(),),
    GetPage(name: AppRoutes.login, page: () => const LoginPage(),),
    
    // GetPage(
    //   name: AppRoutes.login, 
    //   page: () => const LoginPage(),
    //   binding: BindingsBuilder(() {
    //     Get.put(LoginController());
    //   }),
    // ),

    // GetPage(
    //   name: AppRoutes.chat, 
    //   page: () => const RegisterPage(),
    //   binding: BindingsBuilder(() {
    //     Get.put(RegisterController());
    //   }),
    // ),

    
    // GetPage(
    //   name: AppRoutes.chat, 
    //   page: () => const ChatPage(),
    //   binding: BindingsBuilder(() {
    //     Get.put(ChatController());
    //   }),
    // ),


    // GetPage(
    //   name: AppRoutes.notification, 
    //   page: () => const NotificationPage(),
    //   binding: BindingsBuilder(() {
    //     Get.put(NotificationController());
    //   }),
    // ),
  ];
}
