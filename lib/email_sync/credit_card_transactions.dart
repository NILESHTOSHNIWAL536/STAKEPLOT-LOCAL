import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';

import '../Home_Screen/helper.dart';

class CreditCardTransaction {
  final String bank;
  final String date;
  final String transactionId;
  final String amount;
  final String cardNumber;
  final String merchant;

  CreditCardTransaction({
    required this.bank,
    required this.date,
    required this.transactionId,
    required this.amount,
    required this.cardNumber,
    required this.merchant,
  });

  // Factory to create from JSON
  factory CreditCardTransaction.fromJson(Map<String, dynamic> json) {
    return CreditCardTransaction(
      bank: json['bank'] ?? 'Axis Bank Credit Card',
      date: json['date'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      amount: json['amount'] ?? '',
      cardNumber: json['card_number'] ?? '',
      merchant: json['merchant'] ?? '-',
    );
  }
}

class CreditCardTransactionCard extends StatelessWidget {
  final CreditCardTransaction txn;
  const CreditCardTransactionCard({Key? key, required this.txn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For logo, store an asset at assets/axis_logo.png
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFEAEAEA), width: 1),
        boxShadow: [
          BoxShadow(
              blurRadius: 3,
              color: Colors.black.withOpacity(0.02),
              offset: Offset(1, 2))
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      margin: EdgeInsets.all(9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Row
          Row(
            children: [
              Image.network(
                "", // store your Axis Bank logo here
                height: 32,
                width: 32,
                fit: BoxFit.contain,
                 errorBuilder: getErrorBankLogo()  
              ),
              SizedBox(width: 9),
              Text(
                "AXIS BANK",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD02149),
                  fontSize: 16,
                  letterSpacing: 1.1,
                  fontFamily: "Arial",
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Text(
            "Credit Card Transaction",
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          SizedBox(height: 12),
          Table(
            columnWidths: {0: FixedColumnWidth(90), 1: FlexColumnWidth()},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: [
                Text("Date", style: rowLabelStyle),
                Text(" :  ${txn.date}", style: rowValueStyle),
              ]),
              TableRow(children: [
                Text("Transaction ID", style: rowLabelStyle),
                Text(" :  ${txn.transactionId}", style: rowValueStyle),
              ]),
              TableRow(children: [
                Text("Amount", style: rowLabelStyle),
                Text(" :  ${parseAmount(txn.amount)}", style: rowValueStyle),
              ]),
              TableRow(children: [
                Text("Card Number", style: rowLabelStyle),
                Text(
                  " :  ************${txn.cardNumber}", 
                  style: rowValueStyle,
                ),
              ]),
              TableRow(children: [
                Text("Merchant", style: rowLabelStyle),
                Text(
                  " :  ${txn.merchant ?? '-'}", 
                  style: rowValueStyle,
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// Style helpers
final rowLabelStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 13,
  color: Colors.black87,
  fontFamily: "Arial",
);

final rowValueStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontSize: 13,
  color: Colors.black87,
  fontFamily: "Arial",
);

// Helper for formatting amount like 25,689
String parseAmount(String s) {
  if (s.isEmpty) return '-';
  try {
    final parts = s.split('.');
    final intPart = parts[0];
    final withCommas = int.parse(intPart).toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => "${m[1]},",
        );
    return parts.length > 1
        ? "$withCommas.${parts[1]}"
        : withCommas;
  } catch (e) {
    return s;
  }
}

// Usage Example:
// Pass your JSON map to this widget
/*
CreditCardTransactionCard(
  txn: CreditCardTransaction.fromJson(myJsonMap),
)
*/
