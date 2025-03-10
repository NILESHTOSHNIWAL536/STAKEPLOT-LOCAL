// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // For input formatters
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';

// String selectedDestination = "Paris";
// String selectedAccommodation = "Hotel";

// class SliderPage extends StatefulWidget {
//   List slidersList;
//   String title = "";
//   final Function(int, double) onSliderValueChanged;
//   final Function(String)? onAccommodationChanged;
//   SliderPage({
//     Key? key,
//     required this.slidersList,
//     required this.onSliderValueChanged,
//     this.onAccommodationChanged,
//     this.title = "",
//   }) : super(key: key);

//   @override
//   _SliderPageState createState() => _SliderPageState();
// }

// class _SliderPageState extends State<SliderPage> {
//   final List<String> destinations = [
//     "Paris",
//     "New York",
//     "Tokyo",
//     "Sydney",
//     "London"
//   ];
//   final List<String> accommodations = [
//     "Hotel",
//     "Hostel",
//     "Airbnb",
//     "Resort",
//     "Guesthouse"
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(left: 4, right: 4, top: 0, bottom: 15),
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         color: AppColors.mt,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           textStyle(
//             context: context,
//             text: "Start Calculation",
//             fontWeight: FontWeight.bold,
//             fontsize: 22,
//           ),
//           Padding(
//             padding: EdgeInsets.only(top: Colorcodes.paddingSize / 4),
//             child: Divider(color: Colorcodes.greyLight),
//           ),
//           widget.title == "Trip" ? tripDropDown() : SizedBox.shrink(),
//           getListOfSliders(widget.slidersList),
//           widget.title == "Cars" ? getBrandsOfCars() : SizedBox.shrink(),
//         ],
//       ),
//     );
//   }

//   Widget getListOfSliders(List slidersList) {
//     return Column(
//       children: slidersList
//           .asMap()
//           .entries
//           .map((entry) => sliderContainer(entry.value, entry.key))
//           .toList(),
//     );
//   }

//   Widget sliderContainer(data, int index) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 6),
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Column(
//         children: [
//           topContainer(data, index),
//           SizedBox(height: Colorcodes.paddingSize / 3),
//           buildSlider('label', data['value'], data['min'], data['max'],
//               data['onChanged'], index),
//         ],
//       ),
//     );
//   }

//    Widget topContainer(data, int index) {
//     // Determine if this is the interest rate slider
//     bool isInterestRate = data['name'] == "Interest rate(%)";

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 2,
//           child: textStyle(
//             context: context,
//             text: data['name'],
//             fontWeight: FontWeight.w400,
//             fontsize: 14,
//           ),
//         ),
//         SizedBox(
//           width: 100, // Adjust width as needed
//           child: TextField(
//             controller: data['controller'],
//             keyboardType: TextInputType.numberWithOptions(decimal: isInterestRate),
//             inputFormatters: [
//               isInterestRate
//                   ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
//                   : FilteringTextInputFormatter.digitsOnly,
//             ],
//             textAlign: TextAlign.center,
//             decoration: InputDecoration(
//               prefixText: data['flag'] ? data['symbol'] : null,
//               suffixText: data['flag'] ? null : data['symbol'],
//               contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               filled: true,
//               fillColor: Colorcodes.greyLight,
//             ),
//             onChanged: (value) {
//               double? newValue = double.tryParse(value);
//               if (newValue != null) {
//                 widget.onSliderValueChanged(index, newValue);
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildSlider(String label, double value, double min, double max,
//       Function(double) onChanged, int index) {
//     // Adjust display precision for interest rate
//     bool isInterestRate = widget.slidersList[index]['name'] == "Interest rate(%)";
    
//     return SliderTheme(
//       data: SliderTheme.of(context).copyWith(
//         thumbColor: AppColors.primaryColor,
//         overlayColor: AppColors.backgroundColor,
//         activeTrackColor: AppColors.primaryColor,
//         inactiveTrackColor: AppColors.uncoloredPie,
//         thumbShape: RoundSliderThumbShape(enabledThumbRadius: 11),
//         overlayShape: RoundSliderOverlayShape(overlayRadius: 13),
//       ),
//       child: Slider(
//         value: value,
//         min: min,
//         max: max,
//         divisions: 100,
//         label: isInterestRate ? value.toStringAsFixed(1) : value.toStringAsFixed(0),
//         onChanged: (newValue) {
//           setState(() {
//             widget.slidersList[index]['value'] = newValue;
//             widget.slidersList[index]['controller'].text = 
//                 isInterestRate ? newValue.toStringAsFixed(1) : newValue.toStringAsFixed(0);
//           });
//           widget.onSliderValueChanged(index, newValue);
//         },
//       ),
//     );
//   }

//   Widget tripDropDown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Select Travel Destination:"),
//         DropdownButton<String>(
//           value: selectedDestination,
//           items: destinations.map((String destination) {
//             return DropdownMenuItem<String>(
//               value: destination,
//               child: Text(destination),
//             );
//           }).toList(),
//           onChanged: (String? newValue) {
//             setState(() {
//               selectedDestination = newValue!;
//             });
//           },
//         ),
//         const SizedBox(height: 20),
//         const Text("Accommodation Type:"),
//         DropdownButton<String>(
//           value: selectedAccommodation,
//           items: accommodations.map((String accommodation) {
//             return DropdownMenuItem<String>(
//               value: accommodation,
//               child: Text(accommodation),
//             );
//           }).toList(),
//           onChanged: (String? newValue) {
//             setState(() {
//               selectedAccommodation = newValue!;
//               widget.onAccommodationChanged?.call(newValue!);
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget getBrandsOfCars() {
//     List maintenanceCostMap = [
//       'Toyota',
//       'Honda',
//       'Hyundai',
//       'Mahindra',
//       'Tata',
//       'Jeep',
//     ];

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         textStyle(
//             context: context,
//             text: "Select car brand",
//             fontWeight: FontWeight.w400,
//             fontsize: 17),
//         SizedBox(
//           height: Colorcodes.paddingSize,
//         ),
//         Wrap(
//           spacing: 9,
//           runSpacing: 9,
//           children:
//               maintenanceCostMap.map((element) => getCard(element)).toList(),
//         ),
//       ],
//     );
//   }

//   Widget getCard(e) {
//     return InkWell(
//       onTap: () {
//         setState(() {
//           selectedBrand = e;
//         });
//         print(selectedBrand);
//         widget.onSliderValueChanged(5, 12.0);
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(4),
//             color: AppColors.backgroundColor),
//         child: textStyle(
//             c: selectedBrand == e ? Colorcodes.black : Colorcodes.greyLight,
//             context: context,
//             text: e,
//             fontWeight: FontWeight.w500,
//             fontsize: 18),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';

String selectedDestination = "Paris";
String selectedAccommodation = "Hotel";
String selectedBrand = 'Toyota';

class SliderPage extends StatefulWidget {
  List slidersList;
  String title = "";
  final Function(int, double) onSliderValueChanged;
  final Function(String)? onAccommodationChanged;
  SliderPage({
    Key? key,
    required this.slidersList,
    required this.onSliderValueChanged,
    this.onAccommodationChanged,
    this.title = "",
  }) : super(key: key);

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
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textStyle(
            context: context,
            text: "Start Calculation",
            fontWeight: FontWeight.bold,
            fontsize: 22,
          ),
          Padding(
            padding: EdgeInsets.only(top: Colorcodes.paddingSize / 4),
            child: Divider(color: Colorcodes.greyLight),
          ),
          widget.title == "Trip" ? tripDropDown() : SizedBox.shrink(),
          getListOfSliders(widget.slidersList),
          widget.title == "Cars" ? getBrandsOfCars() : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget getListOfSliders(List slidersList) {
    return Column(
      children: slidersList.asMap().entries.map((entry) => sliderContainer(entry.value, entry.key)).toList(),
    );
  }

  Widget sliderContainer(data, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          topContainer(data, index),
          SizedBox(height: Colorcodes.paddingSize / 3),
          buildSlider(data, index),
        ],
      ),
    );
  }

  Widget topContainer(data, int index) {
    bool isFloatField = data['name'] == "Loan Interest Rate" ||
        data['name'] == "Annual maintenance cost" ||
        data['name'] == "Interest rate(%)" ||
        data['name'] == "Annual interest rate(%)" ||
        data['name'] == "Loan interest rate(%)" ||
        data['name'] == "Property tax rate(%)" ||
        data['name'] == "Maintenance Cost (% per year)" ||
        data['name'] == "Home Appreciation Rate (% per year)" ||
        data['name'] == "Rent Increase Rate (% per year)";

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
            fontsize: 14,
          ),
        ),
        SizedBox(
          width: 80,
          height: 40,
          child: TextField(
            controller: data['controller'],
            keyboardType: TextInputType.numberWithOptions(decimal: isFloatField),
            inputFormatters: [
              isFloatField
                  ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixText: data['flag'] ? data['symbol'] : null,
              suffixText: data['flag'] ? null : data['symbol'],
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: AppColors.button,
            ),
            onSubmitted: (value) {
              double? newValue = double.tryParse(value);
              double min = data['min'];
              double max = data['max'];
              if (newValue != null) {
                if (newValue < min || newValue > max) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${data['name']} must be between $min and $max",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  newValue = newValue.clamp(min, max); // Clamp before passing
                }
                if (!isFloatField) {
                  newValue = newValue.roundToDouble();
                }
                widget.onSliderValueChanged(index, newValue);
              } else {
                data['controller'].text = (isFloatField
                    ? data['value'].toStringAsFixed(1)
                    : data['value'].toStringAsFixed(0));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildSlider(data, int index) {
    bool isFloatField = data['name'] == "Loan Interest Rate" ||
        data['name'] == "Annual maintenance cost" ||
        data['name'] == "Interest rate(%)" ||
        data['name'] == "Annual interest rate(%)" ||
        data['name'] == "Loan interest rate(%)" ||
        data['name'] == "Property tax rate(%)" ||
        data['name'] == "Maintenance Cost (% per year)" ||
        data['name'] == "Home Appreciation Rate (% per year)" ||
        data['name'] == "Rent Increase Rate (% per year)";

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbColor: AppColors.primaryColor,
        overlayColor: AppColors.backgroundColor,
        activeTrackColor: AppColors.primaryColor,
        inactiveTrackColor: AppColors.uncoloredPie,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 11),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 13),
      ),
      child: Slider(
        value: data['value'],
        min: data['min'],
        max: data['max'],
        divisions: isFloatField ? ((data['max'] - data['min']) * 10).toInt() : 100,
        label: isFloatField ? data['value'].toStringAsFixed(1) : data['value'].toStringAsFixed(0),
        onChanged: (newValue) {
          widget.onSliderValueChanged(index, newValue);
        },
      ),
    );
  }

  Widget tripDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Travel Destination:"),
        DropdownButton<String>(
          value: selectedDestination,
          items: destinations.map((String destination) {
            return DropdownMenuItem<String>(value: destination, child: Text(destination));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() { selectedDestination = newValue!; });
          },
        ),
        const SizedBox(height: 20),
        const Text("Accommodation Type:"),
        DropdownButton<String>(
          value: selectedAccommodation,
          items: accommodations.map((String accommodation) {
            return DropdownMenuItem<String>(value: accommodation, child: Text(accommodation));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedAccommodation = newValue!;
              widget.onAccommodationChanged?.call(newValue!);
            });
          },
        ),
      ],
    );
  }

  Widget getBrandsOfCars() {
    List maintenanceCostMap = ['Toyota', 'Honda', 'Hyundai', 'Mahindra', 'Tata', 'Jeep'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textStyle(context: context, text: "Select car brand", fontWeight: FontWeight.w400, fontsize: 17),
        SizedBox(height: Colorcodes.paddingSize),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: maintenanceCostMap.map((element) => getCard(element)).toList(),
        ),
      ],
    );
  }

  Widget getCard(e) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedBrand = e;
          widget.onSliderValueChanged(5, 12.0);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: AppColors.backgroundColor),
        child: textStyle(
          c: selectedBrand == e ? Colorcodes.black : Colorcodes.greyLight,
          context: context,
          text: e,
          fontWeight: FontWeight.w500,
          fontsize: 18,
        ),
      ),
    );
  }
}

Widget textStyle({
  required BuildContext context,
  required String text,
  FontWeight fontWeight = FontWeight.normal,
  double fontsize = 16,
  Color? c,
}) {
  return Text(text, style: TextStyle(fontWeight: fontWeight, fontSize: fontsize, color: c ?? Colors.black));
}