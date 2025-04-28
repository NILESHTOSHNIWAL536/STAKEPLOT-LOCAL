import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/utils.dart';

class TripCost extends StatefulWidget {
  const TripCost({Key? key}) : super(key: key);

  @override
  _TripCostState createState() => _TripCostState();
}

class _TripCostState extends State<TripCost> {
  late List slidersList;

  double travelCost = 300;
  double dailyExpenses = 100;
  double entertainmentBudget = 500;
  double numberOfDays = 7;
  double numberOfMembers = 1;
  double accommodationCost = 1500;
  double totalCost = 0;
  double costPerMember = 0;
double accommodationCostPerDay = 0;
  @override
  void initState() {
    getslidersList();
    calculateTripCost();
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Daily expenses", dailyExpenses, 50, 500, (v) {},
          TextEditingController(text: dailyExpenses.toString())),
      getJsonBodyObj("Entertainment budget", entertainmentBudget, 100, 2000,
          (v) {}, TextEditingController(text: entertainmentBudget.toString())),
      getJsonBodyObj("Number of days", numberOfDays, 1, 30, (v) {},
          TextEditingController(text: numberOfDays.toString()), false, "days"),
      getJsonBodyObj("Travel cost", travelCost, 100, 5000, (v) {},
          TextEditingController(text: travelCost.toString())),
      getJsonBodyObj("Number of members", numberOfMembers, 1, 12, (v) {},
          TextEditingController(text: numberOfMembers.toString()), false, ""),
    ];
  }

  final List<ListItemModel> howToUseContent = [
    ListItemModel(
        title: "Travel Destination",
        description:
            "Select the desired travel destination from the provided options (Beach, Mountains, City, Countryside)."),
    ListItemModel(
        title: "Accommodation Type",
        description:
            "Choose the type of accommodation you prefer for your trip (Hotel, Hostel, Airbnb, Camping)."),
    ListItemModel(
        title: "Daily Expenses",
        description:
            "Adjust the slider to set the estimated daily expenses per person during the trip."),
    ListItemModel(
        title: "Entertainment Budget",
        description:
            "Set the budget allocated for entertainment activities during the trip."),
    ListItemModel(
        title: "Number of Days",
        description:
            "Use the slider to specify the duration of your spring break trip in days."),
    ListItemModel(
        title: "Travel Cost",
        description:
            "Adjust the slider to set the estimated travel cost for transportation to the destination."),
    ListItemModel(
        title: "Number of Members",
        description:
            "Enter the total number of individuals participating in the trip."),
  ];
  
  // Example data for "How it works?"
  final List<ListItemModel> howItWorksContent = [
    ListItemModel(
        title: "Total Trip Cost Calculation",
        description:
            "The calculator computes the total cost of the trip, including travel expenses, accommodation costs, daily expenses, and entertainment budget."),
    ListItemModel(
        title: "Cost Per Member Calculation",
        description:
            "It calculates the average cost per member by dividing the total trip cost by the number of members in the group."),
    ListItemModel(
        title: "Cost Breakdown Visualization",
        description:
            "The cost breakdown is visualized using a doughnut chart, providing a clear breakdown of expenses into categories like travel cost, accommodation cost, daily expenses, and entertainment budget."),
  ];

  void updateSliderValue(int index, double newValue) {
    setState(() {
      slidersList[index]['value'] = newValue;
      slidersList[index]['controller'].text = newValue.toStringAsFixed(0);
      if (index == 0) dailyExpenses = newValue;
      if (index == 1) entertainmentBudget = newValue;
      if (index == 2) numberOfDays = newValue;
      if (index == 3) travelCost = newValue;
      if (index == 4) numberOfMembers = newValue;
      calculateTripCost();
    });
  }

  
void calculateTripCost() {
    accommodationCostPerDay = selectedAccommodation == 'Hotel'
        ? 1500 * (numberOfMembers / 2).round().toDouble()
        : selectedAccommodation == 'Airbnb'
            ? 1000 * (numberOfMembers / 2).round().toDouble()
            : selectedAccommodation == 'Hostel'
                ? 400 * numberOfMembers.toDouble()
                : selectedAccommodation == 'Camping'
                    ? 450 * (numberOfMembers / 2).round().toDouble()
                    : 0.0;

    double totalAccommodationCost = accommodationCostPerDay * numberOfDays;
    double totalDailyExpenses = dailyExpenses * numberOfDays;
    totalCost = travelCost +
        totalAccommodationCost +
        totalDailyExpenses +
        entertainmentBudget;
    costPerMember = totalCost / numberOfMembers;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbarHeader("Trip cost calculator ", context),
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SliderPage(
                      slidersList: slidersList,
                      onSliderValueChanged: updateSliderValue,
                      title: "Trip",
                      onAccommodationChanged: (newAccommodation) {
                        setState(() {
                          selectedAccommodation = newAccommodation;
                          calculateTripCost(); // Recalculate costs when accommodation changes
                        });
                      },
                    ),
                    graph(),
                    CustomExpansionTile(
                      howToUseContent: howToUseContent,
                      howItWorksContent: howItWorksContent,
                    ),
                  ],
                ),
              )),
        ));
  }

  Widget graph() {
    return PieChartGraph(
      title: "Trip Cost Breakdown:",
      graphData: [
        {'title': 'Travel Cost :₹${formatMoneyIndian(doubleToFixed(travelCost.toString()))}',
         'value': travelCost},
        {
          'title': 'Accommodation Cost: ₹${formatMoneyIndian(doubleToFixed((accommodationCostPerDay * numberOfDays).toString()))}',
          'value': accommodationCostPerDay * numberOfDays
        },
        {'title': 'Daily Expenses: ₹${formatMoneyIndian(doubleToFixed((dailyExpenses * numberOfDays).toString()))}',
         'value': dailyExpenses * numberOfDays
         },
        {
          'title': 'Entertainment Budget: ₹${formatMoneyIndian(doubleToFixed(entertainmentBudget.toString()))}',
          'value': entertainmentBudget
        },
      ],
      graphDisc: [
        {
          'title': 'Total Trip Cost:',
          'amount': "₹${formatMoneyIndian(totalCost.toStringAsFixed(0))}"
        },
        {
          'title': 'Cost Per Member:',
          'amount': "₹${formatMoneyIndian(costPerMember.toStringAsFixed(0))}"
        },
      ],
    );
  }
}
