import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

class Emi extends StatefulWidget {
  const Emi({ Key? key }) : super(key: key);

  @override
  _EmiState createState() => _EmiState();
}

class _EmiState extends State<Emi> {


  late List slidersList;

  double loanAmount = 46000.0;
  double annualInterestPaid = 9946.0;
  double loanTenure = 0;


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
  
final List<ListItemModel> howToUseContent = [
    ListItemModel(title: "Loan Amount:", description: "Input: Adjust the slider to set your loan amount (e.g., ₹500,000)."),
    ListItemModel(title: "Annual Interest Rate:", description: "Input: Adjust the slider to set your annual interest rate (e.g., 10%)."),
    ListItemModel(title: "Loan Tenure:", description: "Input: Adjust the slider to set your loan tenure in months (e.g., 12 months)."),
  ];

  // Example data for "How it works?"
  final List<ListItemModel> howItWorksContent = [
    ListItemModel(title: "Calculations:", description: "Monthly payment calculated using the loan amount, interest rate, and tenure.The total interest paid over the loan tenure, calculated as the difference between the total amount paid and the principal."),
  ];


    // Callback function to update the slider values
  void updateSliderValue(int index, double newValue)
  {
    setState(() {
      slidersList[index]['value'] = newValue;
      slidersList[index]['controller'].text = newValue.toStringAsFixed(0);
    });

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
             SliderPage(slidersList: slidersList,onSliderValueChanged: updateSliderValue),
               graph(),
              CustomExpansionTile(
                 howToUseContent: howToUseContent,
                howItWorksContent: howItWorksContent,
              ),
             
            ],
          ),
      ))
    );
  }




   Widget graph(){
    
     return  PieChartGraph(
                title: "EMI Details",  
                 graphData: [
                     {
                      'title':"Principal\n₹${(loanAmount.toString())}",
                      'value': loanAmount 
                    },
                    {
                      'title':'Interest\n₹${(annualInterestPaid.toString())}' ,
                      'value':annualInterestPaid
                    },

                 ],  
                 graphDisc: [
                   {
                      'title': 'EMI:',
                      'amount': "₹ ${(loanAmount).toString()}",
      
                    },
                    {
                      'title': 'Total interest paid:',
                      'amount': "₹ ${annualInterestPaid.toString()}"
                    }
                ]
          );
 }

}