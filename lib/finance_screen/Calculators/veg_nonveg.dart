import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';

class VegNonVegCalculator extends StatefulWidget {
  const VegNonVegCalculator({super.key});

  @override
  _VegNonVegCalculatorState createState() => _VegNonVegCalculatorState();
}

class _VegNonVegCalculatorState extends State<VegNonVegCalculator> {
  String target = "custom_categories";
  RxList categories = [
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
  ].obs;
  RxList categoriesEdit = [
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
  ].obs;
  List<TextEditingController> controllers = [];

  final TextEditingController newCategoryController = TextEditingController();
  final Map<String, List<String>> selectedOptions = {};
  final TextEditingController searchController = TextEditingController();
  final Map<String, Map<String, double>> friendShares = {};
  final RxList addedUser = [].obs;
  final RxList addedMembers = [].obs;
  final RxString splitID = ''.obs;
  final RxBool acceptReset = false.obs;
  final RxBool reloadData = false.obs;
  late IO.Socket socket;
  // TextEditingController newCategoryController =
  //                                 TextEditingController();

  List<Map<dynamic, dynamic>> get friends => userController.friendsList
      .map((e) => e as Map<dynamic, dynamic>)
      .toList();
  bool _isInfoVisible = false; // Controls visibility of the container
  double _opacity = 0.0; // Controls the fade effect
  Timer? _timer;
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
    _loadCustomCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInfoVisible = true;
          _opacity = 1.0; // Fade in
        });
        // Start timer to fade out after 5 seconds
        _timer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _opacity = 0.0; // Fade out
            });
          }
        });
      }
    });
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
    socket.onConnect((_) => {});
    socket.onDisconnect((_) => {});
    socket.onError((error) =>{});
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

// Load custom categories from SharedPreferences
  Future<void> _loadCustomCategories() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedCategories = prefs.getString(target);

      if (savedCategories != null) {
        List<String> names = savedCategories
            .substring(1, savedCategories.length - 1)
            .split("--");
        RxList<Map<String, dynamic>> customCategories = names
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final item = entry.value;

              return {
                'name': item,
                'controller': TextEditingController(),
                'isCustom': index > 2, // 👈 condition here
              };
            })
            .toList()
            .obs;

        setState(() {
          categories.clear();
          categories.addAll(customCategories);
          categoriesEdit.clear();
          categoriesEdit.addAll(categories);
          categories.forEach((element) {
            controllers
                .add(TextEditingController(text: element['name'].toString()));
          });
        });
        _calculateShares();
      } else {
        categoriesEdit.clear();
        categoriesEdit.addAll(categories);
        categories.forEach((element) {
          controllers
              .add(TextEditingController(text: element['name'].toString()));
        });
        _calculateShares();
      }
    } catch (e) {
    }
  }

  // Save custom categories to SharedPreferences
  Future<void> _saveCustomCategories() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> namesList = [];
      categories.forEach((e) {
        namesList.add(e['name'].toString().trim());
      });

      await prefs.setString(
          target, jsonEncode(namesList.join("--").toString().trim()));
    } catch (e) {
      
    }
  }

  Widget _buildInputColumn(
    String label,
    TextEditingController controller,
    int index,
    bool isCustom,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.26,
      // padding: const EdgeInsets.symmetric(horizontal: 5,),
      child: Column(
        children: [
          // Show the category name as a label (not editable here anymore)
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            inputFormatters: allowDecimalInput(),
            onChanged: (value) => _calculateShares(),
            style: TextStyle(
              color: AppColors.accentColor, // <-- Change text input color here
            ),
            decoration: InputDecoration(
              filled: true,
              hintText: label,
              hintStyle: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.grey,
              ),
              fillColor: AppColors.backgroundColor,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget calculation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                snackBarCalledfail(
                    context, SnackbarData().validAmountAndShares);
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  PlotFinanceStaticData().billSplitButton,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.backgroundColor,
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
                snackBarCalledfail(
                    context, SnackbarData().userNameNotAvailable);
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
                snackBarCalledfail(
                    context, SnackbarData().noValidSharesToNotify);
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
                    snackBarCalled(context, "Notification sent successfully!");
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
              width: MediaQuery.of(context).size.width * 0.4,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey)),
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
        double chipWidth = categories.length > 3
            ? MediaQuery.sizeOf(context).width / 5
            : MediaQuery.sizeOf(context).width / 4;
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                  vertical: 6, horizontal: 12), // Spacing between items
              padding:
                  const EdgeInsets.all(0), // Inner padding for each container
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFFF3F4F6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AvatarProfile(
                          background: friend['avatarBackGround'] ??
                              defaultBackGround.value,
                          width: 8,
                          height: 18,
                          name: friend['name'] ?? 'Unknown',
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
                  alignment: WrapAlignment.spaceBetween,
                  children: categories.map((category) {
                    String option = category['name'];
                    bool isSelected =
                        selectedOptions[friendId]?.contains(option) == true;
                    bool isDisabled = category['controller'].text.isEmpty;
                    return SizedBox(
                      // width: chipWidth,
                      child: ChoiceChip(
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
                                    selectedOptions.putIfAbsent(
                                        friendId, () => []);
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
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget commentedData() {
    final limitedFriends = userController.friendsList.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 7),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enables horizontal scrolling
              child: Row(
                children: List.generate(limitedFriends.length, (index) {
                  final String id =
                      limitedFriends[index]['_id']?.toString() ?? '';
                  final bool isSelected = addedUser.contains(id);

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
                            "name":
                                limitedFriends[index]['name']?.toString() ?? '',
                            "id": id,
                            'avatar': limitedFriends[index]['avatar'],
                            'avatarBackGround': limitedFriends[index]
                                ['avatarBackGround'],
                            "balance": 0.0,
                          });
                          selectedOptions[id] = [];
                        }
                        _calculateShares();
                      });
                    },
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4), // spacing between items
                      child: Container(
                        //                  decoration: BoxDecoration(
                        //   color: AppColors.backgroundColor,
                        //   borderRadius: BorderRadius.circular(16),
                        //   border: Border.all(
                        //     color: Color(0xFFF3F4F6),
                        //     width: 1,
                        //   ),
                        //   boxShadow: [
                        //     BoxShadow(
                        //       color: Color.fromRGBO(0, 0, 0, 0.05),
                        //       offset: Offset(0, 1),
                        //       blurRadius: 2,
                        //     ),
                        //   ],
                        // ),
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(10),
                          color: !isSelected
                              ? AppColors.backgroundColor
                              : AppColors.primaryColor,

                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color(0xFFF3F4F6),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        // elevation: 1,

                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: AvatarProfile(
                                  name: limitedFriends[index]['name']
                                          ?.toString() ??
                                      'Unknown',
                                  width: 12,
                                  height: 12,
                                  background: limitedFriends[index]
                                          ['avatarBackGround'] ??
                                      defaultBackGround.value,
                                  flag: true,
                                  fontsize: 5,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                limitedFriends[index]['name']?.toString() ??
                                    'Unknown',
                                overflow: TextOverflow.ellipsis,
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: isSelected
                                      ? AppColors.backgroundColor
                                      : AppColors.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            )
        ],
      ),
    );
  }

  Widget inputDat(String labelText, TextInputType keyboard,
      TextEditingController textController) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 40,
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
          prefixIcon: Icon(Icons.search),
          filled: true,
          hintText: labelText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color.fromRGBO(249, 246, 238, 1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color.fromRGBO(246, 246, 246, 1)),
          ),
          fillColor: AppColors.backgroundColor,
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
      final response = await postDataApiCall('$url/split', requestBody
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

  // @override
  // void dispose() {
  //   for (var category in categories) {
  //     category['controller'].dispose();
  //   }
  //   newCategoryController.dispose();
  //   searchController.dispose();
  //   socket.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Container(
            width: MediaQuery.sizeOf(context).width / 7,
            child: IconButton(
              icon: const Icon(
                Icons.edit,
                color: AppColors.primaryColor,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.primaryColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    // Initialize customCategoryCount
                    int customCategoryCount = categories.length - 3;

                    return StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter modalSetState) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 16,
                            right: 16,
                            top: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Edit Categories',
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: AppColors.backgroundColor,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 25,
                                      color: Colorcodes.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Existing categories
                              ...List.generate(categories.length, (index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controllers[index],
                                          onChanged: (value) {
                                            categoriesEdit[index]['name'] =
                                                value;
                                          },
                                          style: const TextStyle(
                                              color: AppColors.backgroundColor),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: const Color.fromARGB(
                                                59, 255, 255, 255),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 12.0,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              borderSide: const BorderSide(
                                                color: AppColors.backgroundColor,
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              borderSide: const BorderSide(
                                                color: AppColors.backgroundColor,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (categories[index]['isCustom'])
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            modalSetState(() {
                                              setState(() {
                                                categories.removeAt(index);
                                                controllers.removeAt(index);
                                                if (index <
                                                    categoriesEdit.length) {
                                                  categoriesEdit
                                                      .removeAt(index);
                                                }
                                                customCategoryCount--;
                                                _saveCustomCategories();
                                                _calculateShares();
                                              });
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              }),
                              // New category input with Add button
                              if (customCategoryCount < 2)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: newCategoryController,
                                          style: const TextStyle(
                                              color: AppColors.backgroundColor),
                                          decoration: InputDecoration(
                                            hintText: 'Add new category',
                                            hintStyle: const TextStyle(
                                                color: Colors.white70),
                                            filled: true,
                                            fillColor: const Color.fromARGB(
                                                59, 255, 255, 255),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 12.0,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              borderSide: const BorderSide(
                                                color: AppColors.backgroundColor,
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              borderSide: const BorderSide(
                                                color: AppColors.backgroundColor,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (newCategoryController
                                              .text.isNotEmpty) {
                                            modalSetState(() {
                                              setState(() {
                                                categories.add({
                                                  'name': newCategoryController
                                                      .text
                                                      .trim(),
                                                  'controller':
                                                      TextEditingController(),
                                                  'isCustom': true,
                                                });
                                                controllers.add(
                                                  TextEditingController(
                                                    text: newCategoryController
                                                        .text
                                                        .trim(),
                                                  ),
                                                );
                                                categoriesEdit.add({
                                                  'name': newCategoryController
                                                      .text
                                                      .trim(),
                                                  'controller':
                                                      TextEditingController(),
                                                  'isCustom': true,
                                                });
                                                customCategoryCount++;
                                                newCategoryController.clear();
                                                _saveCustomCategories();
                                                _calculateShares();
                                              });
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.backgroundColor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Add',
                                          style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              // Done button
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Update categories with edited names
                                    categories.clear();
                                    controllers
                                        .asMap()
                                        .entries
                                        .forEach((entry) {
                                      final index = entry.key;
                                      final control = entry.value;
                                      categories.add({
                                        'name': control.text,
                                        'controller': TextEditingController(),
                                        'isCustom': index > 2,
                                      });
                                    });

                                    setState(() {
                                      categoriesEdit.clear();
                                      categoriesEdit.addAll(categories);
                                      _calculateShares();
                                    });
                                    _saveCustomCategories();

                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.backgroundColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Done',
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ).whenComplete(() {
                  // No additional cleanup needed here
                });
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isInfoVisible = true;
                  _opacity = 1.0; // Fade in
                });
                _timer?.cancel();

                _timer = Timer(Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _opacity = 0.0; // Fade out
                    });
                  }
                });
              },
              child: Text(
                PlotFinanceStaticData().foodieFundsTitle,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w800,
                  fontSize: 40,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            onEnd: () {
              // Hide container after fade-out completes
              if (_opacity == 0.0 && mounted) {
                setState(() {
                  _isInfoVisible = false;
                });
              }
            },
            child: _isInfoVisible
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.backgroundColor, width: 1),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          "Foodie Fund makes splitting bills with friends super simple—whether it's at a restaurant, or a weekend outing. You can split equally or enter custom shares so everyone pays exactly for what they consumed, not a rupee more or less.",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColors.backgroundColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input fields for categories
              Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Row with 3 default categories
                      // SizedBox(height: 100,),
                      inputDat(PlotFinanceStaticData().searchHint,
                          TextInputType.name, searchController),
                      SizedBox(
                        height: 12,
                      ),
                      commentedData(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          3, // only first 3 categories
                          (index) {
                            final category = categories[index];
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                child: _buildInputColumn(
                                  category["name"],
                                  category["controller"],
                                  index,
                                  category["isCustom"],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // const SizedBox(height: 10),

                      // Newly added categories (if any) below the row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          categories.length > 3
                              ? categories.length - 3
                              : 0, // only extra ones
                          (index) {
                            final category = categories[index + 3];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              child: _buildInputColumn(
                                category["name"],
                                category["controller"],
                                index + 3,
                                category["isCustom"],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                height: 8,
              ),
              // Search bar

              // Scrollable section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  height: _isInfoVisible
                      ? (categories.length > 3
                          ? MediaQuery.sizeOf(context).height / 3.4
                          : MediaQuery.sizeOf(context).height / 3.1)
                      : (categories.length > 3
                          ? MediaQuery.sizeOf(context).height / 2.5
                          : MediaQuery.sizeOf(context).height / 2.2),
                  child: Scrollbar(
                    thumbVisibility: true, // Makes the scrollbar always visible
                    thickness:
                        6.0, // Optional: Adjust the thickness of the scrollbar
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          vegNonvegdata(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Calculation section
              calculation(),
            ],
          ),
        ]),
      ),
    );
  }
}

class CustomShapePainter extends CustomPainter {
  final double scaleX;
  final double scaleY;

  CustomShapePainter({
    this.scaleX = 0.92, // Horizontal scaling (1.0 = original width)
    this.scaleY = 1.13, // Vertical scaling (1.0 = original height)
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scaleX, scaleY); // Scale both width & height

    final Paint paint1 = Paint()..style = PaintingStyle.fill;
    paint1.color = const Color(0xFF60628C);

    final Path path1 = Path();
    path1.moveTo(0, 60.0157);
    path1.cubicTo(0, 31.7314, 0, 17.5892, 8.7868, 8.80242);
    path1.cubicTo(17.5736, 0.015625, 31.7157, 0.015625, 60, 0.015625);
    path1.lineTo(309, 0.015625);
    path1.cubicTo(337.284, 0.015625, 351.426, 0.015625, 360.213, 8.80242);
    path1.cubicTo(369, 17.5892, 369, 31.7314, 369, 60.0156);
    path1.lineTo(369, 507.573);
    path1.cubicTo(369, 524.814, 369, 533.435, 364.51, 540.992);
    path1.cubicTo(360.02, 548.548, 352.967, 552.388, 338.861, 560.067);
    path1.cubicTo(301.584, 580.36, 236.666, 610.998, 184.5, 610.998);
    path1.cubicTo(135.832, 610.998, 76.0644, 591.981, 37.9981, 577.68);
    path1.cubicTo(20.2564, 571.014, 11.3856, 567.681, 5.69278, 559.461);
    path1.cubicTo(0, 551.241, 0, 541.193, 0, 521.097);
    path1.lineTo(0, 60.0157);
    path1.close();

    canvas.drawPath(path1, paint1);

    final Paint paint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = AppColors.backgroundColor.withOpacity(0.7);

    final Path path2 = Path();
    // (keep your existing stroke path here)
    canvas.drawPath(path2, paint2);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CustomShapeWidget extends StatelessWidget {
  final double scaleX;
  final double scaleY;

  const CustomShapeWidget({
    super.key,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 209 * scaleX, // Adjust width according to scale
      height: 600 * scaleY, // Adjust height according to scale
      child: CustomPaint(
        painter: CustomShapePainter(
          scaleX: scaleX,
          scaleY: scaleY,
        ),
      ),
    );
  }
}
