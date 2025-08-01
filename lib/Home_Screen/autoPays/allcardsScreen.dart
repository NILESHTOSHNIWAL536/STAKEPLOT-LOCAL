import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/cardWidget.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:get/get.dart';


class AllCardsScreen extends StatelessWidget {
  final RxList<CardData> cards;
  final RxMap<String, bool> toggleStates;
  final Function(String, bool) onToggleChanged;
  final Function(String) onSetReminder;
  final Function() onDataChanged;
  const AllCardsScreen({
    required this.cards,
    required this.toggleStates,
    required this.onToggleChanged,
    required this.onSetReminder,
    required this.onDataChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontScale = screenSize.width / 375;
    final verticalPadding = screenSize.height * 0.015;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "PayCycles",
          style: TextStyle(fontSize: 20 * fontScale),
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04, vertical: 8.0),
          child: Obx(() => cards.isEmpty
              ? Center(
                  child: Text(
                    "No paycycles available",
                    style: TextStyle(color: Colors.white, fontSize: 16 * fontScale),
                  ),
                )
              : ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, i) => Padding(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding),
                    child: CardWidget(
                      card: cards[i],
                      toggleStates: toggleStates,
                      onToggleChanged: onToggleChanged,
                      onSetReminder: onSetReminder,
                      onDataChanged: onDataChanged,
                      parentContext: context,
                      index: i,
                    ),
                  ),
                )),
        ),
      ),
    );
  }
}

class CustomNeumorphicContainer extends StatelessWidget {
  final double width;
  final double height;

  const CustomNeumorphicContainer({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SvgShapeClipper(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF4B4D73),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              offset: const Offset(-4, -4),
              blurRadius: 14,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              offset: const Offset(4, 4),
              blurRadius: 14,
              spreadRadius: 20,
            ),
          ],
        ),
        child: Center(
            child: Text(
          'PayCycles',
          textAlign: TextAlign.center,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w600,
            fontSize: 22,
            color: AppColors.backgroundColor,
          ),
        )),
      ),
    );
  }
}

class SvgShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.035, size.height * 0.01);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.1,
      size.width * 0.65,
      size.height * 0.1,
      size.width,
      0,
    );
    path.lineTo(size.width, size.height - 10);
    path.quadraticBezierTo(size.width, size.height, size.width - 10, size.height);
    path.lineTo(10, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 10);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}