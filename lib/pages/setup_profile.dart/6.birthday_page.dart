import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '7.name_page.dart';
import '8.gender_page.dart';

class BirthdayPage extends StatefulWidget {
  const BirthdayPage({super.key});

  @override
  State<BirthdayPage> createState() => _BirthdayPageState();
}

class _BirthdayPageState extends State<BirthdayPage> {
  int? selectedDay;
  int? selectedMonth;
  int? selectedYear;

  bool get isFilled =>
      selectedDay != null && selectedMonth != null && selectedYear != null;

  List<int> days = List.generate(31, (i) => i + 1);
  List<int> months = List.generate(12, (i) => i + 1);
  List<int> years = List.generate(100, (i) => DateTime.now().year - i); // 2025–1925
   //hàm tính tuổi
  int calculateAge(int day, int month, int year) {
  final today = DateTime(2025, 12, 10);  
  final birthday = DateTime(year, month, day);

  int age = today.year - birthday.year;
  if (today.month < birthday.month ||
      (today.month == birthday.month && today.day < birthday.day)) {
    age--;
  }

  return age;
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

              // ---------------- TOP BAR ----------------
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const NamePage()),
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  const Text(
                    "2/11",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 20),

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
                  widthFactor: 2 / 11, // tiến trình = 2/11
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
                "Your birthday?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF85ACFF),
                  fontWeight: FontWeight.w600,
                ),
                ),
              ),

              const SizedBox(height: 35),

              // ---------------- PICKERS ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // DAY PICKER
                  _pickerBox(
                    width: 60,
                    child: CupertinoPicker(
                      backgroundColor: Colors.transparent,
                      itemExtent: 32,
                      magnification: 1.1,
                      squeeze: 1.2,
                      useMagnifier: true,
                      onSelectedItemChanged: (index) {
                        setState(() => selectedDay = days[index]);
                      },
                      children: days
                          .map((d) => Text(
                                d.toString().padLeft(2, '0'),
                                style:
                                    const TextStyle(color: Colors.white, fontSize: 18),
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(width: 30),
                  const Text("/", style: TextStyle(color: Colors.white, fontSize: 26)),
                  const SizedBox(width: 30),

                  // MONTH PICKER
                  _pickerBox(
                    width: 60,
                    child: CupertinoPicker(
                      backgroundColor: Colors.transparent,
                      itemExtent: 32,
                      magnification: 1.1,
                      squeeze: 1.2,
                      useMagnifier: true,
                      onSelectedItemChanged: (index) {
                        setState(() => selectedMonth = months[index]);
                      },
                      children: months
                          .map((m) => Text(
                                m.toString().padLeft(2, '0'),
                                style:
                                    const TextStyle(color: Colors.white, fontSize: 18),
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(width: 30),
                  const Text("/", style: TextStyle(color: Colors.white, fontSize: 26)),
                  const SizedBox(width: 30),

                  // YEAR PICKER
                  _pickerBox(
                    width: 90,
                    child: CupertinoPicker(
                      backgroundColor: Colors.transparent,
                      itemExtent: 32,
                      magnification: 1.1,
                      squeeze: 1.2,
                      useMagnifier: true,
                      onSelectedItemChanged: (index) {
                        setState(() => selectedYear = years[index]);
                      },
                      children: years
                          .map((y) => Text(
                                y.toString(),
                                style:
                                    const TextStyle(color: Colors.white, fontSize: 18),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 50),

              // ---------------- NOTE ----------------
              const Text(
                "Your profile shows your age, not your birth day.",
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
                          int age = calculateAge(selectedDay!, selectedMonth!, selectedYear!);

                    if (age < 18) {
                      // Hiện thông báo lỗi
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            "You must be at least 18",
                            style: TextStyle(
                              color: Color.fromARGB(255, 245, 129, 168),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,),
                          ),
                          content: const Text(
                              "This app is only for users aged 18 and above.\nPlease enter a valid birthdate.",
                              style: TextStyle(
                              color: Color.fromARGB(255, 132, 132, 132),
                                fontSize: 14,
                              ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "OK",
                                style: TextStyle(
                                  color: Colors.pinkAccent, // 👉 đổi màu chữ OK
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                  // Nếu tuổi hợp lệ, chuyển sang trang GenderPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GenderPage()),
                  );
                      }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFilled ? Colors.pinkAccent : Colors.grey[700],
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

  // ---------------- CUSTOM PICKER BOX ----------------
  Widget _pickerBox({required Widget child, double width = 70}) {
    return Container(
      width: width,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
