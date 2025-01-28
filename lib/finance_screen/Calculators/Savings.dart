import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';

class Savings extends StatefulWidget {
  const Savings({ Key? key }) : super(key: key);

  @override
  _SavingsState createState() => _SavingsState();
}

class _SavingsState extends State<Savings> {
  @override
  Widget build(BuildContext context) {
  return Scaffold(
          appBar: appbarHeader("Savings goal calculator ", context),
          body: Text("Savings goal calculator "),
    );
  }
}