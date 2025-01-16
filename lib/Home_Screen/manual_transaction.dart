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
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              HomePageIcons.manualTransaction,
              height: 30,
              width: 30,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Manual Transaction',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.normal,
                      fontSize: 18,
                      color: AppColors.accentColor)),
              const SizedBox(height: 8),
              DecoratedContainer(
                  borderRadius: 24,
                  height: 50,
                  child: TextButton(
                      onPressed: () {
                        showCustomModal(context);
                      },
                      child: Text('Start now',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal,
                              fontSize: 14,
                              color: AppColors.primaryColor)))),
            ],
          ),
          const Spacer(),
          // Placeholder for an manual transaction image

          Expanded(
            child: SvgPicture.asset(
              Pictures.manualTransactionImage,
              height: MediaQuery.of(context).size.height *
                  0.25, // Make the SVG fit the height of the container
              //fit: BoxFit.contain, // Scale the image to fit within its bounds
            ),
          ),
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
    'Food': [
      'Groceries',
      'Dining Out',
      'Snacks',
      'Beverages',
      'Bakery',
      'Takeaway'
    ],
    'Transport': [
      'Taxi',
      'Bus',
      'Fuel',
      'Car Rental',
      'Train Tickets',
      'Flight'
    ],
    'Shopping': [
      'Clothing',
      'Electronics',
      'Accessories',
      'Books',
      'Gifts',
      'Groceries',
      'Jewelry',
      'Watches',
      'Handbags',
      'Belts'
    ],
    'Entertainment': [
      'Movies',
      'Concerts',
      'Games',
      'Streaming',
      'Events',
      'Theatre Tickets',
      'Concessions'
    ],
    'Health': [
      'Pharmacy',
      'Doctor Visits',
      'Gym',
      'Supplements',
      'Therapy',
      'Medication',
      'Surgery',
      'Diagnostics'
    ],
    'Education': [
      'Books',
      'Online Courses',
      'School Fees',
      'Workshops',
      'Tutoring',
      'Tuition'
    ],
    'Travel': [
      'Flights',
      'Hotels',
      'Tours',
      'Travel Insurance',
      'Cruises',
      'Tickets',
      'Accommodation',
      'Activities'
    ],
    'Utilities': [
      'Electricity',
      'Water',
      'Internet',
      'Gas',
      'Mobile Recharge',
      'Prepaid Recharge'
    ],
    'Home': ['Rent', 'Furniture', 'Repairs', 'Cleaning Services', 'Gardening'],
    'Personal Care': [
      'Salon',
      'Spa',
      'Skincare',
      'Makeup',
      'Haircare',
      'Lotions',
      'Face Masks',
      'Treatments'
    ],
    'Technology': [
      'Software Subscriptions',
      'Hardware',
      'Cloud Storage',
      'Apps',
      'Web Hosting',
      'Gadgets',
      'Home Appliances'
    ],
    'Kids': ['Toys', 'Clothing', 'Education', 'Games', 'Daycare'],
    'Pets': ['Food', 'Veterinarian', 'Toys', 'Grooming', 'Training'],
    'Gifts & Charity': [
      'Birthdays',
      'Weddings',
      'Donations',
      'Festivals',
      'Fundraisers'
    ],
    'Drinks': ['Alcohol', 'Soft Drinks', 'Juices', 'Cocktails'],
    'Bills': [
      'Electricity',
      'Water',
      'Gas',
      'Phone',
      'Monthly Bill',
      'Cable TV',
      'Streaming Subscription'
    ],
    'Snacks': ['Chips', 'Cookies', 'Sweets', 'Popcorn'],
    'Others': [
      'Miscellaneous Expenses',
      'Uncategorized',
      'One-off Purchases',
      'Random Expenses'
    ],
    'Rent': ['House Rent', 'Office Rent', 'Garage Rent'],
    'Clothing-Shoes': ['Casual Wear', 'Formal Wear', 'Footwear', 'Sportswear'],
    'EMIs': ['Car Loan', 'Home Loan', 'Personal Loan'],
    'Credit Bills': [
      'Credit Card Payments',
      'Late Fees',
      'Outstanding Amount',
      'Minimum Payment Due'
    ],
    'Sports': ['Equipment', 'Gym Membership', 'Outdoor Activities'],
    'Theatre': ['Play Tickets', 'Drama Shows', 'Opera'],
    'Repairs': ['Home Repairs', 'Car Repairs', 'Electronics'],
    'Beauty': ['Salon', 'Spa', 'Cosmetics'],
    'Subscriptions': ['Magazines', 'Apps', 'Streaming Services'],
    'Restaurants': [
      'Casual Dining',
      'Buffet',
      'Fine Dining',
      'Fast Food',
      'Family Restaurants'
    ],
    'Investments': ['Mutual Funds', 'Stocks', 'Real Estate', 'Bonds'],
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
  RxBool isSplit=false.obs;
  RxBool isLend=false.obs;
   late IO.Socket socket;
   

  void initState() {
    super.initState();
    filteredCategories = categories.keys.toList();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Animation controller for the tick mark
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    socket=IO.io(urlWithLocallHost,IO.OptionBuilder().setTransports(['websocket']).build());
    setUpSocketListener();
    // Initialize with all categories
  }

   setUpSocketListener()
   {
     socket.on("disconnect", (data) => {
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
              ? Stack(alignment: Alignment.center, children: [
                  // Confetti blast effect
                  ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality
                        .explosive, // Blast in all directions
                    numberOfParticles: 50, // Number of confetti pieces
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.orange,
                      Colors.pink
                    ],
                    gravity: 0.3, // Confetti falls slowly
                  ),
                  // Animated tick mark
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _iconAnimationController,
                      curve: Curves.elasticOut,
                    ),
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
                ])
              : Column(
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
                      TextField(
                        controller: _amountController,
                        // Link TextField to the controller

                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.attach_money),
                          hintText: 'Enter the amount',
                          hintStyle: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal,
                              fontSize: 16,
                              color: AppColors.accentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onChanged: (value) {
                          // Update the amount variable whenever the input changes
                          setState(() {
                            amount = double.tryParse(
                                value); // Convert string to double
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (amount != null) ...[
                      GestureDetector(
                        onTap: toggleCategoryField,
                        child: TextField(
                          controller: categoryFieldController,
                          readOnly: false,
                          decoration: InputDecoration(
                            hintText: 'Categories',
                            hintStyle: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: 16,
                                color: AppColors.accentColor),
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onTap: () {
                            if (!isCategoryFieldExpanded) {
                              toggleCategoryField();
                            }
                          },
                          onChanged: (value) {
                            filterCategories(
                                value); // Filter categories as the user types
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (isCategoryFieldExpanded) ...[
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredCategories.length,
                          itemBuilder: (BuildContext context, int index) {
                            String category = filteredCategories[index];
                            return ListTile(
                              leading: const Icon(Icons.category),
                              title: Text(category,
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: AppColors.accentColor)),
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                  categoryFieldController.text =
                                      category; // Update text field
                                  isCategoryFieldExpanded =
                                      false; // Collapse the list
                                });
                              },
                            );
                          },
                        ),
                      ),
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
                      Wrap(
                        spacing: 8.0, // Horizontal spacing between chips
                        runSpacing: 8.0, // Vertical spacing between rows
                        children:
                            categories[selectedCategory]!.map((subCategory) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSubCategory = subCategory;
                                 selectedSubCategory2 = subCategory;
                                categoryFieldController.text =
                                    '$selectedCategory ($selectedSubCategory)';
                                //isSplitbill = true;
                                fin =
                                    '$selectedCategory ($selectedSubCategory)';
                                selectedCategory2=selectedCategory;
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
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    if (fin != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Action for Split Bill button
                              //isSplit = true;
                              // splitBill();
                              isSplit.value=true;
                              isLend.value=false;

                              showCustomFriendsModal(context);

                               

                            },
                            child: Text('Bill Split',
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: AppColors.primaryColor)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Action for Continue button
                              isSplit.value=false;
                              isLend.value=true;
                              showCustomFriendsModal(context);

                            },
                            child: Text('Lend money',
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: AppColors.primaryColor)),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Button to trigger celebration
                          Center(
                            child: ElevatedButton(
                              onPressed:(){

                                 if(isSplit.value){
                                       splitBill(selectedCategory2.toString(), amount.toString(), selectedSubCategory2.toString(),true);
                                      
                                 }else if(isLend.value){
                                       splitBill(selectedCategory2.toString(), amount.toString(), selectedSubCategory2.toString(),false);
                                     
                                 }else{
                                    addTransaction(amount.toString(),selectedSubCategory2.toString(),selectedCategory2.toString(),context,"cash");
                                 }
                                 _showCelebration();
                                },
                              child: Text('Continue',
                                  style: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: AppColors.accentColor)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
        ));
  }
  
             
             void splitBill(categories,amount,subCategories,bool isSplit) 
             {
                               
                                  if(categories=="" || amount=="" || subCategories=="")
                                  {
                                        snackBarAllFeilds(context);
                                        return;
                                  }
                                  if(addedMembers.length<=0)
                                  {
                                    snackBarCalled(context, "Pls Add Members....!",Colors.red);
                                    return;
                                  }

                                  if(acceptReset.value)return;
                                  acceptReset.value=true;
                              
                               if(isSplit) splitUserAmount(context,amount,addedMembers,categories,subCategories);
                               else  addLendUserAmount(context,amount,addedMembers,categories,subCategories);
              }



  
void addSocketMessage(addedUser,String amount,String splitName,String splitID) {

                                  //  home
                              //     //  Navigator.pushNamed(context, '/home'); 
                              //  if(frdsList.isEmpty){
                              //       //   Navigator.pop(context);
                              //       // Navigator.pushNamed(context, '/TribeSearch'); 
                              //       return;
                              //  }
                                // {
                                //                   "name": frdsList[index]['name'],
                                //                   "id": values,
                                //                   'avatar':frdsList[index]['avatar'],
                                //                   "balance": 200
                                // },
                                  // print('splitID');
                                  // print(splitID);
                                  // print(addedUser);
                                 if(addedUser.isEmpty){
                  
                                  // snackBarCalled(context, "No Friend Added");
                                  return;
                                 }
     

                                  // int index=0;
                               
                                  addedUser.forEach((rec) { 
                                                            
  
                                                String room1 =rec['name']+userName.value;
                                                String room2 =userName.value+rec['name'];
                                                // index++;
                                                 String  roomId =  (room1.compareTo(room2) <= 0) ? room1 : room2;

                                            var jsonData={
                                                  "messageType": "split",
                                                  "receiver": rec['id'],
                                                  "sender":currentId.value,
                                                  "message": null,
                                                  "image": null,
                                                  "poll": null,
                                                  "post":null,
                                              "split": {
                                                    "BillName" : splitName,
                                                    "Amount" :   amount,
                                                    "Share" : ((double.parse(amount) / (addedUser.length+1)).toString()),
                                                    "isPaid" : false,
                                                    "splitId" :  splitID,
                                                },
                                                  "roomId":roomId,
                                          };

              
                                          socket.emit("joinRoom",roomId);
                                          socket.emit("message",jsonData);
                                          String userToSend=rec['name']+""+rec['name'];
                                          socket.emit("LoadCharts",{"roomId":userToSend,});
                                  });
}

  
  void showCustomFriendsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (BuildContext context) {
      return FriendsUi(); // Use the modal widget here
    },
  );
}





void splitUserAmount(context,String amount,List members,String name,String subCategories)async{
    List nameList=[];
    members.forEach((element) {
         nameList.add(
           {
              'member':(element['id']),
              'markAsComplete':false
           }
         );
    }); 

    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");

    final response = await http.post(
    Uri.parse('${url}/split'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
        "name": name,
        "amount": amount,
        "paymentStatus": nameList,
        "image":''
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            print("Lend Bill ----------------------- ");
            print(body);
           
            splitID.value=body['id']['_id'];
            print("splitID.value");
            print(splitID.value);

             members.forEach((e)
           {
            sendNotificationsToDevice(e['id'],context,"${userName.value} Has Send U a Split Bill..Of ${name} Of ${amount}");
           });
            addSocketMessage(addedMembers,amount.toString(),selectedCategory2.toString(), splitID.value);

            snackBarCalled(context,"Slit Amount send to users!",Colors.black);
            addTransaction(amount, "Split Bill (${subCategories})", name, context, 'cash',true);

      
      }else{
           snackBarCalled(context,"can't split error!",Colors.red);
      }
        acceptReset.value=false;

}




void addLendUserAmount(context,String amount,List members,String name,String subCategories)async{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
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
            "subcategory":'Lend Money',
            "Avatar":members[0]['avatar'],
            "userName":members[0]['name'],
            'dueDate': getCurrentFormattedDate(),
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
           members.forEach((e)
           {
            sendNotificationsToDevice(e['id'],context,"${userName.value} Has Send U a Lend Bill..Of ${name} Of ${amount}");
           }
          );

            snackBarCalled(context,"Lend Amount send to users!",Colors.black);
            addTransaction(amount, "Lend Bill (${subCategories})", name, context, 'cash',true);
            // addSocketMessage(addedMembers,amount.toString(),selectedCategory2.toString()+"Lend Bill (${subCategories})", splitID.value);
            getUserLend(context);
            Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
               duration: Durations.long1,
              child: HomePage(),
              isIos: true,
            ),
          ); 
    // }
      }else{
           snackBarCalled(context,"can't split error!",Colors.red);
      }
        acceptReset.value=false;
}
              
}
