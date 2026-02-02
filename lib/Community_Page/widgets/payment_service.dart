import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
  }

  Future<void> pay(BuildContext context, int amount) async {
    final order = await _createOrder(amount);

    _razorpay.open({
      'key': 'rzp_test_SA0jmoIDCCIeKg',
      'amount': order['amount'],
      'order_id': order['id'],
      'name': 'My App',
      'description': 'Test Payment',
      'method': {
        'upi': true,
        'card': false,
        'netbanking': false,
        'wallet': false,
      }
    });
  }

  Future<Map<String, dynamic>> _createOrder(int amount) async {
    final res = await http.post(
      Uri.parse("http://192.168.1.14:5000/create-order"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );
    return jsonDecode(res.body);
  }

  void _onSuccess(PaymentSuccessResponse res) async {
    await http.post(
      Uri.parse("http://192.168.1.14:5000/verify-payment"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'razorpay_order_id': res.orderId,
        'razorpay_payment_id': res.paymentId,
        'razorpay_signature': res.signature,
        'amount': 499,
      }),
    );
  }

  void _onError(PaymentFailureResponse res) {
    debugPrint("Payment failed");
  }

  void dispose() {
    _razorpay.clear();
  }
}
