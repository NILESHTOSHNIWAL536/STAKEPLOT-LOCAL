import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/font_manager.dart';
import '../../../backed_connections/apis_connect.dart';

class InvitationsList extends StatelessWidget {
  const InvitationsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildInvitationsList(context);
  }

  Widget _buildInvitationsList(BuildContext context) {
    return Obx(() {
      if (collectionsController.isInvitationLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (collectionsController.invitationsList.isEmpty) {
        return Center(
          child: Text(
            "No Invitations",
            style: FontManager().getTextStyle(
              context,
              fontSize: 16,
              lWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: collectionsController.invitationsList.length,
        itemBuilder: (context, index) {
          final invite = collectionsController.invitationsList[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔥 TOP ROW
                Row(
                  children: [
                    /// Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        invite.invitedBy?.name?.substring(0, 1).toUpperCase() ??
                            "U",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// Collection + inviter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invite.collection?.name ?? "",
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 15,
                              lWeight: FontWeight.w600,
                              color: AppColors.accentColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Invited by ${invite.invitedBy?.name ?? ''}",
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// ROLE CHIP
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    invite.role,
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 11,
                      color: AppColors.primaryColor,
                      lWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _showConfirmDialog(context, invite.id, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade300, // light bg
                          foregroundColor: Colors.white, // ✅ TEXT COLOR BLACK
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Accept"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _showConfirmDialog(context, invite.id, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade300,
                          foregroundColor: Colors.white, // ✅ BLACK TEXT
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Reject"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      );
    });
  }

  void _showConfirmDialog(
      BuildContext context, String invitationId, bool isAccept) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Text(
            isAccept ? "Accept Invitation?" : "Reject Invitation?",
            style: FontManager().getTextStyle(
              context,
              fontSize: 16,
              lWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            isAccept
                ? "Are you sure you want to join this collection?"
                : "Are you sure you want to reject this invitation?",
            style: FontManager().getTextStyle(
              context,
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // ✅ close first

                if (isAccept) {
                  await collectionsController.acceptInvitation(invitationId);
                } else {
                  await collectionsController.rejectInvitation(invitationId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAccept ? Colors.green.shade100 : Colors.red.shade100,
                foregroundColor: Colors.black, // ✅ BLACK TEXT
                elevation: 0,
              ),
              child: Text(isAccept ? "Accept" : "Reject"),
            ),
          ],
        );
      },
    );
  }
}
