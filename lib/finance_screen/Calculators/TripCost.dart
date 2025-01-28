

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';

class TripCost extends StatefulWidget {
  const TripCost({ Key? key }) : super(key: key);

  @override
  _TripCostState createState() => _TripCostState();
}

class _TripCostState extends State<TripCost> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
          appBar: appbarHeader("Trip cost calculator ", context),
          body: Text("Trip cost calculator "),
    );
  }
}