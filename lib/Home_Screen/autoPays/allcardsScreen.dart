// import 'package:carousel_slider/carousel_slider.dart';
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
//     final cardWidth = screenSize.width * 0.85;

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
//           child: Obx(() {
//             // Group non-active cards by title (case-insensitive)
//             final Map<String, List<CardData>> groupedCards = {};
//             for (var card in cards) {
//               if (!card.isActive) {
//                 final titleLower = card.title.toLowerCase();
//                 groupedCards[titleLower] = groupedCards[titleLower] ?? [];
//                 groupedCards[titleLower]!.add(card);
//               }
//             }

//             // Separate cards: active cards, non-active single cards, and carousel groups
//             final List<CardData> activeCards = [];
//             final List<CardData> nonActiveSingleCards = [];
//             final List<List<CardData>> carouselGroups = [];
//             for (var card in cards) {
//               final titleLower = card.title.toLowerCase();
//               if (card.isActive) {
//                 activeCards.add(card);
//               } else if (groupedCards[titleLower]!.length < 2) {
//                 nonActiveSingleCards.add(card);
//               } else if (!carouselGroups.any((group) => group.any((c) => c.title.toLowerCase() == titleLower))) {
//                 carouselGroups.add(groupedCards[titleLower]!);
//               }
//             }

//             // Combine lists: non-active single cards, then carousel groups, then active cards
//             final totalItems = nonActiveSingleCards.length + carouselGroups.length + activeCards.length;
//             int globalIndex = 0;

//             return cards.isEmpty
//                 ? Center(
//                     child: Text(
//                       "No paycycles available",
//                       style: TextStyle(color: Colors.white, fontSize: 16 * fontScale),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: totalItems,
//                     itemBuilder: (context, index) {
//                       if (index < nonActiveSingleCards.length) {
//                         // Render non-active single cards
//                         return Padding(
//                           padding: EdgeInsets.symmetric(
//                             vertical: verticalPadding / 1.4,
//                             horizontal: screenSize.width * 0.075,
//                           ),
//                           child: SizedBox(
//                             width: cardWidth,
//                             child: CardWidget(
//                               card: nonActiveSingleCards[index],
//                               toggleStates: toggleStates,
//                               onToggleChanged: onToggleChanged,
//                               onSetReminder: onSetReminder,
//                               onDataChanged: onDataChanged,
//                               parentContext: context,
//                               index: globalIndex++,
//                             ),
//                           ),
//                         );
//                       } else if (index < nonActiveSingleCards.length + carouselGroups.length) {
//                         // Render carousel for grouped non-active cards
//                         final groupIndex = index - nonActiveSingleCards.length;
//                         final group = carouselGroups[groupIndex];
//                         final currentPage = ValueNotifier<int>(0);

//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: verticalPadding),
//                           child: Column(
//                             children: [
//                               CarouselSlider(
//                                 options: CarouselOptions(
//                                   height: screenSize.height * 0.2,
//                                   enlargeCenterPage: true,
//                                   enableInfiniteScroll: false,
//                                   autoPlay: false,
//                                   viewportFraction: 0.85,
//                                   onPageChanged: (index, reason) {
//                                     currentPage.value = index;
//                                   },
//                                 ),
//                                 items: group.map((card) {
//                                   return SizedBox(
//                                     width: cardWidth,
//                                     child: CardWidget(
//                                       card: card,
//                                       toggleStates: toggleStates,
//                                       onToggleChanged: onToggleChanged,
//                                       onSetReminder: onSetReminder,
//                                       onDataChanged: onDataChanged,
//                                       parentContext: context,
//                                       index: globalIndex++,
//                                     ),
//                                   );
//                                 }).toList(),
//                               ),
//                               if (group.length >= 2)
//                                 Padding(
//                                   padding: EdgeInsets.only(top: 5 * fontScale),
//                                   child: ValueListenableBuilder<int>(
//                                     valueListenable: currentPage,
//                                     builder: (context, pageIndex, _) {
//                                       return Row(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: List.generate(group.length, (dotIndex) {
//                                           return Container(
//                                             width: pageIndex == dotIndex ? 5 * fontScale : 5 * fontScale,
//                                             height: pageIndex == dotIndex ? 5 * fontScale : 5 * fontScale,
//                                             margin: EdgeInsets.symmetric(horizontal: 2 * fontScale),
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               color: pageIndex == dotIndex
//                                                   ? AppColors.primaryColor
//                                                   : AppColors.accentColor.withOpacity(0.4),
//                                             ),
//                                           );
//                                         }),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         );
//                       } else {
//                         // Render active cards at the bottom
//                         final activeIndex = index - (nonActiveSingleCards.length + carouselGroups.length);
//                         return Padding(
//                           padding: EdgeInsets.symmetric(
//                             vertical: verticalPadding / 1.4,
//                             horizontal: screenSize.width * 0.075,
//                           ),
//                           child: SizedBox(
//                             width: cardWidth,
//                             child: CardWidget(
//                               card: activeCards[activeIndex],
//                               toggleStates: toggleStates,
//                               onToggleChanged: onToggleChanged,
//                               onSetReminder: onSetReminder,
//                               onDataChanged: onDataChanged,
//                               parentContext: context,
//                               index: globalIndex++,
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                   );
//           }),
//         ),
//       ),
//     );
//   }
// }

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
//     final cardWidth = screenSize.width * 0.85;

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
//           padding: EdgeInsets.symmetric(
//               horizontal: screenSize.width * 0.002, vertical: 8.0),
//           child: Obx(() {
//             // Group non-active cards by title (case-insensitive)
//             final Map<String, List<CardData>> groupedCards = {};
//             for (var card in cards) {
//               if (!card.isActive) {
//                 final titleLower = card.title.toLowerCase();
//                 groupedCards[titleLower] = groupedCards[titleLower] ?? [];
//                 groupedCards[titleLower]!.add(card);
//               }
//             }

//             // Select the latest card from each non-active group (assuming last in list is latest)
//             final List<CardData> nonActiveLatestCards = [];
//             groupedCards.forEach((title, cardList) {
//               if (cardList.isNotEmpty) {
//                 nonActiveLatestCards
//                     .add(cardList.last); // Use last card as latest
//               }
//             });

//             // Get active cards
//             final List<CardData> activeCards =
//                 cards.where((card) => card.isActive).toList();

//             // Combine lists: non-active latest cards, then active cards
//             final totalItems = nonActiveLatestCards.length + activeCards.length;
//             int globalIndex = 0;

//             return cards.isEmpty
//                 ? Center(
//                     child: Text(
//                       "No paycycles available",
//                       style: TextStyle(
//                           color: Colors.white, fontSize: 16 * fontScale),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: totalItems,
//                     itemBuilder: (context, index) {
//                       if (index < nonActiveLatestCards.length) {
//                         // Render latest non-active card for each group
//                         final card = nonActiveLatestCards[index];
//                         final titleLower = card.title.toLowerCase();
//                         final hasSimilarCards =
//                             groupedCards[titleLower]!.length > 1;

//                         return Padding(
//                           padding: EdgeInsets.symmetric(
//                             vertical: verticalPadding / 1.4,
//                             horizontal: screenSize.width * 0.075,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               SizedBox(
//                                 width: cardWidth,
//                                 child: CardWidget(
//                                   card: card,
//                                   toggleStates: toggleStates,
//                                   onToggleChanged: onToggleChanged,
//                                   onSetReminder: onSetReminder,
//                                   onDataChanged: onDataChanged,
//                                   parentContext: context,
//                                   index: globalIndex++,
//                                 ),
//                               ),
//                               if (hasSimilarCards)
//                                 Padding(
//                                   padding:
//                                       EdgeInsets.only(top: 2.0, right: 8.0),
//                                   child: TextButton(
//                                     onPressed: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               SimilarCardsScreen(
//                                             cards: groupedCards[titleLower]!,
//                                             toggleStates: toggleStates,
//                                             onToggleChanged: onToggleChanged,
//                                             onSetReminder: onSetReminder,
//                                             onDataChanged: onDataChanged,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Text(
//                                       'View Similar Cards',
//                                       style: TextStyle(
//                                         color: AppColors.primaryColor,
//                                         fontSize: 14 * fontScale,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         );
//                       } else {
//                         // Render active cards at the bottom
//                         final activeIndex = index - nonActiveLatestCards.length;
//                         return Padding(
//                           padding: EdgeInsets.symmetric(
//                             vertical: verticalPadding / 1.4,
//                             horizontal: screenSize.width * 0.075,
//                           ),
//                           child: SizedBox(
//                             width: cardWidth,
//                             child: CardWidget(
//                               card: activeCards[activeIndex],
//                               toggleStates: toggleStates,
//                               onToggleChanged: onToggleChanged,
//                               onSetReminder: onSetReminder,
//                               onDataChanged: onDataChanged,
//                               parentContext: context,
//                               index: globalIndex++,
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                   );
//           }),
//         ),
//       ),
//     );
//   }
// }

// class SimilarCardsScreen extends StatelessWidget {
//   final List<CardData> cards;
//   final RxMap<String, bool> toggleStates;
//   final Function(String, bool) onToggleChanged;
//   final Function(String) onSetReminder;
//   final Function() onDataChanged;

//   const SimilarCardsScreen({
//     required this.cards,
//     required this.toggleStates,
//     required this.onToggleChanged,
//     required this.onSetReminder,
//     required this.onDataChanged,
//     Key? key,
//   }) : super(key: key);

//   double _calculateAverageAmount() {
//     if (cards.isEmpty) return 0.0;
//     final total = cards.fold<double>(0.0, (sum, card) {
//       final cleaned = card.amount.replaceAll(RegExp(r'[^0-9\.]'), '');
//       final value = double.tryParse(cleaned) ?? 0.0;
//       return sum + value;
//     });
//     return total / cards.length;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final fontScale = screenSize.width / 375;
//     final verticalPadding = screenSize.height * 0.015;
//     final cardWidth = screenSize.width * 0.85;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "${cards[0].title} Cards",
//           style: TextStyle(fontSize: 20 * fontScale),
//         ),
//         backgroundColor: AppColors.backgroundColor,
//       ),
//       body: SafeArea(
//         child: Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: screenSize.width * 0.002, vertical: 8.0),
//             child: Obx(() {
//               return Column(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(16.0 * fontScale),
//                     child: Container(
//                       width: MediaQuery.sizeOf(context).width / 1.6,
//                       padding: EdgeInsets.all(12.0 * fontScale),
//                       decoration: BoxDecoration(
//                           color: Color(0xFFF6F6F6),
//                           borderRadius: BorderRadius.circular(5)),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Average Amount:',
//                             style: FontManager().getTextStyle(
//                               context,
//                               lWeight: FontWeight.w600,
//                               fontSize: 16 * fontScale,
//                               color: Color(0xFF919191),
//                             ),
//                           ),
//                           Text(
//                             ' ${_calculateAverageAmount().toStringAsFixed(1)}',
//                             style: FontManager().getTextStyle(
//                               context,
//                               lWeight: FontWeight.w600,
//                               fontSize: 16 * fontScale,
//                               color: AppColors.primaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: cards.length,
//                       itemBuilder: (context, index) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(
//                             vertical: verticalPadding / 1.4,
//                             horizontal: screenSize.width * 0.075,
//                           ),
//                           child: SizedBox(
//                             width: cardWidth,
//                             child: CardWidget(
//                               card: cards[index],
//                               toggleStates: toggleStates,
//                               onToggleChanged: onToggleChanged,
//                               onSetReminder: onSetReminder,
//                               onDataChanged: onDataChanged,
//                               parentContext: context,
//                               index: index,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               );
//             })),
//       ),
//     );
//   }
// }

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
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05, vertical: 8.0),
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

            // Select the latest card from each non-active group (assuming last in list is latest)
            final List<CardData> nonActiveLatestCards = [];
            groupedCards.forEach((title, cardList) {
              if (cardList.isNotEmpty) {
                nonActiveLatestCards
                    .add(cardList.last); // Use last card as latest
              }
            });

            // Get active cards
            final List<CardData> activeCards =
                cards.where((card) => card.isActive).toList();

            // Combine lists: non-active latest cards, then active cards
            final totalItems = nonActiveLatestCards.length + activeCards.length;
            int globalIndex = 0;

            return cards.isEmpty
                ? Center(
                    child: Text(
                      "No paycycles available",
                      style: TextStyle(
                          color: Colors.white, fontSize: 16 * fontScale),
                    ),
                  )
                : ListView.builder(
                    itemCount: totalItems,
                    itemBuilder: (context, index) {
                      if (index < nonActiveLatestCards.length) {
                        // Render latest non-active card for each group
                        final card = nonActiveLatestCards[index];
                        final titleLower = card.title.toLowerCase();
                        final hasSimilarCards =
                            groupedCards[titleLower]!.length > 1;

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: verticalPadding / 1.4,
                            horizontal: screenSize.width * 0.08,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
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
                              ),
                              if (hasSimilarCards)
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 2.0, right: 2.0),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SimilarCardsScreen(
                                            allCards: cards,
                                            title: card.title,
                                            toggleStates: toggleStates,
                                            onToggleChanged: onToggleChanged,
                                            onSetReminder: onSetReminder,
                                            onDataChanged: onDataChanged,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 14 * fontScale,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      } else {
                        // Render active cards at the bottom
                        final activeIndex = index - nonActiveLatestCards.length;
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

class SimilarCardsScreen extends StatelessWidget {
  final RxList<CardData> allCards;
  final String title;
  final RxMap<String, bool> toggleStates;
  final Function(String, bool) onToggleChanged;
  final Function(String) onSetReminder;
  final Function() onDataChanged;

  const SimilarCardsScreen({
    required this.allCards,
    required this.title,
    required this.toggleStates,
    required this.onToggleChanged,
    required this.onSetReminder,
    required this.onDataChanged,
    Key? key,
  }) : super(key: key);

  double _calculateAverageAmount(List<CardData> cards) {
    if (cards.isEmpty) return 0.0;
    final total = cards.fold<double>(0.0, (sum, card) {
      final cleaned = card.amount.replaceAll(RegExp(r'[^0-9\.]'), '');
      final value = double.tryParse(cleaned) ?? 0.0;
      return sum + value;
    });
    return total / cards.length;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontScale = screenSize.width / 375;
    final verticalPadding = screenSize.height * 0.015;
    final cardWidth = screenSize.width * 0.85;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$title Cards",
          style: TextStyle(fontSize: 20 * fontScale),
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.002, vertical: 8.0),
          child: Obx(() {
            // Filter cards by title (case-insensitive) and exclude active cards
            final filteredCards = allCards
                .where((card) =>
                    card.title.toLowerCase() == title.toLowerCase() &&
                    !card.isActive) // Only include non-active cards
                .toList();

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0 * fontScale),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width / 1.6,
                    padding: EdgeInsets.all(12.0 * fontScale),
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Average Amount:',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w600,
                            fontSize: 16 * fontScale,
                            color: Color(0xFF919191),
                          ),
                        ),
                        Text(
                          ' ${_calculateAverageAmount(filteredCards).toStringAsFixed(1)}',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w600,
                            fontSize: 16 * fontScale,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: filteredCards.isEmpty
                      ? Center(
                          child: Text(
                            "No similar cards available",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * fontScale,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCards.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: verticalPadding / 1.4,
                                horizontal: screenSize.width * 0.075,
                              ),
                              child: SizedBox(
                                width: cardWidth,
                                child: CardWidget(
                                  card: filteredCards[index],
                                  toggleStates: toggleStates,
                                  onToggleChanged: onToggleChanged,
                                  onSetReminder: onSetReminder,
                                  onDataChanged: onDataChanged,
                                  parentContext: context,
                                  index: index,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
