import 'package:flutter/material.dart';
import '6.birthday_page.dart';
import '9.sexual_orientation.dart';

class GenderPage extends StatefulWidget {
  const GenderPage({super.key});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  String? selectedGender; // "Woman" or "Man"
  bool showOnProfile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 30, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---------------- TOP BAR ----------------
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const BirthdayPage()),
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text(
                    "3/11",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // ---------------- PROGRESS BAR ----------------
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 3 / 11,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // ---------------- TITLE ----------------
              const Center(
                child: Text(
                  "What is your gender?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF85ACFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // ---------------- GENDER OPTIONS ----------------
              _genderOption("Woman"),
              const SizedBox(height: 20),
              _genderOption("Man"),

              const SizedBox(height: 40),

              // ---------------- SHOW ON PROFILE CHECKBOX ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: showOnProfile,
                    activeColor: Colors.pinkAccent,
                    checkColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    onChanged: (value) {
                      setState(() => showOnProfile = value!);
                    },
                  ),
                  const Text(
                    "Show on my profile",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),

              const Spacer(),

              // ---------------- NEXT BUTTON ----------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedGender == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const SexualOrientationPage()),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedGender != null
                        ? Colors.pinkAccent
                        : Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24), // border radius lớn hơn
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      color: selectedGender != null
                          ? Colors.white
                          : Colors.white38,
                      fontWeight: FontWeight.bold,
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

  // ---------------- WIDGET: GENDER OPTION ----------------
  Widget _genderOption(String genderText) {
    bool isSelected = selectedGender == genderText;

    return GestureDetector(
      onTap: () {
        setState(() => selectedGender = genderText);
      },
      child: Container(
        width: double.infinity, // full width
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.pinkAccent : Colors.white12,
          borderRadius: BorderRadius.circular(50), // borderRadius lớn hơn
          border: Border.all(
            color: isSelected ? Colors.pinkAccent : Colors.white24,
            width: 2,
          ),
        ),
        alignment: Alignment.center, // chữ căn giữa
        child: Text(
          genderText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
