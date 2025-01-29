import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
 String selectedDestination = "Paris";
  String selectedAccommodation = "Hotel";
class SliderPage extends StatefulWidget {
  List slidersList;
  String title="";
  final Function(int, double) onSliderValueChanged;
  SliderPage({Key? key, required this.slidersList,required this.onSliderValueChanged,this.title=""}) : super(key: key);

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  

  final List<String> destinations = ["Paris", "New York", "Tokyo", "Sydney", "London"];
  final List<String> accommodations = ["Hotel", "Hostel", "Airbnb", "Resort", "Guesthouse"];
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 4, right: 4, top: 0, bottom: 15),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: AppColors.mt, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textStyle(
              context: context,
              text: "Start Calculation",
              fontWeight: FontWeight.bold,
              fontsize: 22),
          Padding(
            padding: EdgeInsets.only(bottom: Colorcodes.paddingSize / 4),
            child: Divider(
              color: Colorcodes.greyLight,
            ),
          ),

         widget.title=="Trip"?tripDropDown():SizedBox.shrink(),

          getListOfSliders(widget.slidersList),


          widget.title=="Cars"?getBrandsOfCars():SizedBox.shrink(),

        ],
      ),
    );
  }

  Widget getListOfSliders(List slidersList) {
    return Column(
      children: slidersList
          .asMap()
          .entries
          .map((entry) => sliderContainer(entry.value, entry.key))
          .toList(),
    );
  }

  Widget sliderContainer(data, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
       padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          topContainer(data),
          SizedBox(
            height: Colorcodes.paddingSize / 3,
          ),
          buildSlider('label', data['value'], data['min'], data['max'],
              data['onChanged'], index)
        ],
      ),
    );
  }

  Widget topContainer(data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            flex: 2,
            child: textStyle(
                context: context,
                text: data['name'],
                fontWeight: FontWeight.w400,
                fontsize: 14)),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
                color: Colorcodes.greyLight,
                borderRadius: BorderRadius.circular(8)),
            child: textStyle(
                context: context,
                text: data['flag'] ?  data['symbol'] +" "+ data['value'].toStringAsFixed(2).toString() : data['value'].toStringAsFixed(2).toString() +" "+ data['symbol'],
                // text: data['flag'] ?  data['symbol'] +" "+ data['controller'].text : data['controller'].text +" "+ data['symbol'],
                fontWeight: FontWeight.w500,
                fontsize: 13)),
      ],
    );
  }

  Widget buildSlider(String label, double value, double min, double max,
    Function(double) onChanged, int index) {
  return SliderTheme(
    data: SliderTheme.of(context).copyWith(
      // Customize the thumb (overlay) color
      thumbColor: AppColors.primaryColor, // Change to your desired color
      overlayColor: AppColors.backgroundColor, // Change overlay color
      activeTrackColor: AppColors.primaryColor, // Change active track color
      inactiveTrackColor: AppColors.uncoloredPie, // Change inactive track color
      // Customize the size of the thumb
      thumbShape: RoundSliderThumbShape(
        enabledThumbRadius: 11, // Increase or decrease thumb size
      ),
      overlayShape: RoundSliderOverlayShape(
        overlayRadius: 13, // Increase or decrease overlay size
      ),
    ),
    child: Slider(
      value: value,
      min: min,
      max: max,
      divisions: 100,
      label: value.toStringAsFixed(0),
      onChanged: (newValue) {
        setState(() {
          widget.slidersList[index]['value'] = newValue;
          widget.slidersList[index]['controller'].text =
              newValue.toStringAsFixed(0);
        });
          // Call parent callback to update page
          widget.onSliderValueChanged(index, newValue);
      },
    ),
  );
}


Widget tripDropDown(){
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Travel Destination:"),
        DropdownButton<String>(
          value: selectedDestination,
          items: destinations.map((String destination) {
            return DropdownMenuItem<String>(
              value: destination,
              child: Text(destination),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedDestination = newValue!;
            });
          },
        ),
        SizedBox(height: 20),
        Text("Accommodation Type:"),
        DropdownButton<String>(
          value: selectedAccommodation,
          items: accommodations.map((String accommodation) {
            return DropdownMenuItem<String>(
              value: accommodation,
              child: Text(accommodation),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedAccommodation = newValue!;
              
            });
          },
        ),
      ],
    );
}



Widget getBrandsOfCars()
{
   List maintenanceCostMap = [
      'Toyota',
      'Honda',
      'Hyundai',
      'Mahindra',
      'Tata',
      'Jeep',
   ];

   return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
      children: [
               textStyle(
              context: context,
              text: "Select car brand",
              fontWeight: FontWeight.w400,
              fontsize: 17),
              SizedBox(
                  height: Colorcodes.paddingSize,
              ),

              Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: maintenanceCostMap.map((element)=>getCard(element)).toList(),
              ),

      ],
   );
}


Widget getCard(e){
   return InkWell(
     onTap: (){
      setState(() {  
         selectedBrand=e;
      });
      print(selectedBrand);
        widget.onSliderValueChanged(5,12.0);
     },
     child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.backgroundColor
      ),
        child:  textStyle(
                c: selectedBrand==e?Colorcodes.black:Colorcodes.greyLight,
                context: context,
                text: e,
                fontWeight: FontWeight.w500,
                fontsize: 18),
       ),
   );
}


}






