import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/email_sync/custom_steps.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Constants/colors.dart';
import '../colorcodes.dart';

class SelectAnyOptionScreen extends StatefulWidget {
  const SelectAnyOptionScreen({Key? key}) : super(key: key);

  @override
  State<SelectAnyOptionScreen> createState() => _SelectAnyOptionScreenState();
}

class _SelectAnyOptionScreenState extends State<SelectAnyOptionScreen> {
  int selectedIndex = 0;

  final List<String> titles = [
    "Credit Card",
    "Create Budget",
    "Add Debt",
  ];
  final List<String> subtitles = [
    "Securely link your card to track expenses with ease.",
    "Securely link your card to track expenses with ease.",
    "Securely link your card to track expenses with ease.",
  ];
  final List<String> svgs = [
    svgIconPath.dio1,
    svgIconPath.dio2,
    svgIconPath.dio3,
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading:leadIcon(context),
          title: textStyleImage(context: context,text: "select any option",c: AppColors.primaryColor,fontWeight: FontWeight.bold,fontsize: 20),
          centerTitle: true,
          actions: [SizedBox(width: 38)], // for symmetry
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.07),
        child: Column(
          children: [
            SizedBox(height: 10),
            // Custom Stepper
            CustomStepper(activeStep: -1),
            SizedBox(height: 22),
            // Option Buttons
            for (int i = 0; i < 3; i++) ...[
              InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () {
                  setState(() => selectedIndex = i);
                  String options = "";
                  if (i == 0) {
                    options = "/addcreditCard";
                  } else if (i == 1) {
                    options = "/Budget";
                  } else {
                    options = "/debt";
                  }
                  // Navigator.of(context).pop();
                  // Navigator.pushNamed(context2, "/FinanceDashboard");
                  Navigator.pushNamed(context, options);
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        selectedIndex == i ? Color(0xFF635D8F) : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: selectedIndex == i
                        ? null
                        : Border.all(color: Color(0xFF635D8F), width: 1),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  margin: EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        svgs[i],
                        width: 32,
                        height: 32,
                        color: selectedIndex == i
                            ? Colors.white
                            : Color(0xFF635D8F),
                      ),
                      SizedBox(height: 4),
                      textStyleImage(context: context,text: titles[i],c:selectedIndex == i ? Colors.white :AppColors.primaryColor,fontWeight: FontWeight.w500,fontsize: 18),
                      SizedBox(height: 4),
                      textStyleImage(context: context,text: subtitles[i],c:selectedIndex == i ? Colors.white :AppColors.primaryColor,fontWeight: FontWeight.w400,fontsize: 12),
                     
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
