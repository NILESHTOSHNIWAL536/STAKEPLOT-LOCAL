// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
// import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
// import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class VegNonVegCalculator extends StatefulWidget {
//   @override
//   _VegNonVegCalculatorState createState() => _VegNonVegCalculatorState();
// }

// class _VegNonVegCalculatorState extends State<VegNonVegCalculator> {
//   final TextEditingController vegController = TextEditingController();
//   final TextEditingController nonVegController = TextEditingController();
//   final TextEditingController alcoholController = TextEditingController();

//   Map<String, List<String>> selectedOptions = {};
//   TextEditingController Textcontroller = TextEditingController();
//   List<Map<dynamic, dynamic>> get friends =>
//       userController.friendsList.map((e) => e as Map<dynamic, dynamic>).toList();

//   List<String> options = [
//     PlotFinanceStaticData().vegLabel, // Updated
//     PlotFinanceStaticData().nonVegLabel, // Updated
//     PlotFinanceStaticData().alcoholLabel // Updated
//   ];
//   Map<String, Map<String, double>> friendShares = {};

//   RxList addedUser = [].obs;
//   RxList addedMembers = [].obs;
//   late IO.Socket socket;

//   @override
//   void initState() {
//     super.initState();

//     // Add the current user to addedMembers
//     _addCurrentUserToMembers();

//     // Initialize selectedOptions for all friends
//     for (var friend in friends) {
//       String friendId = friend['_id'];
//       if (!selectedOptions.containsKey(friendId)) {
//         selectedOptions[friendId] = [];
//       }
//     }

//     socket = IO.io(urlWithLocallHost,
//         IO.OptionBuilder().setTransports(['websocket']).build());
//     setUpSocketListener();
//   }

//   void _addCurrentUserToMembers() {
//     String currentUserId = userController.userId.value;
//     String currentUserName = ControllerManagement.userController.userName.value;
//     String? currentUserAvatar =ControllerManagement.userController. avatar.value;

//     if (!addedMembers.any((member) => member['id'] == currentUserId)) {
//       setState(() {
//         addedMembers.add({
//           "name": currentUserName,
//           "id": currentUserId,
//           "avatar": currentUserAvatar,
//           "balance": 0
//         });
//         addedUser.add(currentUserId);
//         selectedOptions[currentUserId] = [];
//       });
//     }
//   }

//   void setUpSocketListener() {
//     socket.on("disconnect", (data) => {socket.close()});
//   }

//   void _calculateShares() {
//     setState(() {
//       double totalVeg = double.tryParse(vegController.text) ?? 0.0;
//       double totalNonVeg = double.tryParse(nonVegController.text) ?? 0.0;
//       double totalAlcohol = double.tryParse(alcoholController.text) ?? 0.0;

//       friendShares = {};

//       for (var friend in addedMembers) {
//         String? friendId = friend['id'];
//         if (friendId != null) {
//           friendShares[friendId] = {
//             'Veg': 0.0,
//             'Non veg': 0.0,
//             'Alcohol': 0.0,
//             'Total': 0.0
//           };
//         }
//       }

//       for (var friend in addedMembers) {
//         String? friendId = friend['id'];
//         if (friendId != null) {
//           List choices = selectedOptions[friendId] ?? [];

//           if (choices.contains('Veg')) {
//             int vegFriends = addedMembers
//                 .where(
//                     (f) => selectedOptions[f['id']]?.contains('Veg') ?? false)
//                 .length;
//             friendShares[friendId]!['Veg'] =
//                 vegFriends > 0 ? totalVeg / vegFriends : 0.0;
//           }
//           if (choices.contains('Non veg')) {
//             int nonVegFriends = addedMembers
//                 .where((f) =>
//                     selectedOptions[f['id']]?.contains('Non veg') ?? false)
//                 .length;
//             friendShares[friendId]!['Non veg'] =
//                 nonVegFriends > 0 ? totalNonVeg / nonVegFriends : 0.0;
//           }
//           if (choices.contains('Alcohol')) {
//             int alcoholFriends = addedMembers
//                 .where((f) =>
//                     selectedOptions[f['id']]?.contains('Alcohol') ?? false)
//                 .length;
//             friendShares[friendId]!['Alcohol'] =
//                 alcoholFriends > 0 ? totalAlcohol / alcoholFriends : 0.0;
//           }

//           friendShares[friendId]!['Total'] = friendShares[friendId]!['Veg']! +
//               friendShares[friendId]!['Non veg']! +
//               friendShares[friendId]!['Alcohol']!;
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         title: Text(
//           PlotFinanceStaticData().foodieFundsTitle,
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.w600,
//             fontSize: 18,
//             color: AppColors.bg1,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Fixed top section: Input fields
//             Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildInputColumn(PlotFinanceStaticData().vegLabel,
//                       vegController), // Updated
//                   _buildInputColumn(PlotFinanceStaticData().nonVegLabel,
//                       nonVegController), // Updated
//                   _buildInputColumn(PlotFinanceStaticData().alcoholLabel,
//                       alcoholController), // Updated
//                 ],
//               ),
//             ),
//             // Fixed search bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
//               child: InputDat(PlotFinanceStaticData().searchHint,
//                   TextInputType.name, Textcontroller),
//             ),
//             // Scrollable section: commentedData and vegNonvegdata
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     commentedData(),
//                     vegNonvegdata(),
//                   ],
//                 ),
//               ),
//             ),
//             // Fixed bottom section: Calculation
//             Container(
//               color: AppColors.backgroundColor,
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: calculation(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget calculation() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10, top: 2),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 8, right: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 GestureDetector(
//                   // onTap: () {
//                   //   splitUserAmountFood(context, "3000", addedMembers,
//                   //       "foodie split", "Veg & Non Veg", friendShares);
//                   // },
//                   onTap: () {
//                     double totalVeg =
//                         double.tryParse(vegController.text) ?? 0.0;
//                     double totalNonVeg =
//                         double.tryParse(nonVegController.text) ?? 0.0;
//                     double totalAlcohol =
//                         double.tryParse(alcoholController.text) ?? 0.0;

//                     // Check if at least one category has a valid amount
//                     bool hasValidAmount =
//                         totalVeg > 0 || totalNonVeg > 0 || totalAlcohol > 0;

//                     // Check if there are shares for the added members
//                     bool hasShares = addedMembers.any((member) {
//                       String? friendId = member['id'];
//                       return friendShares[friendId]?['Total'] != null &&
//                           (friendShares[friendId]!['Total'] ?? 0) > 0;
//                     });

//                     if (hasValidAmount && hasShares) {
//                       // Proceed with the split if conditions are met
//                       splitUserAmountFood(
//                           context,
//                           (totalVeg + totalNonVeg + totalAlcohol).toString(),
//                           addedMembers,
//                           "foodie split",
//                           "Veg & Non Veg",
//                           friendShares);
//                     } else {
//                       // Show a message to the user that they need to add money or select shares
//                       snackBarCalledfail(
//                           context, SnackbarData().validAmountAndShares);
//                     }
//                   },
//                   child: Container(
//                     width: MediaQuery.of(context).size.width / 2.2,
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//                     decoration: BoxDecoration(
//                       color: AppColors.button,
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: Center(
//                       child: Text(
//                         PlotFinanceStaticData().billSplitButton, // Updated
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.bold,
//                           fontSize: 15,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   // onTap: () {
//                   //   friendShares.forEach((key, value) {
//                   //     if (key != userController.userId.value) {
//                   //       // added this line for excluding current user in notify
//                   //       sendNotificationsToDevice(
//                   //           key,
//                   //           context,
//                   //           "${userName.value} has shared the foodie expense of ${value!['Total'] ?? "0000"}",
//                   //           "/remainders", "",
//                   //                       "",
//                   //                       "Notified successfully");

//                   //     }
//                   //   });
//                   // },
//                   onTap: () {
//                     // Check if friendShares is null or empty
//                     if (friendShares == null || friendShares.isEmpty) {
//                       snackBarCalledfail(
//                           context, SnackbarData().noSharesCalculated);
//                       return;
//                     }

//                     // Check if currentId is null
//                     if (userController.userId.value == null) {
//                       snackBarCalledfail(
//                           context, SnackbarData().userIdNotAvailable);
//                       return;
//                     }

//                     // Check if userName is null
//                     String name=ControllerManagement.userController.userName.value;
//                     if ( name.isEmpty) {
//                       snackBarCalledfail(
//                           context, SnackbarData().userNameNotAvailable);
//                       return;
//                     }

//                     // Check if there are valid recipients other than the current user
//                     bool hasValidRecipients =
//                         friendShares.keys.any((key) => key != userController.userId.value);

//                     if (!hasValidRecipients) {
//                       snackBarCalledfail(
//                           context, SnackbarData().noFriendsToNotify);
//                       return;
//                     }

//                     // Check if shares have valid amounts
//                     bool hasValidShares = friendShares.entries.any((entry) {
//                       String? key = entry.key;
//                       var value = entry.value;
//                       return key != null &&
//                           key != userController.userId.value &&
//                           value != null &&
//                           value['Total'] != null &&
//                           (value['Total'] is double || value['Total'] is int) &&
//                           (value['Total'] as num) > 0;
//                     });

//                     if (!hasValidShares) {
//                       snackBarCalledfail(
//                           context, SnackbarData().noValidSharesToNotify);
//                       return;
//                     }

//                     // Proceed with sending notifications
//                     bool atLeastOneNotificationSent = false;
//                     friendShares.forEach((key, value) {
//                       if (key != null && key != userController.userId.value) {
//                         // Ensure value and total are valid
//                         if (value != null &&
//                             value['Total'] != null &&
//                             (value['Total'] is num) &&
//                             (value['Total'] as num) > 0) {
//                           try {
//                             sendNotificationsToDevice(
//                               key,
//                               context,
//                               "${name} has shared the foodie expense of ₹${(value['Total'] as num).toStringAsFixed(2)}",
//                               "/remainders",
//                               "",
//                               "",
//                               "Notified successfully",
//                             );
//                             atLeastOneNotificationSent = true;
//                             Navigator.pop(context);
//                           } catch (e) {
//                             // Handle notification sending failure
//                             snackBarCalledfail(context,
//                                 SnackbarData().failedToSendNotification);
//                           }
//                         } else {
//                           // Log or show warning for invalid share
//                           snackBarCalledfail(
//                               context, SnackbarData().invalidShareAmount);
//                         }
//                       }
//                     });

//                     // Show success message if at least one notification was sent
//                     if (atLeastOneNotificationSent) {
//                     } else {
//                       snackBarCalledfail(
//                           context, SnackbarData().noNotificationsSent);
//                     }
//                   },
//                   child: Container(
//                     width: MediaQuery.of(context).size.width / 2.2,
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//                     decoration: BoxDecoration(
//                       color: AppColors.button,
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: Center(
//                       child: Text(
//                         PlotFinanceStaticData().notifyButton,
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.bold,
//                           fontSize: 15,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 10),
//           // GestureDetector(
//           //   onTap: () {
//           //     _calculateShares();
//           //   },
//           //   child: getButton(context, PlotFinanceStaticData().calculateButton),
//           // ),
//         ],
//       ),
//     );
//   }

//   Widget vegNonvegdata() {
//     return ListView.builder(
//       shrinkWrap: true, // Takes only the space it needs
//       physics:
//           NeverScrollableScrollPhysics(), // Parent SingleChildScrollView handles scrolling
//       itemCount: addedMembers.length,
//       itemBuilder: (context, index) {
//         var friend = addedMembers[index];
//         String? friendId = friend['id'];
//         bool isCurrentUser = friendId == userController.userId.value;

//         return ListTile(
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Stack(
//                     alignment: Alignment.topRight,
//                     children: [
//                       AvatarProfile(
//                         background: friend['avatarBackGround'] ??
//                             defaultBackGround.value,
//                         width: 8,
//                         height: 18,
//                         name: friend['name'],
//                       ),
//                       if (!isCurrentUser)
//                         GestureDetector(
//                           onTap: () {
//                             addedMembers.removeWhere(
//                                 (member) => member['id'] == friendId);
//                             addedUser.remove(friendId);
//                             selectedOptions.remove(friendId);
//                             _calculateShares();
//                           },
//                           child: Container(
//                             padding: EdgeInsets.all(2),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.close,
//                               size: 16,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   SizedBox(width: 8), // Space between avatar and name
//                   Text(
//                     friend['name'] ?? 'Unknown',
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w500,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Text(
//                     '₹${friendShares[friendId]?['Total']?.toStringAsFixed(2) ?? "0.00"}',
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w500,
//                       fontSize: 16,
//                       color: AppColors.bg3,
//                     ),
//                   ),
//                   SizedBox(width: 8), // Space before remove icon
//                 ],
//               ),
//             ],
//           ),
//           subtitle: Wrap(
//             children: options.map((option) {
//               bool isSelected =
//                   selectedOptions[friendId]?.contains(option) == true;
//               bool isDisabled =
//                   (option == 'Veg' && vegController.text.isEmpty) ||
//                       (option == 'Non veg' && nonVegController.text.isEmpty) ||
//                       (option == 'Alcohol' && alcoholController.text.isEmpty);
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: ChoiceChip(
//                   label: Text(
//                     option,
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.w700,
//                         fontSize: 14,
//                         color: isSelected
//                             ? AppColors.backgroundColor
//                             : AppColors.accentColor),
//                   ),
//                   selected: isSelected,
//                   showCheckmark: false,
//                   selectedColor: AppColors.primaryColor,
//                   backgroundColor: AppColors.mt,
//                   onSelected: isDisabled
//                       ? null
//                       : (selected) {
//                           setState(() {
//                             if (friendId != null) {
//                               if (selected) {
//                                 selectedOptions
//                                     .putIfAbsent(friendId, () => [])
//                                     .add(option);
//                               } else {
//                                 selectedOptions[friendId]?.remove(option);
//                                 if (selectedOptions[friendId]?.isEmpty ??
//                                     false) {
//                                   selectedOptions.remove(friendId);
//                                 }
//                               }
//                               _calculateShares();
//                             }
//                           });
//                         },
//                 ),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }

//   Widget commentedData() {
//     List limitedFriends = userController.friendsList.take(4).toList();

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           limitedFriends.isEmpty
//               ? Center(
//                   child: Text(
//                     PlotFinanceStaticData().noFriendsAvailable,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w500,
//                       fontSize: 16,
//                       color: AppColors.bg3,
//                     ),
//                   ),
//                 )
//               : GridView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                   ),
//                   itemCount: limitedFriends.length,
//                   itemBuilder: (context, index) {
//                     String id = limitedFriends[index]['_id'];
//                     bool isSelected = addedUser.contains(id);

//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           if (isSelected) {
//                             addedUser.remove(id);
//                             addedMembers
//                                 .removeWhere((member) => member['id'] == id);
//                             selectedOptions.remove(id);
//                           } else {
//                             addedUser.add(id);
//                             addedMembers.add({
//                               "name": limitedFriends[index]['name'],
//                               "id": id,
//                               'avatar': limitedFriends[index]['avatar'],
//                               'avatarBackGround': limitedFriends[index]
//                                   ['avatarBackGround'],
//                               "balance": 200,
//                             });
//                             selectedOptions[id] = [];
//                           }
//                         });
//                       },
//                       child: Card(
//                         elevation: 1,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         color: isSelected
//                             ? Colors.green[50]
//                             : AppColors.backgroundColor,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 2, vertical: 5),
//                           child: Row(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(1.0),
//                                 child: AvatarProfile(
//                                   name: limitedFriends[index]['name'],
//                                   width: 10,
//                                   height: 10,
//                                   background: limitedFriends[index]['avatarBackGround'] ?? "",
//                                   flag: true,
//                                   fontsize: 7,
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   limitedFriends[index]['name'],
//                                   overflow: TextOverflow.ellipsis,
//                                   style: FontManager().getTextStyle(
//                                     context,
//                                     lWeight: FontWeight.w400,
//                                     fontSize: 14,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                               Checkbox(
//                                 value: isSelected,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value!) {
//                                       addedUser.add(id);
//                                       addedMembers.add({
//                                         "name": limitedFriends[index]['name'],
//                                         "id": id,
//                                         'avatar': limitedFriends[index]
//                                             ['avatar'],
//                                         'avatarBackGround':
//                                             limitedFriends[index]
//                                                 ['avatarBackGround'],
//                                         "balance": 200,
//                                       });
//                                       selectedOptions[id] = [];
//                                     } else {
//                                       addedUser.remove(id);
//                                       addedMembers.removeWhere(
//                                           (member) => member['id'] == id);
//                                       selectedOptions.remove(id);
//                                     }
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ],
//       ),
//     );
//   }

//   Widget InputDat(String labelText, TextInputType keyboard,
//       TextEditingController textController) {
//     return Center(
//       child: Container(
//         width: MediaQuery.of(context).size.width / 1.1,
//         height: MediaQuery.of(context).size.height / 20,
//         child: Center(
//           child: TextFormField(
//             keyboardType: keyboard,
//             controller: textController,
            
//             onChanged: (v) {
//               List filtered = [];

//               if (v.trim().isEmpty) {
//                 filtered = userController.frdsListOrigin;
//               } else {
//                 filtered =  userController.frdsListOrigin.where((element) {
//                   String name = element['name'].toString().toLowerCase();
//                   return name.contains(v.toLowerCase());
//                 }).toList();
//               }

//               List limited = filtered.take(4).toList();

//               setState(() {
//                userController.friendsList.clear();
//                  userController.friendsList.addAll(limited);
//               });
//             },
//             decoration: InputDecoration(
//               filled: true,
//               hintText: labelText,
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(24),
//                 borderSide:
//                     const BorderSide(color: Color.fromRGBO(249, 246, 238, 1)),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(24),
//                 borderSide:
//                     const BorderSide(color: Color.fromRGBO(246, 246, 246, 1)),
//               ),
//               fillColor: AppColors.button,
//               border: InputBorder.none,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputColumn(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
//       child: Column(
//         children: [
//           Text(
//             label,
//             style: FontManager().getTextStyle(
//               context,
//               lWeight: FontWeight.w600,
//               fontSize: 14,
//               color: AppColors.primaryColor,
//             ),
//           ),
//           SizedBox(height: Colorcodes.paddingSize / 2),
//           SizedBox(
//             width: MediaQuery.of(context).size.width / 3 - 33,
//             child: TextField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               onTapOutside: (event) {
//     FocusScope.of(context).unfocus(); // This will dismiss the keyboard
//   },
//               inputFormatters: allowDecimalInput(),
//               onSubmitted: (_) => FocusScope.of(context).unfocus(),
//               onChanged: (value) {
//                 _calculateShares();
//               },
//               decoration: InputDecoration(
//                 contentPadding:
//                     EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void addSocketMessage(addedUser, String amount, String splitName,
//       String splitID, double totalAmount) {
//     if (addedUser.isEmpty) return;

//     addedUser.forEach((rec) {
//       String room1 = rec['name'] +  userController.userName.value;
//       String room2 = userController. userName.value + rec['name'];
//       String roomId = (room1.compareTo(room2) <= 0) ? room1 : room2;

//       var jsonData = {
//         "messageType": "split",
//         "receiver": rec['id'],
//         "sender": userController.userId.value,
//         "message": null,
//         "image": null,
//         "poll": null,
//         "post": null,
//         "split": {
//           "BillName": splitName,
//           "Amount": totalAmount.toString(),
//           "Share": rec['amount'],
//           "isPaid": false,
//           "splitId": splitID,
//         },
//         "roomId": roomId,
//       };

//       socket.emit("joinRoom", roomId);
//       socket.emit("message", jsonData);
//       String userToSend = rec['name'] + "" + rec['name'];
//       socket.emit("LoadCharts", {"roomId": userToSend});
//     });
//   }

//   void splitUserAmountFood(context, String amount, List members, String name,
//       String subCategories, dynamic shareFriends) async {
//     List nameList = [];
//     double totalAmount = 0.0;

//     members.forEach((element) {
//       String id = element['id'];
//       var data = shareFriends[id];
//       totalAmount += data['Total'];
//       nameList.add({
//         'id': id,
//         'name': element['name'],
//         'member': id,
//         'markAsComplete': false,
//         'amount': doubleToFixed(data['Total'].toString()),
//         'isVegNonVeg': true,
//         'priorities': data,
//       });
//     });
//     final SharedPreferences _pref = await SharedPreferences.getInstance();
//     var accessToken = _pref.getString("accessToken");

//     final requestBody = {
//       "name": name,
//       "subcategory": subCategories,
//       "category:": name,
//       "amount": totalAmount,
//       "paymentStatus": nameList,
//       "image": '',
//       'isVegNonVeg': true,
//       "ismanual": true,
//       'isFoodie': true
//     };

//     final response = await http.post(
//       Uri.parse('${url}/split'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         "Authorization": "$accessToken",
//       },
//       body: jsonEncode(requestBody),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final body = json.decode(response.body);
//       splitID.value = body['id']['_id'];

//       List<dynamic> uniqueNameList =
//           {for (var item in nameList) item['id']: item}.values.toList();

//       uniqueNameList.forEach((e) {
//         for (var e in nameList) {
//           if (e['id'] != userController.userId.value) {
//             // Log notification details

//             sendNotificationsToDevice(
//                 e['id'],
//                 context,
//                 "${ userController.userName.value} has sent you a ${name} Of ${e['amount']}",
//                 "/chat");
//           }
//         }
//       });

//       addSocketMessage(nameList, amount.toString(), "Calculation".toString(),
//           splitID.value, totalAmount);

//       snackBarCalled(context, SnackbarData().splitAmountSent);
//       Navigator.pop(context);
//     } else {
//       snackBarCalledfail(context, SnackbarData().authenticationError, Colors.red);
//     }
//     acceptReset.value = false;
//   }
// }

// String doubleToFixed(String number) {
//   double value = double.parse(number);
//   return value.toStringAsFixed(2);
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// // Assuming these are defined in your project
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
// import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
// import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';

// class VegNonVegCalculator extends StatefulWidget {
//   @override
//   _VegNonVegCalculatorState createState() => _VegNonVegCalculatorState();
// }

// class _VegNonVegCalculatorState extends State<VegNonVegCalculator> {
//   // Replace fixed controllers with a dynamic list of category objects
//   List<Map<String, dynamic>> categories = [
//     {
//       'name': PlotFinanceStaticData().vegLabel,
//       'controller': TextEditingController(),
//       'isCustom': false,
//     },
//     {
//       'name': PlotFinanceStaticData().nonVegLabel,
//       'controller': TextEditingController(),
//       'isCustom': false,
//     },
//     {
//       'name': PlotFinanceStaticData().alcoholLabel,
//       'controller': TextEditingController(),
//       'isCustom': false,
//     },
//   ];

//   final TextEditingController newCategoryController = TextEditingController();
//   Map<String, List<String>> selectedOptions = {};
//   final TextEditingController searchController = TextEditingController();
//   Map<String, Map<String, double>> friendShares = {};

//   RxList addedUser = [].obs;
//   RxList addedMembers = [].obs;
//   late IO.Socket socket;

//   List<Map<dynamic, dynamic>> get friends =>
//       userController.friendsList.map((e) => e as Map<dynamic, dynamic>).toList();

//   @override
//   void initState() {
//     super.initState();
//     _addCurrentUserToMembers();
//     for (var friend in friends) {
//       String friendId = friend['_id'];
//       selectedOptions[friendId] = [];
//     }
//     socket = IO.io(
//         urlWithLocallHost, IO.OptionBuilder().setTransports(['websocket']).build());
//     setUpSocketListener();
//   }

//   void _addCurrentUserToMembers() {
//     String currentUserId = userController.userId.value;
//     String currentUserName = ControllerManagement.userController.userName.value;
//     String? currentUserAvatar = ControllerManagement.userController.avatar.value;

//     if (!addedMembers.any((member) => member['id'] == currentUserId)) {
//       setState(() {
//         addedMembers.add({
//           "name": currentUserName,
//           "id": currentUserId,
//           "avatar": currentUserAvatar,
//           "balance": 0
//         });
//         addedUser.add(currentUserId);
//         selectedOptions[currentUserId] = [];
//       });
//     }
//   }

//   void setUpSocketListener() {
//     socket.on("disconnect", (data) => {socket.close()});
//   }

//   void _addCustomCategory() {
//     if (categories.where((c) => c['isCustom']).length >= 2) {
//       snackBarCalledfail(context, 'Maximum of 2 custom categories allowed');
//       return;
//     }
//     if (newCategoryController.text.trim().isEmpty) {
//       snackBarCalledfail(context, 'Please enter a category name');
//       return;
//     }
//     setState(() {
//       categories.add({
//         'name': newCategoryController.text.trim(),
//         'controller': TextEditingController(),
//         'isCustom': true,
//       });
//       newCategoryController.clear();
//       // Update selectedOptions for all members
//       for (var member in addedMembers) {
//         String? friendId = member['id'];
//         if (friendId != null && !selectedOptions.containsKey(friendId)) {
//           selectedOptions[friendId] = [];
//         }
//       }
//     });
//   }

//   void _editCategoryName(int index, String newName) {
//     if (newName.trim().isEmpty) {
//       snackBarCalledfail(context, 'Category name cannot be empty');
//       return;
//     }
//     setState(() {
//       String oldName = categories[index]['name'];
//       categories[index]['name'] = newName.trim();
//       // Update selectedOptions to reflect new category name
//       for (var friendId in selectedOptions.keys) {
//         if (selectedOptions[friendId]!.contains(oldName)) {
//           selectedOptions[friendId]!.remove(oldName);
//           selectedOptions[friendId]!.add(newName.trim());
//         }
//       }
//       _calculateShares();
//     });
//   }

//   void _removeCustomCategory(int index) {
//     setState(() {
//       String categoryName = categories[index]['name'];
//       categories.removeAt(index);
//       // Remove category from selectedOptions
//       for (var friendId in selectedOptions.keys) {
//         selectedOptions[friendId]!.remove(categoryName);
//         if (selectedOptions[friendId]!.isEmpty) {
//           selectedOptions.remove(friendId);
//         }
//       }
//       _calculateShares();
//     });
//   }

//   void _calculateShares() {
//     setState(() {
//       friendShares = {};
//       for (var friend in addedMembers) {
//         String? friendId = friend['id'];
//         if (friendId != null) {
//           friendShares[friendId] = {for (var cat in categories) cat['name']: 0.0};
//           friendShares[friendId]!['Total'] = 0.0;
//         }
//       }

//       for (var friend in addedMembers) {
//         String? friendId = friend['id'];
//         if (friendId != null) {
//           List choices = selectedOptions[friendId] ?? [];
//           for (var category in categories) {
//             String catName = category['name'];
//             double totalAmount = double.tryParse(category['controller'].text) ?? 0.0;
//             if (choices.contains(catName)) {
//               int participants = addedMembers
//                   .where((f) => selectedOptions[f['id']]?.contains(catName) ?? false)
//                   .length;
//               friendShares[friendId]![catName] =
//                   participants > 0 ? totalAmount / participants : 0.0;
//             }
//             friendShares[friendId]!['Total'] = friendShares[friendId]!
//                 .entries
//                 .where((e) => e.key != 'Total')
//                 .fold(0.0, (sum, e) => sum + e.value);
//           }
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         title: Text(
//           PlotFinanceStaticData().foodieFundsTitle,
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.w600,
//             fontSize: 18,
//             color: AppColors.bg1,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Input fields for categories
//             Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: Wrap(
//                 spacing: 8.0,
//                 runSpacing: 8.0,
//                 children: [
//                   for (int i = 0; i < categories.length; i++)
//                     _buildInputColumn(
//                       categories[i]['name'],
//                       categories[i]['controller'],
//                       i,
//                       categories[i]['isCustom'],
//                     ),
//                   if (categories.where((c) => c['isCustom']).length < 2)
//                     _buildAddCategoryField(),
//                 ],
//               ),
//             ),
//             // Search bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
//               child: InputDat(PlotFinanceStaticData().searchHint,
//                   TextInputType.name, searchController),
//             ),
//             // Scrollable section
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     commentedData(),
//                     vegNonvegdata(),
//                   ],
//                 ),
//               ),
//             ),
//             // Calculation section
//             Container(
//               color: AppColors.backgroundColor,
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: calculation(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInputColumn(
//       String label, TextEditingController controller, int index, bool isCustom) {
//     TextEditingController nameController = TextEditingController(text: label);
//     return Container(
//       width: MediaQuery.of(context).size.width / 3 - 20,
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: nameController,
//                   decoration: InputDecoration(
//                     hintText: 'Category Name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                   onSubmitted: (value) => _editCategoryName(index, value),
//                 ),
//               ),
//               if (isCustom)
//                 IconButton(
//                   icon: Icon(Icons.delete, color: Colors.red),
//                   onPressed: () => _removeCustomCategory(index),
//                 ),
//             ],
//           ),
//           SizedBox(height: Colorcodes.paddingSize / 2),
//           TextField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             onTapOutside: (event) => FocusScope.of(context).unfocus(),
//             inputFormatters: allowDecimalInput(),
//             onChanged: (value) => _calculateShares(),
//             decoration: InputDecoration(
//               contentPadding:
//                   EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddCategoryField() {
//     return Container(
//       width: MediaQuery.of(context).size.width / 3 - 20,
//       child: Column(
//         children: [
//           TextField(
//             controller: newCategoryController,
//             decoration: InputDecoration(
//               hintText: 'New Category',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//             ),
//           ),
//           SizedBox(height: Colorcodes.paddingSize / 2),
//           ElevatedButton(
//             onPressed: _addCustomCategory,
//             child: Text('Add Category'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget calculation() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10, top: 2),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 8, right: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     double totalAmount = categories.fold(
//                         0.0,
//                         (sum, cat) =>
//                             sum + (double.tryParse(cat['controller'].text) ?? 0.0));
//                     bool hasValidAmount = totalAmount > 0;
//                     bool hasShares = addedMembers.any((member) =>
//                         friendShares[member['id']]?['Total'] != null &&
//                         friendShares[member['id']]!['Total']! > 0);

//                     if (hasValidAmount && hasShares) {
//                       splitUserAmountFood(
//                           context,
//                           totalAmount.toString(),
//                           addedMembers,
//                           "foodie split",
//                           "Custom Categories",
//                           friendShares);
//                     } else {
//                       snackBarCalledfail(
//                           context, SnackbarData().validAmountAndShares);
//                     }
//                   },
//                   child: Container(
//                     width: MediaQuery.of(context).size.width / 2.2,
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//                     decoration: BoxDecoration(
//                       color: AppColors.button,
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: Center(
//                       child: Text(
//                         PlotFinanceStaticData().billSplitButton,
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.bold,
//                           fontSize: 15,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     if (friendShares.isEmpty) {
//                       snackBarCalledfail(
//                           context, SnackbarData().noSharesCalculated);
//                       return;
//                     }
//                     if (userController.userId.value == null) {
//                       snackBarCalledfail(
//                           context, SnackbarData().userIdNotAvailable);
//                       return;
//                     }
//                     String name = ControllerManagement.userController.userName.value;
//                     if (name.isEmpty) {
//                       snackBarCalledfail(
//                           context, SnackbarData().userNameNotAvailable);
//                       return;
//                     }
//                     bool hasValidRecipients = friendShares.keys
//                         .any((key) => key != userController.userId.value);
//                     if (!hasValidRecipients) {
//                       snackBarCalledfail(
//                           context, SnackbarData().noFriendsToNotify);
//                       return;
//                     }
//                     bool hasValidShares = friendShares.entries.any((entry) =>
//                         entry.key != userController.userId.value &&
//                         entry.value['Total'] != null &&
//                         (entry.value['Total'] as num) > 0);
//                     if (!hasValidShares) {
//                       snackBarCalledfail(
//                           context, SnackbarData().noValidSharesToNotify);
//                       return;
//                     }

//                     bool atLeastOneNotificationSent = false;
//                     friendShares.forEach((key, value) {
//                       if (key != userController.userId.value &&
//                           value['Total'] != null &&
//                           (value['Total'] as num) > 0) {
//                         try {
//                           sendNotificationsToDevice(
//                             key,
//                             context,
//                             "${name} has shared the foodie expense of ₹${(value['Total'] as num).toStringAsFixed(2)}",
//                             "/remainders",
//                             "",
//                             "",
//                             "Notified successfully",
//                           );
//                           atLeastOneNotificationSent = true;
//                           Navigator.pop(context);
//                         } catch (e) {
//                           snackBarCalledfail(
//                               context, SnackbarData().failedToSendNotification);
//                         }
//                       }
//                     });
//                     if (!atLeastOneNotificationSent) {
//                       snackBarCalledfail(
//                           context, SnackbarData().noNotificationsSent);
//                     }
//                   },
//                   child: Container(
//                     width: MediaQuery.of(context).size.width / 2.2,
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//                     decoration: BoxDecoration(
//                       color: AppColors.button,
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: Center(
//                       child: Text(
//                         PlotFinanceStaticData().notifyButton,
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.bold,
//                           fontSize: 15,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget vegNonvegdata() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: addedMembers.length,
//       itemBuilder: (context, index) {
//         var friend = addedMembers[index];
//         String? friendId = friend['id'];
//         bool isCurrentUser = friendId == userController.userId.value;

//         return ListTile(
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Stack(
//                     alignment: Alignment.topRight,
//                     children: [
//                       AvatarProfile(
//                         background:
//                             friend['avatarBackGround'] ?? defaultBackGround.value,
//                         width: 8,
//                         height: 18,
//                         name: friend['name'],
//                       ),
//                       if (!isCurrentUser)
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               addedMembers
//                                   .removeWhere((member) => member['id'] == friendId);
//                               addedUser.remove(friendId);
//                               selectedOptions.remove(friendId);
//                               _calculateShares();
//                             });
//                           },
//                           child: Container(
//                             padding: EdgeInsets.all(2),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.close,
//                               size: 16,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     friend['name'] ?? 'Unknown',
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w500,
//                       fontSize: 16,
//                       color: AppColors.bg1,
//                     ),
//                   ),
//                 ],
//               ),
//               Text(
//                 '₹${friendShares[friendId]?['Total']?.toStringAsFixed(2) ?? "0.00"}',
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.w500,
//                   fontSize: 16,
//                   color: AppColors.bg3,
//                 ),
//               ),
//             ],
//           ),
//           subtitle: Wrap(
//             children: categories.map((category) {
//               String option = category['name'];
//               bool isSelected = selectedOptions[friendId]?.contains(option) == true;
//               bool isDisabled = category['controller'].text.isEmpty;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: ChoiceChip(
//                   label: Text(
//                     option,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w700,
//                       fontSize: 14,
//                       color: isSelected
//                           ? AppColors.backgroundColor
//                           : AppColors.accentColor,
//                     ),
//                   ),
//                   selected: isSelected,
//                   showCheckmark: false,
//                   selectedColor: AppColors.primaryColor,
//                   backgroundColor: AppColors.mt,
//                   onSelected: isDisabled
//                       ? null
//                       : (selected) {
//                           setState(() {
//                             if (friendId != null) {
//                               if (selected) {
//                                 selectedOptions.putIfAbsent(friendId, () => []).add(option);
//                               } else {
//                                 selectedOptions[friendId]?.remove(option);
//                                 if (selectedOptions[friendId]?.isEmpty ?? false) {
//                                   selectedOptions.remove(friendId);
//                                 }
//                               }
//                               _calculateShares();
//                             }
//                           });
//                         },
//                 ),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }

//   Widget commentedData() {
//     List limitedFriends = userController.friendsList.take(4).toList();

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           limitedFriends.isEmpty
//               ? Center(
//                   child: Text(
//                     PlotFinanceStaticData().noFriendsAvailable,
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.w500,
//                       fontSize: 16,
//                       color: AppColors.bg3,
//                     ),
//                   ),
//                 )
//               : GridView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                   ),
//                   itemCount: limitedFriends.length,
//                   itemBuilder: (context, index) {
//                     String id = limitedFriends[index]['_id'];
//                     bool isSelected = addedUser.contains(id);

//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           if (isSelected) {
//                             addedUser.remove(id);
//                             addedMembers
//                                 .removeWhere((member) => member['id'] == id);
//                             selectedOptions.remove(id);
//                           } else {
//                             addedUser.add(id);
//                             addedMembers.add({
//                               "name": limitedFriends[index]['name'],
//                               "id": id,
//                               'avatar': limitedFriends[index]['avatar'],
//                               'avatarBackGround': limitedFriends[index]
//                                   ['avatarBackGround'],
//                               "balance": 200,
//                             });
//                             selectedOptions[id] = [];
//                           }
//                         });
//                       },
//                       child: Card(
//                         elevation: 1,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         color: isSelected
//                             ? Colors.green[50]
//                             : AppColors.backgroundColor,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 2, vertical: 5),
//                           child: Row(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(1.0),
//                                 child: AvatarProfile(
//                                   name: limitedFriends[index]['name'],
//                                   width: 10,
//                                   height: 10,
//                                   background: limitedFriends[index]['avatarBackGround'] ?? "",
//                                   flag: true,
//                                   fontsize: 7,
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   limitedFriends[index]['name'],
//                                   overflow: TextOverflow.ellipsis,
//                                   style: FontManager().getTextStyle(
//                                     context,
//                                     lWeight: FontWeight.w400,
//                                     fontSize: 14,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                               Checkbox(
//                                 value: isSelected,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value!) {
//                                       addedUser.add(id);
//                                       addedMembers.add({
//                                         "name": limitedFriends[index]['name'],
//                                         "id": id,
//                                         'avatar': limitedFriends[index]
//                                             ['avatar'],
//                                         'avatarBackGround':
//                                             limitedFriends[index]
//                                                 ['avatarBackGround'],
//                                         "balance": 200,
//                                       });
//                                       selectedOptions[id] = [];
//                                     } else {
//                                       addedUser.remove(id);
//                                       addedMembers.removeWhere(
//                                           (member) => member['id'] == id);
//                                       selectedOptions.remove(id);
//                                     }
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ],
//       ),
//     );
//   }

//   Widget InputDat(String labelText, TextInputType keyboard,
//       TextEditingController textController) {
//     return Center(
//       child: Container(
//         width: MediaQuery.of(context).size.width / 1.1,
//         height: MediaQuery.of(context).size.height / 20,
//         child: TextFormField(
//           keyboardType: keyboard,
//           controller: textController,
//           onChanged: (v) {
//             List filtered = [];
//             if (v.trim().isEmpty) {
//               filtered = userController.frdsListOrigin;
//             } else {
//               filtered = userController.frdsListOrigin.where((element) {
//                 String name = element['name'].toString().toLowerCase();
//                 return name.contains(v.toLowerCase());
//               }).toList();
//             }
//             List limited = filtered.take(4).toList();
//             setState(() {
//               userController.friendsList.clear();
//               userController.friendsList.addAll(limited);
//             });
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

//   void addSocketMessage(addedUser, String amount, String splitName,
//       String splitID, double totalAmount) {
//     if (addedUser.isEmpty) return;

//     addedUser.forEach((rec) {
//       String room1 = rec['name'] + userController.userName.value;
//       String room2 = userController.userName.value + rec['name'];
//       String roomId = (room1.compareTo(room2) <= 0) ? room1 : room2;

//       var jsonData = {
//         "messageType": "split",
//         "receiver": rec['id'],
//         "sender": userController.userId.value,
//         "message": null,
//         "image": null,
//         "poll": null,
//         "post": null,
//         "split": {
//           "BillName": splitName,
//           "Amount": totalAmount.toString(),
//           "Share": rec['amount'],
//           "isPaid": false,
//           "splitId": splitID,
//         },
//         "roomId": roomId,
//       };

//       socket.emit("joinRoom", roomId);
//       socket.emit("message", jsonData);
//       String userToSend = rec['name'] + "" + rec['name'];
//       socket.emit("LoadCharts", {"roomId": userToSend});
//     });
//   }

//   void splitUserAmountFood(context, String amount, List members, String name,
//       String subCategories, dynamic shareFriends) async {
//     List nameList = [];
//     double totalAmount = 0.0;

//     members.forEach((element) {
//       String id = element['id'];
//       var data = shareFriends[id];
//       totalAmount += data['Total'];
//       nameList.add({
//         'id': id,
//         'name': element['name'],
//         'member': id,
//         'markAsComplete': false,
//         'amount': doubleToFixed(data['Total'].toString()),
//         'isVegNonVeg': true,
//         'priorities': data,
//       });
//     });
//     final SharedPreferences _pref = await SharedPreferences.getInstance();
//     var accessToken = _pref.getString("accessToken");

//     final requestBody = {
//       "name": name,
//       "subcategory": subCategories,
//       "category": name,
//       "amount": totalAmount,
//       "paymentStatus": nameList,
//       "image": '',
//       'isVegNonVeg': true,
//       "ismanual": true,
//       'isFoodie': true
//     };

//     final response = await http.post(
//       Uri.parse('${url}/split'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         "Authorization": "$accessToken",
//       },
//       body: jsonEncode(requestBody),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final body = json.decode(response.body);
//       splitID.value = body['id']['_id'];

//       List<dynamic> uniqueNameList =
//           {for (var item in nameList) item['id']: item}.values.toList();

//       uniqueNameList.forEach((e) {
//         if (e['id'] != userController.userId.value) {
//           sendNotificationsToDevice(
//               e['id'],
//               context,
//               "${userController.userName.value} has sent you a ${name} of ${e['amount']}",
//               "/chat");
//         }
//       });

//       addSocketMessage(nameList, amount.toString(), "Calculation".toString(),
//           splitID.value, totalAmount);

//       snackBarCalled(context, SnackbarData().splitAmountSent);
//       Navigator.pop(context);
//     } else {
//       snackBarCalledfail(context, SnackbarData().authenticationError, Colors.red);
//     }
//     acceptReset.value = false;
//   }
// }

// String doubleToFixed(String number) {
//   double value = double.parse(number);
//   return value.toStringAsFixed(2);
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Assuming these are defined in your project
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';

class VegNonVegCalculator extends StatefulWidget {
  const VegNonVegCalculator({super.key});

  @override
  _VegNonVegCalculatorState createState() => _VegNonVegCalculatorState();
}

class _VegNonVegCalculatorState extends State<VegNonVegCalculator> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': PlotFinanceStaticData().vegLabel,
      'controller': TextEditingController(),
      'isCustom': false,
    },
    {
      'name': PlotFinanceStaticData().nonVegLabel,
      'controller': TextEditingController(),
      'isCustom': false,
    },
    {
      'name': PlotFinanceStaticData().alcoholLabel,
      'controller': TextEditingController(),
      'isCustom': false,
    },
  ];

  final TextEditingController newCategoryController = TextEditingController();
  final Map<String, List<String>> selectedOptions = {};
  final TextEditingController searchController = TextEditingController();
  final Map<String, Map<String, double>> friendShares = {};
  final RxList addedUser = [].obs;
  final RxList addedMembers = [].obs;
  final RxString splitID = ''.obs;
  final RxBool acceptReset = false.obs;
  late IO.Socket socket;

  List<Map<dynamic, dynamic>> get friends => userController.friendsList
      .map((e) => e as Map<dynamic, dynamic>)
      .toList();

  @override
  void initState() {
    super.initState();
    _addCurrentUserToMembers();
    for (var friend in friends) {
      String friendId = friend['_id']?.toString() ?? '';
      if (friendId.isNotEmpty) {
        selectedOptions[friendId] = [];
      }
    }
    socket = IO.io(
      urlWithLocallHost,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );
    setUpSocketListener();
  }

  void _addCurrentUserToMembers() {
    final String currentUserId = userController.userId.value;
    final String currentUserName = userController.userName.value;
    final String? currentUserAvatar = userController.avatar.value;

    if (currentUserId.isNotEmpty &&
        !addedMembers.any((member) => member['id'] == currentUserId)) {
      setState(() {
        addedMembers.add({
          "name": currentUserName,
          "id": currentUserId,
          "avatar": currentUserAvatar,
          "balance": 0.0,
        });
        addedUser.add(currentUserId);
        selectedOptions[currentUserId] = [];
      });
    }
  }

  void setUpSocketListener() {
    socket.onConnect((_) => print('Socket connected'));
    socket.onDisconnect((_) => print('Socket disconnected'));
    socket.onError((error) => print('Socket error: $error'));
  }

  void _addCustomCategory() {
    if (categories.where((c) => c['isCustom']).length >= 2) {
      snackBarCalledfail(context, 'Maximum of 2 custom categories allowed');
      return;
    }
    if (newCategoryController.text.trim().isEmpty) {
      snackBarCalledfail(context, 'Please enter a category name');
      return;
    }
    setState(() {
      categories.add({
        'name': newCategoryController.text.trim(),
        'controller': TextEditingController(),
        'isCustom': true,
      });
      newCategoryController.clear();
      for (var member in addedMembers) {
        String? friendId = member['id']?.toString();
        if (friendId != null && !selectedOptions.containsKey(friendId)) {
          selectedOptions[friendId] = [];
        }
      }
    });
  }

  void _editCategoryName(int index, String newName) {
    if (newName.trim().isEmpty) {
      snackBarCalledfail(context, 'Category name cannot be empty');
      return;
    }
    setState(() {
      String oldName = categories[index]['name'];
      categories[index]['name'] = newName.trim();
      for (var friendId in selectedOptions.keys) {
        if (selectedOptions[friendId]!.contains(oldName)) {
          selectedOptions[friendId]!.remove(oldName);
          selectedOptions[friendId]!.add(newName.trim());
        }
      }
      _calculateShares();
    });
  }

  void _removeCustomCategory(int index) {
    setState(() {
      String categoryName = categories[index]['name'];
      categories[index]['controller'].dispose();
      categories.removeAt(index);
      for (var friendId in selectedOptions.keys) {
        selectedOptions[friendId]!.remove(categoryName);
        if (selectedOptions[friendId]!.isEmpty) {
          selectedOptions.remove(friendId);
        }
      }
      _calculateShares();
    });
  }

  void _calculateShares() {
    setState(() {
      friendShares.clear();
      for (var friend in addedMembers) {
        String? friendId = friend['id']?.toString();
        if (friendId != null) {
          friendShares[friendId] = {
            for (var cat in categories) cat['name']: 0.0,
            'Total': 0.0,
          };
          List<String> choices = selectedOptions[friendId] ?? [];
          for (var category in categories) {
            String catName = category['name'];
            double totalAmount =
                double.tryParse(category['controller'].text) ?? 0.0;
            if (choices.contains(catName)) {
              int participants = addedMembers
                  .where((f) =>
                      selectedOptions[f['id']]?.contains(catName) ?? false)
                  .length;
              friendShares[friendId]![catName] =
                  participants > 0 ? totalAmount / participants : 0.0;
            }
            friendShares[friendId]!['Total'] = friendShares[friendId]!
                .entries
                .where((e) => e.key != 'Total')
                .fold(0.0, (sum, e) => sum + e.value);
          }
        }
      }
    });
  }

  Widget _buildInputColumn(
      String label, TextEditingController controller, int index, bool isCustom) {
    TextEditingController nameController = TextEditingController(text: label);
    return Container(
      width: MediaQuery.of(context).size.width * 0.3 - 10,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Category Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (value) => _editCategoryName(index, value),
                ),
              ),
              if (isCustom)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeCustomCategory(index),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            inputFormatters: allowDecimalInput(),
            onChanged: (value) => _calculateShares(),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCategoryField() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3 - 10,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          TextField(
            controller: newCategoryController,
            decoration: InputDecoration(
              hintText: 'New Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _addCustomCategory,
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  Widget calculation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              double totalAmount = categories.fold(
                  0.0,
                  (sum, cat) =>
                      sum + (double.tryParse(cat['controller'].text) ?? 0.0));
              bool hasValidAmount = totalAmount > 0;
              bool hasShares = addedMembers.any((member) =>
                  friendShares[member['id']]?['Total'] != null &&
                  friendShares[member['id']]!['Total']! > 0);

              if (hasValidAmount && hasShares) {
                splitUserAmountFood(
                  context,
                  totalAmount.toStringAsFixed(2),
                  addedMembers,
                  "Foodie Split",
                  "Custom Categories",
                  friendShares,
                );
              } else {
                snackBarCalledfail(context, SnackbarData().validAmountAndShares);
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  PlotFinanceStaticData().billSplitButton,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (friendShares.isEmpty) {
                snackBarCalledfail(context, SnackbarData().noSharesCalculated);
                return;
              }
              final String? userId = userController.userId.value;
              if (userId == null || userId.isEmpty) {
                snackBarCalledfail(context, SnackbarData().userIdNotAvailable);
                return;
              }
              final String name = userController.userName.value;
              if (name.isEmpty) {
                snackBarCalledfail(context, SnackbarData().userNameNotAvailable);
                return;
              }
              bool hasValidRecipients =
                  friendShares.keys.any((key) => key != userId);
              if (!hasValidRecipients) {
                snackBarCalledfail(context, SnackbarData().noFriendsToNotify);
                return;
              }
              bool hasValidShares = friendShares.entries.any((entry) =>
                  entry.key != userId &&
                  entry.value['Total'] != null &&
                  (entry.value['Total'] as num) > 0);
              if (!hasValidShares) {
                snackBarCalledfail(context, SnackbarData().noValidSharesToNotify);
                return;
              }

              bool atLeastOneNotificationSent = false;
              friendShares.forEach((key, value) {
                if (key != userId &&
                    value['Total'] != null &&
                    (value['Total'] as num) > 0) {
                  try {
                    sendNotificationsToDevice(
                      key,
                      context,
                      "$name has shared a foodie expense of ₹${(value['Total'] as num).toStringAsFixed(2)}",
                      "/remainders",
                      "",
                      "",
                      "Notified successfully",
                    );
                    atLeastOneNotificationSent = true;
                    Navigator.pop(context);
                  } catch (e) {
                    snackBarCalledfail(
                        context, SnackbarData().failedToSendNotification);
                  }
                }
              });
              if (!atLeastOneNotificationSent) {
                snackBarCalledfail(context, SnackbarData().noNotificationsSent);
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  PlotFinanceStaticData().notifyButton,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget vegNonvegdata() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: addedMembers.length,
      itemBuilder: (context, index) {
        var friend = addedMembers[index];
        String? friendId = friend['id']?.toString();
        bool isCurrentUser = friendId == userController.userId.value;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      AvatarProfile(
                        background: friend['avatarBackGround'] ??
                            defaultBackGround.value,
                        width: 8,
                        height: 18,
                        name: friend['name'] ?? 'Unknown',
                      ),
                      if (!isCurrentUser)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              addedMembers
                                  .removeWhere((member) => member['id'] == friendId);
                              addedUser.remove(friendId);
                              selectedOptions.remove(friendId);
                              _calculateShares();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    friend['name'] ?? 'Unknown',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.bg1,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${friendShares[friendId]?['Total']?.toStringAsFixed(2) ?? "0.00"}',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.bg3,
                ),
              ),
            ],
          ),
          subtitle: Wrap(
            spacing: 8.0,
            children: categories.map((category) {
              String option = category['name'];
              bool isSelected =
                  selectedOptions[friendId]?.contains(option) == true;
              bool isDisabled = category['controller'].text.isEmpty;
              return ChoiceChip(
                label: Text(
                  option,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isSelected
                        ? AppColors.backgroundColor
                        : AppColors.accentColor,
                  ),
                ),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: AppColors.primaryColor,
                backgroundColor: AppColors.mt,
                onSelected: isDisabled
                    ? null
                    : (selected) {
                        setState(() {
                          if (friendId != null) {
                            selectedOptions.putIfAbsent(friendId, () => []);
                            if (selected) {
                              selectedOptions[friendId]!.add(option);
                            } else {
                              selectedOptions[friendId]!.remove(option);
                              if (selectedOptions[friendId]!.isEmpty) {
                                selectedOptions.remove(friendId);
                              }
                            }
                            _calculateShares();
                          }
                        });
                      },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget commentedData() {
    final limitedFriends = userController.friendsList.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (limitedFriends.isEmpty)
            Center(
              child: Text(
                PlotFinanceStaticData().noFriendsAvailable,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.bg3,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: limitedFriends.length,
              itemBuilder: (context, index) {
                final String id = limitedFriends[index]['_id']?.toString() ?? '';
                final bool isSelected = addedUser.contains(id);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        addedUser.remove(id);
                        addedMembers.removeWhere((member) => member['id'] == id);
                        selectedOptions.remove(id);
                      } else {
                        addedUser.add(id);
                        addedMembers.add({
                          "name": limitedFriends[index]['name']?.toString() ?? '',
                          "id": id,
                          'avatar': limitedFriends[index]['avatar'],
                          'avatarBackGround':
                              limitedFriends[index]['avatarBackGround'],
                          "balance": 0.0,
                        });
                        selectedOptions[id] = [];
                      }
                      _calculateShares();
                    });
                  },
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: isSelected ? Colors.green[50] : AppColors.backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 5),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: AvatarProfile(
                              name: limitedFriends[index]['name']?.toString() ??
                                  'Unknown',
                              width: 10,
                              height: 10,
                              background: limitedFriends[index]
                                      ['avatarBackGround'] ??
                                  defaultBackGround.value,
                              flag: true,
                              fontsize: 7,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              limitedFriends[index]['name']?.toString() ??
                                  'Unknown',
                              overflow: TextOverflow.ellipsis,
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  addedUser.add(id);
                                  addedMembers.add({
                                    "name": limitedFriends[index]['name']
                                            ?.toString() ??
                                        '',
                                    "id": id,
                                    'avatar': limitedFriends[index]['avatar'],
                                    'avatarBackGround':
                                        limitedFriends[index]['avatarBackGround'],
                                    "balance": 0.0,
                                  });
                                  selectedOptions[id] = [];
                                } else {
                                  addedUser.remove(id);
                                  addedMembers
                                      .removeWhere((member) => member['id'] == id);
                                  selectedOptions.remove(id);
                                }
                                _calculateShares();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget inputDat(String labelText, TextInputType keyboard,
      TextEditingController textController) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        keyboardType: keyboard,
        controller: textController,
        onChanged: (value) {
          final filtered = value.trim().isEmpty
              ? userController.frdsListOrigin
              : userController.frdsListOrigin.where((element) {
                  final name = element['name']?.toString().toLowerCase() ?? '';
                  return name.contains(value.toLowerCase());
                }).toList();
          final limited = filtered.take(4).toList();
          setState(() {
            userController.friendsList.clear();
            userController.friendsList.addAll(limited);
          });
        },
        decoration: InputDecoration(
          filled: true,
          hintText: labelText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color.fromRGBO(249, 246, 238, 1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color.fromRGBO(246, 246, 246, 1)),
          ),
          fillColor: AppColors.button,
        ),
      ),
    );
  }

  void addSocketMessage(List addedUsers, String amount, String splitName,
      String splitId, double totalAmount) {
    if (addedUsers.isEmpty) return;

    for (var rec in addedUsers) {
      final String room1 = '${rec['name']}${userController.userName.value}';
      final String room2 = '${userController.userName.value}${rec['name']}';
      final String roomId = room1.compareTo(room2) <= 0 ? room1 : room2;

      final jsonData = {
        "messageType": "split",
        "receiver": rec['id'],
        "sender": userController.userId.value,
        "message": null,
        "image": null,
        "poll": null,
        "post": null,
        "split": {
          "BillName": splitName,
          "Amount": totalAmount.toStringAsFixed(2),
          "Share": rec['amount'],
          "isPaid": false,
          "splitId": splitId,
        },
        "roomId": roomId,
      };

      if (socket.connected) {
        socket.emit("joinRoom", roomId);
        socket.emit("message", jsonData);
        socket.emit("LoadCharts", {"roomId": '${rec['name']}${rec['name']}'});
      } else {
        snackBarCalledfail(context, 'Socket not connected');
      }
    }
  }

  Future<void> splitUserAmountFood(
    BuildContext context,
    String amount,
    List members,
    String name,
    String subCategories,
    Map<String, Map<String, double>> shareFriends,
  ) async {
    final List<Map<String, dynamic>> nameList = [];
    double totalAmount = 0.0;

    for (var element in members) {
      final String id = element['id']?.toString() ?? '';
      final data = shareFriends[id];
      if (data != null) {
        totalAmount += data['Total'] ?? 0.0;
        nameList.add({
          'id': id,
          'name': element['name']?.toString() ?? '',
          'member': id,
          'markAsComplete': false,
          'amount': (data['Total'] ?? 0.0).toStringAsFixed(2),
          'isVegNonVeg': true,
          'priorities': data,
        });
      }
    }

    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String? accessToken = pref.getString("accessToken");

    if (accessToken == null) {
      snackBarCalledfail(context, 'Authentication token not found');
      return;
    }

    final requestBody = {
      "name": name,
      "subcategory": subCategories,
      "category": name,
      "amount": totalAmount,
      "paymentStatus": nameList,
      "image": '',
      'isVegNonVeg': true,
      "ismanual": true,
      'isFoodie': true,
    };

    try {
      final response = await http.post(
        Uri.parse('$url/split'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': accessToken,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        splitID.value = body['id']['_id']?.toString() ?? '';

        final uniqueNameList =
            {for (var item in nameList) item['id']: item}.values.toList();

        for (var e in uniqueNameList) {
          if (e['id'] != userController.userId.value) {
            sendNotificationsToDevice(
              e['id'],
              context,
              "${userController.userName.value} has sent you a $name of ${e['amount']}",
              "/chat",
            );
          }
        }

        addSocketMessage(nameList, amount, name, splitID.value, totalAmount);
        snackBarCalled(context, SnackbarData().splitAmountSent);
        Navigator.pop(context);
      } else {
        snackBarCalledfail(context, SnackbarData().authenticationError);
      }
    } catch (e) {
      snackBarCalledfail(context, 'Failed to split amount: $e');
    }
    acceptReset.value = false;
  }

  String doubleToFixed(String number) {
    return double.tryParse(number)?.toStringAsFixed(2) ?? '0.00';
  }

  @override
  void dispose() {
    for (var category in categories) {
      category['controller'].dispose();
    }
    newCategoryController.dispose();
    searchController.dispose();
    socket.dispose();
    super.dispose();
  }

  @override
  
Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: SingleChildScrollView(
                child: Padding(
                  
                  padding: const EdgeInsets.symmetric(vertical: 22,horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      const SizedBox(height: 24),
                      
                      Stack(
                        children: [
                         Positioned(
          top: 0, // Start from the top of the Stack
          left: 0,
          right: 0,
          child: Container(
            // color: Colors.amber,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xE6061F35), // #061F35 with 0.9 opacity (E6 hex = 90%)
        const Color(0x00061F35), // fully transparent
      ],
    ),),
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.backgroundColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    "FoodieFunds",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
                        Container(
                           margin: const EdgeInsets.only(top: 60),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              
                              AvatarProfileImageZero(
                                  url: 'assets/icons/financeScreen/currency.svg',
                                  width: 1,
                                  height: 1
                              ),
                                          
                              Container(
                                width: MediaQuery.sizeOf(context).width * 0.8,
                                padding: const EdgeInsets.all(16),
                                // decoration: BoxDecoration(
                                //  color: Color(0xFF60628C),
                                //   borderRadius: BorderRadius.circular(16),
                                //   border: Border.all(color: AppColors.backgroundColor),
                                //   boxShadow: [
                                //     BoxShadow(
                                //       color: Colors.grey.withOpacity(0.1),
                                //       spreadRadius: 2,
                                //       blurRadius: 8,
                                //       offset: const Offset(0, 2),
                                //     ),
                                //   ],
                                // ),
                                child:  Column(
                    children: [
                      const SizedBox(height: 60), // Space for avatar
                      // Categories
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.center,
                          children: [
                            for (int i = 0; i < categories.length; i++)
                              _buildInputColumn(
                                categories[i]['name'],
                                categories[i]['controller'],
                                i,
                                categories[i]['isCustom'],
                              ),
                            if (categories.where((c) => c['isCustom']).length < 2)
                              _buildAddCategoryField(),
                          ],
                        ),
                      ),
                      // Search bar
                      inputDat(
                        PlotFinanceStaticData().searchHint,
                        TextInputType.name,
                        searchController,
                      ),
                      // Scrollable content
                      Container(
                        height: MediaQuery.sizeOf(context).height/1.4,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              commentedData(),
                              vegNonvegdata(),
                            ],
                          ),
                        ),
                      ),
                      // Calculation buttons
                      calculation(),
                    ],
                  ),
                
                              ),
                                          
                              const SizedBox(height: 24),
                              // Recent Conversions
                            ],
                          ),
                        ),
                       ] ),
                      
                    ]),
                )
                ));
  }

}