import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';

class AutoLoan extends StatefulWidget {
  const AutoLoan({ Key? key }) : super(key: key);

  @override
  _AutoLoanState createState() => _AutoLoanState();
}

class _AutoLoanState extends State<AutoLoan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: appbarHeader("Auto loan calculator ", context),
          body: Text("Auto loan calculator "),
    );
  }
}


PreferredSizeWidget appbarHeader(String title,BuildContext context,){
    return AppBar(
         centerTitle: true,
          title: textStyle(context: context,text: title,fontsize: 16,fontWeight: FontWeight.w500),
    );
}