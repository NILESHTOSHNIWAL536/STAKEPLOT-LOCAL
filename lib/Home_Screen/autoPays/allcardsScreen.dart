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
