import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/chat_controller.dart';
import 'package:twinkle/controllers/chatlist_controller.dart';
import 'package:twinkle/controllers/home_controller.dart';
import 'package:twinkle/controllers/match_controller.dart';
import 'package:twinkle/controllers/subscription/payment_transactions_controller.dart';
import 'package:twinkle/controllers/profile_controller.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/controllers/subscription/subscriptions_controller.dart';
import 'package:twinkle/services/firestore_service.dart';

class MainController extends GetxController {
  final RxInt _currentIndex = 0.obs;
  final PageController pageController = PageController();

  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();
    //Get.lazyPut(() => HomeController());
    Get.lazyPut(() => MatchController());
    Get.lazyPut(() => ChatListController());
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => ProfileSetupController());
    Get.lazyPut(() => FirestoreService());
    Get.lazyPut(() => PaymentTransactionsController());
    Get.lazyPut(() => SubscriptionController());
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
      return 3;
    } catch (e) {
      return 0;
    }
  }
}
