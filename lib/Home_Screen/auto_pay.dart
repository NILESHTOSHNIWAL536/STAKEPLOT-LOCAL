// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/loader.dart';
// import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';

// // Reusable Card Widget
// class CardWidget extends StatelessWidget {
//   final CardData card;
//   final RxMap<String, bool> toggleStates;
//   final Function(String, bool)? onToggleChanged;
//   final Function(String)? onSetReminder;
//   final BuildContext parentContext;

//   const CardWidget({
//     required this.card,
//     required this.toggleStates,
//     required this.parentContext,
//     this.onToggleChanged,
//     this.onSetReminder,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.2,
//       decoration: BoxDecoration(
//         gradient: card.gradient,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.25),
//             blurRadius: 12,
//             offset: Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         card.title,
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w600,
//                           fontSize: 14,
//                           color: AppColors.accentColor,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         card.date,
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w600,
//                           fontSize: 10,
//                           color: AppColors.accentColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   card.amount,
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.w600,
//                     fontSize: 16,
//                     color: AppColors.accentColor,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 4),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.4),
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           chatAvatartImage(
//                             url: 'assets/icons/Home-page/frequency.svg',
//                             height: 50,
//                             width: 50,
//                           ),
//                           SizedBox(width: 2),
//                           Text(
//                             card.frequency,
//                             style: FontManager().getTextStyle(
//                               context,
//                               lWeight: FontWeight.w500,
//                               fontSize: 12,
//                               color: AppColors.primaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (card.frequency.toLowerCase() == 'daily') ...[
//                       const SizedBox(width: 8),
//                       Obx(() => Switch(
//                             value: toggleStates[card.id] ?? true,
//                             onChanged: (value) async {
//                               toggleStates[card.id] = value;
//                               onToggleChanged?.call(card.id, value);
//                               final success = await addRecurringPayment(card.id, value);
//                               if (success) {
//                                 snackBarCalled(parentContext, "Autopay status updated successfully");
//                               } else {
//                                 toggleStates[card.id] = !value;
//                                 onToggleChanged?.call(card.id, !value);
//                                 snackBarCalled(parentContext, "Failed to update autopay status");
//                               }
//                             },
//                             activeColor: AppColors.accentColor,
//                             inactiveThumbColor: Colors.white70,
//                             inactiveTrackColor: Colors.white.withOpacity(0.3),
//                           )),
//                     ],
//                   ],
//                 ),
//                 Container(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       GestureDetector(
//                         onTap: () async {
//                           final confirm = await showDialog<bool>(
//                             context: parentContext,
//                             builder: (context) => AlertDialog(
//                               title: const Text("Add Payment"),
//                               content: const Text("Do you want to add this recurring payment?"),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, false),
//                                   child: const Text("Cancel"),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, true),
//                                   child: const Text("Add"),
//                                 ),
//                               ],
//                             ),
//                           );
//                           if (confirm == true) {
//                             final success = await addRecurringPayment(card.id, true);
//                             snackBarCalled(
//                               parentContext,
//                               success ? "Payment added successfully" : "Failed to add payment",
//                             );
//                           }
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(10),
//                               topRight: Radius.circular(10),
//                             ),
//                           ),
//                           child: const Text(
//                             "+",
//                             style: TextStyle(fontSize: 12, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 2),
//                       GestureDetector(
//                         onTap: () async {
//                           final confirm = await showDialog<bool>(
//                             context: parentContext,
//                             builder: (context) => AlertDialog(
//                               title: Text("Ignore Payment"),
//                               content: Text("Are you sure you want to ignore this recurring payment?"),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, false),
//                                   child: Text("Cancel"),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, true),
//                                   child: Text("Ignore"),
//                                 ),
//                               ],
//                             ),
//                           );
//                           if (confirm == true) {
//                             final success = await ignoreRecurringPayment(card.id);
//                             snackBarCalled(
//                               parentContext,
//                               success ? "Payment ignored successfully" : "Failed to ignore payment",
//                             );
//                           }
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.only(
//                               bottomLeft: Radius.circular(10),
//                               bottomRight: Radius.circular(10),
//                             ),
//                           ),
//                           child: const Text(
//                             "x",
//                             style: TextStyle(fontSize: 12, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 4),
//             Text(
//               "Occurrences",
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.w500,
//                 fontSize: 14,
//                 color: AppColors.bg1,
//               ),
//             ),
//             SizedBox(height: 4),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Wrap(
//                     spacing: 4.0,
//                     runSpacing: 4.0,
//                     children: card.occuranceDate.isEmpty
//                         ? [
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 "No occurrences",
//                                 style: FontManager().getTextStyle(
//                                   context,
//                                   lWeight: FontWeight.w400,
//                                   fontSize: 10,
//                                   color: AppColors.backgroundColor,
//                                 ),
//                               ),
//                             ),
//                           ]
//                         : card.occuranceDate.map((date) => Container(
//                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 date,
//                                 style: FontManager().getTextStyle(
//                                   context,
//                                   lWeight: FontWeight.w400,
//                                   fontSize: 10,
//                                   color: AppColors.backgroundColor,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             )).toList(),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () => onSetReminder?.call(card.id),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       card.nextReminderAt != null
//                       // ? "Next remainder at ${cards[i].nextReminderAt!.day}/${cards[i].nextReminderAt!.month}/${cards[i].nextReminderAt!.year}"
//                           ? "Next reminder at ${formatWhatsAppDateWithoutTime(card.nextReminderAt!)}"
//                           : "Set Reminder",
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w400,
//                         fontSize: 10,
//                         color: AppColors.backgroundColor,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CardStackScreen extends StatefulWidget {
//   @override
//   _CardStackScreenState createState() => _CardStackScreenState();
// }

// class _CardStackScreenState extends State<CardStackScreen> with TickerProviderStateMixin {
//   late List<AnimationController> _controllers;
//   late List<Animation<Offset>> _slideAnimations;
//   final RxList<CardData> cards = <CardData>[].obs;
//   final RxList<CardData> allCards = <CardData>[].obs;
//   final RxInt selectedCardIndex = (-1).obs;
//   final RxBool isLoading = true.obs;
//   final RxMap<String, bool> toggleStates = <String, bool>{}.obs;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAutoPayData();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _controllers = List.generate(
//       cards.length + 1,
//       (index) => AnimationController(
//         duration: Duration(milliseconds: 500),
//         vsync: this,
//       ),
//     );
//     _slideAnimations = _controllers.map((controller) {
//       return Tween<Offset>(begin: Offset.zero, end: Offset(0, -0.8)).animate(
//         CurvedAnimation(parent: controller, curve: Curves.easeInOut),
//       );
//     }).toList();
//   }

//   void _showCustomCalendarPopup(BuildContext context, String cardId) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         final now = DateTime.now();
//         final currentYear = now.year;
//         final currentMonth = now.month;
//         final currentDay = now.day;

//         return AlertDialog(
//           backgroundColor: AppColors.primaryColor,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text(
//             "Select a Date",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//           content: SizedBox(
//             height: 200,
//             width: double.maxFinite,
//             child: GridView.builder(
//               itemCount: 31,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 7,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//                 childAspectRatio: 1,
//               ),
//               itemBuilder: (context, index) {
//                 final selectedDay = index + 1;
//                 return ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.backgroundColor,
//                     padding: EdgeInsets.zero,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   onPressed: () async {
//                     DateTime reminderDate;
//                     if (selectedDay >= currentDay) {
//                       reminderDate = DateTime(currentYear, currentMonth, selectedDay);
//                     } else {
//                       final nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
//                       final nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;
//                       final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
//                       if (selectedDay <= daysInNextMonth) {
//                         reminderDate = DateTime(nextYear, nextMonth, selectedDay);
//                       } else {
//                         reminderDate = DateTime(nextYear, nextMonth, daysInNextMonth);
//                       }
//                       if (now.isAfter(reminderDate)) {
//                         final followingMonth = nextMonth == 12 ? 1 : nextMonth + 1;
//                         final followingYear = nextMonth == 12 ? nextYear + 1 : nextYear;
//                         final daysInFollowingMonth = DateTime(followingYear, followingMonth + 1, 0).day;
//                         final validDay = selectedDay <= daysInFollowingMonth ? selectedDay : daysInFollowingMonth;
//                         reminderDate = DateTime(followingYear, followingMonth, validDay);
//                       }
//                     }

//                     final formattedDate = "${reminderDate.day}/${reminderDate.month}/${reminderDate.year}";
//                     Navigator.pop(context);

//                     final success = await updateRecurringPaymentDate(cardId, reminderDate);
//                     snackBarCalled(
//                       context,
//                       success ? "Reminder set for $formattedDate" : "Failed to set reminder",
//                     );
//                     if (success) await _fetchAutoPayData();
//                   },
//                   child: Center(
//                     child: Text(
//                       '$selectedDay',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _fetchAutoPayData() async {
//     isLoading.value = true;
//     final fetchedCards = await getAutoPayInfo();
//     allCards.assignAll(fetchedCards);
//     cards.assignAll(fetchedCards.take(3).toList());
//     isLoading.value = false;
//     toggleStates.clear();
//     for (var card in cards) {
//       toggleStates[card.id] = true;
//     }
//     _controllers.forEach((controller) => controller.dispose());
//     _initializeAnimations();
//   }

//   @override
//   void dispose() {
//     _controllers.forEach((controller) => controller.dispose());
//     super.dispose();
//   }

//   void _onCardTap(int index, BuildContext context) {
//     if (index == cards.length) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AllCardsScreen(
//             cards: allCards,
//             toggleStates: toggleStates,
//             onToggleChanged: (id, value) => toggleStates[id] = value,
//             onSetReminder: (cardId) => _showCustomCalendarPopup(context, cardId),
//           ),
//         ),
//       );
//     } else {
//       if (selectedCardIndex.value == index) {
//         _controllers[index].reverse();
//         selectedCardIndex.value = -1;
//       } else {
//         if (selectedCardIndex.value != -1) _controllers[selectedCardIndex.value].reverse();
//         selectedCardIndex.value = index;
//         _controllers[index].forward();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Obx(() => Column(
//                 children: [
//                   if (isLoading.value)
//                     Center(child: Spinner())
//                   else
//                     Container(
//                       height: MediaQuery.of(context).size.height * 0.392,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Color(0xFF4A4A6A).withOpacity(0.9),
//                             Color(0xFF3A3A5A).withOpacity(0.8),
//                             Color(0xFF2A2A4A).withOpacity(0.7),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 20,
//                             offset: Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       child: Stack(
//                         clipBehavior: Clip.none,
//                         children: [
//                           for (int i = cards.length; i >= 0; i--)
//                             Positioned(
//                               top: 20.0 + (cards.length - i) * 40.0,
//                               left: 15,
//                               right: 15,
//                               child: AnimatedBuilder(
//                                 animation: _controllers[i],
//                                 builder: (context, child) {
//                                   return SlideTransition(
//                                     position: _slideAnimations[i],
//                                     child: GestureDetector(
//                                       onTap: () => _onCardTap(i, context),
//                                       child: i == cards.length
//                                           ? Container(
//                                               height: MediaQuery.of(context).size.height * 0.2,
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white.withOpacity(0.2),
//                                                 borderRadius: BorderRadius.circular(16),
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color: Colors.black.withOpacity(0.25),
//                                                     blurRadius: 12,
//                                                     offset: Offset(0, 6),
//                                                   ),
//                                                 ],
//                                               ),
//                                               child: Padding(
//                                                 padding: const EdgeInsets.all(8.0),
//                                                 child: Text(
//                                                   "View All",
//                                                   style: FontManager().getTextStyle(
//                                                     context,
//                                                     lWeight: FontWeight.w600,
//                                                     fontSize: 16,
//                                                     color: AppColors.backgroundColor,
//                                                   ),
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                               ),
//                                             )
//                                           : CardWidget(
//                                               card: cards[i],
//                                               toggleStates: toggleStates,
//                                               onToggleChanged: (id, value) => toggleStates[id] = value,
//                                               onSetReminder: (cardId) => _showCustomCalendarPopup(context, cardId),
//                                               parentContext: context,
//                                             ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           Positioned(
//                             bottom: 7,
//                             left: 10,
//                             child: SvgPicture.asset(
//                               'assets/icons/Home-page/autoPays.svg',
//                               width: MediaQuery.of(context).size.width * 0.1,
//                               height: MediaQuery.of(context).size.height * 0.17,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               )),
//         ),
//       ),
//     );
//   }
// }

// class AllCardsScreen extends StatelessWidget {
//   final RxList<CardData> cards;
//   final RxMap<String, bool> toggleStates;
//   final Function(String, bool) onToggleChanged;
//   final Function(String) onSetReminder;

//   const AllCardsScreen({
//     required this.cards,
//     required this.toggleStates,
//     required this.onToggleChanged,
//     required this.onSetReminder,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("All Transactions"),
//         backgroundColor: AppColors.backgroundColor,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Obx(() => cards.isEmpty
//               ? Center(child: Text("No transactions available", style: TextStyle(color: Colors.white)))
//               : ListView.builder(
//                   itemCount: cards.length,
//                   itemBuilder: (context, i) => Padding(
//                     padding: EdgeInsets.symmetric(vertical: 8.0),
//                     child: CardWidget(
//                       card: cards[i],
//                       toggleStates: toggleStates,
//                       onToggleChanged: onToggleChanged,
//                       onSetReminder: onSetReminder,
//                       parentContext: context,
//                     ),
//                   ),
//                 )),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

// Reusable Card Widget
class CardWidget extends StatelessWidget {
  final CardData card;
  final RxMap<String, bool> toggleStates;
  final Function(String, bool)? onToggleChanged;
  final Function(String)? onSetReminder;
  final BuildContext parentContext;
  final Function() onDataChanged;
  const CardWidget({
    required this.card,
    required this.toggleStates,
    required this.parentContext,
    required this.onDataChanged,
    this.onToggleChanged,
    this.onSetReminder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardHeight = screenSize.height *
        0.2; // Responsive card height (25% of screen height)
    final fontScale =
        screenSize.width / 375; // Base font scaling for 375px width
    final padding =
        screenSize.width * 0.03; // Responsive padding (3% of screen width)

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: card.gradient,
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
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 14 * fontScale,
                          color: AppColors.accentColor,
                        ),
                      ),
                      SizedBox(height: 4 * fontScale),
                      Text(
                        card.date,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 10 * fontScale,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  card.amount,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 16 * fontScale,
                    color: AppColors.accentColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4 * fontScale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8 * fontScale, vertical: 4 * fontScale),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2 * fontScale),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          chatAvatartImage(
                            url: 'assets/icons/Home-page/frequency.svg',
                            height: 50 * fontScale,
                            width: 50 * fontScale,
                          ),
                          SizedBox(width: 2 * fontScale),
                          Text(
                            card.frequency,
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: 12 * fontScale,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                   if (card.frequency.toLowerCase() == 'daily') ...[
  SizedBox(width: 8 * fontScale),
  Obx(() => Switch(
    value: toggleStates[card.id] ?? (card.isActive ?? true),
    onChanged: (value) async {
      toggleStates[card.id] = value; // Optimistic update
      onToggleChanged?.call(card.id, value);
      final success = await addRecurringPayment(card.id, value);
      if (success) {
        snackBarCalled(parentContext, "Autopay status updated successfully");
      } else {
        toggleStates[card.id] = !value; // Revert on failure
        onToggleChanged?.call(card.id, !value);
        snackBarCalled(parentContext, "Failed to update autopay status");
      }
      onDataChanged(); // Refresh data after success or failure
    },
    activeColor: AppColors.accentColor,
    inactiveThumbColor: Colors.white70,
    inactiveTrackColor: Colors.white.withOpacity(0.3),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  )),
],
                    
                  ],
                ),
                
                   Column(mainAxisSize: MainAxisSize.min, children: [
                    if (card.isActive == true)
      GestureDetector(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: parentContext,
            builder: (context) => AlertDialog(
              title: const Text("Remove Payment"),
              content: const Text("Do you want to remove this recurring payment?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Remove"),
                ),
              ],
            ),
          );
          if (confirm == true) {
            final success = await addRecurringPayment(card.id, false); // use `false` to remove
            snackBarCalled(
              parentContext,
              success ? "Removed successfully" : "Failed to remove",
            );
            if (success) onDataChanged(); // Refresh UI
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * fontScale, vertical: 4 * fontScale),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10 * fontScale),
          ),
          child: Text(
            "Added",
            style: TextStyle(fontSize: 14 * fontScale, color: Colors.white),
          ),
        ),
      )
                    else ...[
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: parentContext,
                            builder: (context) => AlertDialog(
                              title: const Text("Add Payment"),
                              content: const Text(
                                  "Do you want to add this recurring payment?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Add"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final success =
                                await addRecurringPayment(card.id, true);
                            snackBarCalled(
                              parentContext,
                              success
                                  ? "Added successfully"
                                  : "Failed to add ",
                            );
                            if (success) onDataChanged();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12 * fontScale,
                              vertical: 4 * fontScale),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20 * fontScale),
                              topRight:  Radius.circular(20 * fontScale),
                            ),
                          ),
                          child: Text(
                            "+",
                            style: TextStyle(
                                fontSize: 18 * fontScale, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 2 * fontScale),
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: parentContext,
                            builder: (context) => AlertDialog(
                              title: Text("Ignore Payment"),
                              content: Text(
                                  "Are you sure you want to delete this recurring payment?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("delete"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final success =
                                await ignoreRecurringPayment(card.id);
                            snackBarCalled(
                              parentContext,
                              success
                                  ? " Deleted successfully"
                                  : "Failed to delete autopay",
                            );
                            if (success) onDataChanged();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.5 * fontScale,
                              vertical: 4 * fontScale),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20 * fontScale),
                              bottomRight: Radius.circular(20 * fontScale),
                            ),
                          ),
                          child: Text(
                            "x",
                            style: TextStyle(
                                fontSize: 18 * fontScale, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ])
                
              
              ],
            ),
            SizedBox(height: 4 * fontScale),
            Text(
              "Occurrences",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 14 * fontScale,
                color: AppColors.bg1,
              ),
            ),
            SizedBox(height: 4 * fontScale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 4.0 * fontScale,
                    runSpacing: 4.0 * fontScale,
                    children: card.occuranceDate.isEmpty
                        ? [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8 * fontScale,
                                  vertical: 4 * fontScale),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(4 * fontScale),
                              ),
                              child: Text(
                                "No occurrences",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 10 * fontScale,
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                            ),
                          ]
                        : card.occuranceDate
                            .map((date) => Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8 * fontScale,
                                      vertical: 4 * fontScale),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(8 * fontScale),
                                  ),
                                  child: Text(
                                    date,
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w400,
                                      fontSize: 10 * fontScale,
                                      color: AppColors.backgroundColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                  ),
                ),
                GestureDetector(
                  onTap: () => onSetReminder?.call(card.id),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8 * fontScale, vertical: 6 * fontScale),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10 * fontScale),
                    ),
                    child: Text(
                      card.nextReminderAt != null
                          ? "Upcoming reminder: ${formatWhatsAppDateWithoutTime(card.nextReminderAt!)}"
                          : "Set Reminder",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 12 * fontScale,
                        color: AppColors.backgroundColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CardStackScreen extends StatefulWidget {
  @override
  _CardStackScreenState createState() => _CardStackScreenState();
}

class _CardStackScreenState extends State<CardStackScreen>
    with TickerProviderStateMixin {
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
        // titlePadding: EdgeInsets.only(left: 24, right: 8, top: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Choose a Day for Your Reminder",
              style: FontManager()
                                                    .getTextStyle(
                                                  context,
                                                  lWeight: FontWeight.w600,
                                                  fontSize: 18 * fontScale,
                                                  color: AppColors
                                                      .backgroundColor,
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
                 style: FontManager()
                                                    .getTextStyle(
                                                  context,
                                                  lWeight: FontWeight.w600,
                                                  fontSize: 14 * fontScale,
                                                  color: AppColors
                                                      .backgroundColor,
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
                    bool isToday =
                        selectedDay == currentDay && currentMonth == now.month;

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
                          reminderDate =
                              DateTime(currentYear, currentMonth, selectedDay);
                        } else {
                          final nextMonth =
                              currentMonth == 12 ? 1 : currentMonth + 1;
                          final nextYear =
                              currentMonth == 12 ? currentYear + 1 : currentYear;
                          final daysInNextMonth =
                              DateTime(nextYear, nextMonth + 1, 0).day;

                          if (selectedDay <= daysInNextMonth) {
                            reminderDate =
                                DateTime(nextYear, nextMonth, selectedDay);
                          } else {
                            reminderDate =
                                DateTime(nextYear, nextMonth, daysInNextMonth);
                          }

                          if (now.isAfter(reminderDate)) {
                            final followingMonth =
                                nextMonth == 12 ? 1 : nextMonth + 1;
                            final followingYear =
                                nextMonth == 12 ? nextYear + 1 : nextYear;
                            final daysInFollowingMonth = DateTime(
                                    followingYear, followingMonth + 1, 0)
                                .day;
                            final validDay = selectedDay <= daysInFollowingMonth
                                ? selectedDay
                                : daysInFollowingMonth;
                            reminderDate = DateTime(
                                followingYear, followingMonth, validDay);
                          }
                        }

                        final formattedDate =
                            "${reminderDate.day}/${reminderDate.month}/${reminderDate.year}";
                        Navigator.pop(context);

                        final success = await updateRecurringPaymentDate(
                            cardId, reminderDate);
                        snackBarCalled(
                          context,
                          success
                              ? "Reminder set for $formattedDate"
                              : "Failed to set reminder",
                        );
                        if (success) await _fetchAutoPayData();
                      },
                      child: Center(
                        child: Text(
                          '$selectedDay',
                          style: FontManager()
                                                    .getTextStyle(
                                                  context,
                                                  lWeight: FontWeight.w600,
                                                  fontSize: 14 * fontScale,
                                                  color: AppColors
                                                      .accentColor,
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
    allCards.assignAll(fetchedCards);
    cards.assignAll(fetchedCards.take(3).toList());
    isLoading.value = false;
    toggleStates.clear();
    for (var card in cards) {
      toggleStates[card.id] = true;
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
            onSetReminder: (cardId) =>
                _showCustomCalendarPopup(context, cardId),
            onDataChanged: _fetchAutoPayData,
          ),
        ),
      );
    } 
    else {
      if (selectedCardIndex.value == index) {
        _controllers[index].reverse();
        selectedCardIndex.value = -1;
      } else {
        if (selectedCardIndex.value != -1)
          _controllers[selectedCardIndex.value].reverse();
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
    final stackHeight =
        screenSize.height * 0.37; // Increased to accommodate overlap
    final horizontalPadding = screenSize.width * 0.04;
    final cardSpacing = screenSize.height * 0.05; // Responsive card spacing

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding/2, vertical: 8.0),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20 * fontScale,
                            offset: Offset(0, 8 * fontScale),
                          ),
                        ],
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
                                              color: Colors.white
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      16 * fontScale),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.25),
                                                  blurRadius:
                                                      12 * fontScale,
                                                  offset: Offset(
                                                      0, 6 * fontScale),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  10.0 * fontScale),
                                              child: Text(
                                                "View All",
                                                style: FontManager()
                                                    .getTextStyle(
                                                  context,
                                                  lWeight: FontWeight.w600,
                                                  fontSize: 16 * fontScale,
                                                  color: AppColors
                                                      .backgroundColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                          : CardWidget(
                                              card: cards[i],
                                              toggleStates: toggleStates,
                                              onToggleChanged: (id, value) =>
                                                  toggleStates[id] = value,
                                              onSetReminder: (cardId) =>
                                                  _showCustomCalendarPopup(
                                                      context, cardId),
                                              parentContext: context,
                                              onDataChanged: _fetchAutoPayData,
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          Positioned(
                            bottom: 12 * fontScale,
                            left: horizontalPadding,
                            child: CustomNeumorphicContainer(
                               width: MediaQuery.of(context).size.width*0.8,
          height: MediaQuery.of(context).size.height*0.16,
                            ),
                            // child: SvgPicture.asset(
                            //   'assets/icons/Home-page/autoPays.svg',
                            //   width: screenSize.width * 0.24,
                            //   height: screenSize.height * 0.16,
                            // ),
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
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.04, vertical: 8.0),
          child: Obx(() => cards.isEmpty
              ? Center(
                  child: Text(
                    "No paycycles available",
                    style: TextStyle(
                        color: Colors.white, fontSize: 16 * fontScale),
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
         child:  Center(
          child: Text(
            'PayCycles',
            textAlign: TextAlign.center,
            style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w600,
                fontSize: 22 ,
                color: AppColors.backgroundColor,
              ),)
          ),
      ),
    );
  }
}

class SvgShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.035, size.height * 0.01); // 8.82 of 255, scaled
    path.cubicTo(
      size.width * 0.35, size.height * 0.1,
      size.width * 0.65, size.height * 0.1,
      size.width, 0,
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
