/// VNPay Configuration
/// Manual implementation without vnpay_flutter package
/// Configuration for VNPay sandbox test environment
class VNPayConfig {
  // Test Sandbox Credentials (Demo from VNPay)
  // QUAN TRỌNG: Không được có khoảng trắng thừa ở đầu/cuối
  static const String tmnCode = "26BPWI8S";
  
  // Hash Secret - MỚI NHẤT từ email cuối cùng (20/12/2024 - 2:57 PM)
  // PHẢI chính xác 32 ký tự, không có khoảng trắng
  static const String hashSecret = " JTIDX9T5TAB33XJIKUS3S2K5KLHE7FGX";
  
  // API Endpoints - Sandbox
  static const String paymentUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
  
  // Return URL - Use a URL that WebView can intercept
  // For testing, use a dummy URL that doesn't actually exist
  // The WebView will catch this URL and process the payment result
  static const String returnUrl = "https://twinkledating.app/vnpay-return";
  
  // Configuration
  static const String version = "2.1.0";
  static const String command = "pay";
  static const String currCode = "VND";
  static const String locale = "vn";
  static const String orderType = "other";
  
  // Timeout
  static const int timeoutMinutes = 15;
}