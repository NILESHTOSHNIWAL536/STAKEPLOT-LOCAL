import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';

class BankSlider extends StatelessWidget {
const BankSlider({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
        height:  MediaQuery.of(context).size.height/2.5,
        width: MediaQuery.of(context).size.width/1.1,
      child: ListView(
        scrollDirection: Axis.horizontal,
          children: [
                getSliderContainer(context),
                getSliderContainer(context),
                getSliderContainer(context),
          ],
      ),
    );
  }

  Widget getSliderContainer(context){
     return Container(
       height:  MediaQuery.of(context).size.height/2.5,
        width: MediaQuery.of(context).size.width/1.1,
        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        decoration: BoxDecoration(
           color: Colorcodes.greyLight,
           borderRadius: BorderRadius.circular(20),
        ),
     );
  }
}