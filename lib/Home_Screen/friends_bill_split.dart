
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/amount_entry_modal.dart';
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

RxList addedUser = [].obs;
RxList addedMembers = [].obs;

class NewFriendsUi extends StatefulWidget {
  final bool showContinueButton;
  final double totalAmount;
  final String userId;
  final String userName;
  final String userAvatar;
  final bool isLendMode;
  final String? category;
  final String? subcategory;
  final bool flag;
  const NewFriendsUi({
    Key? key,
    this.showContinueButton = true,
    required this.totalAmount,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.isLendMode = false,
    this.category,
    this.subcategory,
    this.flag=false,
  }) : super(key: key);

  @override
  _NewFriendsUiState createState() => _NewFriendsUiState();
}

class _NewFriendsUiState extends State<NewFriendsUi> {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, left: 18, right: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select people',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.bg1,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: InputDat('Search', TextInputType.name, textController),
              ),
              Text(
                'My friends',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.bg1,
                ),
              ),
              const SizedBox(height: 10),
              addedMembers.isNotEmpty
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / 5,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: addedMembers.map((element) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 6,
                            height: MediaQuery.of(context).size.width / 7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Center(
                                        child: AvatarProfileImage(
                                          url: element['avatar'] ??
                                              widget.userAvatar,
                                          width: 10,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            addedMembers.removeWhere((ele) =>
                                                ele['id'] == element['id']);
                                            addedUser.remove(element['id']);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    element['name'],
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 12,
                                      maxLines: 1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
              commentedData(),
              if (widget.showContinueButton)
                Center(
                  child: InkWell(
                    onTap: () async {
                      if (addedMembers.isNotEmpty) {
                        if (widget.isLendMode) {
                          if (addedMembers.length > 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please select only one friend for lending')),
                            );
                            return;
                          }
                          Navigator.pop(
                              context,
                              addedMembers[
                                  0]); // Return single friend’s details
                        } else {
                          Navigator.pop(context);
                          final amounts = await showAmountEntryModal(
                            context,
                            widget.category ?? 'Uncategorized',
                            widget.subcategory ?? 'General',
                          );

                          if (amounts != null) {
                            Navigator.pop(context,
                                amounts); // Return amounts to TransactionHistory
                          }
                          ;
                          if (amounts != null) {
                            Navigator.pop(
                                context, amounts); // Return amounts for split
                          } else {}
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please select at least one friend')),
                        );
                      }
                    },
                    child: getButton(context, "Continue"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, double>?> showAmountEntryModal(
    BuildContext context,
    String category,
    String subcategory,
  ) async {
    return await showModalBottomSheet<Map<String, double>?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return AmountEntryModal(
          selectedFriends: addedMembers.toList(),
          totalAmount: widget.totalAmount,
          userId: widget.userId,
          userName: widget.userName,
          userAvatar: widget.userAvatar,
          cate: category,
          subcate: subcategory,
          flag: widget.flag,
        );
      },
    );
  }

  Widget commentedData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              child: SizedBox(
                height: 70,
                width: MediaQuery.of(context).size.width,

                child: frdsList.isEmpty? Center(
                        child: Text(
                          'No friends available',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppColors.bg3),
                        ),
                      )
                    :ListView.builder(
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
                                if (addedUser.contains(values)) {
                                  addedUser.remove(values);
                                  addedMembers.removeWhere(
                                      (element) => element['id'] == values);
                                } else if (widget.isLendMode &&
                                    addedMembers.isNotEmpty) {
                                  // For lend mode, replace the current selection
                                  addedUser.clear();
                                  addedMembers.clear();
                                  addedUser.add(values);
                                  addedMembers.add({
                                    "name": frdsList[index]['name'],
                                    "id": values,
                                    'avatar': frdsList[index]['avatar'],
                                    "balance": 200,
                                  });
                                } else {
                                  addedUser.add(values);
                                  addedMembers.add({
                                    "name": frdsList[index]['name'],
                                    "id": values,
                                    'avatar': frdsList[index]['avatar'],
                                    "balance": 200,
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
                                          widget.userAvatar,
                                      width: 8,
                                      height: 18,
                                    ),
                                  ),
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
                          Text(
                            frdsList[index]['name'],
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w400,
                              fontSize: 14,
                              color: AppColors.bg1,
                            ),
                          ),
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

  Widget InputDat(String labelText, TextInputType keyboardType,
      TextEditingController controller) {
    return Center(
      child: Container(
        color: const Color.fromRGBO(246, 246, 246, 1),
        width: MediaQuery.of(context).size.width / 1.1,
        child: TextFormField(
          keyboardType: keyboardType,
          controller: controller,
          onChanged: (value) {
            var filteredList = [];
            if (value.isEmpty) {
              frdsList.clear();
              frdsList.addAll(frdsListOrigin);
            } else {
              frdsListOrigin.forEach((element) {
                if (element['name']
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase())) {
                  filteredList.add(element);
                }
              });
              setState(() {
                frdsList.clear();
                frdsList.addAll(filteredList);
              });
            }
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
    );
  }
}
