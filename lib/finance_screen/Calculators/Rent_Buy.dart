

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

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
             SliderPage(slidersList: slidersList),
              graph(),
              CustomExpansionTile(
                 howToUseContent: Expansioncalculator.creditcardTitle1,
                howItWorksContent: Expansioncalculator.creditcardTitle2,
              ),
            ],
          ),
      ))
    );

  }


   Widget graph(){
     return  PieChartGraph(
                 title: "Rent vs Buy Details:",  
                 graphData: [
                  {
                      'title':'Principal\n₹46000' ,
                      'value':46000.0
                    },
                    {
                      'title':'Interest\n₹39946' ,
                      'value':9946.0
                    },
                    
                 ],  
                 graphDisc: const[
                    {
                      'title':'Total cost of renting:' ,
                      'amount':"₹"+"79,35,829"
                    },
                    {
                      'title':'Total cost of buying:' ,
                      'amount':"₹"+"42,93,433"
                    }
                 ]
          );
 }

}