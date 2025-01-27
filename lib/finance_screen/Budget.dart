import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';

class Budget extends StatefulWidget {
  const Budget({ Key? key }) : super(key: key);

  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  @override
  Widget build(BuildContext context) 
  {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Text("Nilesh"),
        ),
        bottomNavigationBar: BottomNavigations(data: 1),
      ),
    );
  }
}