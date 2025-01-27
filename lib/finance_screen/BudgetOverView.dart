
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:get/get.dart';


class BudgetOverView extends StatefulWidget {
 String amount;
 String name;
 String period;
 BudgetOverView({ Key? key,required this.amount,required this.name,required this.period }) : super(key: key);


  @override
  _BudgetOverViewState createState() => _BudgetOverViewState();
}

class _BudgetOverViewState extends State<BudgetOverView> {
 
  @override
  Widget build(BuildContext context) 
  {
    double height =MediaQuery.of(context).size.height;
    double width =MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
       
        body: getBudgetUiScreen(height,width),
        bottomNavigationBar: BottomNavigations(data: 1),
      ),
    );
  }



 Widget getBudgetUiScreen(height,width){
     
     return Container(
      width:  width,
      height: height/1.1,
      padding: EdgeInsets.symmetric(horizontal: 20,),
      decoration: BoxDecoration(
         color: AppColors.backgroundColor
      ),
       child: Column(
           mainAxisAlignment: MainAxisAlignment.start,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              SizedBox(height: Colorcodes.paddingSize,),
                 textStyle(
                   context: context,
                   text: "Budget Categories",
                   fontsize: 20,
                   fontWeight: FontWeight.bold
                ),
                              
               SizedBox(height: Colorcodes.paddingSize/2,),

              

                InkWell(
                  onTap: (){
                        //  bedgetCalculator();
                  },
                  child: getButton(context, "Continue")
                ),
           ],
       ),
     );
 }
}