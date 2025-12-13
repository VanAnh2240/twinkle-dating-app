import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/home_controller.dart';
import 'package:twinkle/pages/chatlist_page.dart';
import 'package:twinkle/pages/match_page.dart';
import 'package:twinkle/pages/profile_page.dart';
import 'package:twinkle/pages/setting_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key}) {
    Get.put(HomeController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.black, // NỀN ĐEN

      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          _buildHomeScreen(),
          MatchPage(),
          ChatListPage(),
          ProfilePage(),
        ],
      ),

      bottomNavigationBar: Obx(() =>
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF111111), // đen nhám
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTabIndex,
            type: BottomNavigationBarType.fixed,

            selectedItemColor: Colors.pinkAccent,     // màu nhấn
            unselectedItemColor: Colors.grey.shade500,

            showUnselectedLabels: false,
            showSelectedLabels: true,

            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Match"),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chat"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Text(
        "Welcome to Twinkle ✨",
        style: TextStyle(
          color: Colors.pinkAccent,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
