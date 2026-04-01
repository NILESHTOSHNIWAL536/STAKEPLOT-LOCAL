import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
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
            /// TITLE
            Text(
              "Access & Permissions",
              style: FontManager().getTextStyle(
                context,
                fontSize: 16,
                lWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            /// MEMBERS
            ...members.map((m) => _memberRow(context, m)),

            const SizedBox(height: 16),

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            /// ➕ ICON (MATCH DESIGN)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5B5F7B), // dark bluish
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),

            const SizedBox(width: 12),

            /// TEXT
            Expanded(
              child: Text(
                "Invite more members",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 15,
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
        title: const Text("Change Access"),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {

              final collectionId =
                  collectionsController.collectionDetails.value!.collection.id;

              await collectionsController.updateMemberRole(
                collectionId: collectionId,
                userId: m.userId,
                body: {"role": selectedRole},
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

Widget _memberRow(BuildContext context, MemberModel m) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
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
          backgroundColor: Colors.indigo.shade200,
          child: Text(
            m.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
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
              fontSize: 14,
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
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 8),

        /// EDIT
        GestureDetector(
          onTap: () => _showRoleDialog(context, m),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, size: 18),
              const SizedBox(width: 4),
              Text(
                "Edit",
                style: FontManager().getTextStyle(context,
                    fontSize: 12, color: Colorcodes.black),
              ),
            ],
          ),
        ),
      ],
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
        color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
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
