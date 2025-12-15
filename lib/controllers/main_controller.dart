import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/chat_controller.dart';
import 'package:twinkle/controllers/chatlist_controller.dart';
import 'package:twinkle/controllers/home_controller.dart';
import 'package:twinkle/controllers/match_controller.dart';
import 'package:twinkle/controllers/profile_controller.dart';

class MainController extends GetxController {
  final RxInt _currentIndex = 0.obs;
  final PageController pageController = PageController();

  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => MatchController());
    Get.lazyPut(() => ChatListController());
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => ProfileController());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changeTabIndex(int index) {
    if (_currentIndex.value == index) return;
    _currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void onPageChanged(int index) {
    _currentIndex.value = index;
  }

  int getUnreadCount() {
    try {
      // Nếu muốn lấy từ HomeController, dùng:
      // final homeController = Get.find<HomeController>();
      // return homeController.getTotalUnreadCount();
      return 3;
    } catch (e) {
      return 0;
    }
  }
}
