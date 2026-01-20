import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/email_sync/custom_steps.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../Constants/colors.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../controllers/credit_card_controller.dart';
import '../finance_screen/Budgets/Budget.dart';
import '../finance_screen/finanace_dashboard/creditCard_slider.dart';
import 'add_credit_card_bank.dart';

RxBool loadingBankdetails = false.obs;

class GettingDataScreen extends StatefulWidget 
{
  @override
  State<GettingDataScreen> createState() => _GettingDataScreenState();
}

class _GettingDataScreenState extends State<GettingDataScreen> {
  @override
  void initState() {
    super.initState();
    loadingBankdetails.value = false;
    CardDueController().LinkBankData(context);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFFF7F7FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: AppSizes.h30),
              CustomStepper(activeStep: 2),
              SizedBox(height: AppSizes.h20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width,
                    child: Lottie.asset(
                      'assets/splashScreen/login_email.json',
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error); // fallback UI
                      },
                    ),
                  ),
                  SizedBox(height: AppSizes.h40),
                  textStyle(
                      context: context,
                      text: "We are getting your data",
                      c: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontsize: 20),
                  SizedBox(height: AppSizes.h40),
                  Obx(() => !loadingBankdetails.value
                      ? Loader()
                      : InkWell(
                          onTap: () =>
                              pushnameToRoute(context, CardDueCarousel()),
                          child: Icon(Icons.check_circle,
                              color: Colors.green, size: 50))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
