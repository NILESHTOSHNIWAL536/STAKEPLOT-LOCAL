import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/bill.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
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
      frdsList.map((e) => e as Map<dynamic, dynamic>).toList();

  List<String> options = ['Veg', 'Non veg', 'Alcohol'];
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
    String currentUserId = currentId.value;
    String currentUserName = userName.value;
    String? currentUserAvatar = avatar.value;

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
    double h = MediaQuery.sizeOf(context).height;
    double w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Veg and Non veg Calculator',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w700,
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
                  _buildInputColumn('Veg', vegController),
                  _buildInputColumn('Non-veg', nonVegController),
                  _buildInputColumn('Alcohol', alcoholController),
                ],
              ),
            ),
            // Fixed search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: InputDat('Search', TextInputType.name, Textcontroller),
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
                  onTap: () {
                    splitUserAmountFood(context, "3000", addedMembers,
                        "foodie split", "Veg & Non Veg", friendShares);
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
                        'Bill split',
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
                    friendShares.forEach((key, value) {
                      if (key != currentId.value) {
                        // added this line for excluding current user in notify
                        sendNotificationsToDevice(
                            key,
                            context,
                            "${userName.value} has shared the foodie expense of ${value!['Total'] ?? "0000"}",
                            "/remainder");
                      }
                    });
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
                        'Notify',
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
          GestureDetector(
            onTap: () {
              _calculateShares();
            },
            child: getButton(context, "Calculate"),
          ),
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
        bool isCurrentUser = friendId == currentId.value;

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
                      AvatarProfileImage(
                        url: friend['avatar'] ?? userAvatar,
                        width: 8,
                        height: 18,
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: Text(
                    option,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.button,
                  onSelected: (selected) {
                    setState(() {
                      if (friendId != null) {
                        if (selected) {
                          selectedOptions
                              .putIfAbsent(friendId, () => [])
                              .add(option);
                        } else {
                          selectedOptions[friendId]?.remove(option);
                          if (selectedOptions[friendId]?.isEmpty ?? false) {
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
    List limitedFriends = frdsList.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          limitedFriends.isEmpty
              ? Center(
                  child: Text(
                    'No friends available',
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
                              "balance": 200,
                            });
                            selectedOptions[id] = [];
                          }
                        });
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: isSelected ? Colors.green[50] : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 6),
                          child: Row(
                            children: [
                              AvatarProfileImage(
                                url: limitedFriends[index]['avatar'] ??
                                    userAvatar,
                                width: 24,
                                height: 24,
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
                filtered = frdsListOrigin;
              } else {
                filtered = frdsListOrigin.where((element) {
                  String name = element['name'].toString().toLowerCase();
                  return name.contains(v.toLowerCase());
                }).toList();
              }

              List limited = filtered.take(4).toList();

              setState(() {
                frdsList.clear();
                frdsList.addAll(limited);
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
        'priorities': data
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
      'ismanual':true,
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

      nameList.forEach((e) {
        for (var e in nameList) {
          if (e['id'] != currentId.value) {
            // Log notification details
           
            sendNotificationsToDevice(
                e['id'],
                context,
                "${userName.value} has sent you a ${name} Of ${e['amount']}",
                "/chat");
          }
        }
      });

      addSocketMessage(nameList, amount.toString(), "Calculation".toString(),
          splitID.value, totalAmount);

      snackBarCalled(context, "Split amount sent to users!", Colors.black);
      Navigator.pop(context);
    } else {
      snackBarCalled(context, "can't split error!", Colors.red);
    }
    acceptReset.value = false;
  }
}

String doubleToFixed(String number) {
  double value = double.parse(number);
  return value.toStringAsFixed(2);
}
