
// ==================== ABOUT ME STEP ====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';


class AboutMeStep extends StatelessWidget {
  AboutMeStep({super.key});

  final ProfileSetupController controller = Get.find();

  final List<String> aboutMeOptions = [
    'I\'m a foodie',
    'Adventure seeker',
    'Dog lover',
    'Cat person',
    'Night owl',
    'Early bird',
    'Beach lover',
    'Mountain person',
    'Coffee addict',
    'Tea enthusiast',
    'Movie buff',
    'Bookworm',
    'Gym rat',
    'Homebody',
    'Social butterfly',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Text(
                  'What else makes you-you?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Don\'t hold back. Authentically embrace authenticity.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 32),

                Obx(() => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: aboutMeOptions.map((option) {
                    final isSelected = controller.aboutMe.contains(option);
                    return InkWell(
                      onTap: () => controller.toggleAboutMe(option),
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.quaternaryColor.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.quaternaryColor
                                : Colors.white24,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
        ),

        // Next Button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.quaternaryColor,
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
