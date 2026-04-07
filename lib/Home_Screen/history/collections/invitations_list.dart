import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:get/get.dart';
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
        return const Center(child: Text("No Invitations"));
      }

      return Column(
        children: collectionsController.invitationsList.map((invite) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor, // light grey like screenshot
              borderRadius: BorderRadius.circular(14),
            ),

            /// 🔥 MAIN ROW
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black,
                  child: Text(
                    invite.invitedBy?.name?.substring(0, 1).toUpperCase() ??
                        "A",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// NAME + ROLE + TIME
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    invite.collection?.name ?? "",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),

                                /// ROLE TAG
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    invite.role.toLowerCase(),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// TIME
                          Text(
                            formatWhatsAppDate(
                                invite.createdAt ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      /// MESSAGE
                      Text(
                        "You have been invited by ${invite.invitedBy?.name ?? "someone"}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// BUTTONS
                      Row(
                        children: [
                          /// ACCEPT BUTTON
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  _showConfirmDialog(context, invite.id, true),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "Accept",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          /// DELETE BUTTON
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  _showConfirmDialog(context, invite.id, false),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  /// 🔥 CONFIRM DIALOG
  void _showConfirmDialog(
      BuildContext context, String invitationId, bool isAccept) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isAccept ? "Accept Invitation?" : "Reject Invitation?"),
          content: Text(
            isAccept
                ? "Do you want to accept this invite?"
                : "Do you want to delete this invite?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (isAccept) {
                  await collectionsController.acceptInvitation(
                      invitationId, context);
                } else {
                  Navigator.pop(context);
                  await collectionsController.rejectInvitation(invitationId);
                }
              },
              child: Text(isAccept ? "Accept" : "Delete"),
            ),
          ],
        );
      },
    );
  }
}
