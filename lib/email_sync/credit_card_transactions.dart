import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import '../components/helper.dart';

class CreditCardTransaction {
  final String bank;
  final String bankName;
  final String date;
  final String transactionId;
  final String amount;
  final String cardNumber;
  final String merchant;
  final String logo;

  CreditCardTransaction({
    required this.bank,
    required this.bankName,
    required this.date,
    required this.transactionId,
    required this.amount,
    required this.cardNumber,
    required this.merchant,
    required this.logo,
  });

  // Factory to create from JSON
  factory CreditCardTransaction.fromJson(Map<String, dynamic> json) {
    return CreditCardTransaction(
      bank: json['bank'] ?? '',
      bankName: json['bank'] ?? '',
      date: json['date'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      amount: json['amount'] ?? '',
      cardNumber: json['card_number'] ?? '',
      merchant: json['merchant'] ?? '-',
      logo: json['logo'] ?? '-',
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
      margin: EdgeInsets.symmetric(vertical: 8),
      // width: MediaQuery.of(context).size.width,
      // color: Colorcodes.billBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Row
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Row(
              children: [
                Image.network(txn.logo, // store your Axis Bank logo here
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                    errorBuilder: getErrorBankLogo()),
                SizedBox(width: 9),
                Container(
                  width: MediaQuery.of(context).size.width / 1.4,
                  child: Text(
                    txn.bank,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        // color: AppColors.primaryColor,
                        fontSize: 16,
                        letterSpacing: 1.1,
                        overflow: TextOverflow.ellipsis),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Divider(
            thickness: 1,
            color: Colorcodes.greyLight.withOpacity(0.8),
            endIndent: 0,
            indent: 0,
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                buildRow("Date", txn.date, context),
                buildRow("Transaction ID", txn.transactionId, context),
                buildRow("Amount", parseAmount(txn.amount), context),
                buildRow(
                    "Card Number", "************${txn.cardNumber}", context),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget buildRow(String title, String value, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: rowLabelStyle(context),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            " : ",
            style: rowValueStyle(context),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            style: rowValueStyle(context),
          ),
        ),
      ],
    ),
  );
}

// Style helpers
TextStyle rowLabelStyle(context) => FontManager().getTextStyle(context,
    lWeight: FontWeight.w600,
    fontSize: 15,
    lineHeight: 1.3,
    color: Colors.black87,
    overflow: TextOverflow.ellipsis);

// final rowValueStyle = TextStyle(
TextStyle rowValueStyle(context) => FontManager().getTextStyle(context,
    lWeight: FontWeight.w500,
    fontSize: 15,
    lineHeight: 1.3,
    color: Colors.black87,
    overflow: TextOverflow.ellipsis);

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
    return parts.length > 1 ? "$withCommas.${parts[1]}" : withCommas;
  } catch (e) {
    return s;
  }
}

class CreditCardTransaction2 {
  final String bank;
  final String bankName;
  final String date;
  final String transactionId;
  final String amount;
  final String cardNumber;
  final String merchant;
  final String logo;

  CreditCardTransaction2({
    required this.bank,
    required this.bankName,
    required this.date,
    required this.transactionId,
    required this.amount,
    required this.cardNumber,
    required this.merchant,
    required this.logo,
  });

  factory CreditCardTransaction2.fromJson(Map<String, dynamic> json) {
    return CreditCardTransaction2(
      bank: json['bank'] ?? '',
      bankName: json['bank'] ?? '',
      date: json['date'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      amount: json['amount'] ?? '',
      cardNumber: json['card_number'] ?? '',
      merchant: json['merchant'] ?? '-',
      logo: json['logo'] ?? '-',
    );
  }
}

class CreditCardTransactionCard2 extends StatelessWidget {
  final CreditCardTransaction2 txn;
  const CreditCardTransactionCard2({Key? key, required this.txn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double containerWidth = MediaQuery.of(context).size.width - 95;
    final double cardHeight = MediaQuery.of(context).size.height / 4.8;

    return Container(
      width: containerWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      constraints: BoxConstraints(
        minHeight: 140,
        maxWidth: MediaQuery.of(context).size.width * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo and Bank Name Row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: Row(
              children: [
                Image.network(
                  txn.logo,
                  height: 32,
                  width: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.error,
                    color: Color(0xFF635D8F),
                    size: 32,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    txn.bank,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1,
            color: Colorcodes.greyLight.withOpacity(0.8),
            indent: 18,
            endIndent: 18,
          ),
          // Compact Transaction Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRow("Amount", parseAmount(txn.amount), context),
                buildRow("Card Number", "****${txn.cardNumber}", context),
                buildRow("transactionId", "${txn.transactionId}", context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(String title, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            // width: 80,
            child: Text(
              title,
              style: rowLabelStyle(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              ": ",
              style: rowValueStyle(context),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: rowValueStyle(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle rowLabelStyle(BuildContext context) => FontManager().getTextStyle(
        context,
        lWeight: FontWeight.w600,
        fontSize: 14,
        lineHeight: 1.2,
        color: Colors.black87,
        overflow: TextOverflow.ellipsis,
      );

  TextStyle rowValueStyle(BuildContext context) => FontManager().getTextStyle(
        context,
        lWeight: FontWeight.bold,
        fontSize: 14,
        lineHeight: 1.2,
        color: Colors.black87,
        overflow: TextOverflow.ellipsis,
      );

  String parseAmount(String s) {
    if (s.isEmpty) return '-';
    try {
      final parts = s.split('.');
      final intPart = parts[0];
      final withCommas = int.parse(intPart).toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => "${m[1]},",
          );
      return parts.length > 1 ? "$withCommas.${parts[1]}" : withCommas;
    } catch (e) {
      return s;
    }
  }
}
