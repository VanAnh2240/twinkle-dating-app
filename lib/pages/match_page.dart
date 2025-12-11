import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import '../controllers/match_controller.dart';
import '../models/users_model.dart';

class MatchPage extends StatelessWidget {
  final CardSwiperController swiperController = CardSwiperController();
  final MatchController matchController = Get.put(MatchController());
  String currentID = Get.find<AuthController>().user!.uid;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final users = matchController.potentialMatches;

        /// Không còn người để quẹt
        if (users.isEmpty) {
          return Center(
            child: Text(
              "Không còn người để quẹt nữa 😅",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }

        /// CardSwiper
        return CardSwiper(
          controller: swiperController,
          cards: users.map((user) => _buildUserCard(user)).toList(),
          numberOfCardsDisplayed: 2,
          onSwipe: (index, direction) {
            if (index >= users.length) return;

            final user = users[index];

            if (direction == CardSwiperDirection.right) {
              matchController.createMatch(currentID);
            }
          },
        );

      }),
    );
  }

  /// UI thẻ người dùng
  Widget _buildUserCard(UsersModel user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(user.profile_picture ?? ""),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          /// Gradient dưới cùng giúp chữ nổi hơn
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          /// Tên + tuổi + bio
          Positioned(
            left: 20,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.first_name ?? ''}, ${_calculateAge(user.date_of_birth)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (user.bio != null && user.bio!.isNotEmpty)
                  SizedBox(
                    width: 260,
                    child: Text(
                      user.bio!,
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tính tuổi
  int _calculateAge(DateTime? dob) {
    if (dob == null) return 18;
    final now = DateTime.now();
    int age = now.year - dob.year;

    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
