import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';

class Debt extends StatefulWidget {
  const Debt({ Key? key }) : super(key: key);

  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<Debt> {
  @override
  Widget build(BuildContext context) 
  {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Text("Debt Page Coming Soon......"),
        ),
        bottomNavigationBar: BottomNavigations(data: 1),
      ),
    );
  }
}