import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';

class NameStep extends StatelessWidget {
  NameStep({super.key});

  final ProfileSetupController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen tuyền theo ảnh
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                _buildInputLabel("What's your first name?", AppTheme.secondaryColor),
                _buildTextField(
                  initialValue: controller.firstName.value,
                  hint: "Enter first name",
                  onChanged: (v) => controller.firstName.value = v,
                ),

                const SizedBox(height: 32),

                const SizedBox(height: 32),

                _buildInputLabel("And your last name?", AppTheme.secondaryColor),
                _buildTextField(
                  initialValue: controller.lastName.value,
                  hint: "Enter last name",
                  onChanged: (v) => controller.lastName.value = v,
                ),
                const SizedBox(height: 40),

                const Spacer(),

                // Next Button 
                Obx(() {
                  bool isFilled = controller.firstName.value.isNotEmpty && 
                                 controller.lastName.value.isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56, 
                      child: ElevatedButton(
                        onPressed: isFilled ? controller.nextStep : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFilled ? AppTheme.quaternaryColor : Colors.white10,
                          disabledBackgroundColor: Colors.white10, // Đảm bảo màu khi null không bị mặc định xám xanh
                          
                          padding: EdgeInsets.symmetric(horizontal: 16), 
                          
                          elevation: isFilled ? 4 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            color: isFilled ? Colors.white : Colors.white24,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.0, 
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget phụ tạo tiêu đề câu hỏi
  Widget _buildInputLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget phụ tạo TextField dạng Underline gạch chân
  Widget _buildTextField({
    required String initialValue,
    required String hint,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: const Color(0xFFFF52AF),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        // Style gạch chân
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}