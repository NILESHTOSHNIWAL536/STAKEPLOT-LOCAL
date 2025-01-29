import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

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
         getJsonBodyObj("Down Payment",3000,1000,5000,(value){},TextEditingController(text: '332')),
         getJsonBodyObj("Loan Interest Rate",4,1,100,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Loan Tenure",110,100,400,(value){},TextEditingController(text: '2332')),
         getJsonBodyObj("Annual maintenance cost",12,10,120,(value){},TextEditingController(text: '2332')),
     ];
  }
  
  
  @override
  Widget build(BuildContext context) {
      return  Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: appbarHeader("Credit card pay off calculator ", context),
          body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SliderPage(slidersList: slidersList),
               graph(),
              CustomExpansionTile(
                 howToUseContent: Expansioncalculator.creditcardTitle1,
                howItWorksContent: Expansioncalculator.creditcardTitle2,
              ),
  ])
  )
  ),
    );
  }



 Widget graph(){
     return  PieChartGraph(
                 title: "Fetch",  
                 graphData: [
                    {
                      'title':'Principal\n₹21500' ,
                      'value':21500.0
                    },
                    {
                      'title':'Interest\n₹39946' ,
                      'value':39946.0
                    },
                 ],  
                 graphDisc: const[
                    {
                      'title':'Monthly pay off:' ,
                      'amount':"₹"+"22"
                    },
                    {
                      'title':'Total interest paid:' ,
                      'amount':"₹"+"3,946"
                    }
                 ],  
          );
 }

}


