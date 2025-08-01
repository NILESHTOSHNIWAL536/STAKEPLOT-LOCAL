import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VegNonVegCalculator extends StatefulWidget {
  @override
  _VegNonVegCalculatorState createState() => _VegNonVegCalculatorState();
}

class _VegNonVegCalculatorState extends State<VegNonVegCalculator> {
  final TextEditingController vegController = TextEditingController();
  final TextEditingController nonVegController = TextEditingController();
  final TextEditingController alcoholController = TextEditingController();

  Map<String, List<String>> selectedOptions = {};
  TextEditingController Textcontroller = TextEditingController();
  List<Map<dynamic, dynamic>> get friends =>
      userController.friendsList.map((e) => e as Map<dynamic, dynamic>).toList();

  List<String> options = [
    PlotFinanceStaticData().vegLabel, // Updated
    PlotFinanceStaticData().nonVegLabel, // Updated
    PlotFinanceStaticData().alcoholLabel // Updated
  ];
  Map<String, Map<String, double>> friendShares = {};

  RxList addedUser = [].obs;
  RxList addedMembers = [].obs;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();

    // Add the current user to addedMembers
    _addCurrentUserToMembers();

    // Initialize selectedOptions for all friends
    for (var friend in friends) {
      String friendId = friend['_id'];
      if (!selectedOptions.containsKey(friendId)) {
        selectedOptions[friendId] = [];
      }
    }

    socket = IO.io(urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    setUpSocketListener();
  }

  void _addCurrentUserToMembers() {
    String currentUserId = userController.userId.value;
    String currentUserName = ControllerManagement.userController.userName.value;
    String? currentUserAvatar =ControllerManagement.userController. avatar.value;

    if (!addedMembers.any((member) => member['id'] == currentUserId)) {
      setState(() {
        addedMembers.add({
          "name": currentUserName,
          "id": currentUserId,
          "avatar": currentUserAvatar,
          "balance": 0
        });
        addedUser.add(currentUserId);
        selectedOptions[currentUserId] = [];
      });
    }
  }

  void setUpSocketListener() {
    socket.on("disconnect", (data) => {socket.close()});
  }

  void _calculateShares() {
    setState(() {
      double totalVeg = double.tryParse(vegController.text) ?? 0.0;
      double totalNonVeg = double.tryParse(nonVegController.text) ?? 0.0;
      double totalAlcohol = double.tryParse(alcoholController.text) ?? 0.0;

      friendShares = {};

      for (var friend in addedMembers) {
        String? friendId = friend['id'];
        if (friendId != null) {
          friendShares[friendId] = {
            'Veg': 0.0,
            'Non veg': 0.0,
            'Alcohol': 0.0,
            'Total': 0.0
          };
        }
      }

      for (var friend in addedMembers) {
        String? friendId = friend['id'];
        if (friendId != null) {
          List choices = selectedOptions[friendId] ?? [];

          if (choices.contains('Veg')) {
            int vegFriends = addedMembers
                .where(
                    (f) => selectedOptions[f['id']]?.contains('Veg') ?? false)
                .length;
            friendShares[friendId]!['Veg'] =
                vegFriends > 0 ? totalVeg / vegFriends : 0.0;
          }
          if (choices.contains('Non veg')) {
            int nonVegFriends = addedMembers
                .where((f) =>
                    selectedOptions[f['id']]?.contains('Non veg') ?? false)
                .length;
            friendShares[friendId]!['Non veg'] =
                nonVegFriends > 0 ? totalNonVeg / nonVegFriends : 0.0;
          }
          if (choices.contains('Alcohol')) {
            int alcoholFriends = addedMembers
                .where((f) =>
                    selectedOptions[f['id']]?.contains('Alcohol') ?? false)
                .length;
            friendShares[friendId]!['Alcohol'] =
                alcoholFriends > 0 ? totalAlcohol / alcoholFriends : 0.0;
          }

          friendShares[friendId]!['Total'] = friendShares[friendId]!['Veg']! +
              friendShares[friendId]!['Non veg']! +
              friendShares[friendId]!['Alcohol']!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          PlotFinanceStaticData().foodieFundsTitle,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.bg1,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed top section: Input fields
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInputColumn(PlotFinanceStaticData().vegLabel,
                      vegController), // Updated
                  _buildInputColumn(PlotFinanceStaticData().nonVegLabel,
                      nonVegController), // Updated
                  _buildInputColumn(PlotFinanceStaticData().alcoholLabel,
                      alcoholController), // Updated
                ],
              ),
            ),
            // Fixed search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: InputDat(PlotFinanceStaticData().searchHint,
                  TextInputType.name, Textcontroller),
            ),
            // Scrollable section: commentedData and vegNonvegdata
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    commentedData(),
                    vegNonvegdata(),
                  ],
                ),
              ),
            ),
            // Fixed bottom section: Calculation
            Container(
              color: AppColors.backgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: calculation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget calculation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  // onTap: () {
                  //   splitUserAmountFood(context, "3000", addedMembers,
                  //       "foodie split", "Veg & Non Veg", friendShares);
                  // },
                  onTap: () {
                    double totalVeg =
                        double.tryParse(vegController.text) ?? 0.0;
                    double totalNonVeg =
                        double.tryParse(nonVegController.text) ?? 0.0;
                    double totalAlcohol =
                        double.tryParse(alcoholController.text) ?? 0.0;

                    // Check if at least one category has a valid amount
                    bool hasValidAmount =
                        totalVeg > 0 || totalNonVeg > 0 || totalAlcohol > 0;

                    // Check if there are shares for the added members
                    bool hasShares = addedMembers.any((member) {
                      String? friendId = member['id'];
                      return friendShares[friendId]?['Total'] != null &&
                          (friendShares[friendId]!['Total'] ?? 0) > 0;
                    });

                    if (hasValidAmount && hasShares) {
                      // Proceed with the split if conditions are met
                      splitUserAmountFood(
                          context,
                          (totalVeg + totalNonVeg + totalAlcohol).toString(),
                          addedMembers,
                          "foodie split",
                          "Veg & Non Veg",
                          friendShares);
                    } else {
                      // Show a message to the user that they need to add money or select shares
                      snackBarCalledfail(
                          context, SnackbarData().validAmountAndShares);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        PlotFinanceStaticData().billSplitButton, // Updated
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
                  // onTap: () {
                  //   friendShares.forEach((key, value) {
                  //     if (key != userController.userId.value) {
                  //       // added this line for excluding current user in notify
                  //       sendNotificationsToDevice(
                  //           key,
                  //           context,
                  //           "${userName.value} has shared the foodie expense of ${value!['Total'] ?? "0000"}",
                  //           "/remainders", "",
                  //                       "",
                  //                       "Notified successfully");

                  //     }
                  //   });
                  // },
                  onTap: () {
                    // Check if friendShares is null or empty
                    if (friendShares == null || friendShares.isEmpty) {
                      snackBarCalledfail(
                          context, SnackbarData().noSharesCalculated);
                      return;
                    }

                    // Check if currentId is null
                    if (userController.userId.value == null) {
                      snackBarCalledfail(
                          context, SnackbarData().userIdNotAvailable);
                      return;
                    }

                    // Check if userName is null
                    String name=ControllerManagement.userController.userName.value;
                    if ( name.isEmpty) {
                      snackBarCalledfail(
                          context, SnackbarData().userNameNotAvailable);
                      return;
                    }

                    // Check if there are valid recipients other than the current user
                    bool hasValidRecipients =
                        friendShares.keys.any((key) => key != userController.userId.value);

                    if (!hasValidRecipients) {
                      snackBarCalledfail(
                          context, SnackbarData().noFriendsToNotify);
                      return;
                    }

                    // Check if shares have valid amounts
                    bool hasValidShares = friendShares.entries.any((entry) {
                      String? key = entry.key;
                      var value = entry.value;
                      return key != null &&
                          key != userController.userId.value &&
                          value != null &&
                          value['Total'] != null &&
                          (value['Total'] is double || value['Total'] is int) &&
                          (value['Total'] as num) > 0;
                    });

                    if (!hasValidShares) {
                      snackBarCalledfail(
                          context, SnackbarData().noValidSharesToNotify);
                      return;
                    }

                    // Proceed with sending notifications
                    bool atLeastOneNotificationSent = false;
                    friendShares.forEach((key, value) {
                      if (key != null && key != userController.userId.value) {
                        // Ensure value and total are valid
                        if (value != null &&
                            value['Total'] != null &&
                            (value['Total'] is num) &&
                            (value['Total'] as num) > 0) {
                          try {
                            sendNotificationsToDevice(
                              key,
                              context,
                              "${name} has shared the foodie expense of ₹${(value['Total'] as num).toStringAsFixed(2)}",
                              "/remainders",
                              "",
                              "",
                              "Notified successfully",
                            );
                            atLeastOneNotificationSent = true;
                            Navigator.pop(context);
                          } catch (e) {
                            // Handle notification sending failure
                            snackBarCalledfail(context,
                                SnackbarData().failedToSendNotification);
                          }
                        } else {
                          // Log or show warning for invalid share
                          snackBarCalledfail(
                              context, SnackbarData().invalidShareAmount);
                        }
                      }
                    });

                    // Show success message if at least one notification was sent
                    if (atLeastOneNotificationSent) {
                    } else {
                      snackBarCalledfail(
                          context, SnackbarData().noNotificationsSent);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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
          ),
          SizedBox(height: 10),
          // GestureDetector(
          //   onTap: () {
          //     _calculateShares();
          //   },
          //   child: getButton(context, PlotFinanceStaticData().calculateButton),
          // ),
        ],
      ),
    );
  }

  Widget vegNonvegdata() {
    return ListView.builder(
      shrinkWrap: true, // Takes only the space it needs
      physics:
          NeverScrollableScrollPhysics(), // Parent SingleChildScrollView handles scrolling
      itemCount: addedMembers.length,
      itemBuilder: (context, index) {
        var friend = addedMembers[index];
        String? friendId = friend['id'];
        bool isCurrentUser = friendId == userController.userId.value;

        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      AvatarProfile(
                        background: friend['avatarBackGround'] ??
                            defaultBackGround.value,
                        width: 8,
                        height: 18,
                        name: friend['name'],
                      ),
                      if (!isCurrentUser)
                        GestureDetector(
                          onTap: () {
                            addedMembers.removeWhere(
                                (member) => member['id'] == friendId);
                            addedUser.remove(friendId);
                            selectedOptions.remove(friendId);
                            _calculateShares();
                          },
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 8), // Space between avatar and name
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
              Row(
                children: [
                  Text(
                    '₹${friendShares[friendId]?['Total']?.toStringAsFixed(2) ?? "0.00"}',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.bg3,
                    ),
                  ),
                  SizedBox(width: 8), // Space before remove icon
                ],
              ),
            ],
          ),
          subtitle: Wrap(
            children: options.map((option) {
              bool isSelected =
                  selectedOptions[friendId]?.contains(option) == true;
              bool isDisabled =
                  (option == 'Veg' && vegController.text.isEmpty) ||
                      (option == 'Non veg' && nonVegController.text.isEmpty) ||
                      (option == 'Alcohol' && alcoholController.text.isEmpty);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: Text(
                    option,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isSelected
                            ? AppColors.backgroundColor
                            : AppColors.accentColor),
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
                              if (selected) {
                                selectedOptions
                                    .putIfAbsent(friendId, () => [])
                                    .add(option);
                              } else {
                                selectedOptions[friendId]?.remove(option);
                                if (selectedOptions[friendId]?.isEmpty ??
                                    false) {
                                  selectedOptions.remove(friendId);
                                }
                              }
                              _calculateShares();
                            }
                          });
                        },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget commentedData() {
    List limitedFriends = userController.friendsList.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          limitedFriends.isEmpty
              ? Center(
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
              : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: limitedFriends.length,
                  itemBuilder: (context, index) {
                    String id = limitedFriends[index]['_id'];
                    bool isSelected = addedUser.contains(id);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            addedUser.remove(id);
                            addedMembers
                                .removeWhere((member) => member['id'] == id);
                            selectedOptions.remove(id);
                          } else {
                            addedUser.add(id);
                            addedMembers.add({
                              "name": limitedFriends[index]['name'],
                              "id": id,
                              'avatar': limitedFriends[index]['avatar'],
                              'avatarBackGround': limitedFriends[index]
                                  ['avatarBackGround'],
                              "balance": 200,
                            });
                            selectedOptions[id] = [];
                          }
                        });
                      },
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: isSelected
                            ? Colors.green[50]
                            : AppColors.backgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 5),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: AvatarProfile(
                                  name: limitedFriends[index]['name'],
                                  width: 10,
                                  height: 10,
                                  background: limitedFriends[index]['avatarBackGround'] ?? "",
                                  flag: true,
                                  fontsize: 7,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  limitedFriends[index]['name'],
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
                                    if (value!) {
                                      addedUser.add(id);
                                      addedMembers.add({
                                        "name": limitedFriends[index]['name'],
                                        "id": id,
                                        'avatar': limitedFriends[index]
                                            ['avatar'],
                                        'avatarBackGround':
                                            limitedFriends[index]
                                                ['avatarBackGround'],
                                        "balance": 200,
                                      });
                                      selectedOptions[id] = [];
                                    } else {
                                      addedUser.remove(id);
                                      addedMembers.removeWhere(
                                          (member) => member['id'] == id);
                                      selectedOptions.remove(id);
                                    }
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

  Widget InputDat(String labelText, TextInputType keyboard,
      TextEditingController textController) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        height: MediaQuery.of(context).size.height / 20,
        child: Center(
          child: TextFormField(
            keyboardType: keyboard,
            controller: textController,
            
            onChanged: (v) {
              List filtered = [];

              if (v.trim().isEmpty) {
                filtered = userController.frdsListOrigin;
              } else {
                filtered =  userController.frdsListOrigin.where((element) {
                  String name = element['name'].toString().toLowerCase();
                  return name.contains(v.toLowerCase());
                }).toList();
              }

              List limited = filtered.take(4).toList();

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
      ),
    );
  }

  Widget _buildInputColumn(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Column(
        children: [
          Text(
            label,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: Colorcodes.paddingSize / 2),
          SizedBox(
            width: MediaQuery.of(context).size.width / 3 - 33,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              onTapOutside: (event) {
    FocusScope.of(context).unfocus(); // This will dismiss the keyboard
  },
              inputFormatters: allowDecimalInput(),
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              onChanged: (value) {
                _calculateShares();
              },
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addSocketMessage(addedUser, String amount, String splitName,
      String splitID, double totalAmount) {
    if (addedUser.isEmpty) return;

    addedUser.forEach((rec) {
      String room1 = rec['name'] +  userController.userName.value;
      String room2 = userController. userName.value + rec['name'];
      String roomId = (room1.compareTo(room2) <= 0) ? room1 : room2;

      var jsonData = {
        "messageType": "split",
        "receiver": rec['id'],
        "sender": userController.userId.value,
        "message": null,
        "image": null,
        "poll": null,
        "post": null,
        "split": {
          "BillName": splitName,
          "Amount": totalAmount.toString(),
          "Share": rec['amount'],
          "isPaid": false,
          "splitId": splitID,
        },
        "roomId": roomId,
      };

      socket.emit("joinRoom", roomId);
      socket.emit("message", jsonData);
      String userToSend = rec['name'] + "" + rec['name'];
      socket.emit("LoadCharts", {"roomId": userToSend});
    });
  }

  void splitUserAmountFood(context, String amount, List members, String name,
      String subCategories, dynamic shareFriends) async {
    List nameList = [];
    double totalAmount = 0.0;

    members.forEach((element) {
      String id = element['id'];
      var data = shareFriends[id];
      totalAmount += data['Total'];
      nameList.add({
        'id': id,
        'name': element['name'],
        'member': id,
        'markAsComplete': false,
        'amount': doubleToFixed(data['Total'].toString()),
        'isVegNonVeg': true,
        'priorities': data,
      });
    });
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");

    final requestBody = {
      "name": name,
      "subcategory": subCategories,
      "category:": name,
      "amount": totalAmount,
      "paymentStatus": nameList,
      "image": '',
      'isVegNonVeg': true,
      "ismanual": true,
      'isFoodie': true
    };

    final response = await http.post(
      Uri.parse('${url}/split'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      splitID.value = body['id']['_id'];

      List<dynamic> uniqueNameList =
          {for (var item in nameList) item['id']: item}.values.toList();

      uniqueNameList.forEach((e) {
        for (var e in nameList) {
          if (e['id'] != userController.userId.value) {
            // Log notification details

            sendNotificationsToDevice(
                e['id'],
                context,
                "${ userController.userName.value} has sent you a ${name} Of ${e['amount']}",
                "/chat");
          }
        }
      });

      addSocketMessage(nameList, amount.toString(), "Calculation".toString(),
          splitID.value, totalAmount);

      snackBarCalled(context, SnackbarData().splitAmountSent);
      Navigator.pop(context);
    } else {
      snackBarCalledfail(context, SnackbarData().authenticationError, Colors.red);
    }
    acceptReset.value = false;
  }
}

String doubleToFixed(String number) {
  double value = double.parse(number);
  return value.toStringAsFixed(2);
}
