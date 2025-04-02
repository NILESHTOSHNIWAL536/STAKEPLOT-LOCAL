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
    // Assuming currentId, userName, and userAvatar are available globally from ApisConnect
    String currentUserId = currentId.value; // Current user's ID
    String currentUserName = userName.value; // Current user's name
    String? currentUserAvatar = avatar.value; // Current user's avatar

    // Check if the current user is already in addedMembers to avoid duplicates
    if (!addedMembers.any((member) => member['id'] == currentUserId)) {
      setState(() {
        addedMembers.add({
          "name": currentUserName,
          "id": currentUserId,
          "avatar": currentUserAvatar,
          "balance": 0 // Assuming balance starts at 0 for the current user
        });
        addedUser.add(currentUserId); // Add to addedUser for consistency
        selectedOptions[currentUserId] = []; // Initialize selection options
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

      // Initialize friendShares for each member (including current user)
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

      // Calculate shares for each friend based on their selections
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
        title: Text('Veg and Non veg Calculator',
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.w700, fontSize: 18, color: AppColors.bg1)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(height: h / 60),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text('My Friends',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.bg1)),
              ),
              SizedBox(height: h / 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: InputDat('Search', TextInputType.name, Textcontroller),
              ),
              commentedData(),
              vegNonvegdata(),
              calculation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget calculation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      splitUserAmount(context, "3000", addedMembers, "cater",
                          "sub cater", friendShares);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2.2,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(24)),
                      child: Center(
                        child: Text(
                          'Bill split',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.primaryColor),
                        ),
                      ),
                    )),
                GestureDetector(
                  onTap: () {
                    friendShares.forEach((key, value) {
                      sendNotificationsToDevice(key, context,
                          "You need to pay lend To ${userName.value} of ${value!['Total'] ?? "0000"}");
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    decoration: BoxDecoration(
                        color: AppColors.button,
                        borderRadius: BorderRadius.circular(24)),
                    child: Center(
                      child: Text(
                        'Notify',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primaryColor),
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
              print('Calculate button tapped...');
              _calculateShares();
            },
            child: getButton(context, "Calculate"),
          ),
        ],
      ),
    );
  }

  Widget vegNonvegdata() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.4,
      child: ListView.builder(
        itemCount: addedMembers.length,
        itemBuilder: (context, index) {
          var friend = addedMembers[index];
          String? friendId = friend['id'];

          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AvatarProfileImage(
                      url: friend['avatar'] ?? userAvatar,
                      width: 8,
                      height: 18,
                    ),
                    Text(friend['name'] ?? 'Unknown',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.bg1)),
                  ],
                ),
                Text(
                    'Total: ₹${friendShares[friendId]?['Total']?.toStringAsFixed(2) ?? "0.00"}',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.bg3))
              ],
            ),
            subtitle: Wrap(
                children: options.map((option) {
              bool isSelected =
                  selectedOptions[friendId]?.contains(option) == true;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: Text(option,
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primaryColor)),
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
            }).toList()),
          );
        },
      ),
    );
  }

  Widget commentedData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 1, 14, 1),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height / 12,
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
                                addedUser.contains(values)
                                    ? addedUser.remove(values)
                                    : addedUser.add(values);
                                if (addedUser.contains(values)) {
                                  addedMembers.add({
                                    "name": frdsList[index]['name'],
                                    "id": values,
                                    'avatar': frdsList[index]['avatar'],
                                    "balance": 200
                                  });
                                  selectedOptions[values] =
                                      []; // Initialize for friend
                                } else {
                                  List f = [];
                                  addedMembers.forEach((element) {
                                    if (element['id'] != values) {
                                      f.add(element);
                                    }
                                  });
                                  setState(() {
                                    addedMembers.clear();
                                    addedMembers.addAll(f);
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
                                              userAvatar,
                                          width: 8,
                                          height: 18)),
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
                          Text((frdsList[index]['name']),
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.black))
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

  Widget InputDat(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        color: Color.fromRGBO(246, 246, 246, 1),
        width: MediaQuery.of(context).size.width / 1.1,
        child: Center(
          child: TextFormField(
            keyboardType: keyBoard,
            controller: Textcontroller,
            onChanged: (v) {
              var frdsList2 = [];
              if (v == "") {
                frdsList.clear();
                frdsList.addAll(frdsListOrigin);
              }
              frdsListOrigin.forEach((element) {
                if (element['name'].toString().contains(v)) {
                  frdsList2.add(element);
                }
              });
              setState(() {
                frdsList.clear();
                frdsList.addAll(frdsList2);
              });
            },
            decoration: InputDecoration(
              filled: true,
              hintText: lableText,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(249, 246, 238, 1))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: Color.fromRGBO(246, 246, 246, 1))),
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(label,
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.primaryColor)),
          SizedBox(height: Colorcodes.paddingSize),
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

  void splitUserAmount(context, String amount, List members, String name,
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
        "amount": totalAmount,
        "paymentStatus": nameList,
        "image": '',
        'isVegNonVeg': true,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      splitID.value = body['id']['_id'];

      nameList.forEach((e) {
        sendNotificationsToDevice(e['id'], context,
            "${userName.value} has sent u a split bill for ${name} Of ${e['amount']}");
      });

      addSocketMessage(nameList, amount.toString(),
          "selectedCategory2".toString(), splitID.value, totalAmount);

      snackBarCalled(context, "Split amount sent to users!", Colors.black);
      Navigator.pop(context);
    } else {
      snackBarCalled(context, "can't split error!", Colors.red);
    }
    acceptReset.value = false;
  }
}

// Assuming this is defined elsewhere, but included here for completeness
String doubleToFixed(String number) {
  double value = double.parse(number);
  return value.toStringAsFixed(2);
}
