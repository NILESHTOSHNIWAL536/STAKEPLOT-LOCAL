import 'package:flutter/material.dart';
import '../finance_screen/finanace_dashboard/creditCard_slider.dart';
import 'add_credit_card_bank.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class DisplayCreditCard extends StatelessWidget {
  const DisplayCreditCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Your Credit Cards",
          style: FontManager().getTextStyle(context,
              color: Colors.black, lWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            /// 🔹 Section Title
            Text(
              "Manage Cards",
              style: FontManager().getTextStyle(context,
                  fontSize: 16,
                  lWeight: FontWeight.w600,
                  color: Colors.black87),
            ),

            const SizedBox(height: 12),

            /// ➕ Add Card Button (Modern UI)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddCreditCardBankScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: Colors.blue, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Link Credit Card",
                      style: FontManager().getTextStyle(context,
                          fontSize: 15,
                          lWeight: FontWeight.w600,
                          color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ℹ️ Info Text (Optional)
            Center(
              child: Text(
                "Securely link your credit card to track dues and payments",
                textAlign: TextAlign.center,
                style: FontManager().getTextStyle(context,
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            ),

            /// 💳 Card Carousel
            const SizedBox(height: 24),
            CardDueCarousel(
              flag: false,
            ),
          ],
        ),
      ),
    );
  }
}
