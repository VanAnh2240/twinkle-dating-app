import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'vnpay_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VNPayService {
  String _generateTxnRef() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'TXN$timestamp';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}'
        '${dateTime.month.toString().padLeft(2, '0')}'
        '${dateTime.day.toString().padLeft(2, '0')}'
        '${dateTime.hour.toString().padLeft(2, '0')}'
        '${dateTime.minute.toString().padLeft(2, '0')}'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _generatePaymentUrl({
    required String txnRef,
    required String orderInfo,
    required double amount,
    required DateTime createDate,
    required DateTime expireDate,
  }) {
    final vnpAmount = (amount * 100).toInt();

    final params = <String, String>{
      'vnp_Version': VNPayConfig.version,
      'vnp_Command': 'pay',
      'vnp_TmnCode': VNPayConfig.tmnCode,
      'vnp_Amount': vnpAmount.toString(),
      'vnp_CurrCode': VNPayConfig.currCode,
      'vnp_TxnRef': txnRef,
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': VNPayConfig.orderType,
      'vnp_Locale': VNPayConfig.locale,
      'vnp_ReturnUrl': VNPayConfig.returnUrl,
      'vnp_IpAddr': '127.0.0.1',
      'vnp_CreateDate': _formatDateTime(createDate),
      'vnp_ExpireDate': _formatDateTime(expireDate),
    };

    print('📋 All parameters:');
    params.forEach((key, value) {
      print('   $key = $value');
    });

    final sortedKeys = params.keys.toList()..sort();
    
    print('🔤 Sorted keys: $sortedKeys');
    
    final hashData = sortedKeys
        .map((key) {
          final encodedKey = Uri.encodeComponent(key).replaceAll('%20', '+');
          final encodedValue = Uri.encodeComponent(params[key]!).replaceAll('%20', '+');
          return '$encodedKey=$encodedValue';
        })
        .join('&');

    print('🔐 Hash data (URL encoded - theo PHP code): $hashData');
    print('🔑 Hash secret: "${VNPayConfig.hashSecret}"');
    print('🔑 Hash secret (trimmed): "${VNPayConfig.hashSecret.trim()}"');
    print('🔑 Hash secret length: ${VNPayConfig.hashSecret.length}');
    print('🔑 Hash secret trimmed length: ${VNPayConfig.hashSecret.trim().length}');

    final cleanHashSecret = VNPayConfig.hashSecret.trim();
    final keyBytes = utf8.encode(cleanHashSecret);
    final dataBytes = utf8.encode(hashData);
    
    final hmacSha512 = Hmac(sha512, keyBytes);
    final digest = hmacSha512.convert(dataBytes);
    
    final secureHash = digest.toString();
    
    print('🔐 Key bytes length: ${keyBytes.length}');
    print('🔐 Data bytes length: ${dataBytes.length}');
    print('🔐 Digest bytes: ${digest.bytes.length}');
    print('🔐 Generated secure hash: $secureHash');

    final queryParams = <String>[];
    for (final key in sortedKeys) {
      final encodedValue = Uri.encodeComponent(params[key]!);
      queryParams.add('$key=$encodedValue');
    }
    final queryString = queryParams.join('&');

    final paymentUrl = '${VNPayConfig.paymentUrl}?$queryString&vnp_SecureHash=$secureHash';

    print('🌐 Final payment URL length: ${paymentUrl.length}');
    
    return paymentUrl;
  }

  /// Create payment and show WebView (Main method)
  Future<Map<String, dynamic>> createPaymentAndShow({
    required BuildContext context,
    required String plan_id,
    required String plan_name,
    required double amount,
    required String user_id,
  }) async {
    try {
      print('═══════════════════════════════════════');
      print('🚀 Creating VNPay payment...');
      print('═══════════════════════════════════════');
      
      final txnRef = _generateTxnRef();
      final orderInfo = 'Payment for $plan_name plan - Twinkle Dating';
      final now = DateTime.now();
      final createDate = now;
      final expireDate = now.add(Duration(minutes: VNPayConfig.timeoutMinutes));

      print('📝 Transaction details:');
      print('   TxnRef: $txnRef');
      print('   Amount: $amount VND');
      print('   Order Info: $orderInfo');
      print('   Create Date: ${_formatDateTime(createDate)}');
      print('   Expire Date: ${_formatDateTime(expireDate)}');

      // Generate payment URL manually
      final paymentUrl = _generatePaymentUrl(
        txnRef: txnRef,
        orderInfo: orderInfo,
        amount: amount,
        createDate: createDate,
        expireDate: expireDate,
      );

      print('✅ Payment URL generated successfully');
      print('═══════════════════════════════════════');

      // Show payment in WebView
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => VNPayWebViewPage(
            paymentUrl: paymentUrl,
            txnRef: txnRef,
          ),
        ),
      );

      return result ?? {
        'success': false,
        'isPaid': false,
        'message': 'User cancelled payment',
      };
    } catch (e) {
      print('❌ Error in createPaymentAndShow: $e');
      return {
        'success': false,
        'isPaid': false,
        'message': 'Error creating payment: $e',
      };
    }
  }

  /// Verify callback from VNPay
  Map<String, dynamic> verifyCallback(Map<String, String> params) {
    try {
      print('═══════════════════════════════════════');
      print('🔍 Verifying VNPay callback...');
      print('═══════════════════════════════════════');
      print('📋 All callback params:');
      params.forEach((key, value) {
        print('   $key = $value');
      });

      final secureHash = params['vnp_SecureHash'];
      if (secureHash == null || secureHash.isEmpty) {
        print('❌ Missing secure hash');
        return {
          'success': false,
          'message': 'Missing secure hash',
        };
      }

      // Remove vnp_SecureHash and vnp_SecureHashType from params for verification
      final paramsToVerify = Map<String, String>.from(params);
      paramsToVerify.remove('vnp_SecureHash');
      paramsToVerify.remove('vnp_SecureHashType');

      // Sort and build hash data
      final sortedKeys = paramsToVerify.keys.toList()..sort();
      print('🔤 Sorted keys for verification: $sortedKeys');
      
      final hashData = sortedKeys
          .map((key) => '$key=${paramsToVerify[key]}')
          .join('&');

      print('🔐 Hash data for verification: $hashData');

      // Generate hash
      final cleanHashSecret = VNPayConfig.hashSecret.trim();
      final key = utf8.encode(cleanHashSecret);
      final bytes = utf8.encode(hashData);
      final hmacSha512 = Hmac(sha512, key);
      final digest = hmacSha512.convert(bytes);
      final calculatedHash = digest.toString();

      print('🔐 Calculated hash: $calculatedHash');
      print('🔐 Received hash:   $secureHash');

      // Verify hash
      if (calculatedHash.toLowerCase() != secureHash.toLowerCase()) {
        print('❌ Hash verification FAILED');
        return {
          'success': false,
          'message': 'Invalid signature',
        };
      }

      print('✅ Hash verified successfully');
      
      // Check transaction status
      final responseCode = params['vnp_ResponseCode'];
      final transactionStatus = params['vnp_TransactionStatus'];

      print('📊 Transaction result:');
      print('   Response code: $responseCode');
      print('   Transaction status: $transactionStatus');

      if (responseCode == '00' && transactionStatus == '00') {
        print('✅ Payment successful');
        
        // Parse amount (VNPay returns amount * 100)
        final amountStr = params['vnp_Amount'] ?? '0';
        final amount = int.parse(amountStr) / 100;

        return {
          'success': true,
          'isPaid': true,
          'txnRef': params['vnp_TxnRef'],
          'amount': amount,
          'bankCode': params['vnp_BankCode'],
          'bankTranNo': params['vnp_BankTranNo'],
          'cardType': params['vnp_CardType'],
          'orderInfo': params['vnp_OrderInfo'],
          'payDate': params['vnp_PayDate'],
          'transactionNo': params['vnp_TransactionNo'],
          'responseCode': responseCode,
          'message': _getErrorMessage(responseCode!),
        };
      } else {
        print('❌ Payment failed or cancelled');
        return {
          'success': true,
          'isPaid': false,
          'message': _getErrorMessage(responseCode ?? ''),
          'responseCode': responseCode,
        };
      }
    } catch (e) {
      print('❌ Error verifying callback: $e');
      return {
        'success': false,
        'message': 'Error verifying: $e',
      };
    }
  }

  /// Parse callback URL
  Map<String, String> parseCallbackUrl(String url) {
    final uri = Uri.parse(url);
    return uri.queryParameters;
  }

  /// Get error message from response code
  String _getErrorMessage(String code) {
    switch (code) {
      case '00':
        return 'Giao dịch thành công';
      case '07':
        return 'Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, giao dịch bất thường)';
      case '09':
        return 'Giao dịch không thành công: Thẻ/Tài khoản chưa đăng ký dịch vụ InternetBanking';
      case '10':
        return 'Giao dịch không thành công: Xác thực thông tin thẻ/tài khoản không đúng quá 3 lần';
      case '11':
        return 'Giao dịch không thành công: Đã hết hạn chờ thanh toán';
      case '12':
        return 'Giao dịch không thành công: Thẻ/Tài khoản bị khóa';
      case '13':
        return 'Giao dịch không thành công: Sai mật khẩu xác thực OTP';
      case '24':
        return 'Giao dịch không thành công: Khách hàng hủy giao dịch';
      case '51':
        return 'Giao dịch không thành công: Tài khoản không đủ số dư';
      case '65':
        return 'Giao dịch không thành công: Tài khoản đã vượt quá hạn mức giao dịch trong ngày';
      case '70':
        return 'Giao dịch không thành công: Ngân hàng bảo trì hoặc lỗi kết nối';
      case '75':
        return 'Ngân hàng thanh toán đang bảo trì';
      case '79':
        return 'Giao dịch không thành công: Nhập sai mật khẩu thanh toán quá số lần quy định';
      case '99':
        return 'Các lỗi khác';
      default:
        return 'Giao dịch không thành công';
    }
  }
}

/// WebView widget to display VNPay payment page
class VNPayWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String txnRef;

  const VNPayWebViewPage({
    Key? key,
    required this.paymentUrl,
    required this.txnRef,
  }) : super(key: key);

  @override
  State<VNPayWebViewPage> createState() => _VNPayWebViewPageState();
}

class _VNPayWebViewPageState extends State<VNPayWebViewPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  String _loadingStatus = 'Đang khởi tạo...';
  String? _errorMessage;
  final VNPayService _vnPayService = VNPayService();

  @override
  void initState() {
    super.initState();
    print('🚀 VNPayWebViewPage initialized');
    print('📱 Payment URL: ${widget.paymentUrl}');
    _initWebView();
  }

  void _initWebView() {
    setState(() {
      _loadingStatus = 'Đang thiết lập WebView...';
    });

    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.61 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('📄 Page loading started: $url');
            setState(() {
              _loadingStatus = 'Đang tải trang thanh toán...';
              _errorMessage = null;
            });
            
            // Check if this is the return URL
            if (url.contains(VNPayConfig.returnUrl.replaceAll('https://', '').replaceAll('http://', ''))) {
              print('✅ Return URL detected, processing...');
              _handleReturnUrl(url);
            }
          },
          onPageFinished: (String url) {
            print('✅ Page loaded successfully: $url');
            setState(() {
              _isLoading = false;
              _loadingStatus = 'Đã tải xong';
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView error occurred:');
            print('   Error code: ${error.errorCode}');
            print('   Description: ${error.description}');
            print('   Error type: ${error.errorType}');
            
            setState(() {
              _isLoading = false;
              _errorMessage = 'Lỗi tải trang: ${error.description}';
              _loadingStatus = 'Đã xảy ra lỗi';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔄 Navigation request: ${request.url}');
            
            // Check if this is return URL
            if (request.url.contains(VNPayConfig.returnUrl.replaceAll('https://', '').replaceAll('http://', ''))) {
              print('✅ Return URL intercepted');
              _handleReturnUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            print('❌ HTTP error occurred:');
            print('   Status code: ${error.response?.statusCode}');
            
            setState(() {
              _errorMessage = 'Lỗi HTTP: ${error.response?.statusCode}';
            });
          },
        ),
      );

    // Load the payment URL
    print('🌐 Starting to load payment URL...');
    setState(() {
      _loadingStatus = 'Đang kết nối với VNPay...';
    });
    
    _controller.loadRequest(Uri.parse(widget.paymentUrl)).then((_) {
      print('✅ Load request sent successfully');
    }).catchError((error) {
      print('❌ Error loading URL: $error');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải trang thanh toán: $error';
        _loadingStatus = 'Kết nối thất bại';
      });
    });
  }

  void _handleReturnUrl(String url) {
    try {
      print('📥 Processing return URL...');
      
      final params = _vnPayService.parseCallbackUrl(url);
      print('📋 Params: $params');
      
      final result = _vnPayService.verifyCallback(params);
      print('✅ Verification result: $result');
      
      // Return result and close WebView
      Navigator.of(context).pop(result);
    } catch (e) {
      print('❌ Error handling return URL: $e');
      Navigator.of(context).pop({
        'success': false,
        'isPaid': false,
        'message': 'Lỗi xử lý kết quả thanh toán: $e',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thanh toán VNPay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isLoading)
              Text(
                _loadingStatus,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop({
              'success': true,
              'isPaid': false,
              'message': 'Người dùng hủy thanh toán',
            });
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          
          if (_isLoading && _errorMessage == null)
            Container(
              color: const Color(0xFF121212),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.pinkAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _loadingStatus,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vui lòng đợi...',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (_errorMessage != null)
            Container(
              color: const Color(0xFF121212),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 64,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Không thể tải trang thanh toán',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                                _loadingStatus = 'Đang thử lại...';
                              });
                              _initWebView();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop({
                                'success': false,
                                'isPaid': false,
                                'message': 'Không thể tải trang thanh toán',
                              });
                            },
                            child: const Text('Hủy'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('🗑️ VNPayWebViewPage disposed');
    super.dispose();
  }
}