

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';

class RentBuy extends StatefulWidget {
  const RentBuy({ Key? key }) : super(key: key);

  @override
  _RentBuyState createState() => _RentBuyState();
}

class _RentBuyState extends State<RentBuy> {

  late List slidersList;

  @override
  void initState()
  {
      getslidersList();
  }

   void getslidersList(){
      slidersList=[
         getJsonBodyObj("Home price",4,3,12,(value){},TextEditingController(text: '2')),
         getJsonBodyObj("Down payment(%)",4,1,12,(value){},TextEditingController(text: '332')),
         getJsonBodyObj("Loan interest rate(%)",4,1,12,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Loan tenure(months)",4,1,12,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Property tax rate(%)",4,1,12,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Maintenance Cost (% per year)",4,1,12,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Home Appreciation Rate (% per year)",4,1,12,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Monthly Rent",4,1,12,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Rent Increase Rate (% per year)",4,1,12,(value){},TextEditingController(text: '2332')),
     ];
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
          appBar: appbarHeader("Rent vs Buy Calculator", context),
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