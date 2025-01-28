

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';

class TripCost extends StatefulWidget {
  const TripCost({ Key? key }) : super(key: key);

  @override
  _TripCostState createState() => _TripCostState();
}

class _TripCostState extends State<TripCost> {

  late List slidersList;

  @override
  void initState()
  {
      getslidersList();
  }

   void getslidersList(){
      slidersList=[
         getJsonBodyObj("Daily expenses",4,3,12,(value){},TextEditingController(text: '2')),
         getJsonBodyObj("Entertainment budget",4,1,12,(value){},TextEditingController(text: '332')),
         getJsonBodyObj("No. of days",4,1,12,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Travel cost",4,1,12,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Number of member",4,1,12,(value){},TextEditingController(text: '2332')),
     ];
  }

  @override
  Widget build(BuildContext context) {
  
     return Scaffold(
          appBar: appbarHeader("Trip cost calculator ", context),
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
  ));
  }
}