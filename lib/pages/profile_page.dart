import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/services/user_service.dart';

class ProfilePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final UserService userService = Get.put(UserService());

  @override
  Widget build(BuildContext context) {
    final currentID = authController.user!.uid;

    return FutureBuilder(
      future: userService.getUserById(currentID),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            ),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,

            title: Text(
              "Profile",
              style: TextStyle(
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),

            centerTitle: true,

            /// 🔥 SIGN OUT BUTTON TRÊN GÓC PHẢI
            actions: [
              IconButton(
                onPressed: () => authController.signOut(),
                icon: Icon(Icons.logout, color: Colors.redAccent),
                tooltip: "Sign Out",
              )
            ],
          ),

          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [

                /// Avatar
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: user.profile_picture != null &&
                            user.profile_picture!.isNotEmpty
                        ? NetworkImage(user.profile_picture!)
                        : null,
                    child: (user.profile_picture == null ||
                            user.profile_picture!.isEmpty)
                        ? Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                ),

                SizedBox(height: 12),

                /// Name
                Text(
                  "${user.first_name ?? ''} ${user.last_name ?? ''}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                /// Email
                Text(
                  user.email ?? "",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),

                SizedBox(height: 20),

                _buildInfoCard(title: "Gender", value: user.gender ?? "Not set"),
                _buildInfoCard(
                    title: "Date of Birth",
                    value: user.date_of_birth != null
                        ? "${user.date_of_birth!.day}/${user.date_of_birth!.month}/${user.date_of_birth!.year}"
                        : "Not set"),
                _buildInfoCard(title: "Bio", value: user.bio ?? "No bio"),
                _buildInfoCard(
                    title: "Location", value: user.location ?? "Unknown"),

                SizedBox(height: 25),

                /// Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed("/edit-profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({required String title, required String value}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.label, color: Colors.pinkAccent),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
