import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';

class Emi extends StatefulWidget {
  const Emi({ Key? key }) : super(key: key);

  @override
  _EmiState createState() => _EmiState();
}

class _EmiState extends State<Emi> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
          appBar: appbarHeader("EMI calculator", context),
          body: Text("EMI calculator "),
    );
  }
}