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
  final List<ListItemModel> howToUseContent = [
  ListItemModel(
      title: "Car Price",
      description: "Use the slider to set the price of the car you intend to purchase."),
  ListItemModel(
      title: "Down Payment (%)",
      description: "Adjust the slider to set the percentage of the car price you plan to pay as a down payment."),
  ListItemModel(
      title: "Loan Interest Rate (%)",
      description: "Set the annual interest rate for the loan using the slider."),
  ListItemModel(
      title: "Loan Tenure (Months)",
      description: "Adjust the slider to set the loan tenure in months (1-120 months)."),
  ListItemModel(
      title: "Annual Maintenance Cost (% of car price)",
      description: "Set the annual maintenance cost as a percentage of the car price using the slider."),
  ListItemModel(
      title: "Select Car Brand",
      description: "Choose from various car brands to see estimates tailored to specific vehicles."),
];


  // Example data for "How it works?"
  final List<ListItemModel> howItWorksContent = [
  ListItemModel(
      title: "Monthly Loan Payment Calculation",
      description: "The calculator determines the Equated Monthly Installment (EMI) based on the car price, down payment, loan interest rate, and loan tenure."),
  ListItemModel(
      title: "Total Loan Cost Calculation",
      description: "This includes the total amount paid towards the loan over the specified tenure, considering the EMI payments."),
  ListItemModel(
      title: "Annual Maintenance Cost Calculation",
      description: "The calculator estimates the annual maintenance expenses based on the selected car brand and the specified maintenance cost percentage."),
  ListItemModel(
      title: "Depreciation Value Calculation",
      description: "The estimated depreciation value of the car after four years is calculated based on the selected car brand."),
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
    return Scaffold(
          appBar: appbarHeader("Auto loan calculator ", context),
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
  )
  ),
    );
  }

   Widget graph(){
     return  PieChartGraph(
                 title: "Auto loan Details:",  
                 graphData: [
                    {
                      'title':'Total loan cost\n₹28,51,372.59' ,
                      'value':4300.0
                    },
                    {
                      'title':'Depreciation Value\n₹18,00,000' ,
                      'value':3946.0
                    },
                    {
                      'title':'Annual maintenance cost\n₹10,500' ,
                      'value':1246.0
                    },

                 ],  
                 graphDisc:const [
                     {
                      'title':'Monthly loan payment:' ,
                      'amount':"₹"+"47,522.88"
                    },
                    {
                      'title':'Total loan cost:' ,
                      'amount':"₹"+"28,51,372.59"
                    },
                    {
                      'title':'Annual maintenance cost:' ,
                      'amount':"₹"+"10,500.00"
                    },
                    {
                      'title':'Depreciation value after 4 years:' ,
                      'amount':"₹"+"18,00,000.00"
                    },
                 ],  
          );
 }

}


PreferredSizeWidget appbarHeader(String title,BuildContext context,){
    return AppBar(
         centerTitle: true,
          title: textStyle(context: context,text: title,fontsize: 16,fontWeight: FontWeight.w500),
    );
}