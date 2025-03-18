import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:confetti/confetti.dart';
//import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Manualtransaction extends StatefulWidget {
  const Manualtransaction({super.key});

  @override
  State<Manualtransaction> createState() => _ManualtransactionState();
}

class _ManualtransactionState extends State<Manualtransaction> {
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width/0.8,
      // padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: AvatarProfileImage(
                    url: HomePageIcons.manualTransaction,
                    height: 24,
                    width: 24,
                  )),
              SizedBox(width: MediaQuery.of(context).size.width / 52),
              Container(
                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Manual Transaction',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w600,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: AppColors.accentColor)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => showCustomModal(context),
                      child: Container(
                        height: Colorcodes.paddingSize * 1.7,
                        width: Colorcodes.paddingSize * 5,
                        decoration: BoxDecoration(
                            color: AppColors.button,
                            borderRadius: BorderRadius.circular(16)),
                        child: Center(
                          child: Text('Start now',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: AppColors.primaryColor)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
             
                AvatarProfileImage(
                  url: LikeComment.manualTransaction,
                  height: 11,
                  width: 16,
                )
            ],
          )

          
        ],
      ),
    );
  }
}

void showCustomModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (BuildContext context) {
      return ModalContent(); // Use the modal widget here
    },
  );
}

class ModalContent extends StatefulWidget {
  const ModalContent({Key? key}) : super(key: key);

  @override
  _ModalContentState createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent>
    with SingleTickerProviderStateMixin {
  String? selectedCategory;
  String? selectedSubCategory;
  final TextEditingController _amountController = TextEditingController();
  double? amount;
  String? fin;
  final TextEditingController categoryFieldController = TextEditingController();
  bool isCategoryFieldExpanded = false;
  final TextEditingController searchController = TextEditingController();
  List<String> filteredCategories = [];
  late ConfettiController _confettiController;
  late AnimationController _iconAnimationController;
  bool _isCelebrationVisible = false;
  String? selectedCategory2;
  String? selectedSubCategory2;
  // List  addedUser=[];
  // List addedMembers=[];

  late IO.Socket socket;

  void initState() {
    super.initState();
    getAllTransaction(context);
    getCategoryData();
    filteredCategories = categories.keys.toList();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Animation controller for the tick mark
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    socket = IO.io(urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    setUpSocketListener();
    // Initialize with all categories
  }

  setUpSocketListener() {
    socket.on(
        "disconnect",
        (data) => {
              socket.close(),
            });
  }

  void dispose() {
    _confettiController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        // Show all categories when search is cleared
        filteredCategories = categories.keys.toList();
      } else {
        // Filter categories by search query
        filteredCategories = categories.keys
            .where((category) =>
                category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void resetToInitialScreen() {
    setState(() {
      selectedCategory = null;
      selectedSubCategory = null;
      isCategoryFieldExpanded = false;
      // isSplitbill = (selectedCategory != null &&
      //     selectedSubCategory != null &&
      //     amount != null);
    });
  }

  void toggleCategoryField() {
    setState(() {
      isCategoryFieldExpanded = !isCategoryFieldExpanded;
    });
  }

//celebration after tapping continue
  void _showCelebration() {
    // Trigger confetti and animation

    setState(() {
      _isCelebrationVisible = true;
    });
    _confettiController.play(); // Start confetti animation
    _iconAnimationController.forward();
    // Start tick icon animation
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        // Added Directionality widget

        textDirection: TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isCelebrationVisible
              // Show Celebration if Continue button is tapped
              ? celebration()
              : AnimatedPadding(
                  padding: MediaQuery.of(context)
                      .viewInsets, // Adjusts padding when keyboard appears
                  duration: const Duration(milliseconds: 100),

                  curve: Curves.easeOut,
                  child: Container(
                    color: AppColors.backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            selectedSubCategory == null
                                ? selectedCategory == null
                                    ? 'Manual Transaction'
                                    : ''
                                : 'Manual Transactions',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.accentColor),
                          ),
                          const SizedBox(height: 16),

                          // Enter Amount Field (Only shown if no category is selected)

                          if (selectedCategory == null &&
                              selectedSubCategory == null) ...[
                            AmountWidget(),
                            const SizedBox(height: 16),
                          ],

                          if (amount != null) ...[
                            categoryWidget(),
                          ],
                          const SizedBox(height: 8),
                          if (isCategoryFieldExpanded) ...[
                            categoryExpandedWidget(),
                          ],

                          // Subcategories List (Visible after category is selected)
                          if (selectedCategory != null &&
                              selectedSubCategory == null) ...[
                            Text('$selectedCategory',
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: AppColors.accentColor)),
                            SizedBox(
                              height: 5,
                            ),
                            subcategoryWidget(),
                          ],

                          if (fin != null) ...[
                            buttonsWidget(),
                            continueButton(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
        ));
  }

  Widget celebration() {
    return Stack(alignment: Alignment.center, children: [
      // Confetti blast effect
      ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality:
            BlastDirectionality.explosive, // Blast in all directions
        numberOfParticles: 50, // Number of confetti pieces
        colors: const [Colors.green, Colors.blue, Colors.orange, Colors.pink],
        gravity: 0.3, // Confetti falls slowly
      ),
      // Animated tick mark
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
                'Successfully Added',
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
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.currency_rupee),
        hintText: 'Enter amount',
        fillColor: AppColors.button,
        filled: true,
        hintStyle: FontManager().getTextStyle(context,
            lWeight: FontWeight.normal,
            fontSize: 16,
            color: AppColors.accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accentColor, // Default border color
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentColor
              // When not focused

              ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accentColor, // Color when focused
            // Slightly thicker when focused for emphasis
          ),
        ),
      ),
      onChanged: (value) {
        setState(() {
          // Update the amount variable whenever the input changes
          amount = double.tryParse(value); // Convert string to double
        });
      },
    );
  }

  Widget categoryWidget() {
    return GestureDetector(
      onTap: toggleCategoryField,
      child: TextField(
        controller: categoryFieldController,
        readOnly: false,
        decoration: InputDecoration(
          hintText: 'Select Category',
          fillColor: AppColors.button,
          filled: true,
          hintStyle: FontManager().getTextStyle(context,
              lWeight: FontWeight.normal,
              fontSize: 16,
              color: AppColors.accentColor),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.accentColor, // When not focused
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.accentColor, // Color when focused
              // Slightly thicker when focused for emphasis
            ),
          ),
        ),
        onTap: () {
          if (!isCategoryFieldExpanded) {
            toggleCategoryField();
          }
        },
        onChanged: (value) {
          filterCategories(value); // Filter categories as the user types
        },
      ),
    );
  }

  Widget categoryExpandedWidget() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredCategories.length,
        itemBuilder: (BuildContext context, int index) {
          String category = filteredCategories[index];
          String urlPath = "";
          try {
            urlPath = Categories.link +
                BudgetCategories.listofCategories[
                    BudgetCategories.listofCategories.keys.elementAt(index)];
          } catch (e) {}

          return ListTile(
            //leading: const Icon(Icons.category),

            leading: Container(
              height: 40,
              width: 40,
              child: AvatarProfileImage(
                url: urlPath,
                width: 4,
                height: 4,
              ),
            ),
            title: Text(category,
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                    color: AppColors.accentColor)),
            onTap: () {
              setState(() {
                selectedCategory = category;
                categoryFieldController.text = category; // Update text field
                isCategoryFieldExpanded = false; // Collapse the list
              });
            },
          );
        },
      ),
    );
  }

  Widget subcategoryWidget() {
    return Wrap(
      spacing: 4.0, // Horizontal spacing between chips
      runSpacing: 2.0, // Vertical spacing between rows
      children: categories[selectedCategory]!.map((subCategory) {
        // Get the URL path for the subcategory's icon from BudgetSubCategories
        String urlPath = BudgetSubCategories.listofSubCategories[subCategory] ??
            "assets/icons/subCategoryIcons/default.svg";

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedSubCategory = subCategory;
              selectedSubCategory2 = subCategory;
              categoryFieldController.text =
                  '$selectedCategory ($selectedSubCategory)';
              // isSplitbill = true; // Uncomment if needed
              fin = '$selectedCategory ($selectedSubCategory)';
              selectedCategory2 = selectedCategory;
              resetToInitialScreen();
            });
          },
          child: Chip(
            avatar: ProfileImage(
              url: urlPath,
            ),
            label: Text(
              subCategory,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.normal,
                fontSize: 14,
                color: AppColors.accentColor,
              ),
            ),
            backgroundColor: AppColors.button,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buttonsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            if (isLend.value) {
              addedUser.clear();
              addedMembers.clear();
            }
            isSplit.value = true;
            isLend.value = false;

            final result =
                await showCustomFriendsModal(context, amount ?? 0.0, false);
            if (result != null && addedMembers.isNotEmpty) {
              // print("buttonsWidget: Split mode - Received amounts: $result");
              splitUserAmount(
                context,
                amount.toString(),
                addedMembers,
                selectedCategory2.toString(),
                selectedSubCategory2.toString(),
                amounts: result as Map<String, double>,
              );
            }
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
                'Bill Split',
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
            if (isSplit.value) {
              addedUser.clear();
              addedMembers.clear();
            }
            isSplit.value = false;
            isLend.value = true;
            // showCustomFriendsModal(context, amount ?? 0.0);
            final result =
                await showCustomFriendsModal(context, amount ?? 0.0, true);
            if (result != null) {
              // print("buttonsWidget: Lend mode - Selected friend: $result");
              // Don't send amount yet, just pop out and wait for parent "Continue"
              // Navigator.pop(context); // Close the modal to return to Manualtransaction
            }
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
                'Lend money',
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
        // Button to trigger celebration
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: () {
                if (isSplit.value && addedMembers.isNotEmpty) {
                  splitBill(selectedCategory2.toString(), amount.toString(),
                      selectedSubCategory2.toString(), true);
                } else if (isLend.value && addedMembers.isNotEmpty) {
                  if (addedMembers.length > 1) {
                    snackBarCalled(
                        context,
                        "Please select only one friend for lending",
                        Colors.red);
                    return;
                  }
                  //   print("continueButton: Lending ${amount.toString()} to ${addedMembers[0]['id']}");
                  addLendUserAmount(
                    context,
                    amount.toString(),
                    addedMembers,
                    selectedCategory2.toString(),
                    selectedSubCategory2.toString(),
                  );
                } else {
                  addTransaction(
                    amount.toString(),
                    selectedSubCategory2.toString(),
                    selectedCategory2.toString(),
                    context,
                    "cash",
                  );
                }
              },
              child: getButton(context, "Continue"),
            ),
          ),
        ),
      ],
    );
  }

  void splitBill(categories, amount, subCategories, bool isSplitAmount) {
    if (categories == "" || amount == "" || subCategories == "") {
      snackBarAllFeilds(context);
      return;
    }
    if (addedMembers.length <= 0) {
      snackBarCalled(context, "Please add members to proceed!", Colors.red);
      return;
    }

    if (acceptReset.value) return;
    acceptReset.value = true;
    isLend.value = false;
    isSplit.value = false;
    if (isSplitAmount)
      splitUserAmount(context, amount, addedMembers, categories, subCategories);
    else
      addLendUserAmount(
          context, amount, addedMembers, categories, subCategories);
  }

  void addSocketMessage(addedUser, String amount, String splitName,
      String splitID, double parsedTotalAmount) {
    if (addedUser.isEmpty) {
      return;
    }

    // int index=0;

    addedUser.forEach((rec) {
      String room1 = rec['name'] + userName.value;
      String room2 = userName.value + rec['name'];
      // index++;
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
          "Amount": parsedTotalAmount, // This is now the individual amount
          "Share": amount,
          "isPaid": false,
          "splitId": splitID,
        },
        "roomId": roomId,
      };

      socket.emit("joinRoom", roomId);
      socket.emit("message", jsonData);
      String userToSend = rec['name'] + "" + rec['name'];
      socket.emit("LoadCharts", {
        "roomId": userToSend,
      });
    });
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
        return NewFriendsUi(
          totalAmount: totalAmount,
          userId: currentId.value,
          userName: userName.value,
          userAvatar: avatar.value,
          isLendMode: isLendMode,
        );
      },
    );
  }

// void showCustomFriendsModal2(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(18),
//         ),
//       ),
//       builder: (BuildContext context) {
//         return FriendsUi(); // Use the modal widget here
//       },
//     );
//   }
  void splitUserAmount(
    BuildContext context,
    String totalAmount,
    List members,
    String name,
    String subCategories, {
    Map<String, double>? amounts, // Manual amounts including user's share
  }) async {
    double? parsedTotalAmount = double.tryParse(totalAmount);
    if (parsedTotalAmount == null || parsedTotalAmount <= 0) {
      // print("splitUserAmount: Invalid totalAmount: $totalAmount");
      snackBarCalled(context, "Invalid amount entered!", Colors.red);
      return;
    }
    // print("splitUserAmount: Parsed totalAmount: $parsedTotalAmount");

    if (members.isEmpty) {
      // print("splitUserAmount: No members selected");
      snackBarCalled(context, "No members selected!", Colors.red);
      return;
    }
    // print("splitUserAmount: Members count: ${members.length}, Members: $members");

    // Prepare paymentStatus list with individual amounts
    List<Map<String, dynamic>> nameList = [];
    if (amounts != null) {
      // print("splitUserAmount: Using manual amounts: $amounts");
      members.forEach((element) {
        double memberAmount = amounts[element['id']] ?? 0.0;
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': memberAmount,
        });
        // print("splitUserAmount: Added member ${element['id']} with amount: $memberAmount");
      });
      // Include the user's amount if present in amounts (commented out in your version)
      // if (amounts.containsKey(currentId.value)) {
      //   nameList.add({
      //     'member': currentId.value,
      //     'markAsComplete': false,
      //     'amount': amounts[currentId.value]!,
      //   });
      //   print("splitUserAmount: Added user ${currentId.value} with amount: ${amounts[currentId.value]}");
      // }
    } else {
      // print("splitUserAmount: Falling back to equal split");
      double amountPerPerson = parsedTotalAmount / (members.length + 1);
      members.forEach((element) {
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': amountPerPerson,
        });
        // print("splitUserAmount: Added member ${element['id']} with equal amount: $amountPerPerson");
      });
      nameList.add({
        'member': currentId.value,
        'markAsComplete': false,
        'amount': amountPerPerson,
      });
      // print("splitUserAmount: Added user ${currentId.value} with equal amount: $amountPerPerson");
    }

    // Verify total matches (optional, for debugging)
    double calculatedTotal =
        nameList.fold(0.0, (sum, item) => sum + item['amount']);
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    // print("splitUserAmount: Access token retrieved: ${accessToken != null ? 'Yes' : 'No'}");

    final response = await http.post(
      Uri.parse('$url/split'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        "subcategory": subCategories,
        "category": name,
        "amount": calculatedTotal,
        "paymentStatus": nameList,
        "image": '',
      }),
    );
    // print("splitUserAmount: API request sent with paymentStatus: $nameList");
    // print("splitUserAmount: API response status: ${response.statusCode}, body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      splitID.value = body['id']['_id'];
      // print("splitUserAmount: Split ID set: ${splitID.value}");

      // Send notifications with individual amounts
      for (var member in members) {
        double memberAmount = amounts?[member['id']] ??
            (parsedTotalAmount / (members.length + 1));
        String formattedAmount = memberAmount.toStringAsFixed(2);
        // print("splitUserAmount: Sending notification to ${member['id']} with amount: $formattedAmount");
        sendNotificationsToDevice(
          member['id'],
          context,
          "${userName.value} has sent you a Split Bill of $name for ₹$formattedAmount",
        );
      }

      // Send socket messages with individual amounts
      if (amounts != null) {
        members.forEach((member) {
          double memberAmount = amounts[member['id']] ?? 0.0;
          // print("splitUserAmount: Sending socket message to ${member['id']} with amount: $memberAmount");
          addSocketMessage([member], memberAmount.toString(), name,
              splitID.value, parsedTotalAmount);
        });
      } else {
        double amountPerPerson = parsedTotalAmount / (members.length + 1);
        // print("splitUserAmount: Sending socket message (equal split) with amount: $amountPerPerson");
        addSocketMessage(members, amountPerPerson.toString(), name,
            splitID.value, parsedTotalAmount);
      }

      // print("splitUserAmount: Split successful, showing celebration");
      snackBarCalled(
          context,
          "The split amount has been successfully sent to users!",
          Colors.black);
      Navigator.pop(context);
      _showCelebration();
    } else {
      // print("splitUserAmount: API error - Status: ${response.statusCode}, Body: ${response.body}");
      snackBarCalled(context,
          "An error occurred while trying to split the bill!", Colors.red);
    }

    acceptReset.value = false;
    // print("splitUserAmount: Finished execution");
  }

  void addLendUserAmount(context, String amount, List members, String name,
      String subCategories) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    //  print('nameList');
    //  print(nameList);

    final response = await http.post(
      Uri.parse('${url}/bill'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        "userName": members[0]['name'],
        "avatarType": members[0]['avatar'],
        "billReceiverId": members[0]['id'],
        "category": name,
        "subcategory": subCategories,
        "type": "Lend Money",
        "amount": amount,
        // 'dueDate': getCurrentFormattedDate(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      members.forEach((e) {
        sendNotificationsToDevice(e['id'], context,
            "${userName.value} has sent u a lend bill..Of ${name} Of ${amount}");
      });
      snackBarCalled(context,
          "Lend amount has been successfully sent to users!", Colors.black);
      addTransaction(
          amount, "Lend Bill (${subCategories})", name, context, 'cash', true);
      getUserLend(context);
    } else {
      snackBarCalled(
          context, "An error occurred while trying to lend money!", Colors.red);
    }
    acceptReset.value = false;
  }
}
