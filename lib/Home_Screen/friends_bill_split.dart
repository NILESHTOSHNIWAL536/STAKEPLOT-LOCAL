import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/amount_entry_modal.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/lendMessage.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';

import 'package:get/get.dart';

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
  final bool ismanual;
  
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
    this.flag = false,
    this.ismanual = true,
  }) : super(key: key);

  @override
  _NewFriendsUiState createState() => _NewFriendsUiState();
}

class _NewFriendsUiState extends State<NewFriendsUi> {
  TextEditingController textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Clear the selected friends lists when the screen is initialized
    // addedUser.clear();
    // addedMembers.clear();
  }
 
 
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
      // height: MediaQuery.of(context).size.height / 2,
      child: Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 18,
          right: 18,
          bottom:
              MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        ),
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
                                        child: AvatarProfile(
                                            name: element['name'],
                                            width: 12,
                                            height: 12,
                                            background:
                                                element['avatarBackGround'])),
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
              // if (widget.showContinueButton)
              //   Center(
              //     child: InkWell(
              //       onTap: () async {
              //         if (addedMembers.isNotEmpty) {

              //           if (widget.isLendMode) {

              //             if (addedMembers.length > 1) {

              //               ScaffoldMessenger.of(context).showSnackBar(
              //                 const SnackBar(
              //                     content: Text(
              //                         'Please select only one friend for lending')),
              //               );
              //               return;
              //             }
              //             Navigator.pop(context, addedMembers[0]);
              //           } else {

              //             Navigator.pop(context);
              //             final amounts = await showAmountEntryModal(
              //               context,
              //               widget.category ?? 'Uncategorized',
              //               widget.subcategory ?? 'General',
              //             );

              //             if (amounts != null) {

              //               Navigator.pop(context, amounts);
              //             }
              //             ;
              //             if (amounts != null) {

              //               Navigator.pop(context, amounts);
              //             } else {

              //             }
              //           }

              //         } else {

              //           ScaffoldMessenger.of(context).showSnackBar(
              //             const SnackBar(
              //                 content:
              //                     Text('Please select at least one friend')),
              //           );
              //         }
              //       },
              //       child: getButton(context, "Continue"),
              //     ),
              //   ),

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
                          // Show LendDetailsModal
                          final Map<String, String?>? lendDetails =
                              await showModalBottomSheet<Map<String, String?>>(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(18)),
                            ),
                            builder: (BuildContext context) {
                              return LendDetailsModal(
                                amount: widget.totalAmount,
                                member: addedMembers[0],
                                category: widget.category ?? 'Uncategorized',
                                subCategory: widget.subcategory ?? 'General',
                                onConfirm: () {},
                              );
                            },
                          );

                          if (lendDetails != null) {
                            // Return a map with member details, message, and due date
                            Navigator.pop(context, {
                              'member': addedMembers[0],
                              'message': lendDetails['message'],
                              'dueDate': lendDetails['dueDate'],
                            });
                          } else {
                            // User dismissed the modal without confirming
                            snackBarCalled(
                                context, "Please provide lend details");
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(content: Text('Lend details not provided')),
                            // );
                          }
                        } else {
                          Navigator.pop(context);
                          final amounts = await showAmountEntryModal(
                            context,
                            widget.category ?? 'Uncategorized',
                            widget.subcategory ?? 'General',
                          );

                          if (amounts != null) {
                            Navigator.pop(context, amounts);
                          }
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
              const SizedBox(height: 16),
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
          ismanual: widget.ismanual,
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
                child: frdsList.isEmpty
                    ? Center(
                        child: Text(
                          'No friends available',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppColors.bg3),
                        ),
                      )
                    : ListView.builder(
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
                                        addedMembers.removeWhere((element) =>
                                            element['id'] == values);
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
                                          'avatarBackGround': frdsList[index]
                                                  ['avatarBackGround'] ??
                                              defaultBackGround.value,
                                          "balance": 200,
                                        });
                                      } else {
                                        addedUser.add(values);
                                        addedMembers.add({
                                          "name": frdsList[index]['name'],
                                          "id": values,
                                          'avatar': frdsList[index]['avatar'],
                                          'avatarBackGround': frdsList[index]
                                                  ['avatarBackGround'] ??
                                              defaultBackGround.value,
                                          "balance": 200,
                                        });
                                      }
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 5,
                                    height: 50,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: AvatarProfile(
                                              name: frdsList[index]['name'],
                                              width: 12,
                                              height: 12,
                                              background: frdsList[index]
                                                      ['avatarBackGround'] ??
                                                  defaultBackGround.value),
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
        color: AppColors.backgroundColor,
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
