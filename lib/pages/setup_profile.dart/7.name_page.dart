import 'package:flutter/material.dart';
import '5.rule_page.dart';
import '6.birthday_page.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}


class _NamePageState extends State<NamePage> {
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();

  bool get isFilled =>
      firstNameController.text.isNotEmpty &&
      middleNameController.text.isNotEmpty &&
      lastNameController.text.isNotEmpty;

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
              // ---------------- TOP BAR ----------------
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RulePage()),
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text(
                    "1/11",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // -------- PROGRESS BAR (11 steps) ----------
              // ---------------- PROGRESS BAR (1/11) ----------------
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1 / 11,  // Tiến trình trang 1/11
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100),

              // ---------------- FIRST NAME ----------------
              const Text(
                "What’s your first name?",
                style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF85ACFF),
                    fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: firstNameController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter first name",
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pinkAccent),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- MIDDLE NAME ----------------
              const Text(
                "Your middle name?",
                style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF85ACFF),
                    fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: middleNameController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter middle name",
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pinkAccent),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- LAST NAME ----------------
              const Text(
                "And your last name?",
                style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF85ACFF),
                    fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: lastNameController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter last name",
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pinkAccent),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- NOTE ----------------
              const Text(
                "This is how it’ll appear on your profile.\nCan’t change it later.",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),

              const Spacer(),

              // ---------------- NEXT BUTTON ----------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isFilled
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BirthdayPage()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFilled
                        ? Colors.pinkAccent
                        : const Color.fromARGB(255, 193, 193, 193),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18,
                      color: isFilled ? Colors.white : Colors.white38,
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
}
