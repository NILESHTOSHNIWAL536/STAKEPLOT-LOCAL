// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class PaymentService {
//   late Razorpay _razorpay;

//   PaymentService() {
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
//   }

//   Future<void> pay(BuildContext context, int amount) async {
//     final order = await _createOrder(amount);

//     _razorpay.open({
//       'key': 'rzp_test_SCLZaM1b5POcqX',
//       'amount': order['amount'],
//       'order_id': order['id'],
//       'name': 'My App',
//       'description': 'Test Payment',
      
//     });
//   }

//   Future<Map<String, dynamic>> _createOrder(int amount) async {
//     final res = await http.post(
//       Uri.parse("http://192.168.1.5:5000/create-order"),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'amount': amount}),
//     );
//     return jsonDecode(res.body);
//   }

//   void _onSuccess(PaymentSuccessResponse res) async {
//     await http.post(
//       Uri.parse("http://192.168.1.5:5000/verify-payment"),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'razorpay_order_id': res.orderId,
//         'razorpay_payment_id': res.paymentId,
//         'razorpay_signature': res.signature,
//         'amount': 499,
//       }),
//     );
//   }

//   void _onError(PaymentFailureResponse res) {
//     debugPrint("Payment failed");
//   }

//   void dispose() {
//     _razorpay.clear();
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {

  late Razorpay _razorpay;

  Function()? onSuccess;
  Function(String)? onError;

  String? _orderId;

  static const backendUrl =
      "http://192.168.1.5:5000/api/payments";

  PaymentService() {
    _razorpay = Razorpay();

    _razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);

    _razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR, _handleError);
  }

  Future<void> startPayment() async {
    try {

      final order = await _createOrder();
      print("✅ ORDER RECEIVED:");
      print(order);


      _orderId = order['id'];

      var options = {
        'key': 'rzp_test_SCLZaM1b5POcqX',
        'amount': order['amount'],
        'order_id': order['id'],
        'name': 'Your App',
        'description': 'Premium Upgrade',
        'timeout': 180,
      };
 print("🚀 Opening Razorpay...");
      _razorpay.open(options);

    } catch (e) {
        print("❌ START PAYMENT ERROR:");
      print(e);

      onError?.call("Payment start failed");
      
    }
  }

 Future<Map<String, dynamic>> _createOrder() async {

  final response = await http.post(
    Uri.parse("$backendUrl/create-order"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({}),
  ).timeout(const Duration(seconds: 20));

  final data = jsonDecode(response.body);

  // ⭐ STORE ORDER ID
  _orderId = data['id'];

  return data;
}
Future<String?> checkPaymentStatus() async {

  if (_orderId == null) return null;

  try {

    final res = await http.get(
      Uri.parse("$backendUrl/payment-status/$_orderId"),
    );

    final data = jsonDecode(res.body);

    print("Payment status from server: ${data['status']}");

    return data['status'];

  } catch (e) {

    print("Status check failed: $e");
    return null;
  }
}


  Future<void> _handleSuccess(
    PaymentSuccessResponse response) async {

  await Future.delayed(Duration(seconds: 2));

  final verify = await http.post(
    Uri.parse("$backendUrl/verify-payment"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'razorpay_order_id': response.orderId,
      'razorpay_payment_id': response.paymentId,
      'razorpay_signature': response.signature,
    }),
  );

  if (verify.statusCode == 200) {
   Future.delayed(const Duration(milliseconds: 300), () {
  onSuccess?.call();
});

  } else {
    onError?.call("Verification failed");
  }
}


  void _handleError(PaymentFailureResponse response) async {

  print("⚠️ Payment error triggered...");
  print("Checking real payment status...");

  final status = await checkPaymentStatus();

  // ⭐ If actually successful → treat as success
  if (status == "SUCCESS") {

    print("✅ Payment actually succeeded!");

    onSuccess?.call();
    return;
  }

  print("❌ Payment genuinely failed");

  onError?.call(response.message ?? "Payment Failed");
}


  void dispose() {
    _razorpay.clear();
  }
}