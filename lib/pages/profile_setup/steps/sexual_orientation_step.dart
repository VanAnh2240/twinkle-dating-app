import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';

// ==================== SEXUAL ORIENTATION STEP ====================
class SexualOrientationStep extends StatelessWidget {
  SexualOrientationStep({super.key});

  final ProfileSetupController controller = Get.find();

  final List<String> orientations = [
    'Straight',
    'Gay',
    'Lesbian',
    'Bisexual',
    'Asexual',
    'Demisexual',
    'Pansexual',
    'Queer',
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
                  'Your sexual orientation?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),

                const SizedBox(height: 32),

                Obx(() => Column(
                  children: orientations.map((orientation) {
                    final isSelected = controller.sexualOrientation.value == orientation;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () => controller.sexualOrientation.value = orientation,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.quaternaryColor.withOpacity(0.1)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.quaternaryColor : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            orientation,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),

                const SizedBox(height: 24),

                // Show on profile toggle
                Obx(() => Row(
                  children: [
                    Checkbox(
                      value: controller.showSexualOrientationOnProfile.value,
                      onChanged: (value) {
                        controller.showSexualOrientationOnProfile.value = value ?? false;
                      },
                      activeColor: AppTheme.quaternaryColor,
                      checkColor: Colors.white,
                    ),
                    Expanded(
                      child: Text(
                        'Show on my profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
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