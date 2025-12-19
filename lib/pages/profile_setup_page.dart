import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/pages/profile_setup/steps/rules_step.dart';
import 'package:twinkle/pages/profile_setup/steps/name_step.dart';
import 'package:twinkle/pages/profile_setup/steps/birthday_step.dart';
import 'package:twinkle/pages/profile_setup/steps/gender_step.dart';
import 'package:twinkle/pages/profile_setup/steps/location_step.dart';
import 'package:twinkle/pages/profile_setup/steps/sexual_orientation_step.dart';
import 'package:twinkle/pages/profile_setup/steps/interested_in_step.dart';
import 'package:twinkle/pages/profile_setup/steps/lifestyle_step.dart';
import 'package:twinkle/pages/profile_setup/steps/about_me_step.dart';
import 'package:twinkle/pages/profile_setup/steps/interests_hobbies_step.dart';
import 'package:twinkle/pages/profile_setup/steps/values_step.dart';
import 'package:twinkle/pages/profile_setup/steps/bio_step.dart';
import 'package:twinkle/pages/profile_setup/steps/photos_step.dart';
import 'package:twinkle/themes/theme.dart';

class ProfileSetupPage extends StatelessWidget {
  ProfileSetupPage({super.key});

  final ProfileSetupController controller = Get.put(ProfileSetupController());

  Widget _buildStepContent() {
    final step = controller.steps[controller.currentStep.value];
    
    switch (step.id) {
      case 'rules':
        return RulesStep();
      case 'name':
        return NameStep();
      case 'birthday':
        return BirthdayStep();
      case 'gender':
        return GenderStep();
      case 'location':
        return LocationStep();
      case 'sexual_orientation':
        return SexualOrientationStep();
      case 'interested_in':
        return InterestedInStep();
      case 'lifestyle':
        return LifestyleStep();
      case 'about_me':
        return AboutMeStep();
      case 'interests_hobbies':
        return InterestsHobbiesStep();
      case 'values':
        return ValuesStep();
      case 'bio':
        return BioStep();
      case 'photos':
        return PhotosStep();
      default:
        return Center(child: Text('Unknown step'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          final step = controller.steps[controller.currentStep.value];
          final isRulesStep = step.id == 'rules';
          
          return Column(
            children: [
              // Progress bar (hide on rules step)
              if (!isRulesStep)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: controller.progress,
                          backgroundColor: Colors.grey[900],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.quaternaryColor), 
                        ),
                      ),
                    ],
                  ),
                ),

              // Back button (hide on rules step)
              if (!isRulesStep)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: controller.currentStep.value > 0
                            ? controller.previousStep
                            : null,
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      if (!step.isRequired)
                        TextButton(
                          onPressed: controller.skipStep,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Step content with animation
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0.1, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(controller.currentStep.value),
                    child: _buildStepContent(),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}