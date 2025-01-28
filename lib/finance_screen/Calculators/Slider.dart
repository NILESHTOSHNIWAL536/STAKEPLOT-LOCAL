


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';


class SliderPage extends StatefulWidget {
  List slidersList;
  SliderPage({ Key? key,required this.slidersList }) : super(key: key);

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
         margin: EdgeInsets.symmetric(horizontal: 4,vertical: 20),
         padding: EdgeInsets.symmetric(horizontal: 4,vertical: 20),
         width: MediaQuery.of(context).size.width,
         child: Column(
           mainAxisAlignment: MainAxisAlignment.start,
           crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                     textStyle(context: context,text: "Start Calulations",fontWeight: FontWeight.w500,fontsize: 20),
                  
                      Padding(
                        padding:  EdgeInsets.symmetric(vertical: Colorcodes.paddingSize/4),
                        child: Divider(
                           color: Colorcodes.greyLight,
                           endIndent: 20,
                           indent: 20,
                        ),
                      ),

                      getListOfSliders(widget.slidersList),

            ],
         ),
    );
  }


  Widget getListOfSliders(List slidersList){
       return Column(
           children: slidersList.map((e)=>sliderContainer(e)).toList(),
       ); 
  }

  Widget sliderContainer(data){
      return Container(
           child: Column(
              children: [
                       topContainer(data),
                       SizedBox(height: Colorcodes.paddingSize,),
                       buildSlider('label', data['value'], data['min'], data['max'], data['onChanged'])
                       
              ],
           ),
      );
  }

  Widget topContainer(data){
    
    return Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                              textStyle(context: context,text: data['name'],fontWeight: FontWeight.w500,fontsize: 20),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4,vertical: 4),
                                decoration: BoxDecoration(
                                    color:Colorcodes.greyLight,
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                child: textStyle(context: context,text: data['controller'].text,fontWeight: FontWeight.w500,fontsize: 20)
                              ),
                       ],
                     );
  }


}



Widget  buildSlider(String label, double value, double min, double max,Function(double) onChanged) {

     return   Slider(
          value: value,
          min: min,
          max: max,
          divisions: 100,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
          inactiveColor: AppColors.uncoloredPie,
    );
}