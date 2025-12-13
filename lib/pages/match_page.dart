import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/match_controller.dart';

class MatchPage extends StatelessWidget {
  MatchPage({super.key});

  final MatchController controller = Get.put(MatchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.profile_picture.isNotEmpty
                      ? NetworkImage(user.profile_picture)
                      : null,
                  child: user.profile_picture.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text('${user.first_name} ${user.last_name}'),
                subtitle: Text(user.bio),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Swipe left
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () =>
                          controller.swipeLeft(user.user_id),
                    ),
                    // Swipe right
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.green),
                      onPressed: () =>
                          controller.swipeRight(user.user_id),
                          //controller = Get.put(MatchController());
                          //nếu press icon => kích hoạt method swipeRight trong match_controller
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
