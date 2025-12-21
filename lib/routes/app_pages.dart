import 'package:get/get.dart';
import 'package:twinkle/controllers/blocklist_controller.dart';
import 'package:twinkle/controllers/home_controller.dart';
import 'package:twinkle/controllers/profile_controller.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/controllers/subscription/subscriptions_controller.dart';
import 'package:twinkle/pages/block_list_page.dart';
import 'package:twinkle/pages/chatlist_page.dart';
import 'package:twinkle/pages/profile/account_page.dart';
import 'package:twinkle/pages/profile/birthday_setting_page.dart';
import 'package:twinkle/pages/profile/change_password_page.dart';
import 'package:twinkle/pages/profile/email_setting_page.dart';
import 'package:twinkle/pages/profile/my_profile_page.dart';
import 'package:twinkle/pages/profile/name_setting_page.dart';
import 'package:twinkle/pages/profile/privacy_security_page.dart';
import 'package:twinkle/pages/profile_setup_page.dart';
import 'package:twinkle/pages/setting_page.dart';
import 'package:twinkle/pages/subscriptions_page.dart';
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
    GetPage(name: AppRoutes.register, page: () => RegisterPage(),),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordPage(),),
    GetPage(
      name: AppRoutes.profileSetup, 
      page: () => ProfileSetupPage(),
      binding: BindingsBuilder(() {
        Get.put(ProfileSetupController());
      }),
    ),

    
    GetPage(
      name: AppRoutes.main, 
      page: () => MainPage(),
      binding: BindingsBuilder(() {
        Get.put(MainController());
      })
    ),

    
    GetPage(
      name: AppRoutes.home, 
      page: () => HomePage(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
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

    GetPage(
      name: AppRoutes.subscription, 
      page: () => SubscriptionPage(),
      binding: BindingsBuilder(() {
        Get.put(SubscriptionController());
      })
    ),
    
    //===============================PROFILE==================================//
    GetPage(
      name: AppRoutes.settings,
      page: () => SettingPage(),
    ),

    GetPage(
      name: AppRoutes.account,
      page: () => AccountPage(),
    ),

    GetPage(
      name: AppRoutes.nameSetting,
      page: () => NameSettingPage(),
    ),

    GetPage(
      name: AppRoutes.emailSetting,
      page: () => EmailSettingPage(),
    ),

    GetPage(
      name: AppRoutes.birthdaySetting,
      page: () => BirthdaySettingPage(),
    ),

    GetPage(
      name: AppRoutes.changePassword,
      page: () => ChangePasswordPage(),
    ),

    GetPage(
      name: AppRoutes.privacySecurity,
      page: () => PrivacySecurityPage(),
    ),

    GetPage(
      name: AppRoutes.myProfile,
      page: () => MyProfilePage(),
    ),

    GetPage(
      name: AppRoutes.blockList, 
      page: () => BlockListPage(),
      binding: BindingsBuilder(() {
        Get.put(BlockListController());
      })
    ),

  ];

}
