import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class ZaloPayService {
  final Dio _dio = Dio();
  
  // Official ZaloPay Sandbox credentials
  static const String appId = '2553';
  static const String key1 = 'PcY4iZIKFCIdgZvA6ueMcMHHUbRLYjPL';
  static const String key2 = 'kLtgPl8YESDmyABkQgeZByOUJsbcpNI2';
  
  static const String createOrderUrl = 'https://sb-openapi.zalopay.vn/v2/create';
  static const String queryOrderUrl = 'https://sb-openapi.zalopay.vn/v2/query';

  String _generateMac(String data, String key) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }

  /// Tạo đơn hàng thanh toán trên ZaloPay Sandbox
  /// Trả về Map chứa 'order_url' và 'app_trans_id' nếu thành công
  Future<Map<String, dynamic>?> createOrder({
    required String bookingId,
    required double amount,
  }) async {
    try {
      final now = DateTime.now();
      final appTime = now.millisecondsSinceEpoch;
      
      final datePrefix = DateFormat('yyMMdd').format(now);
      final timestampSuffix = appTime % 100000;
      final appTransId = '${datePrefix}_${bookingId.replaceAll("-", "")}$timestampSuffix';

      final embedData = jsonEncode({
        'redirecturl': 'app://sportmanagement/payment/callback',
      });
      final item = jsonEncode([]);
      final amountInt = amount.toInt();
      
      // hmacInput = app_id + "|" + app_trans_id + "|" + app_user + "|" + amount + "|" + app_time + "|" + embed_data + "|" + item
      final macInput = '$appId|$appTransId|sport_user|$amountInt|$appTime|$embedData|$item';
      final mac = _generateMac(macInput, key1);

      final requestData = {
        'app_id': int.parse(appId),
        'app_user': 'sport_user',
        'app_trans_id': appTransId,
        'app_time': appTime,
        'amount': amountInt,
        'item': item,
        'embed_data': embedData,
        'description': 'Sport Energy - Thanh toan dat san #$bookingId',
        'bank_code': '',
        'mac': mac,
      };

      // ignore: avoid_print
      print('ZaloPay Create Order Request: $requestData');

      final response = await _dio.post(
        createOrderUrl,
        data: requestData,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      // ignore: avoid_print
      print('ZaloPay Create Order Response status: ${response.statusCode}, body: ${response.data}');

      if (response.statusCode == 200) {
        final resData = response.data as Map<String, dynamic>;
        if (resData['return_code'] == 1) {
          return {
            'order_url': resData['order_url'],
            'app_trans_id': appTransId,
            'qr_code': resData['qr_code'],
          };
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('ZaloPay Create Order Error: $e');
      return null;
    }
  }

  /// Truy vấn trạng thái đơn hàng trên ZaloPay Sandbox
  /// Trả về true nếu đã thanh toán thành công
  Future<bool> checkOrderStatus(String appTransId) async {
    try {
      // hmacInput = app_id + "|" + app_trans_id + "|" + key1
      final macInput = '$appId|$appTransId|$key1';
      final mac = _generateMac(macInput, key1);

      final requestData = {
        'app_id': int.parse(appId),
        'app_trans_id': appTransId,
        'mac': mac,
      };

      // ignore: avoid_print
      print('ZaloPay Query Order Request: $requestData');

      final response = await _dio.post(
        queryOrderUrl,
        data: requestData,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      // ignore: avoid_print
      print('ZaloPay Query Order Response status: ${response.statusCode}, body: ${response.data}');

      if (response.statusCode == 200) {
        final resData = response.data as Map<String, dynamic>;
        // return_code: 1: Thành công, 2: Thất bại, 3: Đang xử lý
        if (resData['return_code'] == 1) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('ZaloPay Query Order Error: $e');
      return false;
    }
  }
}
