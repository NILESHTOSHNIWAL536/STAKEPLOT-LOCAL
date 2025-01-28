import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

class AutoLoan extends StatefulWidget {
  const AutoLoan({ Key? key }) : super(key: key);

  @override
  _AutoLoanState createState() => _AutoLoanState();
}

class _AutoLoanState extends State<AutoLoan> {

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
    return Scaffold(
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
                        Container(
                width: MediaQuery.of(context).size.width/1.1,
                height:  MediaQuery.of(context).size.height/4,
                child: PieChartGraph()
              ),
              CustomExpansionTile(
                 howToUseContent: Expansioncalculator.creditcardTitle1,
                howItWorksContent: Expansioncalculator.creditcardTitle2,
              ),
             
            ],
          ),
      ))
  ])
  )
  ),
    );
  }
}


PreferredSizeWidget appbarHeader(String title,BuildContext context,){
    return AppBar(
         centerTitle: true,
          title: textStyle(context: context,text: title,fontsize: 16,fontWeight: FontWeight.w500),
    );
}