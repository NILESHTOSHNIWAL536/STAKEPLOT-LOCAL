

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
  final List<ListItemModel> howToUseContent = [
  ListItemModel(
      title: "Home Price",
      description: "Adjust the slider to set the price of the home you are considering to buy."),
  ListItemModel(
      title: "Down Payment (%)",
      description: "Use the slider to set the percentage of the home price you plan to pay upfront as a down payment."),
  ListItemModel(
      title: "Loan Interest Rate (%)",
      description: "Set the annual interest rate for the loan using the slider."),
  ListItemModel(
      title: "Loan Tenure (Months)",
      description: "Adjust the slider to set the loan tenure in months (1-360 months)."),
  ListItemModel(
      title: "Property Tax Rate (%)",
      description: "Use the slider to set the annual property tax rate as a percentage of the home price."),
  ListItemModel(
      title: "Maintenance Cost (% per year)",
      description: "Set the annual maintenance cost as a percentage of the home price using the slider."),
  ListItemModel(
      title: "Home Appreciation Rate (% per year)",
      description: "Adjust the slider to set the expected annual appreciation rate of the home’s value."),
  ListItemModel(
      title: "Monthly Rent",
      description: "Use the slider to set the current monthly rent."),
  ListItemModel(
      title: "Rent Increase Rate (% per year)",
      description: "Adjust the slider to set the annual rent increase rate."),
];


  // Example data for "How it works?"
  final List<ListItemModel> howItWorksContent = [
  ListItemModel(
      title: "EMI Calculation",
      description: "The calculator determines the Equated Monthly Installment (EMI) based on the home price, down payment, loan interest rate, and loan tenure."),
  ListItemModel(
      title: "Total Buy Cost Calculation",
      description: "This includes the down payment, total loan cost (EMI x loan tenure), property tax, and maintenance cost over the loan tenure. "
          "The appreciated value of the home over the loan tenure is subtracted from the total buy cost to account for the potential increase in home value."),
  ListItemModel(
      title: "Total Rent Cost Calculation",
      description: "The total rent paid over the loan tenure is calculated by accounting for the initial rent and the annual rent increase rate."),
  ListItemModel(
      title: "Comparison",
      description: "The calculator compares the total cost of buying and renting over the specified period. "
          "The results are displayed in a doughnut chart, visually representing the costs of both options."),
];

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