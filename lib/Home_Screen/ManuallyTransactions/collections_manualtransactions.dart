import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Constants/booleanFlag.dart';
import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/core/app_shadows.dart';
import '../../Constants/font_manager.dart';
import '../../Utils/homepageStrings.dart.dart';
import '../../backed_connections/apis_connect.dart';
import '../../finvu_screens/shareAccountLogin.dart';



class CollectionsManualtransactions extends StatefulWidget {
  double amount;
  String transactionId;
  CollectionsManualtransactions(
      {Key? key, required this.amount, required this.transactionId})
      : super(key: key);

  @override
  State<CollectionsManualtransactions> createState() =>
      _CollectionsManualtransactionsState();
}

class _CollectionsManualtransactionsState
    extends State<CollectionsManualtransactions> {
      final Map<String, TextEditingController> controllersList = {};
  // ✅ Title Case Converter
  String toTitleCase(String text) {
    if (text.isEmpty) return "";
    return text
        .toLowerCase()
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _collectionWidget(),
          const SizedBox(height: 12),
          Obx(() => collectionsController.selectedCollectionId.value.isNotEmpty
              ? _membersWidget()
              : const SizedBox()),
          widget.transactionId != "" ? continueButton() : SizedBox.shrink()
        ],
      ),
    );
  }

  Widget continueButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSizes.p10),
              child: InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  // if (cashInAndOut.value) return;
                  cashInAndOut.value = true;

                  if (!collectionsController.canAddTransactions.value) {
                    cashInAndOut.value = false;
                    snackBarCalledfail(context,
                        "Split Amount need to be equal to the Total Amount");
                    return;
                  }

                  if (collectionsController.selectedCollectionId != "") {
                    collectionsController.splitManulaTansactions(
                        widget.transactionId.toString(), context ,controllersList);
                  }
                  cashInAndOut.value = false;
                },
                child: Obx(() => cashInAndOut.value
                    ? getspinner(context)
                    : getButton(
                        context,
                        HomepageStringsDart().addButton,
                        collectionsController.canAddTransactions.value
                            ? AppColors.primaryColor
                            : AppColors.primaryColor.withOpacity(0.3))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COLLECTION UI =================
  Widget _collectionWidget() {
    return Obx(() {
      if (collectionsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Collection",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.accentColor,
                )),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: collectionsController.collectionsList.map((collection) {
                bool isSelected =
                    collectionsController.selectedCollectionId.value ==
                        collection.id;

                return GestureDetector(
                  onTap: () async {
                    if (isSelected) {
                      collectionsController.selectedCollectionId.value = "";
                      collectionsController.canAddTransactions.value = true;
                    } else {
                      await collectionsController.getCollectionById(
                          collection.id, context, true);
                      collectionsController.selectedCollectionId.value =
                          collection.id;
                      collectionsController.canAddTransactions.value = false;
                    }
                    controllersList.clear();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.button : Colors.white,
                      borderRadius: BorderRadius.circular(25),

                      // ✅ Proper Border
                      border: Border.all(
                        color: isSelected
                            ? AppColors.button
                            : Colors.grey.shade300,
                        width: 1.2,
                      ),

                      // ✅ Shadow only when selected
                      boxShadow: isSelected ? [AppShadows.soft] : [],
                    ),
                    child: Text(
                      toTitleCase(collection.name), // ✅ Title Case here
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w600,
                        fontSize: 14,
                        color:
                            isSelected ? Colors.white : AppColors.accentColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  // ================= MEMBERS UI =================
  Widget _membersWidget() {
    final collection = collectionsController.collectionDetails.value;

    if (collection == null ||
        collection.members == null ||
        collection.members.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text("No members found")),
      );
    }

    final members = collection.members;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Enter Amount",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  )),
              Text("Total Amount :" + widget.amount.toString(),
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  )),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];

              final key = member.userId;
              controllersList.putIfAbsent(key, () => TextEditingController());

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),

                  // ✅ Border added
                  border: Border.all(color: Colors.grey.shade200),

                  boxShadow: [AppShadows.soft],
                ),
                child: Row(
                  children: [
                    // 👤 NAME
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.button,
                            child: Text(
                              (member.name ?? "U")[0].toUpperCase(),
                              style: FontManager()
                                  .getTextStyle(context, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              toTitleCase(member.name),
                              overflow: TextOverflow.ellipsis,
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 💰 INPUT
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: controllersList[key],
                        onChanged: (value) {
                          double total =
                              controllersList.values.fold(0, (sum, controller) {
                            return sum +
                                (double.tryParse(controller.text) ?? 0);
                          });

                          if (total == widget.amount) {
                            collectionsController.canAddTransactions.value =
                                true;
                          } else {
                            collectionsController.canAddTransactions.value =
                                false;
                          }
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: "₹ ",
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= COMMON CARD =================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [AppShadows.soft],
    );
  }
}
