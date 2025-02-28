import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Tribe/tribe_one.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

RxList addedUser = [].obs;
RxList addedMembers = [].obs;

class NewFriendsUi extends StatefulWidget {
  final bool showContinueButton;
  final double totalAmount;
  final String userId;
  final String userName;
  final String userAvatar;

  const NewFriendsUi({
    Key? key,
    this.showContinueButton = true,
    required this.totalAmount,
    required this.userId,
    required this.userName,
    required this.userAvatar,
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
      height: MediaQuery.of(context).size.height / 1.9,
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
                                          url: element['avatar'] ?? widget.userAvatar,
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
                                            addedMembers.removeWhere((ele) => ele['id'] == element['id']);
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
                        print("NewFriendsUi: Opening AmountEntryModal with totalAmount: ${widget.totalAmount}");
                        final amounts = await showAmountEntryModal(context);
                        if (amounts != null) {
                          print("NewFriendsUi: Received amounts from AmountEntryModal: $amounts");
                          Navigator.pop(context, amounts); // Pass amounts back to parent
                        } else {
                          print("NewFriendsUi: No amounts returned from AmountEntryModal");
                        }
                      } else {
                        print("NewFriendsUi: No friends selected");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select at least one friend')),
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

  Future<Map<String, double>?> showAmountEntryModal(BuildContext context) async {
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
                                if (addedUser.contains(values)) {
                                  addedUser.remove(values);
                                  addedMembers.removeWhere((element) => element['id'] == values);
                                } else {
                                  addedUser.add(values);
                                  addedMembers.add({
                                    "name": frdsList[index]['name'],
                                    "id": values,
                                    'avatar': frdsList[index]['avatar'],
                                    "balance": 200,
                                  });
                                  print("NewFriendsUi: Added member ${frdsList[index]['name']} with ID: $values");
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
                                      url: frdsList[index]['avatar'] ?? widget.userAvatar,
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

  Widget InputDat(String labelText, TextInputType keyboardType, TextEditingController controller) {
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
                if (element['name'].toString().toLowerCase().contains(value.toLowerCase())) {
                  filteredList.add(element);
                }
              });
              setState(() {
                frdsList.clear();
                frdsList.addAll(filteredList);
                print("NewFriendsUi: Filtered friends list updated: ${frdsList.length} items");
              });
            }
          },
          decoration: InputDecoration(
            filled: true,
            hintText: labelText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: Color.fromRGBO(249, 246, 238, 1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: Color.fromRGBO(246, 246, 246, 1)),
            ),
            fillColor: AppColors.button,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class AmountEntryModal extends StatefulWidget {
  final List selectedFriends;
  final double totalAmount;
  final String userId;
  final String userName;
  final String userAvatar;

  const AmountEntryModal({
    Key? key,
    required this.selectedFriends,
    required this.totalAmount,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  }) : super(key: key);

  @override
  _AmountEntryModalState createState() => _AmountEntryModalState();
}

class _AmountEntryModalState extends State<AmountEntryModal> {
  Map<String, TextEditingController> amountControllers = {};
  double currentTotal = 0.0;
  double leftoverAmount = 0.0;

  @override
  void initState() {
    super.initState();
    int totalParticipants = widget.selectedFriends.length + 1;
    double equalAmount = widget.totalAmount / totalParticipants;
print("-----------------------------------------------------------------------------------------------------------------------------");

    amountControllers[widget.userId] = TextEditingController(
      text: equalAmount.toStringAsFixed(2),
    );
    print("AmountEntryModal: Initialized user ${widget.userName} (ID: ${widget.userId}) with amount: $equalAmount");

    widget.selectedFriends.forEach((friend) {
      amountControllers[friend['id']] = TextEditingController(
        text: equalAmount.toStringAsFixed(2),
      );
      print("AmountEntryModal: Initialized friend ${friend['name']} (ID: ${friend['id']}) with amount: $equalAmount");
    });

    calculateTotal();
  }

  @override
  void dispose() {
    amountControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void calculateTotal() {
    currentTotal = 0.0;
    amountControllers.forEach((key, controller) {
      double amount = double.tryParse(controller.text) ?? 0.0;
      currentTotal += amount;
      print("AmountEntryModal: Amount for ID $key updated to: $amount");
    });
    leftoverAmount = widget.totalAmount - currentTotal;
    print("AmountEntryModal: Current Total: $currentTotal, Leftover: $leftoverAmount");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                children: [
                  AvatarProfileImage(
                    url: widget.userAvatar,
                    width: 10,
                    height: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: amountControllers[widget.userId],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0.00',
                      ),
                      onChanged: (value) => calculateTotal(),
                    ),
                  ),
                ],
              ),
            ),
            ...widget.selectedFriends.map((friend) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      AvatarProfileImage(
                        url: friend['avatar'] ?? widget.userAvatar,
                        width: 10,
                        height: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: amountControllers[friend['id']],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: '0.00',
                          ),
                          onChanged: (value) => calculateTotal(),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            Text(
              'Current Total: ₹${currentTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Text(
              'Leftover: ₹${leftoverAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: leftoverAmount == 0
                    ? Colors.green
                    : leftoverAmount < 0
                        ? Colors.red
                        : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: InkWell(
                onTap: () {
                  if (leftoverAmount != 0) {
                    print("AmountEntryModal: Cannot confirm, leftover amount: $leftoverAmount");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          leftoverAmount > 0
                              ? 'Please distribute the remaining ₹${leftoverAmount.toStringAsFixed(2)}'
                              : 'Total exceeds by ₹${(-leftoverAmount).toStringAsFixed(2)}',
                        ),
                      ),
                    );
                    return;
                  }
                  Map<String, double> amounts = {};
                  amountControllers.forEach((id, controller) {
                    amounts[id] = double.tryParse(controller.text) ?? 0.0;
                  });
                  print("AmountEntryModal: Confirming amounts: $amounts");
                  Navigator.pop(context, amounts);
                },
                child: getButton(context, "Confirm"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}