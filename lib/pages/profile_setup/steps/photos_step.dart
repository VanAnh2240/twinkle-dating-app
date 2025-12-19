// ==================== PHOTOS STEP ====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';

class PhotosStep extends StatelessWidget {
  PhotosStep({super.key});

  final ProfileSetupController controller = Get.find();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage({bool isProfilePicture = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (isProfilePicture) {
          controller.setProfilePicture(image.path);
        } else {
          controller.addPhoto(image.path);
        }

        Get.snackbar(
          'Success',
          'Photo added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// CONTENT
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                const Text(
                  'Add your recent pics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload at least 2 photos',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 32),

                /// GRID PHOTOS (FIX GETX)
                Obx(() {
                  final photos = controller.photos;
                  final profilePic = controller.profilePicture.value;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final hasPhoto = index < photos.length;
                      final photoUrl = hasPhoto ? photos[index] : '';
                      final isProfilePic = photoUrl == profilePic;

                      return GestureDetector(
                        onTap: () =>
                            _pickImage(isProfilePicture: index == 0),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isProfilePic
                                      ? AppTheme.quaternaryColor
                                      : Colors.white24,
                                  width: isProfilePic ? 3 : 1.5,
                                ),
                                image: hasPhoto
                                    ? DecorationImage(
                                        image: NetworkImage(photoUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: hasPhoto
                                  ? null
                                  : const Center(
                                      child: Icon(
                                        Icons.add_photo_alternate,
                                        color: Colors.white38,
                                        size: 40,
                                      ),
                                    ),
                            ),

                            /// REMOVE BUTTON
                            if (hasPhoto)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () =>
                                      controller.removePhoto(photoUrl),
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.black87,
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                            /// PROFILE BADGE
                            if (isProfilePic)
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.quaternaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.star,
                                          size: 12, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Profile',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }),

                const SizedBox(height: 24),

                /// INFO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.quaternaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.quaternaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline,
                          color: AppTheme.quaternaryColor, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'First photo will be your profile picture',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        /// DONE BUTTON (FIX GETX)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            final canProceed = controller.canProceed;
            final loading = controller.isLoading.value;

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    canProceed ? controller.completeSetup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canProceed
                      ? AppTheme.quaternaryColor
                      : Colors.grey[800],
                  padding:
                      const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Done',
                        style: TextStyle(
                          color: canProceed
                              ? Colors.white
                              : Colors.white38,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
