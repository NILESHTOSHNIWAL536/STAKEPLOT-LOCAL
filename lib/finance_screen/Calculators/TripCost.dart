

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

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
final List<ListItemModel> howToUseContent = [
  ListItemModel(
      title: "Travel Destination",
      description: "Select the desired travel destination from the provided options (Beach, Mountains, City, Countryside)."),
  ListItemModel(
      title: "Accommodation Type",
      description: "Choose the type of accommodation you prefer for your trip (Hotel, Hostel, Airbnb, Camping)."),
  ListItemModel(
      title: "Daily Expenses",
      description: "Adjust the slider to set the estimated daily expenses per person during the trip."),
  ListItemModel(
      title: "Entertainment Budget",
      description: "Set the budget allocated for entertainment activities during the trip."),
  ListItemModel(
      title: "Number of Days",
      description: "Use the slider to specify the duration of your spring break trip in days."),
  ListItemModel(
      title: "Travel Cost",
      description: "Adjust the slider to set the estimated travel cost for transportation to the destination."),
  ListItemModel(
      title: "Number of Members",
      description: "Enter the total number of individuals participating in the trip."),
];


  // Example data for "How it works?"
  final List<ListItemModel> howItWorksContent = [
  ListItemModel(
      title: "Total Trip Cost Calculation",
      description: "The calculator computes the total cost of the trip, including travel expenses, accommodation costs, daily expenses, and entertainment budget."),
  ListItemModel(
      title: "Cost Per Member Calculation",
      description: "It calculates the average cost per member by dividing the total trip cost by the number of members in the group."),
  ListItemModel(
      title: "Cost Breakdown Visualization",
      description: "The cost breakdown is visualized using a doughnut chart, providing a clear breakdown of expenses into categories like travel cost, accommodation cost, daily expenses, and entertainment budget."),
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
          appBar: appbarHeader("Trip cost calculator ", context),
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
                 title: "Trip cost details:",  
                 graphData: [
                    {
                      'title':'Remaining amount\n₹4,500' ,
                      'value':4500.0
                    },
                    {
                      'title':'Current savings\n₹500' ,
                      'value':500.0
                    },
                 ],  
                 graphDisc:const [
                     {
                      'title':'Total trip cost:' ,
                      'amount':"₹"+"5,390.94"
                    },
                    {
                      'title':'Interest earned:' ,
                      'amount':"₹"+"90.94"
                    },
                    {
                      'title':'Progress:' ,
                      'amount':"₹"+"10.00%"
                    },
                  
                 ]
          );
 }

}