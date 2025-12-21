import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'zalopay_config.dart';

/// Service xử lý thanh toán ZaloPay qua HTTP API
/// Không cần SDK, work 100%
class ZaloPayService {
  
  /// Tạo mã HMAC SHA256 để bảo mật request
  String _generateHmacSHA256(String data, String key) {
    var hmac = Hmac(sha256, utf8.encode(key));
    var digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }

  /// Tạo app_trans_id unique cho mỗi giao dịch
  /// Format: yyMMdd_xxxx (xxxx là timestamp)
  String _generateAppTransId() {
    final now = DateTime.now();
    final yymmdd = '${now.year.toString().substring(2)}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final timestamp = now.millisecondsSinceEpoch;
    return '${yymmdd}_$timestamp';
  }

  /// Tạo order và nhận zp_trans_token
  Future<Map<String, dynamic>> createOrder({
    required String plan_id,
    required String plan_name,
    required int amount,
    required String user_id,
  }) async {
    try {
      final appTransId = _generateAppTransId();
      final appTime = DateTime.now().millisecondsSinceEpoch;

      // Prepare embed_data
      final embedData = {
        'redirecturl': '${ZaloPayConfig.returnUrlScheme}://zalopay',
      };

      // Prepare item data
      final item = [
        {
          'itemid': plan_id,
          'itemname': plan_name,
          'itemprice': amount,
          'itemquantity': 1,
        }
      ];

      // Create MAC data string theo thứ tự trong docs
      final macData = '${ZaloPayConfig.appId}|$appTransId|$user_id|$amount|$appTime|${jsonEncode(embedData)}|${jsonEncode(item)}';
      
      // Generate MAC
      final mac = _generateHmacSHA256(macData, ZaloPayConfig.key1);

      // Prepare request body
      final requestBody = {
        'app_id': ZaloPayConfig.appId,
        'app_user': user_id,
        'app_trans_id': appTransId,
        'app_time': appTime.toString(),
        'amount': amount.toString(),
        'item': jsonEncode(item),
        'description': 'Thanh toán $plan_name - Twinkle Dating',
        'embed_data': jsonEncode(embedData),
        'bank_code': 'zalopayapp',
        'mac': mac,
      };

      print('📤 Creating ZaloPay order...');
      print('App Trans ID: $appTransId');
      print('Amount: $amount');

      // Call ZaloPay Create Order API
      final response = await http.post(
        Uri.parse(ZaloPayConfig.createOrderUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      print('Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Cannot connect to ZaloPay (${response.statusCode})',
        };
      }

      final result = jsonDecode(response.body);
      print('📥 Response: $result');

      if (result['return_code'] == 1) {
        return {
          'success': true,
          'zpTransToken': result['zp_trans_token'],
          'orderUrl': result['order_url'],
          'appTransId': appTransId,
        };
      } else {
        return {
          'success': false,
          'message': result['return_message'] ?? 'Cannot create order',
          'returnCode': result['return_code'],
        };
      }
    } catch (e) {
      print('Error creating order: $e');
      return {
        'success': false,
        'message': 'Lỗi: $e',
      };
    }
  }

  /// Mở ZaloPay app để thanh toán
  Future<Map<String, dynamic>> openZaloPayApp(String orderUrl) async {
    try {
      final Uri uri = Uri.parse(orderUrl);
      
      print('Launching ZaloPay...');
      print('URL: $orderUrl');
      
      // Kiểm tra có thể mở không
      bool canOpen = await canLaunchUrl(uri);
      
      if (!canOpen) {
        return {
          'success': false,
          'message': 'Không thể mở ZaloPay',
          'needsInstall': true,
        };
      }
      
      // Mở ZaloPay app
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        print('ZaloPay opened successfully');
        return {
          'success': true,
          'message': 'Đã mở ZaloPay',
        };
      } else {
        return {
          'success': false,
          'message': 'Không thể khởi chạy ZaloPay',
        };
      }
    } catch (e) {
      print('Error launching ZaloPay: $e');
      return {
        'success': false,
        'message': 'Lỗi: $e',
      };
    }
  }

  /// Query trạng thái giao dịch
  Future<Map<String, dynamic>> queryOrderStatus(String appTransId) async {
    try {
      print('Querying order status...');
      print('App Trans ID: $appTransId');
      
      // Create MAC for query
      final macData = '${ZaloPayConfig.appId}|$appTransId|${ZaloPayConfig.key1}';
      final mac = _generateHmacSHA256(macData, ZaloPayConfig.key1);

      final response = await http.post(
        Uri.parse(ZaloPayConfig.queryOrderUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'app_id': ZaloPayConfig.appId,
          'app_trans_id': appTransId,
          'mac': mac,
        },
      );

      print('📥 Query response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Lỗi kết nối (${response.statusCode})',
        };
      }

      final result = jsonDecode(response.body);
      print('📥 Query result: $result');

      // return_code meanings:
      // 1: Giao dịch thành công
      // 2: Giao dịch thất bại
      // 3: Giao dịch đang xử lý
      
      if (result['return_code'] == 1) {
        print('Payment successful');
        return {
          'success': true,
          'isPaid': true,
          'amount': result['amount'],
          'zpTransId': result['zp_trans_id'],
          'serverTime': result['server_time'],
        };
      } else if (result['return_code'] == 2) {
        print('Payment failed');
        return {
          'success': true,
          'isPaid': false,
          'message': 'Giao dịch thất bại hoặc chưa thanh toán',
        };
      } else if (result['return_code'] == 3) {
        print('Payment processing');
        return {
          'success': true,
          'isPaid': false,
          'isProcessing': true,
          'message': 'Giao dịch đang được xử lý',
        };
      } else {
        return {
          'success': false,
          'message': result['return_message'] ?? 'Không thể truy vấn giao dịch',
        };
      }
    } catch (e) {
      print('Error querying order: $e');
      return {
        'success': false,
        'message': 'Lỗi: $e',
      };
    }
  }

  /// Polling để kiểm tra trạng thái thanh toán
  /// Gọi sau khi user quay lại app từ ZaloPay
  Future<Map<String, dynamic>> waitForPaymentConfirmation(
    String appTransId, {
    int maxAttempts = 10,
    Duration interval = const Duration(seconds: 3),
  }) async {
    print('⏰ Starting payment verification polling...');
    print('Max attempts: $maxAttempts, Interval: ${interval.inSeconds}s');
    
    for (int i = 0; i < maxAttempts; i++) {
      print('🔄 Attempt ${i + 1}/$maxAttempts');
      
      await Future.delayed(interval);
      
      final result = await queryOrderStatus(appTransId);
      
      // Nếu thanh toán thành công
      if (result['isPaid'] == true) {
        print('🎉 Payment confirmed!');
        return result;
      }
      
      // Nếu có lỗi thực sự (không phải đang xử lý)
      if (result['success'] == false && result['isProcessing'] != true) {
        print('⚠️ Query failed');
        return result;
      }
      
      print('⏳ Still processing, waiting...');
    }
    
    print('⏱️ Timeout reached');
    return {
      'success': false,
      'message': 'Hết thời gian chờ. Vui lòng kiểm tra lại giao dịch.',
    };
  }
}