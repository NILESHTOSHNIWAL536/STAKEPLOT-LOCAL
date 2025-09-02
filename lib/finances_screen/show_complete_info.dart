


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../colorcodes.dart';
import 'creditCard_slider.dart';

class ShowCompleteInfo extends StatefulWidget {
   int index=0;
  ShowCompleteInfo({ Key? key,this.index=0 }) : super(key: key);

  @override
  State<ShowCompleteInfo> createState() => _ShowCompleteInfoState();
}

class _ShowCompleteInfoState extends State<ShowCompleteInfo> {
  final List<String> titles = [
    "Credit Card",
    "Budget",
    "Debt",
  ];

  final List<String> routes = [
    "/addcreditCard",
    "/Budget",
    "/debt",
  ];

    final List<String> svgs = [
      svgIconPath.dio1,
      svgIconPath.dio2,
      svgIconPath.dio3,
  ];

  int selectedIndex = 0;

  @override
  void initState()
  {
    super.initState();
    selectedIndex = widget.index;
  }



  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Info"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height/1.1,
        child: Column(
           children: [
             getTabs(context),
             getCardContent()
           ],
         ),
      )
    );
  }


  Widget getCardContent()
  {
    switch (selectedIndex)
    {
      case 0:
        return Expanded(child: CardDueCarousel(flag: false,));
      case 1:
        return Center(child: Text("Create Budget Content"));
      case 2:
        return Center(child: Text("Add Debt Content"));
      default:
        return Center(child: Text("Unknown Content"));
    }
    
  }

  Widget getTabs(BuildContext context) {

  return Row(
    children: [
      const SizedBox(height: 22),
      // Option Buttons
      for (int i = 0; i < routes.length; i++) ...[
        InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () {
            setState(() => selectedIndex = i);
            // Navigator.pushNamed(context, routes[i]);
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 3.4,
            
            decoration: BoxDecoration(
              color: selectedIndex == i ? const Color(0xFF635D8F) : Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: selectedIndex == i
                  ? null
                  : Border.all(color: const Color(0xFF635D8F), width: 1),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 10),
            margin: const EdgeInsets.all(5),
            child: Column(
              children: [
                SvgPicture.asset(
                  svgs[i],
                  width: 32,
                  height: 32,
                  color: selectedIndex == i ? Colors.white : const Color(0xFF635D8F),
                ),
                const SizedBox(height: 4),
                Text(
                  titles[i],
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: selectedIndex == i ? Colors.white : const Color(0xFF37344F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  );
}


}