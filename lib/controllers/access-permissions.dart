import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:get/get.dart';
import '../Constants/font_manager.dart';
import '../backed_connections/apis_connect.dart';
import '../model/collections_model.dart';
import 'Invite-members-screen.dart';

class AccessPermissionsWidget extends StatelessWidget {
  const AccessPermissionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final details = collectionsController.collectionDetails.value;
      if (details == null) return const SizedBox();

      final members = details.members;

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              "Access & Permissions",
              style: FontManager().getTextStyle(
                context,
                fontSize: 14,
                color: AppColors.primaryColor,
                lWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            /// MEMBERS
            ...members.map((m) => _memberRow(context, m)),

            /// INVITE BUTTON
            _inviteRow(context),
          ],
        ),
      );
    });
  }

  Widget _inviteRow(BuildContext context) {
    final collectionId =
        collectionsController.collectionDetails.value?.collection.id ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => InviteSelectUsersScreen(
                    collectionId: collectionId,
                  )),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            /// ➕ ICON (MATCH DESIGN)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF5B5F7B), // dark bluish
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),

            const SizedBox(
              width: 10,
            ),

            /// TEXT
            Expanded(
              child: Text(
                "Invite more members",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 13,
                  lWeight: FontWeight.w600,
                  color: const Color(0xFF5B5F7B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showRoleDialog(BuildContext context, MemberModel m) {
  String selectedRole = m.role;

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text("Change Access",
            style: FontManager().getTextStyle(
              context,
              fontSize: 16,
              lWeight: FontWeight.w600,
            )),
        backgroundColor: Colors.white,
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _roleOption("VIEW", selectedRole,
                    () => setState(() => selectedRole = "VIEW"), context),
                const SizedBox(height: 8),
                _roleOption("CONTRIBUTE", selectedRole,
                    () => setState(() => selectedRole = "CONTRIBUTE"), context),
              ],
            );
          },
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              /// ❌ CANCEL BUTTON
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Cancel",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 13,
                        lWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              /// ✅ SAVE BUTTON
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final collectionId = collectionsController
                        .collectionDetails.value!.collection.id;

                    await collectionsController.updateMemberRole(
                      collectionId: collectionId,
                      userId: m.userId,
                      body: {"role": selectedRole},
                    );

                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor, // primary cool color
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Save",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 13,
                        lWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

Widget _memberRow(BuildContext context, MemberModel m) {
  return InkWell(
    onTap: () => _showRoleDialog(context, m),
    child: Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          /// AVATAR
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryColor, // primary cool color
            child: Text(
              m.name[0].toUpperCase(),
              style: FontManager().getTextStyle(context, color: Colors.white),
            ),
          ),

          const SizedBox(width: 10),

          /// NAME
          Expanded(
            flex: 2,
            child: Text(
              m.name,
              style: FontManager().getTextStyle(
                context,
                fontSize: 12,
                lWeight: FontWeight.w600,
              ),
            ),
          ),

          /// AMOUNT
          Expanded(
            child: Text(
              "₹${m.setAmount}",
              textAlign: TextAlign.center,
              style: FontManager().getTextStyle(
                context,
                fontSize: 13,
                lWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),

          /// ROLE CHIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              m.role,
              style: FontManager().getTextStyle(
                context,
                fontSize: 11,
                color: AppColors.appIcon,
                lWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 4),
          Text(
            "Edit",
            style: FontManager()
                .getTextStyle(context, fontSize: 12, color: Colorcodes.black),
          ),
        ],
      ),
    ),
  );
}

Widget _roleOption(String role, String selectedRole, VoidCallback onTap,
    BuildContext context) {
  final isSelected = role == selectedRole;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
            color: Colors.black,
          ),
          const SizedBox(width: 10),
          Text(role,
              style: FontManager().getTextStyle(
                context,
                fontSize: 14,
                lWeight: FontWeight.w500,
              )),
        ],
      ),
    ),
  );
}
