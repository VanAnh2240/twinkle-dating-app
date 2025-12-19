import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/profile_setup_controller.dart';
import 'package:twinkle/themes/theme.dart';

class BirthdayStep extends StatefulWidget {
  const BirthdayStep({super.key});

  @override
  State<BirthdayStep> createState() => _BirthdayStepState();
}

class _BirthdayStepState extends State<BirthdayStep> {
  final ProfileSetupController controller = Get.find();

  int? selectedDay;
  int? selectedMonth;
  int? selectedYear;

  List<int> days = List.generate(31, (i) => i + 1);
  List<int> months = List.generate(12, (i) => i + 1);
  List<int> years =
      List.generate(100, (i) => DateTime.now().year - i);

  bool get isFilled =>
      selectedDay != null &&
      selectedMonth != null &&
      selectedYear != null;

  int calculateAge(DateTime birthday) {
    final today = DateTime.now();
    int age = today.year - birthday.year;

    if (today.month < birthday.month ||
        (today.month == birthday.month &&
            today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  void _onNext() {
    if (!isFilled) {
      Get.snackbar(
        'Incomplete',
        'Please select your full birth date',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final dob = DateTime(
      selectedYear!,
      selectedMonth!,
      selectedDay!,
    );

    final age = calculateAge(dob);

    if (age < 18) {
      Get.snackbar(
        'Age restriction',
        'You must be at least 18 years old',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    controller.dateOfBirth.value = dob;
    controller.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your birthday?",
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF85ACFF),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 35),

              /// ---------------- PICKERS ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// DAY
                  _pickerBox(
                    width: 60,
                    child: CupertinoPicker(
                      itemExtent: 32,
                      useMagnifier: true,
                      onSelectedItemChanged: (i) {
                        setState(() => selectedDay = days[i]);
                      },
                      children: days
                          .map((d) => Text(
                                d.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(width: 16),
                  const Text("/", style: TextStyle(color: Colors.white, fontSize: 26)),
                  const SizedBox(width: 16),

                  /// MONTH
                  _pickerBox(
                    width: 60,
                    child: CupertinoPicker(
                      itemExtent: 32,
                      useMagnifier: true,
                      onSelectedItemChanged: (i) {
                        setState(() => selectedMonth = months[i]);
                      },
                      children: months
                          .map((m) => Text(
                                m.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(width: 16),
                  const Text("/", style: TextStyle(color: Colors.white, fontSize: 26)),
                  const SizedBox(width: 16),

                  /// YEAR
                  _pickerBox(
                    width: 90,
                    child: CupertinoPicker(
                      itemExtent: 32,
                      useMagnifier: true,
                      onSelectedItemChanged: (i) {
                        setState(() => selectedYear = years[i]);
                      },
                      children: years
                          .map((y) => Text(
                                y.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                "Your profile shows your age, not your birth day.",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),

              const Spacer(),

              /// NEXT BUTTON
              Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.quaternaryColor,
                    disabledBackgroundColor: Colors.white10,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    elevation: 4,
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
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerBox({required double width, required Widget child}) {
    return Container(
      width: width,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
