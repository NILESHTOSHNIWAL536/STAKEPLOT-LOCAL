import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:confetti/confetti.dart';
//import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
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
import 'package:flutter_application_code_stakeplot/finance_screen/Budget.dart';
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
      //height: 300,
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
              SizedBox(width: MediaQuery.of(context).size.width / 28),
              Column(
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
              AvatarProfileImage(
                url: LikeComment.manualTransaction,
                height: 9.5,
                width: 10,
              ),
            ],
          )

          // Expanded(
          // child: SvgPicture.asset(
          //   Pictures.manualTransactionImage,
          //   height: MediaQuery.of(context).size.height *
          //       0.4, // Make the SVG fit the height of the container
          //   //fit: BoxFit.contain, // Scale the image to fit within its bounds
          // ),
          // ),
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
  final Map<String, List<String>> categories = {
    "Food": [
      "Swiggy",
      "Zomato",
      "Restaurant",
      "Cafe",
      "Pizza",
      "Dairy",
      "Tea",
      "Chai",
      "canteen",
      "Bistro",
      "Mcdonalds",
      "kfc",
      "subway",
      "dominos",
      "Dhaba",
      "Chicken",
      "Italia",
      "bawarchi",
      "cafe",
      "Tiffin",
      "mea",
      "Vegetables",
      "udupi",
      "coffee",
      "eats",
      "Frankie",
      "kirana",
      "Store",
      "General Store",
      "rasoi",
      "fish",
      "milk"
    ],
    "Shopping": [
      "Shoppers",
      "Mart",
      "WestSide",
      "Electronics",
      "Supermarket",
      "Amazon",
      "Flipkart",
      "Fashion",
      "Fabrics",
      "kart",
      "Electronics",
      "shopping",
      "ratnadeep",
      "Mobiles",
      "lifestyle",
      "market",
      "more",
      "supermarket",
      "shop",
      "max",
      "zudio",
      "centro"
    ],
    "Travel": [
      "Fuel",
      "Petrol",
      "Ola",
      "Uber",
      "Metro",
      "Traffic polic",
      "puncture",
      "Mobility",
      "Travels",
      "Transport",
      "Filling",
      "Rapido",
      "Tsrtc",
      "irctc"
    ],
    "Health": ["Medical", "Pharmacy", "Hospital", "Medplus"],
    "Bills": [
      "Electricity",
      "Water",
      "Gas",
      "Internet",
      "Mobile Recharge",
      "Rent",
      "DTH",
      "AIRTEL",
      "JIO",
      "ELECTRICITY",
      "Solutions",
      "godaddy",
      "hostinger",
      "bpcl"
    ],
    "Subscriptions": [
      "Netflix",
      "PrimeVideo",
      "Spotify",
      "Hotstar",
      "appleServices",
      "disney"
    ],
    "Events": [
      "Weddings",
      "Birthday",
      "Festival",
      "Anniversary",
      "Flowers",
      "pubs",
      "Gift"
    ],
    "Personal Care": ["Salon", "Spa", "Haircare", "Skincare"],
    "Services": [
      "Housemaid",
      "Carpenter",
      "Electrician",
      "Plumber",
      "Bike/Car Service",
      "Hardware/sanitary Workshop",
      "Events",
      "Service",
      "Bike",
      "Auto",
      "hardware",
      "sanitary",
      "communications",
      "traders",
      "Enterprises",
      "solutions"
    ],
    "Emi": ["Eazypay", "slice", "postpaid"],
    "Investments": ["MutualFund", "Stocks", "Gold"],
    "Insurance": ["Life Insurance", "Vehicle Insurance", "POLICYBAZAAR"],
    "Support": ["Charity"],
    "Current": ["TDS"],
    "Children": [
      "School Fees",
      "Tuitions",
      "Baby store",
      "miniklub",
      "uniforms",
      "baby care",
      "children"
    ],
    "Pet Care": ["Pet"],
    "Sports": [
      "Gym Membership",
      "Sports Equipment",
      "Snooker",
      "cricket",
      "box"
    ],
    "Alcohol": ["Liquor", "Wine", "Cigarettes"],
    "Hobbies": ["Photography", "Gardening"],
    "Education": ["Stationary", "Fees", "institute", "college"],
    "Commerce": [
      "Amazon",
      "Flipkart",
      "Myntra",
      "Nykaa",
      "Blinkit",
      "zepto",
      "Grofers",
      "Bluedart",
      "ekart"
    ],
    "snacks": [
      "juice",
      "Sweets",
      "Chai",
      "Biscuit",
      "Thickshake",
      "chocolate",
      "Ice cream",
      "chat",
      "mithai",
      "Bakes",
      "Bakery",
      "Cakes",
      "Tea",
      "chips",
      "confectioners",
      "cool drink"
    ],
    "Entertainment": [
      "Bookmyshow",
      "district",
      "gokarting",
      "gaming",
      "Entertainment",
      "pvr",
      "cinepolis",
      "imax",
      "Escape",
      "Adventures"
    ]
  };

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
  RxBool isSplit = false.obs;
  RxBool isLend = false.obs;
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          selectedSubCategory == null
                              ? selectedCategory == null
                                  ? 'Manual Transactions'
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
        hintText: 'Enter the amount',
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
          hintText: 'Categories',
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
                    BudgetCategories.listofCategories.keys
                        .elementAt(index)];
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
      spacing: 8.0, // Horizontal spacing between chips
      runSpacing: 8.0, // Vertical spacing between rows
      children: categories[selectedCategory]!.map((subCategory) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedSubCategory = subCategory;
              selectedSubCategory2 = subCategory;
              categoryFieldController.text =
                  '$selectedCategory ($selectedSubCategory)';
              //isSplitbill = true;
              fin = '$selectedCategory ($selectedSubCategory)';
              selectedCategory2 = selectedCategory;
              resetToInitialScreen();
            });
          },
          child: Chip(
            avatar: Icon(
              Icons.category, // Replace with a relevant icon
              color: Colors.blue, // Icon color
              size: 18, // Adjust size to fit within the chip
            ),
            label: Text(
              subCategory,
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal,
                  fontSize: 14,
                  color: AppColors.accentColor),
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
          onTap: () {
            // Action for Split Bill button
            //isSplit = true;
            // splitBill();
            isSplit.value = true;
            isLend.value = false;

            showCustomFriendsModal(context);
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2.4,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(24)),
            child: Center(
              child: Text(
                'Bill Split',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryColor),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Action for Continue button
            isSplit.value = false;
            isLend.value = true;
            showCustomFriendsModal(context);
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2.4,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(24)),
            child: Center(
              child: Text(
                'Lend money',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryColor),
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
                if (isSplit.value) {
                  splitBill(selectedCategory2.toString(), amount.toString(),
                      selectedSubCategory2.toString(), true);
                } else if (isLend.value) {
                  splitBill(selectedCategory2.toString(), amount.toString(),
                      selectedSubCategory2.toString(), false);
                } else {
                  addTransaction(
                      amount.toString(),
                      selectedSubCategory2.toString(),
                      selectedCategory2.toString(),
                      context,
                      "cash");
                }
                // _showCelebration();
              },
              child: getButton(context, "Continue"),
            ),
          ),
        ),
      ],
    );
  }

  void splitBill(categories, amount, subCategories, bool isSplit) {
    if (categories == "" || amount == "" || subCategories == "") {
      snackBarAllFeilds(context);
      return;
    }
    if (addedMembers.length <= 0) {
      snackBarCalled(context, "Please add members....!", Colors.red);
      return;
    }

    if (acceptReset.value) return;
    acceptReset.value = true;

    if (isSplit)
      splitUserAmount(context, amount, addedMembers, categories, subCategories);
    else
      addLendUserAmount(
          context, amount, addedMembers, categories, subCategories);
  }

  void addSocketMessage(
      addedUser, String amount, String splitName, String splitID) {
   
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
          "Amount": amount,
          "Share": ((double.parse(amount) / (addedUser.length + 1)).toString()),
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

  void showCustomFriendsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (BuildContext context) {
        return FriendsUi(); // Use the modal widget here
      },
    );
  }

  void splitUserAmount(context, String amount, List members, String name,
      String subCategories) async {
    List nameList = [];
    members.forEach((element) {
      nameList.add({'member': (element['id']), 'markAsComplete': false});
    });

    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");

    final response = await http.post(
      Uri.parse('${url}/split'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        "name": name,
        "subcategory": subCategories,
        "category:": name,
        "amount": amount,
        "paymentStatus": nameList,
        "image": ''
      }),
    );
    //printData(response,context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);

      splitID.value = body['id']['_id'];

      members.forEach((e) {
        sendNotificationsToDevice(e['id'], context,
            "${userName.value} has send u a Split Bill..Of ${name} Of ${doubleToFixed((getDouble(amount)/members.length+1).toString())}");
      });
      addSocketMessage(addedMembers, amount.toString(),
          selectedCategory2.toString(), splitID.value);

      snackBarCalled(context, "Split amount sent to users!", Colors.black);
      // addTransaction(amount, "Split Bill (${subCategories})", name, context, 'cash', true);
      Navigator.pop(context);
    } else {
      snackBarCalled(context, "can't split error!", Colors.red);
    }
    acceptReset.value = false;
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
        "name": name,
        "amount": amount,
        "billReceiverId": members[0]['id'],
        "subcategory": 'Lend Money',
        "Avatar": members[0]['avatar'],
        "userName": members[0]['name'],
        'dueDate': getCurrentFormattedDate(),
      }),
    );
    //printData(response,context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      members.forEach((e) {
        sendNotificationsToDevice(e['id'], context,
            "${userName.value} has sent u a lend bill..Of ${name} Of ${amount}");
      });

      snackBarCalled(context, "Lend amount sent to users!", Colors.black);
      addTransaction(
          amount, "Lend Bill (${subCategories})", name, context, 'cash', true);
      // addSocketMessage(addedMembers,amount.toString(),selectedCategory2.toString()+"Lend Bill (${subCategories})", splitID.value);
      getUserLend(context);
      Navigator.pop(context);
      // Navigator.push(
      //   context,
      //   PageTransition(
      //     type: PageTransitionType.fade,
      //     duration: Durations.long1,
      //     child: HomePage(),
      //     isIos: true,
      //   ),
      // );
      // }
    } else {
      snackBarCalled(context, "can't split ,error!", Colors.red);
    }
    acceptReset.value = false;
  }
}
