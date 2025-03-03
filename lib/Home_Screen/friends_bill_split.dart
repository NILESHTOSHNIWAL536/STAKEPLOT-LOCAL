// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:get/get_rx/src/rx_types/rx_types.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/manual_transaction.dart';

// RxList addedUser = [].obs;
// RxList addedMembers = [].obs;

// class NewFriendsUi extends StatefulWidget {
//   final bool showContinueButton;
//   final double totalAmount;
//   final String userId;
//   final String userName;
//   final String userAvatar;
//   final bool isLendMode;
//   const NewFriendsUi({
//     Key? key,
//     this.showContinueButton = true,
//     required this.totalAmount,
//     required this.userId,
//     required this.userName,
//     required this.userAvatar,
//     this.isLendMode = false,
//   }) : super(key: key);

//   @override
//   _NewFriendsUiState createState() => _NewFriendsUiState();
// }

// class _NewFriendsUiState extends State<NewFriendsUi> {
//   TextEditingController textController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.backgroundColor,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//       ),
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height / 1.9,
//       child: Padding(
//         padding: const EdgeInsets.only(top: 24, left: 18, right: 18),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Select people',
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: AppColors.bg1,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 child: InputDat('Search', TextInputType.name, textController),
//               ),
//               Text(
//                 'My friends',
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.w600,
//                   fontSize: 16,
//                   color: AppColors.bg1,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               addedMembers.isNotEmpty
//                   ? Container(
//                       width: MediaQuery.of(context).size.width,
//                       height: MediaQuery.of(context).size.width / 5,
//                       child: ListView(
//                         scrollDirection: Axis.horizontal,
//                         children: addedMembers.map((element) {
//                           return Container(
//                             width: MediaQuery.of(context).size.width / 6,
//                             height: MediaQuery.of(context).size.width / 7,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Stack(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(0.0),
//                                       child: Center(
//                                         child: AvatarProfileImage(
//                                           url: element['avatar'] ??
//                                               widget.userAvatar,
//                                           width: 10,
//                                           height: 20,
//                                         ),
//                                       ),
//                                     ),
//                                     Positioned(
//                                       right: 0,
//                                       top: 0,
//                                       child: InkWell(
//                                         onTap: () {
//                                           setState(() {
//                                             addedMembers.removeWhere((ele) =>
//                                                 ele['id'] == element['id']);
//                                             addedUser.remove(element['id']);
//                                           });
//                                         },
//                                         child: const Icon(
//                                           Icons.remove_circle,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Center(
//                                   child: Text(
//                                     element['name'],
//                                     style: FontManager().getTextStyle(
//                                       context,
//                                       fontSize: 12,
//                                       maxLines: 1,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     )
//                   : const SizedBox.shrink(),
//               commentedData(),
//               if (widget.showContinueButton)
//                 Center(
//                   child: InkWell(
//                     onTap: () async {
//                       if (addedMembers.isNotEmpty) {
//                         if (widget.isLendMode) {
//                           if (addedMembers.length > 1) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text(
//                                       'Please select only one friend for lending')),
//                             );
//                             return;
//                           }
//                           print(
//                               "NewFriendsUi: Lend mode - Selected friend: ${addedMembers[0]}");
//                           Navigator.pop(
//                               context,
//                               addedMembers[
//                                   0]); // Return single friend’s details
//                         } else {
//                           print(
//                               "NewFriendsUi: Split mode - Opening AmountEntryModal with totalAmount: ${widget.totalAmount}");
//                           Navigator.pop(context);
//                           final amounts = await showAmountEntryModal(context);
//                           if (amounts != null) {
//                             print(
//                                 "NewFriendsUi: Split mode - Received amounts: $amounts");
//                             Navigator.pop(
//                                 context, amounts); // Return amounts for split
//                           } else {
//                             print(
//                                 "NewFriendsUi: Split mode - No amounts returned");
//                           }
//                         }
//                       } else {
//                         print("NewFriendsUi: No friends selected");
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content:
//                                   Text('Please select at least one friend')),
//                         );
//                       }
//                     },
//                     child: getButton(context, "Continue"),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<Map<String, double>?> showAmountEntryModal(
//       BuildContext context) async {
//     return await showModalBottomSheet<Map<String, double>?>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//       ),
//       builder: (BuildContext context) {
//         return AmountEntryModal(
//           selectedFriends: addedMembers.toList(),
//           totalAmount: widget.totalAmount,
//           userId: widget.userId,
//           userName: widget.userName,
//           userAvatar: widget.userAvatar,
//         );
//       },
//     );
//   }

//   Widget commentedData() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
//               child: SizedBox(
//                 height: 70,
//                 width: MediaQuery.of(context).size.width,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: frdsList.length,
//                   itemBuilder: (context, index) {
//                     String values = frdsList[index]['_id'];
//                     return InkWell(
//                       onTap: () {},
//                       child: Column(
//                         children: [
//                           GestureDetector(
//                             // onTap: () {
//                             //   setState(() {
//                             //     if (addedUser.contains(values)) {
//                             //       addedUser.remove(values);
//                             //       addedMembers.removeWhere((element) => element['id'] == values);
//                             //     } else {
//                             //       addedUser.add(values);
//                             //       addedMembers.add({
//                             //         "name": frdsList[index]['name'],
//                             //         "id": values,
//                             //         'avatar': frdsList[index]['avatar'],
//                             //         "balance": 200,
//                             //       });
//                             //       print("NewFriendsUi: Added member ${frdsList[index]['name']} with ID: $values");
//                             //     }
//                             //   });
//                             // },
//                             onTap: () {
//                               setState(() {
//                                 if (addedUser.contains(values)) {
//                                   addedUser.remove(values);
//                                   addedMembers.removeWhere(
//                                       (element) => element['id'] == values);
//                                 } else if (widget.isLendMode &&
//                                     addedMembers.isNotEmpty) {
//                                   // For lend mode, replace the current selection
//                                   addedUser.clear();
//                                   addedMembers.clear();
//                                   addedUser.add(values);
//                                   addedMembers.add({
//                                     "name": frdsList[index]['name'],
//                                     "id": values,
//                                     'avatar': frdsList[index]['avatar'],
//                                     "balance": 200,
//                                   });
//                                   print(
//                                       "NewFriendsUi: Lend mode - Replaced with ${frdsList[index]['name']} (ID: $values)");
//                                 } else {
//                                   addedUser.add(values);
//                                   addedMembers.add({
//                                     "name": frdsList[index]['name'],
//                                     "id": values,
//                                     'avatar': frdsList[index]['avatar'],
//                                     "balance": 200,
//                                   });
//                                   print(
//                                       "NewFriendsUi: Added member ${frdsList[index]['name']} with ID: $values");
//                                 }
//                               });
//                             },
//                             child: Container(
//                               width: MediaQuery.of(context).size.width / 5,
//                               height: 50,
//                               child: Stack(
//                                 children: [
//                                   Center(
//                                     child: AvatarProfileImage(
//                                       url: frdsList[index]['avatar'] ??
//                                           widget.userAvatar,
//                                       width: 8,
//                                       height: 18,
//                                     ),
//                                   ),
//                                   addedUser.contains(values)
//                                       ? const Positioned(
//                                           right: 0,
//                                           top: 0,
//                                           child: Icon(
//                                             Icons.check,
//                                             size: 30,
//                                             color: Colors.green,
//                                           ),
//                                         )
//                                       : const SizedBox.shrink(),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Text(
//                             frdsList[index]['name'],
//                             style: FontManager().getTextStyle(
//                               context,
//                               lWeight: FontWeight.w400,
//                               fontSize: 14,
//                               color: AppColors.bg1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget InputDat(String labelText, TextInputType keyboardType,
//       TextEditingController controller) {
//     return Center(
//       child: Container(
//         color: const Color.fromRGBO(246, 246, 246, 1),
//         width: MediaQuery.of(context).size.width / 1.1,
//         child: TextFormField(
//           keyboardType: keyboardType,
//           controller: controller,
//           onChanged: (value) {
//             var filteredList = [];
//             if (value.isEmpty) {
//               frdsList.clear();
//               frdsList.addAll(frdsListOrigin);
//             } else {
//               frdsListOrigin.forEach((element) {
//                 if (element['name']
//                     .toString()
//                     .toLowerCase()
//                     .contains(value.toLowerCase())) {
//                   filteredList.add(element);
//                 }
//               });
//               setState(() {
//                 frdsList.clear();
//                 frdsList.addAll(filteredList);
//                 print(
//                     "NewFriendsUi: Filtered friends list updated: ${frdsList.length} items");
//               });
//             }
//           },
//           decoration: InputDecoration(
//             filled: true,
//             hintText: labelText,
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(24),
//               borderSide:
//                   const BorderSide(color: Color.fromRGBO(249, 246, 238, 1)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(24),
//               borderSide:
//                   const BorderSide(color: Color.fromRGBO(246, 246, 246, 1)),
//             ),
//             fillColor: AppColors.button,
//             border: InputBorder.none,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AmountEntryModal extends StatefulWidget {
//   final List selectedFriends;
//   final double totalAmount;
//   final String userId;
//   final String userName;
//   final String userAvatar;

//   const AmountEntryModal({
//     Key? key,
//     required this.selectedFriends,
//     required this.totalAmount,
//     required this.userId,
//     required this.userName,
//     required this.userAvatar,
//   }) : super(key: key);

//   @override
//   _AmountEntryModalState createState() => _AmountEntryModalState();
// }

// class _AmountEntryModalState extends State<AmountEntryModal> {
//   Map<String, TextEditingController> amountControllers = {};
//   double currentTotal = 0.0;
//   double leftoverAmount = 0.0;
//   double initialEqualAmount = 0.0; // Store initial values
//   Map<String, bool> isModified = {};
//   @override
//   void initState() {
//     super.initState();
//     int totalParticipants = widget.selectedFriends.length + 1;
//     initialEqualAmount = widget.totalAmount / totalParticipants;

//     amountControllers[widget.userId] = TextEditingController(
//       text: initialEqualAmount.toStringAsFixed(2),
//     );
//     isModified[widget.userId] = false;
//     print(
//         "AmountEntryModal: Initialized user ${widget.userName} (ID: ${widget.userId}) with amount: $initialEqualAmount");

//     widget.selectedFriends.forEach((friend) {
//       amountControllers[friend['id']] = TextEditingController(
//         text: initialEqualAmount.toStringAsFixed(2),
//       );
//       isModified[friend['id']] = false;
//       print(
//           "AmountEntryModal: Initialized friend ${friend['name']} (ID: ${friend['id']}) with amount: $initialEqualAmount");
//     });

//     calculateTotal();
//   }

//   @override
//   void dispose() {
//     amountControllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }

//   void calculateTotal() {
//     currentTotal = 0.0;
//     amountControllers.forEach((key, controller) {
//       double amount = double.tryParse(controller.text.replaceAll(',', '')) ?? 0.0;
//       // Cap individual amount at totalAmount
//       if (amount > widget.totalAmount) {
//         amount = widget.totalAmount;
//         controller.text = amount.toStringAsFixed(2);
//         print("AmountEntryModal: Capped amount for ID $key to total: $amount");
//       }
//       currentTotal += amount;
//       print("AmountEntryModal: Amount for ID $key is: $amount, Modified: ${isModified[key]}");
//     });
//     leftoverAmount = widget.totalAmount - currentTotal;
//     print("AmountEntryModal: Current Total: $currentTotal, Leftover: $leftoverAmount");
//     setState(() {});
//   }

//   void settleLeftover() {
//     if (leftoverAmount == 0) {
//       print("AmountEntryModal: No leftover to settle");
//       return;
//     }

//     if (leftoverAmount < 0) {
//       print("AmountEntryModal: Negative leftover detected, adjusting...");
//       // Adjust amounts to fit totalAmount
//       double overage = -leftoverAmount;
//       List<String> adjustableParticipants = [];
//       amountControllers.forEach((id, controller) {
//        double amount = double.tryParse(controller.text.replaceAll(',', '')) ?? 0.0;
// if (amount > 0) {
//   adjustableParticipants.add(id);
// }
//       });
//       double reductionPerPerson = overage / adjustableParticipants.length;

//       for (var id in adjustableParticipants) {
//         double currentAmount = double.tryParse(amountControllers[id]!.text.replaceAll(',', '')) ?? 0.0;
//         double newAmount = (currentAmount - reductionPerPerson).clamp(0, widget.totalAmount);
//         amountControllers[id]!.text = newAmount.toStringAsFixed(2);
//         print("AmountEntryModal: Reduced ID $id: Updated amount from $currentAmount to $newAmount");
//       }
//     } else {
//       // Distribute positive leftover among unchanged participants
//       List<String> unchangedParticipants = [];
//       amountControllers.forEach((id, controller) {
//         if (!isModified[id]!) {
//           unchangedParticipants.add(id);
//         }
//       });

//       if (unchangedParticipants.isEmpty) {
//         unchangedParticipants = amountControllers.keys.toList();
//         print("AmountEntryModal: All amounts modified, distributing leftover among all: $unchangedParticipants");
//       } else {
//         print("AmountEntryModal: Distributing leftover among unchanged participants: $unchangedParticipants");
//       }

//       double leftoverPerPerson = leftoverAmount / unchangedParticipants.length;

//       for (var id in unchangedParticipants) {
//         double currentAmount = double.tryParse(amountControllers[id]!.text.replaceAll(',', '')) ?? 0.0;
//         double newAmount = (currentAmount + leftoverPerPerson).clamp(0, widget.totalAmount);
//         amountControllers[id]!.text = newAmount.toStringAsFixed(2);
//         print("AmountEntryModal: Settled ID $id: Updated amount from $currentAmount to $newAmount");
//       }
//     }

//     calculateTotal();
//     print("AmountEntryModal: Leftover settled, new total: $currentTotal, new leftover: $leftoverAmount");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedPadding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context)
//             .viewInsets
//             .bottom, // Adjusts for keyboard height
//         left: 16.0,
//         right: 16.0,
//         top: 16.0,
//       ),
//       duration: const Duration(milliseconds: 100), // Smooth animation
//       curve: Curves.easeInOut,
//       child: SingleChildScrollView(
//         child: Column(
//           //mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Enter Amounts (Total: ₹${widget.totalAmount.toStringAsFixed(2)})',
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: AppColors.accentColor,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       AvatarProfileImage(
//                         url: widget.userAvatar,
//                         width: 10,
//                         height: 20,
//                       ),
//                       const SizedBox(width: 10),
//                       Text(
//                         widget.userName,
//                         style: FontManager().getTextStyle(
//                           context,
//                           fontSize: 16,
//                           color: AppColors.bg1,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     width: 100,
//                     child: TextField(
//                       controller: amountControllers[widget.userId],
//                       keyboardType:
//                           TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
//                         ThousandsFormatter(),
//                       ],
//                       decoration: InputDecoration(
//                         prefixIcon: const Icon(Icons.currency_rupee, size: 18),
//                         prefixIconConstraints: const BoxConstraints(
//                           minWidth: 30,
//                           minHeight: 30,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 8),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         hintText: '0.00',
//                         hintStyle: TextStyle(
//                           color: Colors.grey.withOpacity(0.5),
//                           fontSize: 14,
//                         ),
//                       ),
//                       style: const TextStyle(fontSize: 14),
//                       textAlign: TextAlign.right,
//                       onChanged: (value) {
//                         isModified[widget.userId] = true;
//                         calculateTotal();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ...widget.selectedFriends.map((friend) => Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           AvatarProfileImage(
//                             url: friend['avatar'] ?? widget.userAvatar,
//                             width: 10,
//                             height: 20,
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             friend['name'],
//                             style: FontManager().getTextStyle(
//                               context,
//                               fontSize: 16,
//                               color: AppColors.bg1,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         width: 100,
//                         child: TextField(
//                           controller: amountControllers[friend['id']],
//                           keyboardType:
//                               TextInputType.numberWithOptions(decimal: true),
//                           inputFormatters: [
//                             FilteringTextInputFormatter.allow(
//                                 RegExp(r'[0-9.]')),
//                             ThousandsFormatter(),
//                           ],
//                           decoration: InputDecoration(
//                             prefixIcon:
//                                 const Icon(Icons.currency_rupee, size: 18),
//                             prefixIconConstraints: const BoxConstraints(
//                               minWidth: 30,
//                               minHeight: 30,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 10, horizontal: 8),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             hintText: '0.00',
//                             hintStyle: TextStyle(
//                               color: Colors.grey.withOpacity(0.5),
//                               fontSize: 14,
//                             ),
//                           ),
//                           style: const TextStyle(fontSize: 14),
//                           textAlign: TextAlign.right,
//                           onChanged: (value) {
//                             isModified[friend['id']] = true;
//                             calculateTotal();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),
//             const SizedBox(height: 10),
//             Text(
//               'Current Total: ₹${currentTotal.toStringAsFixed(2)}',
//               style: const TextStyle(fontSize: 16, color: Colors.blue),
//             ),
//             Text(
//               'Leftover: ₹${leftoverAmount.toStringAsFixed(2)}',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: leftoverAmount == 0
//                     ? Colors.green
//                     : leftoverAmount < 0
//                         ? Colors.red
//                         : Colors.orange,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Click Settle to split leftover amount equally among all',
//               style: FontManager().getTextStyle(
//                 context,
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
//               overflow:
//                   TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//             ),

//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 InkWell(
//                   onTap: settleLeftover,
//                   child: buttonContainer(context, "Settle"),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     if (leftoverAmount != 0) {
//                       print(
//                           "AmountEntryModal: Cannot confirm, leftover amount: $leftoverAmount");
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             leftoverAmount > 0
//                                 ? 'Please distribute the remaining ₹${leftoverAmount.toStringAsFixed(2)}'
//                                 : 'Total exceeds by ₹${(-leftoverAmount).toStringAsFixed(2)}',
//                           ),
//                         ),
//                       );
//                       return;
//                     }
//                     Map<String, double> amounts = {};
//                     amountControllers.forEach((id, controller) {
//                       amounts[id] = double.tryParse(controller.text) ?? 0.0;
//                     });

//                     print("AmountEntryModal: Confirming amounts: $amounts");
//                     Navigator.pop(context, amounts);
//                   },
//                   child: buttonContainer(context, "Confirm"),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 10,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget buttonContainer(context, str,
//     [color = AppColors.primaryColor, textColor = AppColors.bg5]) {
//   return Container(
//     width: MediaQuery.of(context).size.width / 2.3,
//     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//     decoration:
//         BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
//     child: Center(
//       child: Text(
//         str,
//         style: FontManager().getTextStyle(context,
//             lWeight: FontWeight.bold, fontSize: 15, color: textColor),
//       ),
//     ),
//   );
// }

// class ThousandsFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     if (newValue.text.isEmpty) {
//       return newValue.copyWith(text: '');
//     }

//     // Remove commas from old and new values for comparison
//     String oldText = oldValue.text.replaceAll(',', '');
//     String newText = newValue.text.replaceAll(',', '');

//     // Handle decimal part if present
//     List<String> parts = newText.split('.');
//     String integerPart = parts[0];
//     String decimalPart = parts.length > 1 ? '.' + parts[1] : '';

//     // Format integer part with commas
//     final RegExp regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
//     String formattedInteger =
//         integerPart.replaceAllMapped(regExp, (Match m) => '${m[1]},');
//     String finalText = formattedInteger + decimalPart;

//     // Calculate new cursor position
//     int oldCommaCount = oldText.split('').where((c) => c == ',').length;
//     int newCommaCount = finalText.split('').where((c) => c == ',').length;
//     int cursorOffset =
//         newValue.selection.baseOffset + (newCommaCount - oldCommaCount);

//     // Adjust cursor position to stay in the correct relative spot
//     if (cursorOffset < 0) cursorOffset = 0;
//     if (cursorOffset > finalText.length) cursorOffset = finalText.length;

//     return newValue.copyWith(
//       text: finalText,
//       selection: TextSelection.collapsed(offset: cursorOffset),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/manual_transaction.dart';

import 'dart:convert';

// import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';

//import 'package:get/get.dart';

import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';

import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

RxList addedUser = [].obs;
RxList addedMembers = [].obs;

class NewFriendsUi extends StatefulWidget {
  final bool showContinueButton;
  final double totalAmount;
  final String userId;
  final String userName;
  final String userAvatar;
  final bool isLendMode;
  final String? category;
  final String? subcategory;
  const NewFriendsUi({
    Key? key,
    this.showContinueButton = true,
    required this.totalAmount,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.isLendMode = false,
    this.category,
    this.subcategory,
  }) : super(key: key);

  @override
  _NewFriendsUiState createState() => _NewFriendsUiState();
}

class _NewFriendsUiState extends State<NewFriendsUi> {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.9,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, left: 18, right: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select people',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.bg1,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: InputDat('Search', TextInputType.name, textController),
              ),
              Text(
                'My friends',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.bg1,
                ),
              ),
              const SizedBox(height: 10),
              addedMembers.isNotEmpty
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / 5,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: addedMembers.map((element) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 6,
                            height: MediaQuery.of(context).size.width / 7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Center(
                                        child: AvatarProfileImage(
                                          url: element['avatar'] ??
                                              widget.userAvatar,
                                          width: 10,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            addedMembers.removeWhere((ele) =>
                                                ele['id'] == element['id']);
                                            addedUser.remove(element['id']);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    element['name'],
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 12,
                                      maxLines: 1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
              commentedData(),
              if (widget.showContinueButton)
                Center(
                  child: InkWell(
                    onTap: () async {
                      if (addedMembers.isNotEmpty) {
                        if (widget.isLendMode) {
                          if (addedMembers.length > 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please select only one friend for lending')),
                            );
                            return;
                          }
                          Navigator.pop(
                              context,
                              addedMembers[
                                  0]); // Return single friend’s details
                        } else {
                          Navigator.pop(context);
                          final amounts = await showAmountEntryModal(
                            context,
                            widget.category ?? 'Uncategorized',
                            widget.subcategory ?? 'General',
                          );
                         
                          if (amounts != null) {
                            Navigator.pop(context,
                                amounts); // Return amounts to TransactionHistory
                          }
                          ;
                          if (amounts != null) {
                           
                            Navigator.pop(
                                context, amounts); // Return amounts for split
                          } else {
                          
                          }
                        }
                      } else {
                       
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please select at least one friend')),
                        );
                      }
                    },
                    child: getButton(context, "Continue"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, double>?> showAmountEntryModal(
    BuildContext context,
    String category,
    String subcategory,
  ) async {
    return await showModalBottomSheet<Map<String, double>?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return AmountEntryModal(
          selectedFriends: addedMembers.toList(),
          totalAmount: widget.totalAmount,
          userId: widget.userId,
          userName: widget.userName,
          userAvatar: widget.userAvatar,
          cate: category,
          subcate: subcategory,
        );
      },
    );
  }

  Widget commentedData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              child: SizedBox(
                height: 70,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: frdsList.length,
                  itemBuilder: (context, index) {
                    String values = frdsList[index]['_id'];
                    return InkWell(
                      onTap: () {},
                      child: Column(
                        children: [
                          GestureDetector(
                            
                            onTap: () {
                              setState(() {
                                if (addedUser.contains(values)) {
                                  addedUser.remove(values);
                                  addedMembers.removeWhere(
                                      (element) => element['id'] == values);
                                } else if (widget.isLendMode &&
                                    addedMembers.isNotEmpty) {
                                  // For lend mode, replace the current selection
                                  addedUser.clear();
                                  addedMembers.clear();
                                  addedUser.add(values);
                                  addedMembers.add({
                                    "name": frdsList[index]['name'],
                                    "id": values,
                                    'avatar': frdsList[index]['avatar'],
                                    "balance": 200,
                                  });
                                 
                                } else {
                                  addedUser.add(values);
                                  addedMembers.add({
                                    "name": frdsList[index]['name'],
                                    "id": values,
                                    'avatar': frdsList[index]['avatar'],
                                    "balance": 200,
                                  });
                                }
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 5,
                              height: 50,
                              child: Stack(
                                children: [
                                  Center(
                                    child: AvatarProfileImage(
                                      url: frdsList[index]['avatar'] ??
                                          widget.userAvatar,
                                      width: 8,
                                      height: 18,
                                    ),
                                  ),
                                  addedUser.contains(values)
                                      ? const Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Icon(
                                            Icons.check,
                                            size: 30,
                                            color: Colors.green,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            frdsList[index]['name'],
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w400,
                              fontSize: 14,
                              color: AppColors.bg1,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget InputDat(String labelText, TextInputType keyboardType,
      TextEditingController controller) {
    return Center(
      child: Container(
        color: const Color.fromRGBO(246, 246, 246, 1),
        width: MediaQuery.of(context).size.width / 1.1,
        child: TextFormField(
          keyboardType: keyboardType,
          controller: controller,
          onChanged: (value) {
            var filteredList = [];
            if (value.isEmpty) {
              frdsList.clear();
              frdsList.addAll(frdsListOrigin);
            } else {
              frdsListOrigin.forEach((element) {
                if (element['name']
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase())) {
                  filteredList.add(element);
                }
              });
              setState(() {
                frdsList.clear();
                frdsList.addAll(filteredList);
              
              });
            }
          },
          decoration: InputDecoration(
            filled: true,
            hintText: labelText,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide:
                  const BorderSide(color: Color.fromRGBO(249, 246, 238, 1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide:
                  const BorderSide(color: Color.fromRGBO(246, 246, 246, 1)),
            ),
            fillColor: AppColors.button,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class AmountEntryModal extends StatefulWidget {
  final List selectedFriends;
  final double totalAmount;
  final String userId;
  final String userName;
  final String userAvatar;
  bool flag = true;
  final String? cate;
  final String? subcate;

  AmountEntryModal(
      {Key? key,
      required this.selectedFriends,
      required this.totalAmount,
      required this.userId,
      required this.userName,
      required this.userAvatar,
      this.flag=true,
      this.cate,
      this.subcate})
      : super(key: key);

  @override
  _AmountEntryModalState createState() => _AmountEntryModalState();
}

class _AmountEntryModalState extends State<AmountEntryModal> {
  Map<String, TextEditingController> amountControllers = {};
  double currentTotal = 0.0;
  double leftoverAmount = 0.0;
  double initialEqualAmount = 0.0; // Store initial values
  Map<String, bool> isModified = {};
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    int totalParticipants = widget.selectedFriends.length + 1;
    initialEqualAmount = widget.totalAmount / totalParticipants;

    amountControllers[widget.userId] = TextEditingController(
      text: initialEqualAmount.toStringAsFixed(2),
    );
    isModified[widget.userId] = false;
   
    widget.selectedFriends.forEach((friend) {
      amountControllers[friend['id']] = TextEditingController(
        text: initialEqualAmount.toStringAsFixed(2),
      );
      isModified[friend['id']] = false;
     });
    socket = IO.io(urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    setUpSocketListener();
    calculateTotal();
  }

  setUpSocketListener() {
    socket.on(
        "disconnect",
        (data) => {
              socket.close(),
            });
  }

  @override
  void dispose() {
    amountControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void calculateTotal() {
    currentTotal = 0.0;
    amountControllers.forEach((key, controller) {
      double amount =
          double.tryParse(controller.text.replaceAll(',', '')) ?? 0.0;
      // Cap individual amount at totalAmount
      if (amount > widget.totalAmount) {
        amount = widget.totalAmount;
        controller.text = amount.toStringAsFixed(2);
      }
      currentTotal += amount;
 
    });
    leftoverAmount = widget.totalAmount - currentTotal;
   
    setState(() {});
  }

  void settleLeftover() {
    if (leftoverAmount == 0) {
     
      return;
    }

    if (leftoverAmount < 0) {
     
      // Adjust amounts to fit totalAmount
      double overage = -leftoverAmount;
      List<String> adjustableParticipants = [];
      amountControllers.forEach((id, controller) {
        double amount =
            double.tryParse(controller.text.replaceAll(',', '')) ?? 0.0;
        if (amount > 0) {
          adjustableParticipants.add(id);
        }
      });
      double reductionPerPerson = overage / adjustableParticipants.length;

      for (var id in adjustableParticipants) {
        double currentAmount =
            double.tryParse(amountControllers[id]!.text.replaceAll(',', '')) ??
                0.0;
        double newAmount =
            (currentAmount - reductionPerPerson).clamp(0, widget.totalAmount);
        amountControllers[id]!.text = newAmount.toStringAsFixed(2);
       
      }
    } else {
      // Distribute positive leftover among unchanged participants
      List<String> unchangedParticipants = [];
      amountControllers.forEach((id, controller) {
        if (!isModified[id]!) {
          unchangedParticipants.add(id);
        }
      });

      if (unchangedParticipants.isEmpty) {
        unchangedParticipants = amountControllers.keys.toList();
       
      } else {
       
      }

      double leftoverPerPerson = leftoverAmount / unchangedParticipants.length;

      for (var id in unchangedParticipants) {
        double currentAmount =
            double.tryParse(amountControllers[id]!.text.replaceAll(',', '')) ??
                0.0;
        double newAmount =
            (currentAmount + leftoverPerPerson).clamp(0, widget.totalAmount);
        amountControllers[id]!.text = newAmount.toStringAsFixed(2);
       
      }
    }

    calculateTotal();
   
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context)
            .viewInsets
            .bottom, // Adjusts for keyboard height
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      duration: const Duration(milliseconds: 100), // Smooth animation
      curve: Curves.easeInOut,
      child: SingleChildScrollView(
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Amounts (Total: ₹${widget.totalAmount.toStringAsFixed(2)})',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AvatarProfileImage(
                        url: widget.userAvatar,
                        width: 10,
                        height: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.userName,
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 16,
                          color: AppColors.bg1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: amountControllers[widget.userId],
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ThousandsFormatter(),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.right,
                      onChanged: (value) {
                        isModified[widget.userId] = true;
                        calculateTotal();
                      },
                    ),
                  ),
                ],
              ),
            ),
            ...widget.selectedFriends.map((friend) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AvatarProfileImage(
                            url: friend['avatar'] ?? widget.userAvatar,
                            width: 10,
                            height: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            friend['name'],
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 16,
                              color: AppColors.bg1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: amountControllers[friend['id']],
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                            ThousandsFormatter(),
                          ],
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.currency_rupee, size: 18),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.right,
                          onChanged: (value) {
                            isModified[friend['id']] = true;
                            calculateTotal();
                          },
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            Text(
              'Current Total: ₹${currentTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Text(
              'Leftover: ₹${leftoverAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: leftoverAmount == 0
                    ? Colors.green
                    : leftoverAmount < 0
                        ? Colors.red
                        : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Click Settle to split leftover amount equally among all',
              style: FontManager().getTextStyle(
                context,
                fontSize: 12,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: settleLeftover,
                  child: buttonContainer(context, "Settle"),
                ),
                widget.flag
                    ? Center(
                        child: InkWell(
                          onTap: () {
                            if (leftoverAmount != 0) {
                              // Shows a snackbar and returns
                              return;
                            }
                            Map<String, double> amounts = {};
                            amountControllers.forEach((id, controller) {
                              amounts[id] = double.tryParse(
                                      controller.text.replaceAll(',', '')) ??
                                  0.0;
                            });
                            splitUserAmount(
                              context,
                              widget.totalAmount.toString(),
                              addedMembers,
                              widget.cate ?? 'Uncategorized',
                              widget.subcate ?? 'General',
                              amounts: amounts,
                            );
                            Navigator.pop(context, amounts);
                          },
                          child: buttonContainer(context, "Continue"),
                        ),
                      )
                    : InkWell(
                       onTap: () {
                    if (leftoverAmount != 0) {
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            leftoverAmount > 0
                                ? 'Please distribute the remaining ₹${leftoverAmount.toStringAsFixed(2)}'
                                : 'Total exceeds by ₹${(-leftoverAmount).toStringAsFixed(2)}',
                          ),
                        ),
                      );
                      return;
                    }
                    Map<String, double> amounts = {};
                    amountControllers.forEach((id, controller) {
                      amounts[id] = double.tryParse(controller.text) ?? 0.0;
                    });

               
                    Navigator.pop(context, amounts);
                  },
                  child: buttonContainer(context, "Confirm"),
                ),
                       
              ],
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  void addSocketMessage(
  List addedUser,
  String amount,
  String splitName,
  String splitID,
  double parsedTotalAmount,
) {
  if (addedUser.isEmpty) {
  
    return;
  }

  for (var rec in addedUser) {
    String room1 = rec['name'] + userName.value;
    String room2 = userName.value + rec['name'];
    String roomId = (room1.compareTo(room2) <= 0) ? room1 : room2;

    var jsonData = {
      "messageType": "split",
      "receiver": rec['id'],
      "sender": currentId.value,
      "message": null,
      "image": null,
      "poll": null,
      "post": null,
      "split": {
        "BillName": splitName,
        "Amount": parsedTotalAmount,
        "Share": amount,
        "isPaid": false,
        "splitId": splitID,
      },
      "roomId": roomId,
    };

    try {
      socket.emit("joinRoom", roomId);
      socket.emit("message", jsonData);
      String userToSend = rec['name'] + rec['name']; // Fix concatenation if needed
      socket.emit("LoadCharts", {"roomId": userToSend});
    
    } catch (e) {
     
    }
  }
}
  void splitUserAmount(
    BuildContext context,
    String totalAmount,
    List members,
    String category,
    String subcategory, {
    Map<String, double>? amounts, // Manual amounts including user's share
  }) async {
    double? parsedTotalAmount = double.tryParse(totalAmount);
    if (parsedTotalAmount == null || parsedTotalAmount <= 0) {
    
      snackBarCalled(context, "Invalid amount entered!", Colors.red);
      return;
    }
    

    if (members.isEmpty) {
      snackBarCalled(context, "No members selected!", Colors.red);
      return;
    }
    

    // Prepare paymentStatus list with individual amounts
    List<Map<String, dynamic>> nameList = [];
    double calculatedTotal = 0.0;

    if (amounts != null) {
      members.forEach((element) {
        double memberAmount = amounts[element['id']] ?? 0.0;
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': memberAmount,
        });
        calculatedTotal += memberAmount;
      });
      // Include the user's amount if present
      if (amounts.containsKey(currentId.value)) {
        double userAmount = amounts[currentId.value]!;
        nameList.add({
          'member': currentId.value,
          'markAsComplete': false,
          'amount': userAmount,
        });
        calculatedTotal += userAmount;
      }
    } else {
      double amountPerPerson = parsedTotalAmount / (members.length + 1);
      members.forEach((element) {
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': amountPerPerson,
        });
        calculatedTotal += amountPerPerson;
      });
      nameList.add({
        'member': currentId.value,
        'markAsComplete': false,
        'amount': amountPerPerson,
      });
      calculatedTotal += amountPerPerson;
      
    }

    // Verify total matches
    if ((calculatedTotal - parsedTotalAmount).abs() > 0.01) {
      // Allow small floating-point errors
      snackBarCalled(context, "Total amount mismatch!", Colors.red);
      return;
    }

    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    if (accessToken == null) {
      snackBarCalled(context, "Authentication error!", Colors.red);
      return;
    }

    final response = await http.post(
      Uri.parse('$url/split'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        "name": category,
        "subcategory": subcategory,
        "category": category,
        "amount": calculatedTotal,
        "paymentStatus": nameList,
        "image": '',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      splitID.value = body['id']['_id'];

      // Send notifications and socket messages with individual amounts
      for (var member in members) {
        double memberAmount = amounts?[member['id']] ??
            (parsedTotalAmount / (members.length + 1));
        String formattedAmount = memberAmount.toStringAsFixed(2);
        sendNotificationsToDevice(
          member['id'],
          context,
          "${userName.value} has sent you a Split Bill of $category ($subcategory) for ₹$formattedAmount",
        );
        addSocketMessage(
          [member],
          formattedAmount,
          category,
          splitID.value,
          parsedTotalAmount,
        );
      }

      snackBarCalled(context, "Split amount sent to users!", Colors.black);
      //Navigator.pop(context);
    } else {
      snackBarCalled(context, "Can't split, error!", Colors.red);
    }

    acceptReset.value = false;
  }
}

Widget buttonContainer(context, str,
    [color = AppColors.primaryColor, textColor = AppColors.bg5]) {
  return Container(
    width: MediaQuery.of(context).size.width / 2.3,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    decoration:
        BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
    child: Center(
      child: Text(
        str,
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.bold, fontSize: 15, color: textColor),
      ),
    ),
  );
}

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove commas from old and new values for comparison
    String oldText = oldValue.text.replaceAll(',', '');
    String newText = newValue.text.replaceAll(',', '');

    // Handle decimal part if present
    List<String> parts = newText.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.' + parts[1] : '';

    // Format integer part with commas
    final RegExp regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedInteger =
        integerPart.replaceAllMapped(regExp, (Match m) => '${m[1]},');
    String finalText = formattedInteger + decimalPart;

    // Calculate new cursor position
    int oldCommaCount = oldText.split('').where((c) => c == ',').length;
    int newCommaCount = finalText.split('').where((c) => c == ',').length;
    int cursorOffset =
        newValue.selection.baseOffset + (newCommaCount - oldCommaCount);

    // Adjust cursor position to stay in the correct relative spot
    if (cursorOffset < 0) cursorOffset = 0;
    if (cursorOffset > finalText.length) cursorOffset = finalText.length;

    return newValue.copyWith(
      text: finalText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
