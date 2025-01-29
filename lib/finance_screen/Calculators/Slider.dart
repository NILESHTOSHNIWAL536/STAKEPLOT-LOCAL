// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';

// class SliderPage extends StatefulWidget {
//   List slidersList;
//   SliderPage({Key? key, required this.slidersList}) : super(key: key);

//   @override
//   _SliderPageState createState() => _SliderPageState();
// }

// class _SliderPageState extends State<SliderPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(left: 4, right: 4, top: 0, bottom: 15),
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//           color: AppColors.mt, borderRadius: BorderRadius.circular(20)),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           textStyle(
//               context: context,
//               text: "Start Calulations",
//               fontWeight: FontWeight.bold,
//               fontsize: 22),
//           Padding(
//             padding: EdgeInsets.only(bottom: Colorcodes.paddingSize / 4),
//             child: Divider(
//               color: Colorcodes.greyLight,
//             ),
//           ),
//           getListOfSliders(widget.slidersList),
//         ],
//       ),
//     );
//   }

//   Widget getListOfSliders(List slidersList) {
//     return Column(
//       children: slidersList.map((e) => sliderContainer(e)).toList(),
//     );
//   }

//   Widget sliderContainer(data) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 5),
//       child: Column(
//         children: [
//           topContainer(data),
//           SizedBox(
//             height: Colorcodes.paddingSize / 3,
//           ),
//           buildSlider('label', data['value'], data['min'], data['max'],
//               data['onChanged'])
//         ],
//       ),
//     );
//   }

//   Widget topContainer(data) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//             flex: 2,
//             child: textStyle(
//                 context: context,
//                 text: data['name'],
//                 fontWeight: FontWeight.w500,
//                 fontsize: 17)),
//         Container(
//             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//                 color: Colorcodes.greyLight,
//                 borderRadius: BorderRadius.circular(8)),
//             child: textStyle(
//                 context: context,
//                 text: "₹" + data['controller'].text,
//                 fontWeight: FontWeight.w500,
//                 fontsize: 20)),
//       ],
//     );
//   }
// }

// Widget buildSlider(String label, double value, double min, double max,
//     Function(double) onChanged) {
//   return Slider(
//     value: value,
//     min: min,
//     max: max,
//     divisions: 100,
//     label: value.toStringAsFixed(0),
//     onChanged: onChanged,
//     activeColor: AppColors.primaryColor,
//     inactiveColor: AppColors.uncoloredPie,
//   );
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';

class SliderPage extends StatefulWidget {
  List slidersList;
  final Function(int, double) onSliderValueChanged;
  SliderPage({Key? key, required this.slidersList,required this.onSliderValueChanged}) : super(key: key);

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
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
          getListOfSliders(widget.slidersList),
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
      margin: EdgeInsets.symmetric(vertical: 5),
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
                fontWeight: FontWeight.w500,
                fontsize: 17)),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colorcodes.greyLight,
                borderRadius: BorderRadius.circular(8)),
            child: textStyle(
                context: context,
                text: "₹" + data['controller'].text,
                fontWeight: FontWeight.w500,
                fontsize: 14)),
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
        enabledThumbRadius: 12, // Increase or decrease thumb size
      ),
      overlayShape: RoundSliderOverlayShape(
        overlayRadius: 15, // Increase or decrease overlay size
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
}
