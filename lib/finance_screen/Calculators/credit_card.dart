import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';

class CreditCard extends StatefulWidget {
  const CreditCard({ Key? key }) : super(key: key);

  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {

   late List slidersList;

  @override
  void initState()
  {
      getslidersList();
  }

   void getslidersList(){
      slidersList=[
         getJsonBodyObj("Car Price",4,3,12,(value){},TextEditingController(text: '2')),
         getJsonBodyObj("Down Payment",4,1,12,(value){},TextEditingController(text: '332')),
         getJsonBodyObj("Loan Interest Rate",4,1,12,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Loan Tenure",4,1,12,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Annual maintenance cost",4,1,12,(value){},TextEditingController(text: '2332')),
     ];
  }
  
  
  @override
  Widget build(BuildContext context) {
      return  Scaffold(
          appBar: appbarHeader("Auto loan calculator ", context),
          body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: AppColors.mt,
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        SliderPage(slidersList: slidersList),
             
            ],
          ),
      ))
  ])
  )
  ),
    );
  }
}