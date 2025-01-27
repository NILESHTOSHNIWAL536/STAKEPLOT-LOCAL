import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/BudgetOverView.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:get/get.dart';
// import 'package:getwidget/getwidget.dart';


class BudgetSearch extends StatefulWidget {
  String amount;
  String name;
  String period;
 BudgetSearch({ Key? key,required this.amount,required this.name,required this.period }) : super(key: key);

  @override
  _BudgetSearchState createState() => _BudgetSearchState();
}

class _BudgetSearchState extends State<BudgetSearch> {
  TextEditingController nameController= TextEditingController(text: "");
  @override
  Widget build(BuildContext context) {
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
       child: SingleChildScrollView(
         child: Expanded(
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
                   searchList(width,height),
                    SizedBox(height: Colorcodes.paddingSize,),
              
                     Obx(()=> getCategories.value? getListOfCat():getListOfCat()),
           
                    SizedBox(height: Colorcodes.paddingSize,),
           
                    InkWell(
                      onTap: (){
                             Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BudgetOverView(amount:widget.amount, name: widget.name, period: widget.period),
                          ),
                        );  
                      },
                      child: getButton(context, "Continue")
                    ),
               ],
           ),
         ),
       ),
     );
 }

 Widget getListOfCat(){
  return Container(
    width: MediaQuery.of(context).size.width,
    child:  Wrap(
      spacing: 8.0, // Adjust spacing between items
      runSpacing: 8.0, // Adjust spacing between lines
                      children: categoriesSeleted.map((name){
                        return   getUipartOfCatero(context,name.toString());
                    }).toList(),
             ),
  );
 }


Widget getUipartOfCatero(BuildContext context,String name){
  return Container(
         padding: EdgeInsets.symmetric(horizontal: 5,vertical: 7),
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(4),
            color: Colorcodes.white,
         ),
         child: Row(
           mainAxisSize: MainAxisSize.min,
            children: [
                   textStyle(context: context,text: toUpperCase(name.toString()),fontsize: 16),
                   const SizedBox(width: 10,),
                   InkWell(
                      onTap: (){
                             categoriesSeleted.remove(name);
                             getCategories.value=!getCategories.value;
                      },
                      child: Icon(Icons.close,color: AppColors.primaryColor,size: 20,),
                   ),
  
            ],
         ),
         
    );
}

 Widget searchList(double width,double height){
    return Container(
      width: width/1.1,
      child: Column(
          children: [
                TextFeildWidgetCustom
                (
                    textEditingController: nameController,
                    heading: "Name",
                    keyBoard: TextInputType.emailAddress,
                    lableText: "Enter the name",
                    icon: ProfileIcons.friends,
                    flag: false,
                ),

                
          ],
      ),
    );
}


}