import 'package:flutter/material.dart';
import '9.sexual_orientation.dart';
import '11.looking_for.dart';

class InterestedTargetPage extends StatefulWidget {
  const InterestedTargetPage({super.key});

  @override
  State<InterestedTargetPage> createState() => _InterestedTargetPageState();
}

class _InterestedTargetPageState extends State<InterestedTargetPage> {
  String? selectedOption; // "Woman", "Man", "Everyone"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 24, 32),
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
                        MaterialPageRoute(
                            builder: (_) => const SexualOrientationPage()),
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text(
                    "5/11",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------- PROGRESS BAR 5/11 ----------------
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 5 / 11,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 70),

              // ---------------- TITLE ----------------
              const Text(
                "Who are you interested in?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF85ACFF),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              // ---------------- OPTIONS ----------------
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _optionButton("Woman"),
                  const SizedBox(height: 16),
                  _optionButton("Man"),
                  const SizedBox(height: 16),
                  _optionButton("Everyone"),
                ],
              ),

              const Spacer(),

              // ---------------- NEXT BUTTON ----------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedOption == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LookingForPage()),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedOption != null
                        ? Colors.pinkAccent
                        : Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      color: selectedOption != null
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

  // ---------------- WIDGET: OPTION BUTTON ----------------
  Widget _optionButton(String text) {
    bool isSelected = selectedOption == text;

    return GestureDetector(
      onTap: () {
        setState(() => selectedOption = text);
      },
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.pinkAccent : Colors.white12,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.pinkAccent : Colors.white24,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
