import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';

class CreditCard extends StatefulWidget {
  const CreditCard({ Key? key }) : super(key: key);

  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: appbarHeader("Credit card pay off calculator ", context),
          body: Text("Credit card pay off calculator "),
    );
  }
}