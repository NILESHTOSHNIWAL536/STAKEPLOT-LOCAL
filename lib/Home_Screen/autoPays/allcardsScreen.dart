// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/cardWidget.dart';
// import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
// import 'package:get/get.dart';


// class AllCardsScreen extends StatelessWidget {
//   final RxList<CardData> cards;
//   final RxMap<String, bool> toggleStates;
//   final Function(String, bool) onToggleChanged;
//   final Function(String) onSetReminder;
//   final Function() onDataChanged;
//   const AllCardsScreen({
//     required this.cards,
//     required this.toggleStates,
//     required this.onToggleChanged,
//     required this.onSetReminder,
//     required this.onDataChanged,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final fontScale = screenSize.width / 375;
//     final verticalPadding = screenSize.height * 0.015;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "PayCycles",
//           style: TextStyle(fontSize: 20 * fontScale),
//         ),
//         backgroundColor: AppColors.backgroundColor,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04, vertical: 8.0),
//           child: Obx(() => cards.isEmpty
//               ? Center(
//                   child: Text(
//                     "No paycycles available",
//                     style: TextStyle(color: Colors.white, fontSize: 16 * fontScale),
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: cards.length,
//                   itemBuilder: (context, i) => Padding(
//                     padding: EdgeInsets.symmetric(vertical: verticalPadding),
//                     child: CardWidget(
//                       card: cards[i],
//                       toggleStates: toggleStates,
//                       onToggleChanged: onToggleChanged,
//                       onSetReminder: onSetReminder,
//                       onDataChanged: onDataChanged,
//                       parentContext: context,
//                       index: i,
//                     ),
//                   ),
//                 )),
//         ),
//       ),
//     );
//   }
// }


import 'package:carousel_slider/carousel_slider.dart';
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
    final cardWidth = screenSize.width * 0.85;

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
          child: Obx(() {
            // Group non-active cards by title (case-insensitive)
            final Map<String, List<CardData>> groupedCards = {};
            for (var card in cards) {
              if (!card.isActive) {
                final titleLower = card.title.toLowerCase();
                groupedCards[titleLower] = groupedCards[titleLower] ?? [];
                groupedCards[titleLower]!.add(card);
              }
            }

            // Separate cards: active cards, non-active single cards, and carousel groups
            final List<CardData> activeCards = [];
            final List<CardData> nonActiveSingleCards = [];
            final List<List<CardData>> carouselGroups = [];
            for (var card in cards) {
              final titleLower = card.title.toLowerCase();
              if (card.isActive) {
                activeCards.add(card);
              } else if (groupedCards[titleLower]!.length < 2) {
                nonActiveSingleCards.add(card);
              } else if (!carouselGroups.any((group) => group.any((c) => c.title.toLowerCase() == titleLower))) {
                carouselGroups.add(groupedCards[titleLower]!);
              }
            }

            // Combine lists: non-active single cards, then carousel groups, then active cards
            final totalItems = nonActiveSingleCards.length + carouselGroups.length + activeCards.length;
            int globalIndex = 0;

            return cards.isEmpty
                ? Center(
                    child: Text(
                      "No paycycles available",
                      style: TextStyle(color: Colors.white, fontSize: 16 * fontScale),
                    ),
                  )
                : ListView.builder(
                    itemCount: totalItems,
                    itemBuilder: (context, index) {
                      if (index < nonActiveSingleCards.length) {
                        // Render non-active single cards
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: verticalPadding / 1.4,
                            horizontal: screenSize.width * 0.075,
                          ),
                          child: SizedBox(
                            width: cardWidth,
                            child: CardWidget(
                              card: nonActiveSingleCards[index],
                              toggleStates: toggleStates,
                              onToggleChanged: onToggleChanged,
                              onSetReminder: onSetReminder,
                              onDataChanged: onDataChanged,
                              parentContext: context,
                              index: globalIndex++,
                            ),
                          ),
                        );
                      } else if (index < nonActiveSingleCards.length + carouselGroups.length) {
                        // Render carousel for grouped non-active cards
                        final groupIndex = index - nonActiveSingleCards.length;
                        final group = carouselGroups[groupIndex];
                        final currentPage = ValueNotifier<int>(0);

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: verticalPadding),
                          child: Column(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: screenSize.height * 0.2,
                                  enlargeCenterPage: true,
                                  enableInfiniteScroll: false,
                                  autoPlay: false,
                                  viewportFraction: 0.85,
                                  onPageChanged: (index, reason) {
                                    currentPage.value = index;
                                  },
                                ),
                                items: group.map((card) {
                                  return SizedBox(
                                    width: cardWidth,
                                    child: CardWidget(
                                      card: card,
                                      toggleStates: toggleStates,
                                      onToggleChanged: onToggleChanged,
                                      onSetReminder: onSetReminder,
                                      onDataChanged: onDataChanged,
                                      parentContext: context,
                                      index: globalIndex++,
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (group.length >= 2)
                                Padding(
                                  padding: EdgeInsets.only(top: 5 * fontScale),
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: currentPage,
                                    builder: (context, pageIndex, _) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(group.length, (dotIndex) {
                                          return Container(
                                            width: pageIndex == dotIndex ? 5 * fontScale : 5 * fontScale,
                                            height: pageIndex == dotIndex ? 5 * fontScale : 5 * fontScale,
                                            margin: EdgeInsets.symmetric(horizontal: 2 * fontScale),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: pageIndex == dotIndex
                                                  ? AppColors.primaryColor
                                                  : AppColors.accentColor.withOpacity(0.4),
                                            ),
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      } else {
                        // Render active cards at the bottom
                        final activeIndex = index - (nonActiveSingleCards.length + carouselGroups.length);
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: verticalPadding / 1.4,
                            horizontal: screenSize.width * 0.075,
                          ),
                          child: SizedBox(
                            width: cardWidth,
                            child: CardWidget(
                              card: activeCards[activeIndex],
                              toggleStates: toggleStates,
                              onToggleChanged: onToggleChanged,
                              onSetReminder: onSetReminder,
                              onDataChanged: onDataChanged,
                              parentContext: context,
                              index: globalIndex++,
                            ),
                          ),
                        );
                      }
                    },
                  );
          }),
        ),
      ),
    );
  }
}