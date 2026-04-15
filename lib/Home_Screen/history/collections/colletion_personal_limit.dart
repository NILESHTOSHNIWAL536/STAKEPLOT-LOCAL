import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

class PersonLimitPopup {
  static void show(BuildContext context) {
    final controller = collectionsController;

    // 🔥 Dynamic controllers per user
    final Map<String, TextEditingController> textControllers = {};

    final members = controller.collectionDetails.value?.members ?? [];

    for (var m in members) {
      textControllers[m.userId] = TextEditingController(
        text: m.setAmount.toString(),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_context) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

        return Container(
          height: height * 0.7,
          padding: EdgeInsets.all(width * 0.04),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F3EF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.people, color: Colors.white),
                  ),
                  SizedBox(width: width * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Person Limit",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Set individual spending limit",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),

              SizedBox(height: height * 0.02),

              /// 🔹 Members List (Dynamic)
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (_, index) {
                    final m = members[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(width * 0.03),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            child: Center(
                              child: textStyleImage(
                                  text: m.name.isNotEmpty
                                      ? m.name[0].toUpperCase()
                                      : "U",
                                  context: context,
                                  c: AppColors.backgroundColor,
                                  fontsize: 20),
                            ),
                          ),
                          SizedBox(width: width * 0.03),

                          /// Name
                          Expanded(
                            child: Text(
                              m.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),

                          /// Editable Amount
                          SizedBox(
                            width: width * 0.32,
                            child: TextField(
                              controller: textControllers[m.userId],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: "₹ ",
                                hintText: "Enter",
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// 🔹 Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        List memberLimit = [];
                        for (var m in members) {
                          final value =
                              textControllers[m.userId]?.text.trim() ?? "";
                          if (value.isEmpty) continue;
                          memberLimit.add({
                            "userId": m.userId, 'limitAmount': value
                          });
                        }
                        await controller.updateMemberLimit(
                            body: memberLimit, context: _context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: textStyle(
                          text: "Save",
                          context: context,
                          c: AppColors.backgroundColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
