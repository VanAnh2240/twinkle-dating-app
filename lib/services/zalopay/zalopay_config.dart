/// ZaloPay Configuration
/// Cấu hình cho môi trường test sandbox của ZaloPay
class ZaloPayConfig {
  // Test Sandbox Credentials
  static const String appId = "2553"; // Demo app ID
  static const String key1 = "PcY4iZIKFCIdgZvA6ueMcMHHUbRLYjPL"; // Demo key1
  static const String key2 = "kLtgPl8HHhfvMuDHPwKfgfsY4Ydm9eIz"; // Demo key2
  
  // API Endpoints - Sandbox
  static const String createOrderUrl = "https://sb-openapi.zalopay.vn/v2/create";
  static const String queryOrderUrl = "https://sb-openapi.zalopay.vn/v2/query";
  
  // Return URL scheme cho app
  static const String returnUrlScheme = "twinkledating";
  
  // Callback URL (nếu có server backend)
  static const String callbackUrl = ""; // Để trống nếu không có backend
}