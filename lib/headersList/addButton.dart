import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';


class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  bool flag;
  AddButton({ Key? key ,required this.onPressed,this.flag=true}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Padding(
                                  padding:  EdgeInsets.symmetric(vertical:Colorcodes.paddingSize ),
                                  child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:  EdgeInsets.symmetric(horizontal: Colorcodes.paddingHorizontal),
                                        child: InkWell(
                                          onTap: onPressed,
                                        //   onTap: (){
                                        //        Navigator.push(
                                        //               context,
                                        //               PageTransition(
                                        //                 type: PageTransitionType.bottomToTop,
                                        //                 alignment: Alignment.bottomRight,
                                        //                 duration: Durations.long1,
                                  
                                        //                 child:const AddBudget(),
                                        //                 isIos: true,
                                        //               ),
                                        //  );
                                          // },
                                  
                                          child: Container(
                                             
                                             decoration: BoxDecoration(
                                                color: Colorcodes.budgetDarkGreen,
                                                borderRadius: BorderRadius.circular(10)
                                          
                                             ),
                                            padding: EdgeInsets.all(4),
                                            child: Icon(flag?Icons.add:Icons.edit,color: Colorcodes.black,)
                                          ),
                                        ),
                                      ),
                                  ),
                                );
  }
}