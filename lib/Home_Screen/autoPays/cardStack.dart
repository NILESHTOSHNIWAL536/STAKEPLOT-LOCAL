import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/allcardsScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/autoPays/cardWidget.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:get/get.dart';


class CardStackScreen extends StatefulWidget {
  @override
  _CardStackScreenState createState() => _CardStackScreenState();
}

class _CardStackScreenState extends State<CardStackScreen> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  final RxList<CardData> cards = <CardData>[].obs;
  final RxList<CardData> allCards = <CardData>[].obs;
  final RxInt selectedCardIndex = (-1).obs;
  final RxBool isLoading = true.obs;
  final RxMap<String, bool> toggleStates = <String, bool>{}.obs;

  @override
  void initState() {
    super.initState();
    _fetchAutoPayData();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      cards.length + 1,
      (index) => AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(begin: Offset.zero, end: Offset(0, -0.8)).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  void _showCustomCalendarPopup(BuildContext context, String cardId) {
    final screenSize = MediaQuery.of(context).size;
    final fontScale = screenSize.width / 375;
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentDay = now.day;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * fontScale),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Choose a Day for Your Reminder",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 18 * fontScale,
                  color: AppColors.backgroundColor,
                ),
              ),
            ],
          ),
          content: SizedBox(
            height: screenSize.height * 0.3,
            width: screenSize.width * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tap a day on the calendar to schedule your upcoming reminder.",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 14 * fontScale,
                    color: AppColors.backgroundColor,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    itemCount: 31,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8 * fontScale,
                      mainAxisSpacing: 8 * fontScale,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final selectedDay = index + 1;
                      bool isToday = selectedDay == currentDay && currentMonth == now.month;

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.backgroundColor,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8 * fontScale),
                          ),
                        ),
                        onPressed: () async {
                          DateTime reminderDate;
                          if (selectedDay >= currentDay) {
                            reminderDate = DateTime(currentYear, currentMonth, selectedDay);
                          } else {
                            final nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
                            final nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;
                            final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;

                            if (selectedDay <= daysInNextMonth) {
                              reminderDate = DateTime(nextYear, nextMonth, selectedDay);
                            } else {
                              reminderDate = DateTime(nextYear, nextMonth, daysInNextMonth);
                            }

                            if (now.isAfter(reminderDate)) {
                              final followingMonth = nextMonth == 12 ? 1 : nextMonth + 1;
                              final followingYear = nextMonth == 12 ? nextYear + 1 : nextYear;
                              final daysInFollowingMonth = DateTime(followingYear, followingMonth + 1, 0).day;
                              final validDay = selectedDay <= daysInFollowingMonth ? selectedDay : daysInFollowingMonth;
                              reminderDate = DateTime(followingYear, followingMonth, validDay);
                            }
                          }

                          final formattedDate = "${reminderDate.day}/${reminderDate.month}/${reminderDate.year}";
                          Navigator.pop(context);

                          final success = await updateRecurringPaymentDate(cardId, reminderDate);
                          if (success) {
                            final addSuccess = await addRecurringPayment(cardId, true);
                            snackBarCalled(
                              context,
                              addSuccess ? "Added and reminder set for $formattedDate" : "Failed to add",
                            );
                            if (addSuccess) {
                              toggleStates[cardId] = true;
                              await _fetchAutoPayData();
                            }
                          } else {
                            snackBarCalled(context, "Failed to set reminder");
                          }

                          snackBarCalled(
                            context,
                            success ? "Reminder set for $formattedDate" : "Failed to set reminder",
                          );
                          if (success) await _fetchAutoPayData();
                        },
                        child: Center(
                          child: Text(
                            '$selectedDay',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w600,
                              fontSize: 14 * fontScale,
                              color: AppColors.accentColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchAutoPayData() async {
    isLoading.value = true;
    final fetchedCards = await getAutoPayInfo();
    isAutoPayFected.value = !isAutoPayFected.value;
    allCards.clear();
    allCards.assignAll(fetchedCards);
    cards.assignAll(fetchedCards.take(3).toList());
    isLoading.value = false;
    toggleStates.clear();
    for (var card in cards) {
      toggleStates[card.id] = card.isActive;
    }
    _controllers.forEach((controller) => controller.dispose());
    _initializeAnimations();
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _onCardTap(int index, BuildContext context) {
    if (index == cards.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllCardsScreen(
            cards: allCards,
            toggleStates: toggleStates,
            onToggleChanged: (id, value) => toggleStates[id] = value,
            onSetReminder: (cardId) => _showCustomCalendarPopup(context, cardId),
            onDataChanged: _fetchAutoPayData,
          ),
        ),
      );
    } else {
      if (selectedCardIndex.value == index) {
        _controllers[index].reverse();
        selectedCardIndex.value = -1;
      } else {
        if (selectedCardIndex.value != -1) _controllers[selectedCardIndex.value].reverse();
        selectedCardIndex.value = index;
        _controllers[index].forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontScale = screenSize.width / 375;
    final cardHeight = screenSize.height * 0.22;
    final stackHeight = screenSize.height * 0.37;
    final horizontalPadding = screenSize.width * 0.04;
    final horizontalPaddingForStack = screenSize.width * 0.01;
    final cardSpacing = screenSize.height * 0.05;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding / 2, vertical: 8.0),
          child: Obx(() => Column(
                children: [
                  if (isLoading.value)
                    Center(child: Spinner())
                  else
                    Container(
                      height: stackHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4A4A6A).withOpacity(0.9),
                            Color(0xFF3A3A5A).withOpacity(0.8),
                            Color(0xFF2A2A4A).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20 * fontScale),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.3),
                        //     blurRadius: 20 * fontScale,
                        //     offset: Offset(0, 8 * fontScale),
                        //   ),
                        // ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (int i = cards.length; i >= 0; i--)
                            Positioned(
                              top: (cards.length - i) * cardSpacing,
                              left: horizontalPadding,
                              right: horizontalPadding,
                              child: AnimatedBuilder(
                                animation: _controllers[i],
                                builder: (context, child) {
                                  return SlideTransition(
                                    position: _slideAnimations[i],
                                    child: GestureDetector(
                                      onTap: () => _onCardTap(i, context),
                                      child: i == cards.length
                                          ? Container(
                                              height: cardHeight,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(16 * fontScale),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.25),
                                                    blurRadius: 12 * fontScale,
                                                    offset: Offset(0, 6 * fontScale),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(10.0 * fontScale),
                                                child: Text(
                                                  "View All",
                                                  style: FontManager().getTextStyle(
                                                    context,
                                                    lWeight: FontWeight.w600,
                                                    fontSize: 16 * fontScale,
                                                    color: AppColors.backgroundColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            )
                                          : CardWidget(
                                              card: cards[i],
                                              toggleStates: toggleStates,
                                              onToggleChanged: (id, value) => toggleStates[id] = value,
                                              onSetReminder: (cardId) => _showCustomCalendarPopup(context, cardId),
                                              parentContext: context,
                                              onDataChanged: _fetchAutoPayData,
                                              index: i,
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          Positioned(
                            bottom: 12 * fontScale,
                            left: horizontalPaddingForStack,
                            child: CustomNeumorphicContainer(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: MediaQuery.of(context).size.height * 0.16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              )),
        ),
      ),
    );
  }
}