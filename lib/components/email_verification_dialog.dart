import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/themes/theme.dart';

class EmailVerificationDialog extends StatefulWidget {
  final String email;
  final Function(String code)? onVerify;
  final VoidCallback? onResend;

  const EmailVerificationDialog({
    super.key,
    required this.email,
    this.onVerify,
    this.onResend,
  });

  @override
  State<EmailVerificationDialog> createState() => _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  String _maskEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }
    
    return '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}@$domain';
  }

  Future<void> _handleVerify() async {
    if (_codeController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the verification code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.onVerify != null) {
        await widget.onVerify!(_codeController.text.trim());
      }
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Verification failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Title
            Text(
              "Email Verification",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            // Instruction Text
            Text(
              "We will send a notify code to your email",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              _maskEmail(widget.email),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // Input Field
            TextField(
              controller: _codeController,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 8,
              ),
              textAlign: TextAlign.center,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                hintText: "XXXXXX",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  letterSpacing: 8,
                ),
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            // Resend Link
            Center(
              child: InkWell(
                onTap: widget.onResend,
                child: Text(
                  "Don't receive code? Resend email",
                  style: TextStyle(
                    color: Color(0xFF9B59B6), // Light purple
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Send Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "Send",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

