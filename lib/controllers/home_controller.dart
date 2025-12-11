import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}
