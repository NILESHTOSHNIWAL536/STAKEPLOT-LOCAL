import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/email_sync/custom_steps.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/credit_card.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';

import '../avatarProfile.dart';
import '../colorcodes.dart';
import '../controllers/credit_card_controller.dart';
import '../finances_screen/creditCard_slider.dart';
import 'add_credit_card_bank.dart';

RxBool loadingBankdetails = false.obs;

class GettingDataScreen extends StatefulWidget {
  @override
  State<GettingDataScreen> createState() => _GettingDataScreenState();
}

class _GettingDataScreenState extends State<GettingDataScreen> {

   

   @override
  void initState() {
    super.initState();
    loadingBankdetails.value = false;
    CardDueController().LinkBankData();
  }



  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFF7F7FA),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              CustomStepper(activeStep: 2),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                   pushnameToRoute(context,CardDueCarousel());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      svgIconPath.loading_google2,
                      width: w /1.1,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(height: 40),
                    Text(
                      "We are getting your data",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF37344F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 40),
                 Obx(()=>  !loadingBankdetails.value ?Loader():
                   InkWell(
                    onTap: () => pushnameToRoute(context,CardDueCarousel()),
                    child: Icon(Icons.check_circle, color: Colors.green, size: 50))),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}