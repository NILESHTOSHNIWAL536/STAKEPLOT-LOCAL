import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/lendMessage.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

bool isDebit = true;

class Manualtransaction extends StatefulWidget {
  const Manualtransaction({super.key});

  @override
  State<Manualtransaction> createState() => _ManualtransactionState();
}

class _ManualtransactionState extends State<Manualtransaction> {
  @override
  void initState() {
    super.initState();
    getCustomCategory(context);
  }

  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width / 0.8,
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
              AvatarProfileImage(
                url: HomePageIcons.manualTransaction,
                height: 24,
                width: 24,
              ),
              SizedBox(width: MediaQuery.of(context).size.width / 52),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(HomepageStringsDart().manualTransaction,
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w600,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: AppColors.accentColor)),
                    const SizedBox(height: 8),
                    Container(
                        decoration: BoxDecoration(
                                  color: AppColors.button,
                                 // borderRadius: BorderRadius.circular(16)
                                  ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              isDebit = false;
                              showCustomModal(context,isDebit);
                          
                              // player.play(UrlSource('https://www.soundjay.com/button/beep-07.wav'));
                            },
                            child: Container(
                              height: Colorcodes.paddingSize * 1.5,
                              width: Colorcodes.paddingSize * 3,
                              // decoration: BoxDecoration(
                              //     color: AppColors.button,
                              //     borderRadius: BorderRadius.circular(16)),
                              child: Center(
                                child: Text(HomepageStringsDart().cashIn,
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: AppColors.primaryColor)),
                              ),
                            ),
                          ),
                         Container(
                            width: 0.5, // Width of the divider
                            height: Colorcodes.paddingSize * 1.2, // Match the height of the buttons
                            color: AppColors.accentColor, // Color of the divider
                          ),
                          InkWell(
                            onTap: () {
                              isDebit = true;
                              showCustomModal(context,isDebit);
                            },
                            child: Container(
                              height: Colorcodes.paddingSize * 1.5,
                              width: Colorcodes.paddingSize * 3,
                              // decoration: BoxDecoration(
                              //     color: AppColors.button,
                              //     borderRadius: BorderRadius.circular(16)),
                              child: Center(
                                child: Text(HomepageStringsDart().cashOut,
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: AppColors.primaryColor)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          AvatarProfileImage(
            url: LikeComment.manualTransaction,
            height: 10,
            width: 14,
          )
        ],
      ),
    );
  }
}

void showCustomModal(BuildContext context, bool isDebit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.mt,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (BuildContext context) {
      return SafeArea(
          child: ModalContent(isDebit)); // Use the modal widget here
    },
  );
}

class ModalContent extends StatefulWidget {
  final bool isDebit;
  const ModalContent(this.isDebit,{Key? key}) : super(key: key);

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
  bool _isAmountFieldFocused = true;
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
      _isAmountFieldFocused = false;
      // isSplitbill = (selectedCategory != null &&
      //     selectedSubCategory != null &&
      //     amount != null);
    });
  }

  void toggleCategoryField() {
    setState(() {
      isCategoryFieldExpanded = !isCategoryFieldExpanded;
      _isAmountFieldFocused = false;
      _isAmountFieldFocused = false;
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
                  duration: const Duration(milliseconds: 200),

                  curve: Curves.easeOut,
                  child: Container(
                    color: AppColors.mt,
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
                                    ? HomepageStringsDart().manualTransaction
                                    : ''
                                : HomepageStringsDart().manualTransactions,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.accentColor),
                          ),
                          const SizedBox(height: 16),

                          // Enter Amount Field (Only shown if no category is selected)

                          if ((selectedCategory == null &&
                              selectedSubCategory == null) || !isDebit) ...[
                            AmountWidget(),
                            const SizedBox(height: 16),
                          ],

                          if (amount != null) ...[
                              categoryWidget(),
                          ],
                          const SizedBox(height: 8),
                          if (isCategoryFieldExpanded) ...[
                            categoryExpandedWidget(),
                            // getListOfCustomCategory(),
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
                            isDebit?  SplitLendButton():SizedBox.shrink(),
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
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      autofocus: _isAmountFieldFocused,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.currency_rupee),
        hintText: HomepageStringsDart().enterAmount,
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
          amount = double.tryParse(value);
          if(!isDebit){
            selectedCategory="Income";
            categoryFieldController.text="Income";
          }
          fin=null;
          _isAmountFieldFocused = false; // Convert string to double
        });
      },
      onEditingComplete: () {
         fin = '$selectedCategory ($selectedSubCategory)';
        FocusScope.of(context).unfocus(); // Dismiss keyboard when done
      },
    );
  }

  Widget categoryWidget() {
    return GestureDetector(
      onTap: toggleCategoryField,
      child: TextField(
        controller: categoryFieldController,
        readOnly: !isDebit,
        decoration: InputDecoration(
          hintText: HomepageStringsDart().selectCategory,
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
            if(isDebit)  toggleCategoryField();
            else{
              setState(() {
                selectedCategory="Income";
                selectedSubCategory=null;
                categoryFieldController.text="Income";
              });

            }
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
        itemCount: filteredCategories.length + customCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          bool f = (index >= filteredCategories.length);
          String category = f
              ? customCategoryList[index - filteredCategories.length]['name']
              : filteredCategories[index];
          String urlPath = "";

          if (!f) {
            try {
              urlPath = Categories.link +
                  BudgetCategories.listofCategories[
                      BudgetCategories.listofCategories.keys.elementAt(index)];
            } catch (e) {}
          } else {
            urlPath = customCategoryList[index - filteredCategories.length]
                ['imageUrl'];
          }

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
                if (f) {
                  selectedCategory = category;
                  selectedSubCategory = "";
                  isCategoryFieldExpanded = false;
                  _isAmountFieldFocused = false;
                  categoryFieldController.text = '$selectedCategory';
                  // isSplitbill = true; // Uncomment if needed
                  fin = '$selectedCategory ($selectedSubCategory)';
                  selectedCategory2 = selectedCategory;
                  _isAmountFieldFocused = false; // Prevent amount field refocus
                  FocusScope.of(context).unfocus();
                  resetToInitialScreen();
                } else {
                  selectedCategory = category;
                  categoryFieldController.text = category; // Update text field
                  isCategoryFieldExpanded = false;
                  _isAmountFieldFocused = false; // Prevent amount field refocus
                  FocusScope.of(context).unfocus(); // Collapse the list
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget getListOfCustomCategory() {
    return Expanded(
      child: ListView.builder(
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
              _isAmountFieldFocused = false; // Prevent amount field refocus
              FocusScope.of(context).unfocus();
              resetToInitialScreen();
            });
          },
          child: Chip(
            avatar: ProfileImage(
              url: urlPath,
            ),
            label: Text(
              toUpperCase(subCategory),
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

  Widget SplitLendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
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
              splitUserAmountManualTransaction(
                context,
                amount.toString(),
                addedMembers,
                selectedCategory2.toString(),
                selectedSubCategory2.toString(),
                amounts: result as Map<String, double>,
              );
            }
            setState(() {
              _isAmountFieldFocused = false; // Prevent amount field refocus
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

            final result =
                await showCustomFriendsModal(context, amount ?? 0.0, true);
            setState(() {
              _isAmountFieldFocused = false; // Prevent amount field refocus
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
        // Button to trigger celebration
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                if(cashInAndOut.value)return;
                cashInAndOut.value = true;
                if (isSplit.value && addedMembers.isNotEmpty) {
                  splitBill(selectedCategory2.toString(), amount.toString(),selectedSubCategory2.toString(), true);
                } else if (isLend.value && addedMembers.isNotEmpty) {
                  if (addedMembers.length > 1)
                  {
                    snackBarCalled(context,SnackbarData().selectOnlyOneFriendLend,Colors.red);
                    return;
                  }
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
              child: Obx(()=>  cashInAndOut.value? getspinner(context) :getButton(context, HomepageStringsDart().addButton)),
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
      snackBarCalled(context,SnackbarData().addMembersToProceed, Colors.red);
      return;
    }

    if (acceptReset.value) return;
    acceptReset.value = true;
    isLend.value = false;
    isSplit.value = false;
    if (isSplitAmount)
      splitUserAmountManualTransaction(
          context, amount, addedMembers, categories, subCategories);
    else
      addLendUserAmount(context, amount, addedMembers, categories, subCategories);
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

  void splitUserAmountManualTransaction(
    BuildContext context,
    String totalAmount,
    List members,
    String name,
    String subCategories, {
    Map<String, double>? amounts, 
  }) async {
    double? parsedTotalAmount = double.tryParse(totalAmount);
    if (parsedTotalAmount == null || parsedTotalAmount <= 0) {
     
      snackBarCalled(context,SnackbarData().invalidAmountEntered, Colors.red);
      return;
    }

    if (members.isEmpty) {
      snackBarCalled(context,SnackbarData().noMembersSelected, Colors.red);
      return;
    }
   
    List<Map<String, dynamic>> nameList = [];
    if (amounts != null) {
      
      members.forEach((element) {
        double memberAmount = amounts[element['id']] ?? 0.0;
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': memberAmount,
        });
      });
      
    } else {
      double amountPerPerson = parsedTotalAmount / (members.length + 1);
      members.forEach((element) {
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': amountPerPerson,
        });
      });
      nameList.add({
        'member': currentId.value,
        'markAsComplete': false,
        'amount': amountPerPerson,
      });
    }

    double calculatedTotal = nameList.fold(0.0, (sum, item) => sum + item['amount']);

    var response= await postDataApiCall(
      '${url}/split',
      {
        "subcategory": subCategories,
        "category": name,
        "amount": calculatedTotal,
        "paymentStatus": nameList,
        "image": '',
        "ismanual": true,
      },
    );
   
    if (getFlagOfResponse(response)) {
      final body = json.decode(response.body);
      splitID.value = body['id']['_id'];
        for (var member in members) {
        double memberAmount = amounts?[member['id']] ??
            (parsedTotalAmount / (members.length + 1));
        String formattedAmount = memberAmount.toStringAsFixed(2);
        
        sendNotificationsToDevice(
            member['id'],
            context,
            "${userName.value} has sent you a Split Bill of $name for ₹$formattedAmount",
            "/chat");
      }

      if (amounts != null) {
        members.forEach((member) {
          double memberAmount = amounts[member['id']] ?? 0.0;
          addSocketMessage([member], memberAmount.toString(), name,
              splitID.value, parsedTotalAmount);
        });
      } else {
        double amountPerPerson = parsedTotalAmount / (members.length + 1);
        addSocketMessage(members, amountPerPerson.toString(), name,
            splitID.value, parsedTotalAmount);
      }
      currentPage = 1;
      isLoadingMore.value = false;
      searchController.clear();
      getAllTransaction(context);

      snackBarCalled(
          context,
         SnackbarData().splitAmountSuccess,
          Colors.black);
      Navigator.pop(context);
      addedMembers.clear();
      addedUser.clear();
      _showCelebration();

    } else {
      snackBarCalled(context,SnackbarData().splitAmountError, Colors.red);
    }

    acceptReset.value = false;
    cashInAndOut.value =false;
  }

  void addLendUserAmount(context, String amount, List members, String name,
      String subCategories) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
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
        "avatarBackGround": members[0]['avatarBackGround'] ?? "#68B2A0",
        "category": name,
        "subcategory": subCategories,
        "type": "Lend Money",
        "amount": amount,
        'message': messageController.text.toString(),
        'dueDate': selectedDueDate.toString().substring(0, 10)
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);

      members.forEach((e) {
        sendNotificationsToDevice(e['id'], context,"${userName.value} has sent u a lend bill..Of ${name} Of ${amount}");
      });

      snackBarCalled(context,SnackbarData().lendAmountSuccess, Colors.black);
      addTransaction(amount, "Lend Bill (${subCategories})", name, context, 'cash', false,false);
      getUserLend(context);
      messageController.clear();
      addedMembers.clear();
      addedUser.clear();
      selectedDueDate = null;
    } else {
      snackBarCalledfail(
          context,SnackbarData().lendAmountError, Colors.red);
    }

    acceptReset.value = false;
    cashInAndOut.value =false;
  }
}
