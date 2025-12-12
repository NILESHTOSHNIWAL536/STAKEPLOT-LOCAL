


// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/search.dart';
// import 'package:confetti/confetti.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/friends_bill_split.dart';
// import 'package:flutter_application_code_stakeplot/components/helper.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
// import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/repository/manual_transaction_repository.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:flutter_application_code_stakeplot/image_service/profile.dart';
// import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
// import 'package:get/get.dart';
// import 'package:keyboard_actions/keyboard_actions.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// import '../../Constants/custom_keypad.dart';
// import '../../components/shared_utils.dart';
// import '../../routes/index_route.dart';

// bool isDebit = true;

// class ModalContent extends StatefulWidget {
//   final bool isDebit;
//   const ModalContent(this.isDebit, {Key? key,}) : super(key: key);

//   @override
//   _ModalContentState createState() => _ModalContentState();
// }

// class _ModalContentState extends State<ModalContent>
//     with TickerProviderStateMixin {
//   String? selectedCategory;
//   String? selectedSubCategory;
//   final TextEditingController _amountController = TextEditingController();
//   double? amount;
//   String? fin;
//   final TextEditingController categoryFieldController = TextEditingController();
//   bool isCategoryFieldExpanded = false;
//   final TextEditingController searchController = TextEditingController();
//   List<Map<String, dynamic>> filteredCategories = [];
//   late ConfettiController _confettiController;
//   late AnimationController _iconAnimationController;
//   bool _isCelebrationVisible = false;
//   String? selectedCategory2;
//   String? selectedSubCategory2;
//   // List  addedUser=[];
//   // List addedMembers=[];
//   bool _isAmountFieldFocused = true;
//    final FocusNode _amountFocusNode = FocusNode(); 
//   late IO.Socket socket;
//  String _amountText = ''; // keypad input text
//   @override
//   void initState() {
//     super.initState();
//     getAllTransaction(context);
//    filteredCategories = categories.entries
//       .map((entry) => {
//             'category': entry.key,
//             'subcategories': entry.value,
//             'isCategory': true,
//           })
//       .toList();
//     _confettiController =
//         ConfettiController(duration: const Duration(seconds: 2));
//     _iconAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );

//     socket = IO.io(API.urlWithLocallHost,
//         IO.OptionBuilder().setTransports(['websocket']).build());
//     setUpSocketListener();
 
//   }

 
//   // Add transaction

//   setUpSocketListener() {
//     socket.on(
//         "disconnect",
//         (data) => {
//               socket.close(),
//             });
//   }

//   void dispose() {
//      _amountFocusNode.dispose(); 
//     _confettiController.dispose();
//     _iconAnimationController.dispose();
//     super.dispose();
//   }

//   void filterCategories(String query) {
//   setState(() {
//     if (query.isEmpty) {
//       // Show all categories when search is cleared
//       filteredCategories = categories.entries
//           .map((entry) => {
//                 'category': entry.key,
//                 'subcategories': entry.value,
//                 'isCategory': true,
//               })
//           .toList();
//     } else {
//       filteredCategories = [];
//       categories.forEach((category, subcategories) {
//         // Check if category matches the query
//         if (category.toLowerCase().contains(query.toLowerCase())) {
//           filteredCategories.add({
//             'category': category,
//             'subcategories': subcategories,
//             'isCategory': true,
//           });
//         }
//         // Check if any subcategory matches the query
//         subcategories
//             .where((subcategory) =>
//                 subcategory.toLowerCase().contains(query.toLowerCase()))
//             .forEach((subcategory) {
//           filteredCategories.add({
//             'category': category,
//             'subcategory': subcategory,
//             'isCategory': false,
//           });
//         });
//       });
//       // Include custom categories
//       customCategoryList.forEach((customCategory) {
//         if (customCategory['name']
//             .toLowerCase()
//             .contains(query.toLowerCase())) {
//           filteredCategories.add({
//             'category': customCategory['name'],
//             'subcategory': '',
//             'isCategory': true,
//             'isCustom': true,
//             'imageUrl': customCategory['imageUrl'],
//           });
//         }
//       });
//     }
//   });
// }

//   void resetToInitialScreen() {
//     setState(() {
//       selectedCategory = null;
//       selectedSubCategory = null;
//       isCategoryFieldExpanded = false;
//       _isAmountFieldFocused = false;
//     });
//   }

//   void toggleCategoryField() {
//     setState(() {
//       isCategoryFieldExpanded = !isCategoryFieldExpanded;
//       _isAmountFieldFocused = false;
//       _isAmountFieldFocused = false;
//     });
//   }

//  void _onKeypadNumberTap(String value) {
//     setState(() {
//       _amountText += value;
//       _amountController.text = _amountText;
//       amount = double.tryParse(_amountText);

//       if (!widget.isDebit) {
//         selectedCategory = "Income";
//         categoryFieldController.text = "Income";
//       }

//       fin = null;
//     });
//   }

//   void _onKeypadBackspace() {
//     if (_amountText.isEmpty) return;
//     setState(() {
//       _amountText = _amountText.substring(0, _amountText.length - 1);
//       _amountController.text = _amountText;
//       amount = double.tryParse(_amountText);
//       fin = null;
//     });
//   }

//   void _onKeypadSubmit() {
//     FocusScope.of(context).unfocus();

//     if (amount == null || amount == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a valid amount')),
//       );
//       return;
//     }

//     if (selectedCategory != null) {
//       setState(() {
//         fin = '$selectedCategory'
//             '${selectedSubCategory != null ? " ($selectedSubCategory)" : ""}';
//       });
//     }
//   }
//   void _submitAmount() {
//   final value = _amountController.text.trim();

//   if (value.isEmpty) {
//    snackBarCalledfail(context, "Please enter a valid amount");
//     return;
//   }

//   setState(() {
//     amount = double.tryParse(value);

//     if (!isDebit) {
//       selectedCategory = "Income";
//       categoryFieldController.text = "Income";
//     }

//     // This was earlier in onEditingComplete
//     fin = '$selectedCategory ($selectedSubCategory)';
//     _isAmountFieldFocused = false;
//   });

//   // Hide keyboard
//   FocusScope.of(context).unfocus();
// }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isCelebrationVisible
//             ? celebration()
//             : AnimatedPadding(
//                 padding: MediaQuery.of(context).viewInsets,
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeOut,
//                 child: Container(
//                   color: AppColors.mt,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 10),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
                       
//                         //  if ((selectedCategory == null &&
//                         //         selectedSubCategory == null) ||
//                         //     !widget.isDebit) ...[
//                         //   Row(
//                         //     children: [
//                         //       Expanded(child: AmountWidget()),
//                         //     ],
//                         //   ),
//                         //   const SizedBox(height: 16),
//                         //   SizedBox(
//                         //     height: 240,
//                         //     child: CustomKeypad(
//                         //       onKeyTap: _onKeypadNumberTap,
//                         //       onBackspace: _onKeypadBackspace,
//                         //       onSubmit: _onKeypadSubmit,
//                         //     ),
//                         //   ),
//                         //   const SizedBox(height: 16),
//                         // ],

//                         if ((selectedCategory == null &&
//                                 selectedSubCategory == null) ||
//                             !widget.isDebit) ...[
//                           Row(
//                             children: [
//                               Expanded(child: AmountWidget()),
//                               const SizedBox(width: 8),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                         ],
//                         if (amount != null) ...[
//                           categoryWidget(),
//                         ],
//                         const SizedBox(height: 8),
//                         if (isCategoryFieldExpanded) ...[
//                           categoryExpandedWidget(),
//                           // getListOfCustomCategory(),
//                         ],
//                         if (selectedCategory != null &&
//                             selectedSubCategory == null) ...[
//                           Text('$selectedCategory',
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.normal,
//                                   fontSize: 16,
//                                   color: AppColors.accentColor)),
//                           SizedBox(height: 5),
//                           subcategoryWidget(),
//                         ],
//                         if (fin != null) ...[
//                           widget.isDebit
//                               ? SplitLendButton()
//                               : SizedBox.shrink(),
//                           continueButton(),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget celebration() {
//     return Stack(alignment: Alignment.center, children: [
//       // Confetti blast effect
//       ConfettiWidget(
//         confettiController: _confettiController,
//         blastDirectionality:
//             BlastDirectionality.explosive, // Blast in all directions
//         numberOfParticles: 50, // Number of confetti pieces
//         colors: const [Colors.green, Colors.blue, Colors.orange, Colors.pink],
//         gravity: 0.3, // Confetti falls slowly
//       ),
//       // Animated tick mark
//       ScaleTransition(
//         scale: CurvedAnimation(
//           parent: _iconAnimationController,
//           curve: Curves.elasticOut,
//         ),
//         child: Container(
//           width: MediaQuery.sizeOf(context).width * 1.1,
//           height: Colorcodes.paddingSize * 10,
//           color: AppColors.backgroundColor,
//           child: Column(
//             key: const ValueKey('celebration'),
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.check_circle,
//                 color: Colors.green,
//                 size: 100,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 HomepageStringsDart().successfullyAdded,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green[700],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ]);
//   }

//   Widget AmountWidget() {
//     return TextField(
//       controller: _amountController,
//       keyboardType: TextInputType.number,
      
//       // readOnly: true,
//       textInputAction: TextInputAction.done, 
//       autofocus: _isAmountFieldFocused,
//       inputFormatters: allowDecimalInput(),
//       decoration: InputDecoration(
//         prefixIcon: const Icon(Icons.currency_rupee),
        

//         hintText: HomepageStringsDart().enterAmount,
//         fillColor: AppColors.button,
//         filled: true,
//         hintStyle: FontManager().getTextStyle(context,
//             lWeight: FontWeight.normal,
//             fontSize: 16,
//             color: AppColors.accentColor),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: AppColors.accentColor, // Default border color
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: AppColors.accentColor
//               // When not focused

//               ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: AppColors.accentColor, // Color when focused
//             // Slightly thicker when focused for emphasis
//           ),
//         ),
//       ),
//       onChanged: (value) {
//         setState(() {
//           // Update the amount variable whenever the input changes
//           amount = double.tryParse(value);
//           if (!isDebit) {
//             selectedCategory = "Income";
//             categoryFieldController.text = "Income";
//           }
//           fin = null;
//           _isAmountFieldFocused = false; // Convert string to double
//         });
//       },
//       onEditingComplete: () {
//         fin = '$selectedCategory ($selectedSubCategory)';
//         FocusScope.of(context).unfocus(); // Dismiss keyboard when done
//       },
//       onSubmitted: (value) {
//       _submitAmount();   // 👈 same as tapping ✔
//     },
//     );
//   }

// Widget categoryWidget() {
//   return GestureDetector(
//     onTap: toggleCategoryField,
//     child: TextField(
//       controller: categoryFieldController,
//       readOnly: !isDebit,

//       decoration: InputDecoration(
//         hintText: HomepageStringsDart().selectCategory,
//         fillColor: AppColors.button,
//         filled: true,
//         hintStyle: FontManager().getTextStyle(
//           context,
//           lWeight: FontWeight.normal,
//           fontSize: 16,
//           color: AppColors.accentColor,
//         ),
//         prefixIcon: const Icon(Icons.search),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: AppColors.accentColor,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: AppColors.accentColor,
//           ),
//         ),
//       ),
//       onTap: () {
//         if (!isCategoryFieldExpanded) {
//           if (isDebit) {
//             toggleCategoryField();
//           } else {
//             setState(() {
//               selectedCategory = "Income";
//               selectedSubCategory = null;
//               categoryFieldController.text = "Income";
//             });
//           }
//         }
//       },
//       onChanged: (value) {
//         filterCategories(value); // Filter categories and subcategories
//       },
//     ),
//   );
// }
// Widget categoryExpandedWidget() {
//   return Expanded(
//     child: ListView.builder(
//       itemCount: filteredCategories.length,
//       itemBuilder: (BuildContext context, int index) {
//         final item = filteredCategories[index];
//         final isCategory = item['isCategory'] as bool;
//         final category = item['category'] as String;
//         final isCustom = item['isCustom'] ?? false;
//         String urlPath = "";

//         if (isCustom) {
//           urlPath = item['imageUrl'] ?? '';
//         } else if (isCategory) {
//           try {
//             urlPath = Categories.link +BudgetCategories.listofCategories[category]!;
//           } catch (e) {
//             urlPath = '';
//           }
//         } else {
//           urlPath = BudgetSubCategories.listofSubCategories[item['subcategory']] ??
//               "assets/icons/subCategoryIcons/default.svg";
//         }

//         return ListTile(
//           leading: Container(
//             height: 40,
//             width: 40,
//             child: AvatarProfileImage(
//               url: urlPath,
//               width: 4,
//               height: 4,
//             ),
//           ),
//           title: Text(
//             isCategory ? category : '${item['subcategory']} ($category)',
//             style: FontManager().getTextStyle(
//               context,
//               lWeight: FontWeight.normal,
//               fontSize: 16,
//               color: AppColors.accentColor,
//             ),
//           ),
//           onTap: () {
//             setState(() {
//               if (isCategory) {
//                 if (isCustom) {
//                   selectedCategory = category;
//                   selectedSubCategory = "";
//                   selectedCategory2 = selectedCategory;
//                   selectedSubCategory2 = selectedSubCategory;
//                   isCategoryFieldExpanded = false;
//                   categoryFieldController.text = category;
//                   fin = '$selectedCategory (None)';
//                   _isAmountFieldFocused = false;
//                   FocusScope.of(context).unfocus();
//                   resetToInitialScreen();
//                 } else {
//                   selectedCategory = category;
//                   selectedSubCategory = null;
//                   selectedCategory2 = selectedCategory;
//                   selectedSubCategory2 = selectedSubCategory;
//                   categoryFieldController.text = category;
//                   isCategoryFieldExpanded = false;
//                   _isAmountFieldFocused = false;
//                   FocusScope.of(context).unfocus();
//                 }
//               } else {
//                 selectedCategory = item['category'];
//                 selectedSubCategory = item['subcategory'];
//                 selectedCategory2 = selectedCategory;
//                 selectedSubCategory2 = selectedSubCategory;
//                 categoryFieldController.text =
//                     '$selectedCategory ($selectedSubCategory)';
//                 isCategoryFieldExpanded = false;
//                 fin = '$selectedCategory ($selectedSubCategory)';
//                 _isAmountFieldFocused = false;
//                 FocusScope.of(context).unfocus();
//                 resetToInitialScreen();
//               }
//             });
//           },
//         );
//       },
//     ),
//   );
// }
//   Widget getListOfCustomCategory() {
//     return Expanded(
//       child: ListView.builder(
//         itemCount: customCategoryList.length,
//         itemBuilder: (BuildContext context, int index) {
//           final category = customCategoryList[index];
//           final categoryName = category['name'] ?? '';
//           final imageUrl = category['imageUrl'] ?? '';

//           return ListTile(
//             leading: Container(
//               height: 40,
//               width: 40,
//               child: AvatarProfileImage(
//                 url: imageUrl,
//                 width: 4,
//                 height: 4,
//               ),
//             ),
//             title: Text(
//               categoryName,
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.normal,
//                 fontSize: 16,
//                 color: AppColors.accentColor,
//               ),
//             ),
//             onTap: () {
//               setState(() {
//                 selectedCategory = categoryName;
//                 categoryFieldController.text = categoryName;
//                 isCategoryFieldExpanded = false;
//                 _isAmountFieldFocused = false;
//                 FocusScope.of(context).unfocus();
//               });
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget subcategoryWidget() {
//     return Wrap(
//       spacing: 4.0, // Horizontal spacing between chips
//       runSpacing: 2.0, // Vertical spacing between rows
//       children: categories[selectedCategory]!.map((subCategory) {
//         // Get the URL path for the subcategory's icon from BudgetSubCategories
//         String urlPath = BudgetSubCategories.listofSubCategories[subCategory] ??
//             "assets/icons/subCategoryIcons/default.svg";
            
//         return GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedSubCategory = subCategory;
//               selectedSubCategory2 = subCategory;
//               categoryFieldController.text =
//                   '$selectedCategory ($selectedSubCategory)';
//               // isSplitbill = true; // Uncomment if needed
//               fin = '$selectedCategory ($selectedSubCategory)';
//               selectedCategory2 = selectedCategory;
//               _isAmountFieldFocused = false; // Prevent amount field refocus
//               FocusScope.of(context).unfocus();
//               resetToInitialScreen();
//             });
//           },
//           child: Chip(
//             avatar: ProfileImage(
//               url: urlPath,
//             ),
//             label: Text(
//               toUpperCase(subCategory),
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.normal,
//                 fontSize: 14,
//                 color: AppColors.accentColor,
//               ),
//             ),
//             backgroundColor: AppColors.button,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget SplitLendButton() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         GestureDetector(
//           onTap: () async {
//             Navigator.pop(context);
//             FocusScope.of(context).unfocus();
//             if (isLend.value) {
//               addedUser.clear();
//               addedMembers.clear();
//             }
//             isSplit.value = true;
//             isLend.value = false;

//             final result =
//                 await showCustomFriendsModal(context, amount ?? 0.0, false);

//             // if (result != null && addedMembers.isNotEmpty) {

//             //   splitUserAmountManualTransaction(
//             //     context,
//             //     amount.toString(),
//             //     addedMembers,
//             //     selectedCategory2.toString(),
//             //     selectedSubCategory2.toString(),
//             //     amounts: result as Map<String, double>,
//             //   );
//             // }
//             setState(() {
//               _isAmountFieldFocused = false; // Prevent amount field refocus
//             });
//           },
//           child: Container(
//             width: MediaQuery.of(context).size.width / 2.4,
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//             decoration: BoxDecoration(
//               color: AppColors.button,
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Center(
//               child: Text(
//                 HomepageStringsDart().billSplit,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 15,
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         GestureDetector(
//           onTap: () async {
//             FocusScope.of(context).unfocus();
//             if (isSplit.value) {
//               addedUser.clear();
//               addedMembers.clear();
//             }
//             isSplit.value = false;
//             isLend.value = true;

//             await showCustomFriendsModal(context, amount ?? 0.0, true);
//             addLendUserAmount(
//               context,
//               amount.toString(),
//               addedMembers,
//               selectedCategory2.toString(),
//               selectedSubCategory2.toString(),
//             );
//             Navigator.pop(context);
//             setState(() {
//               _isAmountFieldFocused = false; // Prevent amount field refocus
//             });
//           },
//           child: Container(
//             width: MediaQuery.of(context).size.width / 2.4,
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//             decoration: BoxDecoration(
//               color: AppColors.button,
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Center(
//               child: Text(
//                 HomepageStringsDart().lendMoney,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 15,
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget continueButton() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         // Button to trigger celebration
//         Center(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 10),
//             child: InkWell(
//               onTap: () {
//                 FocusScope.of(context).unfocus();
//                 if (cashInAndOut.value) return;
//                 cashInAndOut.value = true;
               
//                 addTransaction(
//                   amount.toString(),
//                   selectedSubCategory2.toString(),
//                   selectedCategory2.toString(),
//                   context,
//                   "cash",
//                 );
//               },
//               // },
//               child: Obx(() => cashInAndOut.value
//                   ? getspinner(context)
//                   : getButton(context, HomepageStringsDart().addButton)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

 
 
//   Future<dynamic> showCustomFriendsModal(
//     BuildContext context,
//     double totalAmount,
//     bool isLendMode,
//   ) async {
//     return await showModalBottomSheet<dynamic>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: NewFriendsUi(
//             totalAmount: totalAmount,
//             userId: userController.userId.value,
//             userName: userController.userName.value,
//             userAvatar: userController.avatar.value,
//             isLendMode: isLendMode,
//             category: selectedCategory2,
//             subcategory: selectedSubCategory2,
//           ),
//         );
//       },
//     );
//   }

//     }




// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/search.dart';
// import 'package:confetti/confetti.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/friends_bill_split.dart';
// import 'package:flutter_application_code_stakeplot/components/helper.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
// import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/repository/manual_transaction_repository.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:flutter_application_code_stakeplot/image_service/profile.dart';
// import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
// import 'package:get/get.dart';
// import 'package:keyboard_actions/keyboard_actions.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// import '../../Constants/custom_keypad.dart';
// import '../../components/shared_utils.dart';
// import '../../routes/index_route.dart';

// bool isDebit = true;

// class ModalContent extends StatefulWidget {
//   final bool isDebit;
//   const ModalContent(this.isDebit, {Key? key,}) : super(key: key);

//   @override
//   _ModalContentState createState() => _ModalContentState();
// }

// class _ModalContentState extends State<ModalContent>
//     with TickerProviderStateMixin {
//   String? selectedCategory;
//   String? selectedSubCategory;
//   final TextEditingController _amountController = TextEditingController();
//   double? amount;
//   String? fin;
//   final TextEditingController categoryFieldController = TextEditingController();
//   bool isCategoryFieldExpanded = false;
//   final TextEditingController searchController = TextEditingController();
//   List<Map<String, dynamic>> filteredCategories = [];
//   late ConfettiController _confettiController;
//   late AnimationController _iconAnimationController;
//   bool _isCelebrationVisible = false;
//   String? selectedCategory2;
//   String? selectedSubCategory2;
//   // List  addedUser=[];
//   // List addedMembers=[];
//   bool _isAmountFieldFocused = true;
//    final FocusNode _amountFocusNode = FocusNode(); 
//   late IO.Socket socket;
//  String _amountText = ''; // keypad input text
//   @override
//   void initState() {
//     super.initState();
//     getAllTransaction(context);
//    filteredCategories = categories.entries
//       .map((entry) => {
//             'category': entry.key,
//             'subcategories': entry.value,
//             'isCategory': true,
//           })
//       .toList();
//     _confettiController =
//         ConfettiController(duration: const Duration(seconds: 2));
//     _iconAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );

//     socket = IO.io(API.urlWithLocallHost,
//         IO.OptionBuilder().setTransports(['websocket']).build());
//     setUpSocketListener();
 
//   }

 
//   // Add transaction

//   setUpSocketListener() {
//     socket.on(
//         "disconnect",
//         (data) => {
//               socket.close(),
//             });
//   }

//   void dispose() {
//      _amountFocusNode.dispose(); 
//     _confettiController.dispose();
//     _iconAnimationController.dispose();
//     super.dispose();
//   }

//   void filterCategories(String query) {
//   setState(() {
//     if (query.isEmpty) {
//       // Show all categories when search is cleared
//       filteredCategories = categories.entries
//           .map((entry) => {
//                 'category': entry.key,
//                 'subcategories': entry.value,
//                 'isCategory': true,
//               })
//           .toList();
//     } else {
//       filteredCategories = [];
//       categories.forEach((category, subcategories) {
//         // Check if category matches the query
//         if (category.toLowerCase().contains(query.toLowerCase())) {
//           filteredCategories.add({
//             'category': category,
//             'subcategories': subcategories,
//             'isCategory': true,
//           });
//         }
//         // Check if any subcategory matches the query
//         subcategories
//             .where((subcategory) =>
//                 subcategory.toLowerCase().contains(query.toLowerCase()))
//             .forEach((subcategory) {
//           filteredCategories.add({
//             'category': category,
//             'subcategory': subcategory,
//             'isCategory': false,
//           });
//         });
//       });
//       // Include custom categories
//       customCategoryList.forEach((customCategory) {
//         if (customCategory['name']
//             .toLowerCase()
//             .contains(query.toLowerCase())) {
//           filteredCategories.add({
//             'category': customCategory['name'],
//             'subcategory': '',
//             'isCategory': true,
//             'isCustom': true,
//             'imageUrl': customCategory['imageUrl'],
//           });
//         }
//       });
//     }
//   });
// }

//   void resetToInitialScreen() {
//     setState(() {
//       selectedCategory = null;
//       selectedSubCategory = null;
//       isCategoryFieldExpanded = false;
//       _isAmountFieldFocused = false;
//     });
//   }

//   void toggleCategoryField() {
//     setState(() {
//       isCategoryFieldExpanded = !isCategoryFieldExpanded;
//       _isAmountFieldFocused = false;
//       _isAmountFieldFocused = false;
//     });
//   }

//  void _onKeypadNumberTap(String value) {
//     setState(() {
//       _amountText += value;
//       _amountController.text = _amountText;
//       amount = double.tryParse(_amountText);

//       if (!widget.isDebit) {
//         selectedCategory = "Income";
//         categoryFieldController.text = "Income";
//       }

//       fin = null;
//     });
//   }

//   void _onKeypadBackspace() {
//     if (_amountText.isEmpty) return;
//     setState(() {
//       _amountText = _amountText.substring(0, _amountText.length - 1);
//       _amountController.text = _amountText;
//       amount = double.tryParse(_amountText);
//       fin = null;
//     });
//   }

//   void _onKeypadSubmit() {
//     FocusScope.of(context).unfocus();

//     if (amount == null || amount == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a valid amount')),
//       );
//       return;
//     }

//     if (selectedCategory != null) {
//       setState(() {
//         fin = '$selectedCategory'
//             '${selectedSubCategory != null ? " ($selectedSubCategory)" : ""}';
//       });
//     }
//   }
//   void _submitAmount() {
//   final value = _amountController.text.trim();

//   if (value.isEmpty) {
//    snackBarCalledfail(context, "Please enter a valid amount");
//     return;
//   }

//   setState(() {
//     amount = double.tryParse(value);

//     if (!isDebit) {
//       selectedCategory = "Income";
//       categoryFieldController.text = "Income";
//     }

//     // This was earlier in onEditingComplete
//     fin = '$selectedCategory ($selectedSubCategory)';
//     _isAmountFieldFocused = false;
//   });

//   // Hide keyboard
//   FocusScope.of(context).unfocus();
// }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: _isCelebrationVisible
//             ? celebration()
//             : AnimatedPadding(
//                 padding: MediaQuery.of(context).viewInsets,
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeOut,
//                 child: Container(
//                   color: AppColors.border,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 10),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
                       
//                         //  if ((selectedCategory == null &&
//                         //         selectedSubCategory == null) ||
//                         //     !widget.isDebit) ...[
//                         //   Row(
//                         //     children: [
//                         //       Expanded(child: AmountWidget()),
//                         //     ],
//                         //   ),
//                         //   const SizedBox(height: 16),
//                         //   SizedBox(
//                         //     height: 240,
//                         //     child: CustomKeypad(
//                         //       onKeyTap: _onKeypadNumberTap,
//                         //       onBackspace: _onKeypadBackspace,
//                         //       onSubmit: _onKeypadSubmit,
//                         //     ),
//                         //   ),
//                         //   const SizedBox(height: 16),
//                         // ],

//                         if ((selectedCategory == null &&
//                                 selectedSubCategory == null) ||
//                             !widget.isDebit) ...[
//                           Row(
//                             children: [
//                               Expanded(child: AmountWidget()),
//                               const SizedBox(width: 8),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                         ],
//                         if (amount != null) ...[
//                           categoryWidget(),
//                         ],
//                         const SizedBox(height: 8),
//                         if (isCategoryFieldExpanded) ...[
//                           categoryExpandedWidget(),
//                           // getListOfCustomCategory(),
//                         ],
//                         if (selectedCategory != null &&
//                             selectedSubCategory == null) ...[
//                           Text('$selectedCategory',
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.normal,
//                                   fontSize: 16,
//                                   color: AppColors.accentColor)),
//                           SizedBox(height: 5),
//                           subcategoryWidget(),
//                         ],
//                         if (fin != null) ...[
//                           widget.isDebit
//                               ? SplitLendButton()
//                               : SizedBox.shrink(),
//                           continueButton(),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget celebration() {
//     return Stack(alignment: Alignment.center, children: [
//       // Confetti blast effect
//       ConfettiWidget(
//         confettiController: _confettiController,
//         blastDirectionality:
//             BlastDirectionality.explosive, // Blast in all directions
//         numberOfParticles: 50, // Number of confetti pieces
//         colors: const [Colors.green, Colors.blue, Colors.orange, Colors.pink],
//         gravity: 0.3, // Confetti falls slowly
//       ),
//       // Animated tick mark
//       ScaleTransition(
//         scale: CurvedAnimation(
//           parent: _iconAnimationController,
//           curve: Curves.elasticOut,
//         ),
//         child: Container(
//           width: MediaQuery.sizeOf(context).width * 1.1,
//           height: Colorcodes.paddingSize * 10,
//           color: AppColors.backgroundColor,
//           child: Column(
//             key: const ValueKey('celebration'),
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.check_circle,
//                 color: Colors.green,
//                 size: 100,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 HomepageStringsDart().successfullyAdded,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green[700],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ]);
//   }

//  Widget AmountWidget() {
//   return Container(
//     // card-like container similar to your screenshot
//     decoration: BoxDecoration(
//       color: AppColors.backgroundColor, // card background
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: AppColors.accentColor.withOpacity(0.03),
//           blurRadius: 6,
//           offset: const Offset(0, 2),
//         ),
//       ],
//       border: Border.all(color: AppColors.accentColor.withOpacity(0.06)),
//     ),
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // small title text at top (e.g. "Add Cash out")
//         Text(
//           isDebit?
         
//                'Add Cash Out' : "Add Cash in",// fallback
//                // use your string if available
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.bold,
//             fontSize: 14,
//             color: AppColors.accentColor,
//           ),
//         ),
//         const SizedBox(height: 8),

//         // thin divider under title
//         Divider(
//           height: 1,
//           color: AppColors.accentColor.withOpacity(0.15),
//           thickness: 1,
//         ),
//         const SizedBox(height: 12),

//         // row with icon box and textfield
//         Row(
//           children: [
//             // icon container (rounded square)
//             Container(
//               height: 44,
//               width: 44,
//               decoration: BoxDecoration(
//                 color: AppColors.button,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: AppColors.accentColor.withOpacity(0.06)),
//               ),
//               child: Center(
//                 // use your avatar image or fallback icon
//                 child: AvatarProfileImage(
//                   url: HomePageIcons.cash,
//                   width: 20,
//                   height: 20,
//                 ),
//                 // If you prefer a simple icon instead of AvatarProfileImage:
//                 // child: Icon(Icons.attach_money, size: 20, color: AppColors.primaryColor),
//               ),
//             ),
//             const SizedBox(width: 12),

//             // amount text field area
//             Expanded(
//               child: TextField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 textInputAction: TextInputAction.done,
//                 autofocus: _isAmountFieldFocused,
//                 inputFormatters: allowDecimalInput(),
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.normal,
//                   fontSize: 16,
//                   color: AppColors.accentColor,
//                 ),
//                 decoration: InputDecoration(
//                   isDense: true,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                   hintText: HomepageStringsDart().enterAmount,
//                   hintStyle: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.normal,
//                     fontSize: 16,
//                     color: AppColors.accentColor.withOpacity(0.45),
//                   ),
//                   border: InputBorder.none, // remove default borders to match image
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     amount = double.tryParse(value);
//                     if (!isDebit) {
//                       selectedCategory = "Income";
//                       categoryFieldController.text = "Income";
//                     }
//                     fin = null;
//                     _isAmountFieldFocused = false;
//                   });
//                 },
//                 onEditingComplete: () {
//                   fin = '$selectedCategory ($selectedSubCategory)';
//                   FocusScope.of(context).unfocus();
//                 },
//                 onSubmitted: (value) {
//                   _submitAmount();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// // Category input (card-style like AmountWidget)
// Widget categoryWidget() {
//   return Container(
//     decoration: BoxDecoration(
//       color: AppColors.backgroundColor,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: AppColors.accentColor.withOpacity(0.03),
//           blurRadius: 6,
//           offset: const Offset(0, 2),
//         ),
//       ],
//       border: Border.all(color: AppColors.accentColor.withOpacity(0.06)),
//     ),
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Title (like Add Cash out title in AmountWidget)
//         Text(
//           HomepageStringsDart().selectCategory ?? 'Select Category',
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.bold,
//             fontSize: 14,
//             color: AppColors.accentColor,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Divider(
//           height: 1,
//           color: AppColors.accentColor.withOpacity(0.12),
//           thickness: 1,
//         ),
//         const SizedBox(height: 12),

//         // Row with icon box + textfield
//         Row(
//           children: [
//             Container(
//               height: 44,
//               width: 44,
//               decoration: BoxDecoration(
//                 color: AppColors.button,
//                 borderRadius: BorderRadius.circular(10),
//                 border:
//                     Border.all(color: AppColors.accentColor.withOpacity(0.06)),
//               ),
//               child: const Center(child: Icon(Icons.search)),
//             ),
//             const SizedBox(width: 12),

//             Expanded(
//               child: TextField(
//                 controller: categoryFieldController,
//                 readOnly: !isDebit,
//                 decoration: InputDecoration(
//                   isDense: true,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                   hintText: HomepageStringsDart().selectCategory,
//                   hintStyle: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.normal,
//                     fontSize: 16,
//                     color: AppColors.accentColor.withOpacity(0.45),
//                   ),
//                   border: InputBorder.none,
//                 ),
//                 onTap: () {
//                   if (!isCategoryFieldExpanded) {
//                     if (isDebit) {
//                       toggleCategoryField();
//                     } else {
//                       setState(() {
//                         selectedCategory = "Income";
//                         selectedSubCategory = null;
//                         categoryFieldController.text = "Income";
//                       });
//                     }
//                   }
//                 },
//                 onChanged: (value) => filterCategories(value),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// // Expanded category list but inside a card-like container to match AmountWidget look
// Widget categoryExpandedWidget() {
//   return Container(
//     // keep it visually consistent with the category card
//     margin: const EdgeInsets.only(top: 8),
//     padding: const EdgeInsets.all(8),
//     decoration: BoxDecoration(
//       color: AppColors.backgroundColor,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: AppColors.accentColor.withOpacity(0.02),
//           blurRadius: 6,
//           offset: const Offset(0, 2),
//         ),
//       ],
//       border: Border.all(color: AppColors.accentColor.withOpacity(0.04)),
//     ),
//     // limit height so it doesn't grow indefinitely
//     constraints: BoxConstraints(
//       maxHeight: MediaQuery.of(context).size.height * 0.35,
//     ),
//     child: filteredCategories.isEmpty
//         ? Center(
//             child: Text(
//               'No categories found',
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.normal,
//                 fontSize: 14,
//                 color: AppColors.accentColor.withOpacity(0.6),
//               ),
//             ),
//           )
//         : ListView.builder(
//             shrinkWrap: true,
//             itemCount: filteredCategories.length,
//             itemBuilder: (BuildContext context, int index) {
//               final item = filteredCategories[index];
//               final isCategory = item['isCategory'] as bool;
//               final category = item['category'] as String;
//               final isCustom = item['isCustom'] ?? false;
//               String urlPath = "";

//               if (isCustom) {
//                 urlPath = item['imageUrl'] ?? '';
//               } else if (isCategory) {
//                 try {
//                   urlPath =
//                       Categories.link + BudgetCategories.listofCategories[category]!;
//                 } catch (e) {
//                   urlPath = '';
//                 }
//               } else {
//                 urlPath = BudgetSubCategories.listofSubCategories[item['subcategory']] ??
//                     "assets/icons/subCategoryIcons/default.svg";
//               }

//               return ListTile(
//                 leading: Container(
//                   height: 40,
//                   width: 40,
//                   child: AvatarProfileImage(
//                     url: urlPath,
//                     width: 4,
//                     height: 4,
//                   ),
//                 ),
//                 title: Text(
//                   isCategory ? category : '${item['subcategory']} ($category)',
//                   style: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.normal,
//                     fontSize: 16,
//                     color: AppColors.accentColor,
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     if (isCategory) {
//                       if (isCustom) {
//                         selectedCategory = category;
//                         selectedSubCategory = "";
//                         selectedCategory2 = selectedCategory;
//                         selectedSubCategory2 = selectedSubCategory;
//                         isCategoryFieldExpanded = false;
//                         categoryFieldController.text = category;
//                         fin = '$selectedCategory (None)';
//                         _isAmountFieldFocused = false;
//                         FocusScope.of(context).unfocus();
//                         resetToInitialScreen();
//                       } else {
//                         selectedCategory = category;
//                         selectedSubCategory = null;
//                         selectedCategory2 = selectedCategory;
//                         selectedSubCategory2 = selectedSubCategory;
//                         categoryFieldController.text = category;
//                         isCategoryFieldExpanded = false;
//                         _isAmountFieldFocused = false;
//                         FocusScope.of(context).unfocus();
//                       }
//                     } else {
//                       selectedCategory = item['category'];
//                       selectedSubCategory = item['subcategory'];
//                       selectedCategory2 = selectedCategory;
//                       selectedSubCategory2 = selectedSubCategory;
//                       categoryFieldController.text =
//                           '$selectedCategory ($selectedSubCategory)';
//                       isCategoryFieldExpanded = false;
//                       fin = '$selectedCategory ($selectedSubCategory)';
//                       _isAmountFieldFocused = false;
//                       FocusScope.of(context).unfocus();
//                       resetToInitialScreen();
//                     }
//                   });
//                 },
//               );
//             },
//           ),
//   );
// }

// // Small tweak to custom list to match card visuals (replace existing getListOfCustomCategory if you want)
// Widget getListOfCustomCategory() {
//   return Container(
//     margin: const EdgeInsets.only(top: 8),
//     decoration: BoxDecoration(
//       color: AppColors.backgroundColor,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: AppColors.accentColor.withOpacity(0.04)),
//     ),
//     constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
//     child: ListView.builder(
//       shrinkWrap: true,
//       itemCount: customCategoryList.length,
//       itemBuilder: (BuildContext context, int index) {
//         final category = customCategoryList[index];
//         final categoryName = category['name'] ?? '';
//         final imageUrl = category['imageUrl'] ?? '';

//         return ListTile(
//           leading: Container(
//             height: 40,
//             width: 40,
//             child: AvatarProfileImage(
//               url: imageUrl,
//               width: 4,
//               height: 4,
//             ),
//           ),
//           title: Text(
//             categoryName,
//             style: FontManager().getTextStyle(
//               context,
//               lWeight: FontWeight.normal,
//               fontSize: 16,
//               color: AppColors.accentColor,
//             ),
//           ),
//           onTap: () {
//             setState(() {
//               selectedCategory = categoryName;
//               categoryFieldController.text = categoryName;
//               isCategoryFieldExpanded = false;
//               _isAmountFieldFocused = false;
//               FocusScope.of(context).unfocus();
//             });
//           },
//         );
//       },
//     ),
//   );
// }

// // Subcategory chips (styling kept same, but placed inside the same visual flow)
// Widget subcategoryWidget() {
//   if (selectedCategory == null || !categories.containsKey(selectedCategory)) {
//     return const SizedBox.shrink();
//   }

//   return Container(
//     margin: const EdgeInsets.only(top: 12),
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     decoration: BoxDecoration(
//       color: AppColors.backgroundColor,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: AppColors.accentColor.withOpacity(0.03),
//           blurRadius: 6,
//           offset: const Offset(0, 2),
//         ),
//       ],
//       border: Border.all(color: AppColors.accentColor.withOpacity(0.06)),
//     ),

//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Title (like AmountWidget style title)
//         Text(
//           "Select Subcategory",
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.bold,
//             fontSize: 14,
//             color: AppColors.accentColor,
//           ),
//         ),

//         const SizedBox(height: 8),

//         Divider(
//           height: 1,
//           thickness: 1,
//           color: AppColors.accentColor.withOpacity(0.15),
//         ),

//         const SizedBox(height: 12),

//         // Subcategory items → wrapped like a grid
//         Wrap(
//           spacing: 10,
//           runSpacing: 12,
//           children: categories[selectedCategory]!.map((subCategory) {
//             final urlPath = BudgetSubCategories.listofSubCategories[subCategory] ??
//                 "assets/icons/subCategoryIcons/default.svg";

//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedSubCategory = subCategory;
//                   selectedSubCategory2 = subCategory;

//                   categoryFieldController.text =
//                       '$selectedCategory ($selectedSubCategory)';
//                   fin = '$selectedCategory ($selectedSubCategory)';
//                   selectedCategory2 = selectedCategory;

//                   _isAmountFieldFocused = false;
//                   FocusScope.of(context).unfocus();
//                   resetToInitialScreen();
//                 });
//               },

//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: AppColors.button,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppColors.accentColor.withOpacity(0.15),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ProfileImage(url: urlPath, ),

//                     const SizedBox(width: 8),

//                     Text(
//                       toUpperCase(subCategory),
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.normal,
//                         fontSize: 14,
//                         color: AppColors.accentColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     ),
//   );
// }

//   Widget SplitLendButton() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         GestureDetector(
//           onTap: () async {
//             Navigator.pop(context);
//             FocusScope.of(context).unfocus();
//             if (isLend.value) {
//               addedUser.clear();
//               addedMembers.clear();
//             }
//             isSplit.value = true;
//             isLend.value = false;

//             final result =
//                 await showCustomFriendsModal(context, amount ?? 0.0, false);

//             // if (result != null && addedMembers.isNotEmpty) {

//             //   splitUserAmountManualTransaction(
//             //     context,
//             //     amount.toString(),
//             //     addedMembers,
//             //     selectedCategory2.toString(),
//             //     selectedSubCategory2.toString(),
//             //     amounts: result as Map<String, double>,
//             //   );
//             // }
//             setState(() {
//               _isAmountFieldFocused = false; // Prevent amount field refocus
//             });
//           },
//           child: Container(
//             width: MediaQuery.of(context).size.width / 2.4,
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//             decoration: BoxDecoration(
//               color: AppColors.button,
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Center(
//               child: Text(
//                 HomepageStringsDart().billSplit,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 15,
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         GestureDetector(
//           onTap: () async {
//             FocusScope.of(context).unfocus();
//             if (isSplit.value) {
//               addedUser.clear();
//               addedMembers.clear();
//             }
//             isSplit.value = false;
//             isLend.value = true;

//             await showCustomFriendsModal(context, amount ?? 0.0, true);
//             addLendUserAmount(
//               context,
//               amount.toString(),
//               addedMembers,
//               selectedCategory2.toString(),
//               selectedSubCategory2.toString(),
//             );
//             Navigator.pop(context);
//             setState(() {
//               _isAmountFieldFocused = false; // Prevent amount field refocus
//             });
//           },
//           child: Container(
//             width: MediaQuery.of(context).size.width / 2.4,
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//             decoration: BoxDecoration(
//               color: AppColors.button,
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Center(
//               child: Text(
//                 HomepageStringsDart().lendMoney,
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 15,
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget continueButton() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         // Button to trigger celebration
//         Center(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 10),
//             child: InkWell(
//               onTap: () {
//                 FocusScope.of(context).unfocus();
//                 if (cashInAndOut.value) return;
//                 cashInAndOut.value = true;
               
//                 addTransaction(
//                   amount.toString(),
//                   selectedSubCategory2.toString(),
//                   selectedCategory2.toString(),
//                   context,
//                   "cash",
//                 );
//               },
//               // },
//               child: Obx(() => cashInAndOut.value
//                   ? getspinner(context)
//                   : getButton(context, HomepageStringsDart().addButton)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

 
 
//   Future<dynamic> showCustomFriendsModal(
//     BuildContext context,
//     double totalAmount,
//     bool isLendMode,
//   ) async {
//     return await showModalBottomSheet<dynamic>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: NewFriendsUi(
//             totalAmount: totalAmount,
//             userId: userController.userId.value,
//             userName: userController.userName.value,
//             userAvatar: userController.avatar.value,
//             isLendMode: isLendMode,
//             category: selectedCategory2,
//             subcategory: selectedSubCategory2,
//           ),
//         );
//       },
//     );
//   }

//     }


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/manual_transaction_repository.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/image_service/profile.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:get/get.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../Constants/custom_keypad.dart';
import '../../components/shared_utils.dart';
import '../../routes/index_route.dart';

bool isDebit = true;

class ModalContent extends StatefulWidget {
  final bool isDebit;
  const ModalContent(this.isDebit, {Key? key}) : super(key: key);

  @override
  _ModalContentState createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent>
   with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<ModalContent>{
  String? selectedCategory;
  String? selectedSubCategory;
  final TextEditingController _amountController = TextEditingController();
  double? amount;
  String? fin;
  final TextEditingController categoryFieldController = TextEditingController();
  bool isCategoryFieldExpanded = false;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredCategories = [];
  late ConfettiController _confettiController;
  late AnimationController _iconAnimationController;
  bool _isCelebrationVisible = false;
  String? selectedCategory2;
  String? selectedSubCategory2;
  bool _isAmountFieldFocused = true;
  final FocusNode _amountFocusNode = FocusNode();
  late IO.Socket socket;
  String _amountText = ''; // keypad input text

  // scroll control and key to compute offset
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _categoryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getAllTransaction(context);

    // initial filtered categories based on tab (cash-in or cash-out)
    _populateInitialFilteredCategories();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    socket = IO.io(API.urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    setUpSocketListener();
  }

  void _populateInitialFilteredCategories() {
    // If cash-in (widget.isDebit == false): show only Income category & its subs
    // If cash-out (widget.isDebit == true): show all categories excluding Income, include custom categories
    filteredCategories = [];
    if (!widget.isDebit) {
      // cash-in: only Income category and its subcategories (if exists)
      if (categories.containsKey('Income')) {
        final subs = categories['Income']!;
        // show as the category entry (isCategory true), and also list subcategories as separate entries if desired
        filteredCategories.add({
          'category': 'Income',
          'subcategories': subs,
          'isCategory': true,
        });
        // also add each subcategory as an explicit sub-entry (keeps search working)
        for (var sub in subs) {
          filteredCategories.add({
            'category': 'Income',
            'subcategory': sub,
            'isCategory': false,
          });
        }
      } else {
        // fallback: if no explicit 'Income' present, show nothing
        filteredCategories = [];
      }
    } else {
      // cash-out: show all categories except 'Income'
      filteredCategories = categories.entries
          .where((e) => e.key.toLowerCase() != 'income')
          .map((entry) => {
                'category': entry.key,
                'subcategories': entry.value,
                'isCategory': true,
              })
          .toList();

      // include custom categories (if any) for cash-out
      for (var custom in customCategoryList) {
        filteredCategories.add({
          'category': custom['name'],
          'subcategory': '',
          'isCategory': true,
          'isCustom': true,
          'imageUrl': custom['imageUrl'],
        });
      }
    }
  }

  // Add transaction
  setUpSocketListener() {
    socket.on("disconnect", (data) => {socket.close()});
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _scrollController.dispose();
    _confettiController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  // helper: whether to include a category (used during search)
  bool _shouldIncludeCategory(String categoryName) {
    // cash-in -> only include 'Income'
    if (!widget.isDebit) {
      return categoryName.toLowerCase() == 'income';
    }
    // cash-out -> exclude 'Income'
    return categoryName.toLowerCase() != 'income';
  }

  void filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        // repopulate initial filter list based on tab
        _populateInitialFilteredCategories();
      } else {
        filteredCategories = [];
        categories.forEach((category, subcategories) {
          // respect include/exclude rule
          if (!_shouldIncludeCategory(category)) {
            return; // skip this entire category
          }

          // Check if category matches the query
          if (category.toLowerCase().contains(query.toLowerCase())) {
            filteredCategories.add({
              'category': category,
              'subcategories': subcategories,
              'isCategory': true,
            });
          }

          // Check if any subcategory matches the query
          for (var subcategory in subcategories) {
            if (subcategory.toLowerCase().contains(query.toLowerCase())) {
              filteredCategories.add({
                'category': category,
                'subcategory': subcategory,
                'isCategory': false,
              });
            }
          }
        });

        // For cash-out only, include custom categories that match search
        if (widget.isDebit) {
          for (var customCategory in customCategoryList) {
            final name = (customCategory['name'] ?? '').toString();
            if (name.toLowerCase().contains(query.toLowerCase())) {
              filteredCategories.add({
                'category': name,
                'subcategory': '',
                'isCategory': true,
                'isCustom': true,
                'imageUrl': customCategory['imageUrl'],
              });
            }
          }
        }
      }
    });
  }

  void resetToInitialScreen() {
    setState(() {
      selectedCategory = null;
      selectedSubCategory = null;
      isCategoryFieldExpanded = false;
      _isAmountFieldFocused = false;
      // re-populate filteredCategories according to tab
      _populateInitialFilteredCategories();
    });
  }

  // Helper to scroll the category widget to the top of the visible scroll area (with padding)
  Future<void> _scrollCategoryToTop({double topPadding = 6.0}) async {
    try {
      if (_categoryKey.currentContext == null) return;

      final RenderBox categoryBox =
          _categoryKey.currentContext!.findRenderObject() as RenderBox;
      final Offset categoryGlobal = categoryBox.localToGlobal(Offset.zero);

      final RenderBox scrollBox =
          _scrollController.position.context.storageContext.findRenderObject()
              as RenderBox;
      final Offset scrollGlobal = scrollBox.localToGlobal(Offset.zero);

      final double dy = categoryGlobal.dy - scrollGlobal.dy;

      double target = _scrollController.offset + dy - topPadding;

      final double min = _scrollController.position.minScrollExtent;
      final double max = _scrollController.position.maxScrollExtent;
      if (target < min) target = min;
      if (target > max) target = max;

      await _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      if (_categoryKey.currentContext != null) {
        await Scrollable.ensureVisible(
          _categoryKey.currentContext!,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    }
  }

  // Wait until keyboard opens (viewInsets.bottom > 0) or timeout, then scroll category to top.
  Future<void> _waitForKeyboardThenScroll({double topPadding = 6.0}) async {
    if (_categoryKey.currentContext == null) return;

    const int maxTries = 10;
    const Duration step = Duration(milliseconds: 40);
    int tries = 0;

    while (tries < maxTries) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      if (bottomInset > 0) break; // keyboard visible
      tries++;
      await Future.delayed(step);
    }

    await Future.delayed(const Duration(milliseconds: 8));
    await _scrollCategoryToTop(topPadding: topPadding);
  }

  // UPDATED toggleCategoryField to scroll the category into view when expanded or when keyboard present
  void toggleCategoryField() {
    setState(() {
      isCategoryFieldExpanded = !isCategoryFieldExpanded;
      _isAmountFieldFocused = false;
      // when opening, ensure the filtered list is correct for tab
      if (isCategoryFieldExpanded) {
        _populateInitialFilteredCategories();
      }
    });

    // schedule scroll after frame so layout is updated
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      if (bottomInset > 0) {
        await _scrollCategoryToTop(topPadding: 6.0);
        return;
      }
      await _waitForKeyboardThenScroll(topPadding: 6.0);
    });
  }

  

  

  void _submitAmount() {
    final value = _amountController.text.trim();

    if (value.isEmpty) {
      snackBarCalledfail(context, "Please enter a valid amount");
      return;
    }

    setState(() {
      amount = double.tryParse(value);

      if (!isDebit) {
        selectedCategory = "Income";
        categoryFieldController.text = "Income";
      }

      fin = '$selectedCategory ($selectedSubCategory)';
      _isAmountFieldFocused = false;
    });

    FocusScope.of(context).unfocus();
  }

   @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Important: call super.build when using AutomaticKeepAliveClientMixin
    super.build(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isCelebrationVisible
            ? celebration()
            : AnimatedPadding(
                padding: MediaQuery.of(context).viewInsets,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Container(
                  color: AppColors.border,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((selectedCategory == null &&
                                  selectedSubCategory == null) ||
                              !widget.isDebit) ...[
                            Row(
                              children: [
                                Expanded(child: AmountWidget()),
                                const SizedBox(width: 8),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (amount != null) ...[
                            categoryWidget(),
                          ],
                           const SizedBox(height: 6),
                         
                          if (isCategoryFieldExpanded) ...[
                          categoryExpandedWidget(),
                          // getListOfCustomCategory(),
                        ],
                          if (selectedCategory != null &&
                              selectedSubCategory == null) ...[
                            subcategoryWidget(),
                          ],
                          if (fin != null) ...[
                            widget.isDebit ? SplitLendButton() : SizedBox.shrink(),
                            continueButton(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget celebration() {
    return Stack(alignment: Alignment.center, children: [
      ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        numberOfParticles: 50,
        colors: const [Colors.green, Colors.blue, Colors.orange, Colors.pink],
        gravity: 0.3,
      ),
      ScaleTransition(
        scale: CurvedAnimation(
          parent: _iconAnimationController,
          curve: Curves.elasticOut,
        ),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 1.1,
          height: Colorcodes.paddingSize * 10,
          color: AppColors.backgroundColor,
          child: Column(
            key: const ValueKey('celebration'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                HomepageStringsDart().successfullyAdded,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget AmountWidget() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.accentColor.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isDebit ? 'Add Cash Out' : "Add Cash in",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: AppColors.accentColor.withOpacity(0.15),
            thickness: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.accentColor.withOpacity(0.06)),
                ),
                child: Center(
                  child: AvatarProfileImage(
                    url: HomePageIcons.addAmount,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofocus: _isAmountFieldFocused,
                  inputFormatters: allowDecimalInput(),
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: HomepageStringsDart().enterAmount,
                    hintStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.normal,
                      fontSize: 16,
                      color: AppColors.accentColor.withOpacity(0.45),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      amount = double.tryParse(value);
                      if (!widget.isDebit) {
                        selectedCategory = "Income";
                        categoryFieldController.text = "Income";
                      }
                      fin = null;
                      _isAmountFieldFocused = false;
                    });
                  },
                  onEditingComplete: () {
                    fin = '$selectedCategory ($selectedSubCategory)';
                    FocusScope.of(context).unfocus();
                  },
                  onSubmitted: (value) {
                    _submitAmount();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Category input (card-style like AmountWidget)
  Widget categoryWidget() {
    return Container(
      key: _categoryKey,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.accentColor.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HomepageStringsDart().selectCategory ?? 'Select Category',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: AppColors.accentColor.withOpacity(0.12),
            thickness: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentColor.withOpacity(0.06)),
                ),
                child: const Center(child: Icon(Icons.search, color: AppColors.accentColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: categoryFieldController,
                  readOnly: !widget.isDebit,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: HomepageStringsDart().selectCategory,
                    hintStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.normal,
                      fontSize: 16,
                      color: AppColors.accentColor.withOpacity(0.45),
                    ),
                    border: InputBorder.none,
                  ),
                  onTap: () {
                    if (!isCategoryFieldExpanded) {
                      if (widget.isDebit) {
                        toggleCategoryField();
                      } else {
                        setState(() {
                          selectedCategory = "Income";
                          selectedSubCategory = null;
                          categoryFieldController.text = "Income";
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
                          if (bottomInset > 0) {
                            await _scrollCategoryToTop(topPadding: 6.0);
                          } else {
                            await _waitForKeyboardThenScroll(topPadding: 6.0);
                          }
                        });
                      }
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
                        if (bottomInset > 0) {
                          await _scrollCategoryToTop(topPadding: 6.0);
                        } else {
                          await _waitForKeyboardThenScroll(topPadding: 6.0);
                        }
                      });
                    }
                  },
                  onChanged: (value) => filterCategories(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Expanded category list but inside a card-like container to match AmountWidget look
  Widget categoryExpandedWidget() {
    return Container(
      // no top margin so expanded list sits flush under category card
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.accentColor.withOpacity(0.04)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: filteredCategories.isEmpty
          ? Center(
              child: Text(
                'No categories found',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.normal,
                  fontSize: 14,
                  color: AppColors.accentColor.withOpacity(0.6),
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              // physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredCategories.length,
              itemBuilder: (BuildContext context, int index) {
                final item = filteredCategories[index];
                final isCategory = item['isCategory'] as bool;
                final category = (item['category'] ?? '') as String;
                final isCustom = item['isCustom'] ?? false;
                String urlPath = "";

                if (isCustom) {
                  urlPath = item['imageUrl'] ?? '';
                } else if (isCategory) {
                  try {
                    urlPath =
                        Categories.link + BudgetCategories.listofCategories[category]!;
                  } catch (e) {
                    urlPath = '';
                  }
                } else {
                  urlPath = BudgetSubCategories.listofSubCategories[item['subcategory']] ??
                      "assets/icons/subCategoryIcons/default.svg";
                }

                return ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  minVerticalPadding: 0,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  leading: SizedBox(
                    height: 36,
                    width: 36,
                    child: AvatarProfileImage(
                      url: urlPath,
                      width: 4,
                      height: 4,
                    ),
                  ),
                  title: Text(
                    isCategory ? category : '${item['subcategory']} ($category)',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.bg3,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (isCategory) {
                        if (isCustom) {
                          selectedCategory = category;
                          selectedSubCategory = "";
                          selectedCategory2 = selectedCategory;
                          selectedSubCategory2 = selectedSubCategory;
                          isCategoryFieldExpanded = false;
                          categoryFieldController.text = category;
                          fin = '$selectedCategory (None)';
                          _isAmountFieldFocused = false;
                          FocusScope.of(context).unfocus();
                          resetToInitialScreen();
                        } else {
                          selectedCategory = category;
                          selectedSubCategory = null;
                          selectedCategory2 = selectedCategory;
                          selectedSubCategory2 = selectedSubCategory;
                          categoryFieldController.text = category;
                          isCategoryFieldExpanded = false;
                          _isAmountFieldFocused = false;
                          FocusScope.of(context).unfocus();
                        }
                      } else {
                        selectedCategory = item['category'];
                        selectedSubCategory = item['subcategory'];
                        selectedCategory2 = selectedCategory;
                        selectedSubCategory2 = selectedSubCategory;
                        categoryFieldController.text =
                            '$selectedCategory ($selectedSubCategory)';
                        isCategoryFieldExpanded = false;
                        fin = '$selectedCategory ($selectedSubCategory)';
                        _isAmountFieldFocused = false;
                        FocusScope.of(context).unfocus();
                        resetToInitialScreen();
                      }
                    });
                  },
                );
              },
            ),
    );
  }

  Widget getListOfCustomCategory() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.04)),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: customCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          final category = customCategoryList[index];
          final categoryName = category['name'] ?? '';
          final imageUrl = category['imageUrl'] ?? '';

          return ListTile(
            leading: Container(
              height: 40,
              width: 40,
              child: AvatarProfileImage(
                url: imageUrl,
                width: 4,
                height: 4,
              ),
            ),
            title: Text(
              categoryName,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.normal,
                fontSize: 16,
                color: AppColors.accentColor,
              ),
            ),
            onTap: () {
              setState(() {
                selectedCategory = categoryName;
                categoryFieldController.text = categoryName;
                isCategoryFieldExpanded = false;
                _isAmountFieldFocused = false;
                FocusScope.of(context).unfocus();
              });
            },
          );
        },
      ),
    );
  }

  Widget subcategoryWidget() {
    if (selectedCategory == null || !categories.containsKey(selectedCategory)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.accentColor.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Subcategory",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.accentColor.withOpacity(0.15),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: categories[selectedCategory]!.map((subCategory) {
              final urlPath = BudgetSubCategories.listofSubCategories[subCategory] ??
                  "assets/icons/subCategoryIcons/default.svg";

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSubCategory = subCategory;
                    selectedSubCategory2 = subCategory;

                    categoryFieldController.text =
                        '$selectedCategory ($selectedSubCategory)';
                    fin = '$selectedCategory ($selectedSubCategory)';
                    selectedCategory2 = selectedCategory;

                    _isAmountFieldFocused = false;
                    FocusScope.of(context).unfocus();
                    resetToInitialScreen();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentColor.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileImage(url: urlPath),
                      const SizedBox(width: 8),
                      Text(
                        toUpperCase(subCategory),
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.normal,
                          fontSize: 14,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget SplitLendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            Navigator.pop(context);
            FocusScope.of(context).unfocus();
            if (isLend.value) {
              addedUser.clear();
              addedMembers.clear();
            }
            isSplit.value = true;
            isLend.value = false;

            final result = await showCustomFriendsModal(context, amount ?? 0.0, false);

            setState(() {
              _isAmountFieldFocused = false;
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2.4,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.button,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                HomepageStringsDart().billSplit,
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
          onTap: () async {
            FocusScope.of(context).unfocus();
            if (isSplit.value) {
              addedUser.clear();
              addedMembers.clear();
            }
            isSplit.value = false;
            isLend.value = true;

            await showCustomFriendsModal(context, amount ?? 0.0, true);
            addLendUserAmount(
              context,
              amount.toString(),
              addedMembers,
              selectedCategory2.toString(),
              selectedSubCategory2.toString(),
            );
            Navigator.pop(context);
            setState(() {
              _isAmountFieldFocused = false;
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2.4,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.button,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                HomepageStringsDart().lendMoney,
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
    );
  }

  Widget continueButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                if (cashInAndOut.value) return;
                cashInAndOut.value = true;

                addTransaction(
                  amount.toString(),
                  selectedSubCategory2.toString(),
                  selectedCategory2.toString(),
                  context,
                  "cash",
                );
              },
              child: Obx(() => cashInAndOut.value
                  ? getspinner(context)
                  : getButton(context, HomepageStringsDart().addButton)),
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> showCustomFriendsModal(
    BuildContext context,
    double totalAmount,
    bool isLendMode,
  ) async {
    return await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: NewFriendsUi(
            totalAmount: totalAmount,
            userId: userController.userId.value,
            userName: userController.userName.value,
            userAvatar: userController.avatar.value,
            isLendMode: isLendMode,
            category: selectedCategory2,
            subcategory: selectedSubCategory2,
          ),
        );
      },
    );
  }
}
