import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import '../controllers/match_controller.dart';
import '../models/users_model.dart';

class MatchPage extends StatelessWidget {
  //final CardSwiperController swiperController = CardSwiperController();
  final MatchController matchController = Get.put(MatchController());
  final AuthController authController = Get.find<AuthController>();
  String currentID = Get.find<AuthController>().user!.uid;

  MatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentID = authController.user!.uid;

    // Lấy danh sách users khi trang được build
    matchController.getMatches();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách người dùng"),
      ),
      body: Obx(() {
        final users = matchController.matches;

        /// Không còn người
        if (users.isEmpty) {
          return const Center(
            child: Text(
              "Không còn người để quẹt nữa 😅",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }

        /// Hiển thị danh sách user
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserCard(user);
          },
        );
      }),
    );
  }

  /// Card user
  Widget _buildUserCard(UsersModel user) {
    final matchController = Get.find<MatchController>();
    final currentID = Get.find<AuthController>().user!.uid;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          matchController.createMatch(currentID, user.id ?? '', );
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.profile_picture ?? ''),
        ),
        title: Text(user.email ?? 'No email'),
        subtitle: Text(user.bio ?? ''),
      ),
    );
  }
}
