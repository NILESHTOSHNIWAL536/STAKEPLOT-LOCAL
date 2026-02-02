import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;

  static const String backendUrl =
      "http://192.168.1.14:5000"; // 🔴 CHANGE TO YOUR IP
  static const int amount = 499;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    print("✅ Razorpay listeners attached");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Razorpay Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: _startPayment,
          child: const Text("Pay ₹499"),
        ),
      ),
    );
  }

  // 🔥 STEP 1: Start payment
  Future<void> _startPayment() async {
    print("➡️ Starting payment");

    final order = await _createOrder();

    print("✅ Order created: ${order['id']}");

    var options = {
      'key': 'rzp_test_SA0jmoIDCCIeKg', // 🔴 YOUR TEST KEY
      'amount': order['amount'],
      'order_id': order['id'],
      'name': 'Test App',
      'description': 'Demo Payment',   
      'prefill': {
        'contact': '9999999999',
        'email': 'test@razorpay.com',
      },
      'theme': {
        'color': '#4B4D73',
      }
    };

    _razorpay.open(options);
  }

  // 🔥 STEP 2: Create order from backend
  Future<Map<String, dynamic>> _createOrder() async {
    final response = await http.post(
      Uri.parse("$backendUrl/create-order"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );

    print("📦 ORDER STATUS: ${response.statusCode}");
    print("📦 ORDER BODY: ${response.body}");

    return jsonDecode(response.body);
  }

  // 🔥 STEP 3: PAYMENT SUCCESS CALLBACK
  Future<void> _handlePaymentSuccess(
      PaymentSuccessResponse response) async {
    print("🔥 PAYMENT SUCCESS CALLBACK FIRED");
    print("Payment ID: ${response.paymentId}");
    print("Order ID: ${response.orderId}");
    print("Signature: ${response.signature}");

    final verifyResponse = await http.post(
      Uri.parse("$backendUrl/verify-payment"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
        'amount': amount,
      }),
    );

    print("✅ VERIFY STATUS: ${verifyResponse.statusCode}");
    print("✅ VERIFY BODY: ${verifyResponse.body}");

    if (verifyResponse.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful 🎉")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification Failed ❌")),
      );
    }
  }

  // 🔥 STEP 4: PAYMENT FAILURE CALLBACK
  void _handlePaymentError(PaymentFailureResponse response) {
    print("❌ PAYMENT FAILED");
    print("Code: ${response.code}");
    print("Message: ${response.message}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Failed")),
    );
  }
}
