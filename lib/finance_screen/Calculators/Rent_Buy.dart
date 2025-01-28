

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';

class RentBuy extends StatefulWidget {
  const RentBuy({ Key? key }) : super(key: key);

  @override
  _RentBuyState createState() => _RentBuyState();
}

class _RentBuyState extends State<RentBuy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: appbarHeader("Rent vs Buy Calculator", context),
          body: Text("Rent vs Buy Calculator"),
    );
  }
}