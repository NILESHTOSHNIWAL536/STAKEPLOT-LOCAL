
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';

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
  final List<String> destinations = [
    "Paris",
    "New York",
    "Tokyo",
    "Sydney",
    "London"
  ];
  final List<String> accommodations = [
    "Hotel",
    "Hostel",
    "Airbnb",
    "Resort",
    "Guesthouse"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 4, right: 4, top: 0, bottom: 15),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // textStyle(
          //     context: context,
          //     text: "Start Calculation",
          //     fontWeight: FontWeight.bold,
          //     fontsize: 22,
          //     c: AppColors.backgroundColor),
          // Padding(
          //   padding: EdgeInsets.only(top: Colorcodes.paddingSize / 4),
          //   child: Divider(color: Colorcodes.greyLight),
          // ),
          widget.title == "Trip" ? tripDropDown() : SizedBox.shrink(),
          getListOfSliders(widget.slidersList),
          widget.title == "Cars" ? getBrandsOfCars() : SizedBox.shrink(),
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
              fontWeight: FontWeight.w300,
              fontsize: 16,
              c: AppColors.accentColor),
        ),
        SizedBox(
          width: 100,
          height: 40,
          child: TextField(
            controller: data['controller'],
            keyboardType:
                TextInputType.numberWithOptions(decimal: isFloatField),
            inputFormatters: [
              isFloatField
                  ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            style: FontManager().getTextStyle(
              context,

              color: AppColors.backgroundColor, // Change this to your desired color
              fontSize: 16, // Optional: change font size
              lWeight: FontWeight.w500, // Optional: make it bolder/lighter
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixText: data['flag'] ? data['symbol'] : null,
              prefixStyle: FontManager().getTextStyle(
                context,
                color: AppColors.backgroundColor,
              ),
              suffixText: data['flag'] ? null : data['symbol'],
              suffixStyle: FontManager().getTextStyle(
                context,
                color: AppColors.backgroundColor,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.amtCal)),
              filled: true,
              fillColor: AppColors.amtCal,
            ),
            onSubmitted: (value) {
              double? newValue = double.tryParse(value);
              double min = data['min'];
              double max = data['max'];
              if (newValue != null) {
                if (newValue < min || newValue > max) {
                  snackBarCalledfail(
                    context,
                    "${data['name']} must be between $min and $max",
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
        divisions:
            isFloatField ? ((data['max'] - data['min']) * 10).toInt() : 100,
        label: isFloatField
            ? data['value'].toStringAsFixed(1)
            : data['value'].toStringAsFixed(0),
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
        Text(
          "Select Travel Destination:",
          style: FontManager().getTextStyle(
            context,
            color: AppColors.backgroundColor,
            fontSize: 16,
            lWeight: FontWeight.w500,
          ),
        ),
        DropdownButton<String>(
          value: selectedDestination,
          style: FontManager().getTextStyle(
            context,
            color: AppColors.backgroundColor,
            fontSize: 16,
            lWeight: FontWeight.w500,
          ),
          items: destinations.map((String destination) {
            return DropdownMenuItem<String>(
                value: destination, child: Text(destination));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedDestination = newValue!;
            });
          },
        ),
        const SizedBox(height: 20),
        Text(
          "Accommodation Type:",
          style: FontManager().getTextStyle(
            context,
            color: AppColors.backgroundColor,
            fontSize: 16,
            lWeight: FontWeight.w500,
          ),
        ),
        DropdownButton<String>(
          value: selectedAccommodation,
          style: FontManager().getTextStyle(
            context,
            color: AppColors.backgroundColor,
            fontSize: 16,
            lWeight: FontWeight.w500,
          ),
          items: accommodations.map((String accommodation) {
            return DropdownMenuItem<String>(
                value: accommodation, child: Text(accommodation));
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
    List maintenanceCostMap = [
      'Toyota',
      'Honda',
      'Hyundai',
      'Mahindra',
      'Tata',
      'Jeep'
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textStyle(
            context: context,
            text: "Select car brand",
            fontWeight: FontWeight.w400,
            fontsize: 17,
            c: AppColors.backgroundColor),
        SizedBox(height: Colorcodes.paddingSize),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children:
              maintenanceCostMap.map((element) => getCard(element)).toList(),
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
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppColors.backgroundColor),
        child: textStyle(
          c: selectedBrand == e ? Colorcodes.black : Colorcodes.greyLight,
          context: context,
          text: e,
          fontWeight: FontWeight.w500,
          fontsize: 16,
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
  return Text(text,
      style: TextStyle(
          fontWeight: fontWeight,
          fontSize: fontsize,
          color: c ?? AppColors.accentColor));
}
