import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/main_controller.dart';
import 'package:twinkle/pages/chatlist_page.dart';
import 'package:twinkle/pages/home_page.dart';
import 'package:twinkle/pages/match_page.dart';
import 'package:twinkle/pages/profile_page.dart';
import 'package:twinkle/themes/theme.dart';

class MainPage extends StatelessWidget {
  final MainController controller = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(), 
        onPageChanged: controller.onPageChanged,
        children: [
          HomePage(),     
          MatchPage(),    
          ChatListPage(), 
          ProfilePage(),  
          //ProfileSetupPage(),  
        ],
      ),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: const EdgeInsets.all(14), 
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24), 
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.textTeriaryColor,
                boxShadow: [ 
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.explore_rounded, 0),
                  _navItem(Icons.favorite, 1),
                  _navItem(Icons.mail_rounded, 2, badge: controller.getUnreadCount()),
                  _navItem(Icons.person, 3),
                 // _navItem(Icons.settings, 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, {int badge = 0}) {
    final isSelected = controller.currentIndex == index;
    return GestureDetector(
      onTap: () => controller.changeTabIndex(index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryColor : Colors.grey,
            size: 28,
          ),
          if (badge > 0)
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    badge > 99 ? '99+' : badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

}
