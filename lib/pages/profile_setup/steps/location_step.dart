// ==================== LOCATION STEP ====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';

class LocationStep extends StatelessWidget {
  LocationStep({super.key});

  final ProfileSetupController controller = Get.find();
  final TextEditingController textController = TextEditingController();

  @override
  void onInit() {
    if (controller.location.value.isNotEmpty) {
      textController.text = controller.location.value;
    }
  }

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
                  'Where do you live?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: textController,
                  onChanged: (value) => controller.location.value = value,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'City, Country',
                    hintStyle: TextStyle(color: Colors.white38),
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: AppTheme.quaternaryColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: AppTheme.quaternaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Your location helps us connect you with nearby people',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
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