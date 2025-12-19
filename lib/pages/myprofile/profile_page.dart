import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/services/firestore_service.dart';
import 'package:twinkle/models/profile_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/services/profile/profile_service.dart';
import 'package:twinkle/themes/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController authController = Get.find<AuthController>();
  final FirestoreService _firestoreService = Get.put(FirestoreService());
  final ProfileService _profileService = ProfileService();

  UsersModel? _user;
  ProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final currentID = authController.user!.uid;
    final user = await _firestoreService.getUserById(currentID);
    final profile = await _profileService.getProfile(currentID);

    setState(() {
      _user = user;
      _profile = profile ?? ProfileModel(user_id: currentID);
      _isLoading = false;
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Confirm Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Do you really want to log out of\nyour account?",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          authController.signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF6B4A),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3D3D3D),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _calculateAge() {
    if (_user?.date_of_birth == null) return 0;
    return (DateTime.now().difference(_user!.date_of_birth!).inDays / 365).floor();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFF6C9EFF), Color(0xFF9B59B6)],
          ).createShader(bounds),
          child: Text(
            "My Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Get.toNamed(AppRoutes.myProfile);
              _loadData(); // Reload data after editing
            },
            icon: Icon(Icons.edit, color: AppTheme.primaryColor),
            tooltip: "Edit Profile",
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.settings),
            icon: Icon(Icons.settings, color: Colors.white),
            tooltip: "Settings",
          ),
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Sign Out",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Profile Card with Photo
              if (_profile != null && _profile!.photos.isNotEmpty)
                _buildMainPhotoCard()
              else
                _buildNoPhotoCard(),

              SizedBox(height: 24),

              // Bio Section
              if (_profile != null && _profile!.bio.isNotEmpty) ...[
                _buildSection("My bio", _profile!.bio),
                SizedBox(height: 24),
              ],

              // About me Section
              if (_profile != null && _profile!.about_me.isNotEmpty) ...[
                _buildAboutMeSection(),
                SizedBox(height: 24),
              ],

              // Looking for Section
              _buildSection("I'm looking for", _getLookingForText()),
              SizedBox(height: 24),

              // Interests Section
              if (_profile != null && _profile!.interests.isNotEmpty) ...[
                _buildTagSection("My interests", _profile!.interests),
                SizedBox(height: 24),
              ],

              // Additional Photos
              if (_profile != null && _profile!.photos.length > 1)
                ..._profile!.photos.sublist(1).map((photo) => Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          photo,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 300,
                            color: Colors.grey[800],
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                          ),
                        ),
                      ),
                    )),

              // Communities Section
              if (_profile != null && _profile!.communities.isNotEmpty) ...[
                _buildTagSection("My Convictions", _profile!.communities),
                SizedBox(height: 24),
              ],

              // Values Section
              if (_profile != null && _profile!.values.isNotEmpty) ...[
                _buildTagSection("Personal Values", _profile!.values),
                SizedBox(height: 24),
              ],

              // Swipe right if you section
              _buildSwipeRightSection(),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainPhotoCard() {
    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(_profile!.photos[0]),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New here badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF6C9EFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "New here",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            SizedBox(height: 12),
            // Name and Age
            Text(
              "${_user?.first_name ?? ''}, ${_calculateAge()}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            // Location
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text(
                  _profile?.location ?? "Hồ Chí Minh City",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 4),
            // Distance
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                SizedBox(width: 4),
                Text(
                  "3 km away",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPhotoCard() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[800],
            child: Icon(Icons.person, size: 50, color: Colors.grey),
          ),
          SizedBox(height: 16),
          Text(
            "${_user?.first_name ?? ''} ${_user?.last_name ?? ''}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _user?.email ?? "",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await Get.toNamed(AppRoutes.myProfile);
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text("Add Photos", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF9B59B6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTagSection(String title, List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF9B59B6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Text(
                  tag,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              )).toList(),
        ),
      ],
    );
  }

  Widget _buildSwipeRightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Swipe right if you",
          style: TextStyle(
            color: Color(0xFF9B59B6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.smoke_free, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "No smoking",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutMeSection() {
    final Map<String, String> emojiMap = {
      'Work': '📚',
      'Gender': '♂️',
      'Location': '📍',
      'Hometown': '🏠',
      'Height': '📏',
      'Exercise': '🏃',
      'Educational level': '🎓',
      'Drinking': '🍷',
      'Smoking': '🚬',
      'Religion': '☪️',
      'Family plans': '👶',
      'Star sign': '⭐',
    };

    // Parse about_me list to map
    Map<String, String> aboutMeMap = {};
    for (var item in _profile!.about_me) {
      final parts = item.split(': ');
      if (parts.length >= 2) {
        aboutMeMap[parts[0]] = parts.sublist(1).join(': ');
      }
    }

    List<String> tags = [];
    aboutMeMap.forEach((key, value) {
      if (value.isNotEmpty && key != 'Looking for') {
        final emoji = emojiMap[key] ?? '•';
        tags.add('$emoji $value');
      }
    });

    String aboutMeText = tags.isEmpty ? 'No info added yet' : tags.join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About me",
          style: TextStyle(
            color: Color(0xFF9B59B6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          aboutMeText,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  String _getLookingForText() {
    if (_profile != null && _profile!.about_me.isNotEmpty) {
      for (var item in _profile!.about_me) {
        if (item.startsWith('Looking for: ')) {
          return '✨ ${item.replaceFirst('Looking for: ', '')}';
        }
      }
    }
    return '✨ a long-term relationship';
  }
}
