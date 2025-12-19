import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';

// ==================== GENDER STEP ====================
class GenderStep extends StatelessWidget {
  GenderStep({super.key});

  final ProfileSetupController controller = Get.find();

  final List<String> genderOptions = [
    'Woman',
    'Man',
    'Non-binary',
    'Prefer not to say',
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
                  'What\'s your gender?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),

                const SizedBox(height: 40),

                Obx(() => Column(
                  children: genderOptions.map((gender) {
                    final isSelected = controller.gender.value == gender;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () => controller.gender.value = gender,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.transparent : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? AppTheme.quaternaryColor : Colors.white24,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            gender,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
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
          child: Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.canProceed ? controller.nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.canProceed
                    ? AppTheme.quaternaryColor
                    : Colors.grey[800],
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  color: controller.canProceed ? Colors.white : Colors.white38,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
        ),
      ],
    );
  }
}
