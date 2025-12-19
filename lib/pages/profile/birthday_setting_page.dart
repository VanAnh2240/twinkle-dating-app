import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/services/firestore_service.dart';
import 'package:twinkle/themes/theme.dart';

class BirthdaySettingPage extends StatefulWidget {
  const BirthdaySettingPage({super.key});

  @override
  State<BirthdaySettingPage> createState() => _BirthdaySettingPageState();
}

class _BirthdaySettingPageState extends State<BirthdaySettingPage> {
  final AuthController authController = Get.find<AuthController>();
  final FirestoreService _firestoreService = Get.put(FirestoreService());
  
  int? _selectedDate = 1;
  int? _selectedMonth = 1;
  int? _selectedYear = 2004;
  
  bool _showDate = true;
  bool _showMonth = true;
  bool _showYear = true;
  
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentID = authController.user!.uid;
    final user = await _firestoreService.getUserById(currentID);
    if (user != null && user.date_of_birth != null) {
      setState(() {
        _selectedDate = user.date_of_birth!.day;
        _selectedMonth = user.date_of_birth!.month;
        _selectedYear = user.date_of_birth!.year;
        _isLoadingData = false;
      });
    } else {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Success!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBirthday() async {
    if (_selectedDate == null || _selectedMonth == null || _selectedYear == null) {
      Get.snackbar(
        'Error',
        'Please select a complete birthday',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentID = authController.user!.uid;
      final birthday = DateTime(_selectedYear!, _selectedMonth!, _selectedDate!);
      
      await _firestoreService.updateUserPartial(
        currentID,
        {
          'date_of_birth': Timestamp.fromDate(birthday),
        },
      );
      
      await _showSuccessDialog('Birthday updated successfully');
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update birthday: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<int> _getDaysInMonth() {
    if (_selectedMonth == null || _selectedYear == null) {
      return List.generate(31, (index) => index + 1);
    }
    final daysInMonth = DateTime(_selectedYear!, _selectedMonth! + 1, 0).day;
    return List.generate(daysInMonth, (index) => index + 1);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Color(0xFF6C9EFF), // Blue
                  Color(0xFF9B59B6), // Purple
                ],
              ).createShader(bounds),
              child: Text(
                "Birthday",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              " Settings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveBirthday,
            child: Text(
              "Save",
              style: TextStyle(
                color: _isLoading ? Colors.grey : AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Birthday Title
            Center(
              child: Text(
                "Birthday",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 32),
            // Change birthday Section
            Text(
              "Change birthday",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateDropdown(
                    label: "Date",
                    value: _selectedDate,
                    items: _getDaysInMonth(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDate = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDateDropdown(
                    label: "Month",
                    value: _selectedMonth,
                    items: List.generate(12, (index) => index + 1),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value;
                        // Adjust date if it's invalid for the new month
                        if (value != null && _selectedYear != null) {
                          final daysInMonth = DateTime(_selectedYear!, value + 1, 0).day;
                          if (_selectedDate != null && _selectedDate! > daysInMonth) {
                            _selectedDate = daysInMonth;
                          }
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDateDropdown(
                    label: "Year",
                    value: _selectedYear,
                    items: List.generate(100, (index) => DateTime.now().year - 17 - index),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            // Display Options Section
            Text(
              "Which parts of your birth date would you like to display?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            _buildCheckboxOption(
              label: "Date",
              value: _showDate,
              onChanged: (value) {
                setState(() {
                  _showDate = value;
                });
              },
            ),
            SizedBox(height: 12),
            _buildCheckboxOption(
              label: "Month",
              value: _showMonth,
              onChanged: (value) {
                setState(() {
                  _showMonth = value;
                });
              },
            ),
            SizedBox(height: 12),
            _buildCheckboxOption(
              label: "Year",
              value: _showYear,
              onChanged: (value) {
                setState(() {
                  _showYear = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDropdown({
    required String label,
    required int? value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              dropdownColor: Color(0xFF1A1A1A),
              style: TextStyle(color: Colors.white),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
              items: items.map((item) {
                return DropdownMenuItem<int>(
                  value: item,
                  child: Text(
                    item.toString().padLeft(2, '0'),
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? (label == "Year" ? Color(0xFF9B59B6) : Colors.white) : Colors.transparent,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? Icon(
                    Icons.check,
                    color: label == "Year" ? Colors.white : Colors.black,
                    size: 16,
                  )
                : null,
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

