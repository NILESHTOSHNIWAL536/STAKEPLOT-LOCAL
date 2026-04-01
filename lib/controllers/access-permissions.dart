import 'package:flutter/material.dart';
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
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
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
            ...members.map((m) {
              return _memberTile(context, m, details.collection.id);
            }),

            const SizedBox(height: 16),

            /// INVITE BUTTON
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InviteMembersScreen(
                      collectionId: details.collection.id,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.add),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Invite more members",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 14,
                      lWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

Widget _memberTile(BuildContext context, MemberModel m, String collectionId) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        /// AVATAR
        CircleAvatar(
          radius: 20,
          child: Text(m.name[0].toUpperCase()),
        ),

        const SizedBox(width: 10),

        /// NAME + AMOUNT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.name,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w600,
                ),
              ),
              Text(
                "₹${m.setAmount}",
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ),
        ),

        /// EDIT
        GestureDetector(
          onTap: () => _showRoleDialog(context, m, collectionId),
          child: Row(
            children: const [
              Icon(Icons.lock_outline, size: 18),
              SizedBox(width: 4),
              Text("Edit Access"),
            ],
          ),
        )
      ],
    ),
  );
}

void _showRoleDialog(BuildContext context, MemberModel m, String collectionId) {
  String selectedRole = m.role;

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Change Access"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Row(
              children: [
                _roleChip("VIEW", selectedRole,
                    () => setState(() => selectedRole = "VIEW")),
                _roleChip("CONTRIBUTE", selectedRole,
                    () => setState(() => selectedRole = "CONTRIBUTE")),
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
              Navigator.pop(context);

              await collectionsController.updateMemberRole(
                collectionId: collectionId,
                userId: m.userId,
                body: {'role': selectedRole},
              );
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

Widget _roleChip(String role, String selectedRole, VoidCallback onTap) {
  final isSelected = role == selectedRole;

  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          role,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
