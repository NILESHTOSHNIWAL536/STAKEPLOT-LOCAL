import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/amount_entry_modal.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/lendMessage.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
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
    addedMembers.clear();
    addedUser.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
                  HomepageStringsDart().selectPeople,
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
                  child: InputDat(HomepageStringsDart().searchLabel,
                      TextInputType.name, textController),
                ),
                Text(
                  HomepageStringsDart().myFriends,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.bg1,
                  ),
                ),
                const SizedBox(height: 10),
                // addedMembers.isNotEmpty
                //     ? Container(
                //         width: MediaQuery.of(context).size.width,
                //         height: MediaQuery.of(context).size.width / 5,
                //         child: ListView(
                //           scrollDirection: Axis.horizontal,
                //           children: addedMembers.map((element) {
                //             return Container(
                //               width: MediaQuery.of(context).size.width / 6,
                //               height: MediaQuery.of(context).size.width / 7,
                //               child: Column(
                //                 mainAxisAlignment: MainAxisAlignment.start,
                //                 crossAxisAlignment: CrossAxisAlignment.center,
                //                 children: [
                //                   Stack(
                //                     children: [
                //                       Padding(
                //                           padding: const EdgeInsets.all(0.0),
                //                           child: AvatarProfile(
                //                               name: element['name'],
                //                               width: 12,
                //                               height: 12,
                //                               background:
                //                                   element['avatarBackGround'])),
                //                       Positioned(
                //                         right: 0,
                //                         top: 0,
                //                         child: InkWell(
                //                           onTap: () {
                //                             setState(() {
                //                               addedMembers.removeWhere((ele) =>
                //                                   ele['id'] == element['id']);
                //                               addedUser.remove(element['id']);
                //                             });
                //                           },
                //                           child: const Icon(
                //                             Icons.remove_circle,
                //                             color: AppColors.accentColor,
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                   Center(
                //                     child: Text(
                //                       element['name'],
                //                       style: FontManager().getTextStyle(
                //                         context,
                //                         fontSize: 12,
                //                         maxLines: 1,
                //                       ),
                //                       overflow: TextOverflow.ellipsis,
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             );
                //           }).toList(),
                //         ),
                //       )
                //     : const SizedBox.shrink(),
                commentedData(),
                if (widget.showContinueButton)
                  Center(
                    child: InkWell(
                      onTap: () async {
                        if (addedMembers.isNotEmpty) {
                          if (widget.isLendMode) {
                            if (addedMembers.length > 1) {
                              snackBarCalledfail(
                                context,
                                SnackbarData().selectOnlyOneFriendLend,
                              );
                              return;
                            } // Show LendDetailsModal
                            final Map<String, String?>? lendDetails =
                                await showModalBottomSheet<
                                    Map<String, String?>>(
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
                              snackBarCalledfail(
                                  context, SnackbarData().provideLendDetails);
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
                          snackBarCalled(
                              context, SnackbarData().selectAtLeastOneFriend);
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
        return SafeArea(
          child: AmountEntryModal(
            selectedFriends: addedMembers.toList(),
            totalAmount: widget.totalAmount,
            userId: widget.userId,
            userName: widget.userName,
            userAvatar: widget.userAvatar,
            cate: category,
            subcate: subcategory,
            flag: widget.flag,
            ismanual: widget.ismanual,
          ),
        );
      },
    );
  }

  Widget commentedData() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
      child: SizedBox(
        height: MediaQuery.of(context).size.width / 1.6,
        width: MediaQuery.of(context).size.width,
        child: userController.friendsList.isEmpty
            ? Center(
                child: Text(
                  HomepageStringsDart().noFriendsAvailable,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.bg3),
                ),
              )
            : GridView.builder(
                itemCount: userController.friendsList.length,
                itemBuilder: (context, index) {
                  String values = userController.friendsList[index]['_id'];
                  return GestureDetector(
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
                            "name": userController.friendsList[index]['name'],
                            "id": values,
                            'avatar': userController.friendsList[index]
                                ['avatar'],
                            'avatarBackGround': userController
                                    .friendsList[index]['avatarBackGround'] ??
                                defaultBackGround.value,
                            "balance": 200,
                          });
                        } else {
                          addedUser.add(values);
                          addedMembers.add({
                            "name": userController.friendsList[index]['name'],
                            "id": values,
                            'avatar': userController.friendsList[index]
                                ['avatar'],
                            'avatarBackGround': userController
                                    .friendsList[index]['avatarBackGround'] ??
                                defaultBackGround.value,
                            "balance": 200,
                          });
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: addedUser.contains(values)
                            ? Border.all(
                                color: AppColors.buttonBorder,
                                width: 1.0,
                              )
                            : Border.all(
                                color: Colors.transparent,
                                width: 0.0,
                              ),
                        borderRadius: BorderRadius.circular(
                            8.0), // Optional: for rounded corners
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          AvatarProfile(
                              name: userController.friendsList[index]['name'],
                              width: 12,
                              height: 12,
                              background: userController.friendsList[index]
                                      ['avatarBackGround'] ??
                                  defaultBackGround.value),
                          Text(
                            userController.friendsList[index]['name'],
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w400,
                              fontSize: 14,
                              color: AppColors.bg1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Number of columns
                  crossAxisSpacing: 0.0, // Spacing between columns
                  mainAxisSpacing: 0.0, // Spacing between rows
                ),
              ),
      ),
    );
  }

  Widget InputDat(String labelText, TextInputType keyboardType,
      TextEditingController controller) {
    return Center(
      child: Container(
        color: AppColors.backgroundColor,
        width: MediaQuery.sizeOf(context).width / 1.07,
        height: MediaQuery.sizeOf(context).width * (32 / 348),
        child: TextFormField(
          keyboardType: keyboardType,
          controller: controller,
          onChanged: (value) {
            var filteredList = [];
            if (value.isEmpty) {
              userController.friendsList.clear();
              userController.friendsList.addAll(userController.frdsListOrigin);
            } else {
              userController.frdsListOrigin.forEach((element) {
                if (element['name']
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase())) {
                  filteredList.add(element);
                }
              });
              setState(() {
                userController.friendsList.clear();
                userController.friendsList.addAll(filteredList);
              });
            }
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            filled: true,
            enabled: false,
            hintText: "Search",
            fillColor: AppColors.backgroundColor,
            hintStyle: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal, fontSize: 14, color: AppColors.accentColor),
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ),
    );
  }
}
