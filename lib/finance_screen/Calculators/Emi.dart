import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';

class Emi extends StatefulWidget {
  const Emi({ Key? key }) : super(key: key);

  @override
  _EmiState createState() => _EmiState();
}

class _EmiState extends State<Emi> {


  late List slidersList;

  @override
  void initState()
  {
      getslidersList();
  }

   void getslidersList(){
      slidersList=[
         getJsonBodyObj("Loan amount",4,3,12,(value){},TextEditingController(text: '2')),
         getJsonBodyObj("Annual interest rate(%)",4,1,12,(value){},TextEditingController(text: '332')),
         getJsonBodyObj("Loan tenure(months)",4,1,12,(value){},TextEditingController(text: '2332')),
        
     ];
  }


  @override
  Widget build(BuildContext context) {
  
  
 

   return  Scaffold(
          appBar: appbarHeader("EMI calculator", context),
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