
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart';

import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';


import 'dart:convert';


import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';

import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AmountEntryModal extends StatefulWidget {
  final List selectedFriends;
  final double totalAmount;
  final String userId;
  final String userName;
  final String userAvatar;
  bool flag = true;
  final String? cate;
  final String? subcate;

  AmountEntryModal(
      {Key? key,
      required this.selectedFriends,
      required this.totalAmount,
      required this.userId,
      required this.userName,
      required this.userAvatar,
      this.flag = true,
      this.cate,
      this.subcate})
      : super(key: key);

  @override
  _AmountEntryModalState createState() => _AmountEntryModalState();
}

class _AmountEntryModalState extends State<AmountEntryModal> {
  Map<String, TextEditingController> amountControllers = {};
  double currentTotal = 0.0;
  double leftoverAmount = 0.0;
  double initialEqualAmount = 0.0; // Store initial values
  Map<String, bool> isModified = {};
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    int totalParticipants = widget.selectedFriends.length + 1;
    initialEqualAmount = widget.totalAmount / totalParticipants;

    amountControllers[widget.userId] = TextEditingController(
      text: initialEqualAmount.toStringAsFixed(2),
    );
    isModified[widget.userId] = false;

    widget.selectedFriends.forEach((friend) {
      amountControllers[friend['id']] = TextEditingController(
        text: initialEqualAmount.toStringAsFixed(2),
      );
      isModified[friend['id']] = false;
    });
    socket = IO.io(urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    setUpSocketListener();
    calculateTotal();
  }

  setUpSocketListener() {
    socket.on(
        "disconnect",
        (data) => {
              socket.close(),
            });
  }

  @override
  void dispose() {
    amountControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void calculateTotal() {
    currentTotal = 0.0;
    amountControllers.forEach((key, controller) {
      double amount =
          double.tryParse(controller.text.replaceAll(',', '')) ?? 0.0;
      // Cap individual amount at totalAmount
      if (amount > widget.totalAmount) {
        amount = widget.totalAmount;
        controller.text = amount.toStringAsFixed(2);
      }
      currentTotal += amount;
    });
    leftoverAmount = widget.totalAmount - currentTotal;

    setState(() {});
  }

  void settleLeftover() {
    if (leftoverAmount == 0) {
      return;
    }

    if (leftoverAmount < 0) {
      // Adjust amounts to fit totalAmount
      double overage = -leftoverAmount;
      List<String> adjustableParticipants = [];
      amountControllers.forEach((id, controller) {
        double amount =
            double.tryParse(controller.text.replaceAll(',', '')) ?? 0.0;
        if (amount > 0) {
          adjustableParticipants.add(id);
        }
      });
      double reductionPerPerson = overage / adjustableParticipants.length;

      for (var id in adjustableParticipants) {
        double currentAmount =
            double.tryParse(amountControllers[id]!.text.replaceAll(',', '')) ??
                0.0;
        double newAmount =
            (currentAmount - reductionPerPerson).clamp(0, widget.totalAmount);
        amountControllers[id]!.text = newAmount.toStringAsFixed(2);
      }
    } else {
      // Distribute positive leftover among unchanged participants
      List<String> unchangedParticipants = [];
      amountControllers.forEach((id, controller) {
        if (!isModified[id]!) {
          unchangedParticipants.add(id);
        }
      });

      if (unchangedParticipants.isEmpty) {
        unchangedParticipants = amountControllers.keys.toList();
      } else {}

      double leftoverPerPerson = leftoverAmount / unchangedParticipants.length;

      for (var id in unchangedParticipants) {
        double currentAmount =
            double.tryParse(amountControllers[id]!.text.replaceAll(',', '')) ??
                0.0;
        double newAmount =
            (currentAmount + leftoverPerPerson).clamp(0, widget.totalAmount);
        amountControllers[id]!.text = newAmount.toStringAsFixed(2);
      }
    }

    calculateTotal();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context)
            .viewInsets
            .bottom, // Adjusts for keyboard height
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      duration: const Duration(milliseconds: 100), // Smooth animation
      curve: Curves.easeInOut,
      child: SingleChildScrollView(
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Amounts (Total: ₹${widget.totalAmount.toStringAsFixed(2)})',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AvatarProfileImage(
                        url: widget.userAvatar,
                        width: 10,
                        height: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.userName,
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 16,
                          color: AppColors.bg1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: amountControllers[widget.userId],
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ThousandsFormatter(),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.right,
                      onChanged: (value) {
                        isModified[widget.userId] = true;
                        calculateTotal();
                      },
                    ),
                  ),
                ],
              ),
            ),
            ...widget.selectedFriends.map((friend) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AvatarProfileImage(
                            url: friend['avatar'] ?? widget.userAvatar,
                            width: 10,
                            height: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            friend['name'],
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 16,
                              color: AppColors.bg1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: amountControllers[friend['id']],
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                            ThousandsFormatter(),
                          ],
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.currency_rupee, size: 18),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.right,
                          onChanged: (value) {
                            isModified[friend['id']] = true;
                            calculateTotal();
                          },
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            Text(
              'Current Total: ₹${currentTotal.toStringAsFixed(2)}',
             style: FontManager().getTextStyle(
                              context,
                              fontSize: 14,
                              color: AppColors.bg1,
                            ),
            ),
             const SizedBox(height: 10),
            Text(
              'Leftover: ₹${leftoverAmount.toStringAsFixed(2)}',
              style: FontManager().getTextStyle(
                              context,
                              fontSize: 14,
                              color:  leftoverAmount == 0
                    ? Colors.green
                    : leftoverAmount < 0
                        ? Colors.red
                        : Colors.orange,
                            ),
            
            ),
            const SizedBox(height: 16),
            Text(
              'Click Settle to split leftover amount equally among all',
              style: FontManager().getTextStyle(
                context,
                fontSize: 12,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: settleLeftover,
                  child: buttonContainer(context, "Settle"),
                ),

                Center(
                  child: InkWell(
                    onTap: () {
                      if (widget.flag) {
                        print("tappeddddddd"); // Debug print when flag is true
                        if (leftoverAmount != 0) {
                          // Shows a snackbar and returns (assuming this is handled elsewhere)
                          return;
                        }
                        Map<String, double> amounts = {};
                        amountControllers.forEach((id, controller) {
                          amounts[id] = double.tryParse(
                                  controller.text.replaceAll(',', '')) ??
                              0.0;
                        });
                        splitUserAmount(
                          context,
                          widget.totalAmount.toString(),
                          addedMembers,
                          widget.cate ?? 'Uncategorized',
                          widget.subcate ?? 'General',
                          amounts: amounts,
                        );
                        Navigator.pop(
                            context); // Pop after processing when flag is true
                      } else {
                        Navigator.pop(context); // Just pop when flag is false
                      }
                    },
                    child: buttonContainer(context, "Continue"),
                  ),
                )
                
              ],
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  void addSocketMessage(
    List addedUser,
    String amount,
    String splitName,
    String splitID,
    double parsedTotalAmount,
  ) {
    if (addedUser.isEmpty) {
      return;
    }

    for (var rec in addedUser) {
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
          "Amount": parsedTotalAmount,
          "Share": amount,
          "isPaid": false,
          "splitId": splitID,
        },
        "roomId": roomId,
      };

      try {
        socket.emit("joinRoom", roomId);
        socket.emit("message", jsonData);
        String userToSend =
            rec['name'] + rec['name']; // Fix concatenation if needed
        socket.emit("LoadCharts", {"roomId": userToSend});
      } catch (e) {}
    }
  }

  void splitUserAmount(
    BuildContext context,
    String totalAmount,
    List members,
    String category,
    String subcategory, {
    Map<String, double>? amounts, // Manual amounts including user's share
  }) async {
    double? parsedTotalAmount = double.tryParse(totalAmount);
    if (parsedTotalAmount == null || parsedTotalAmount <= 0) {
      snackBarCalled(context, "Invalid amount entered!", Colors.red);
      return;
    }

    if (members.isEmpty) {
      snackBarCalled(context, "No members selected!", Colors.red);
      return;
    }

    // Prepare paymentStatus list with individual amounts
    List<Map<String, dynamic>> nameList = [];
    double calculatedTotal = 0.0;

    if (amounts != null) {
      members.forEach((element) {
        double memberAmount = amounts[element['id']] ?? 0.0;
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': memberAmount,
        });
        calculatedTotal += memberAmount;
      });
      // Include the user's amount if present
      if (amounts.containsKey(currentId.value)) {
        double userAmount = amounts[currentId.value]!;
        nameList.add({
          'member': currentId.value,
          'markAsComplete': false,
          'amount': userAmount,
        });
        calculatedTotal += userAmount;
      }
    } else {
      double amountPerPerson = parsedTotalAmount / (members.length + 1);
      members.forEach((element) {
        nameList.add({
          'member': element['id'],
          'markAsComplete': false,
          'amount': amountPerPerson,
        });
        calculatedTotal += amountPerPerson;
      });
      nameList.add({
        'member': currentId.value,
        'markAsComplete': false,
        'amount': amountPerPerson,
      });
      calculatedTotal += amountPerPerson;
    }

    // Verify total matches
    if ((calculatedTotal - parsedTotalAmount).abs() > 0.01) {
      // Allow small floating-point errors
      snackBarCalled(context, "Total amount mismatch!", Colors.red);
      return;
    }

    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    if (accessToken == null) {
      snackBarCalled(context, "Authentication error!", Colors.red);
      return;
    }

    final response = await http.post(
      Uri.parse('$url/split'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        "subcategory": subcategory,
        "category": category,
        "amount": calculatedTotal,
        "paymentStatus": nameList,
        "image": '',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      splitID.value = body['id']['_id'];

      // Send notifications and socket messages with individual amounts
      for (var member in members) {
        double memberAmount = amounts?[member['id']] ??
            (parsedTotalAmount / (members.length + 1));
        String formattedAmount = memberAmount.toStringAsFixed(2);
        sendNotificationsToDevice(
          member['id'],
          context,
          "${userName.value} has sent you a Split Bill of $category ($subcategory) for ₹$formattedAmount",
        );
        addSocketMessage(
          [member],
          formattedAmount,
          category,
          splitID.value,
          parsedTotalAmount,
        );
      }

      snackBarCalled(context, "Split amount sent to users!", Colors.black);
      //Navigator.pop(context);
    } else {
      snackBarCalled(context, "Can't split, error!", Colors.red);
    }

    acceptReset.value = false;
  }
}

Widget buttonContainer(context, str,
    [color = AppColors.primaryColor, textColor = AppColors.bg5]) {
  return Container(
    width: MediaQuery.of(context).size.width / 2.3,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    decoration:
        BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
    child: Center(
      child: Text(
        str,
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.bold, fontSize: 15, color: textColor),
      ),
    ),
  );
}

