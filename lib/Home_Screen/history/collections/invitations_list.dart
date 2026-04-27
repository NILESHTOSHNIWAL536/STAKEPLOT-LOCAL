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
      barrierDismissible: false,
      builder: (_context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Icon(
                      isAccept ? Icons.check_circle : Icons.delete_outline,
                      color: isAccept ? Colors.green : Colors.red,
                      size: 40,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      isAccept ? "Accept Invitation?" : "Delete Invitation?",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      isAccept
                          ? "Do you want to accept this invite?"
                          : "This action will remove the invite permanently.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(_context),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() => isLoading = true);

                                    try {
                                      if (isAccept) {
                                        await collectionsController
                                            .acceptInvitation(
                                                invitationId, context);
                                      } else {
                                        await collectionsController
                                            .rejectInvitation(invitationId);
                                      }

                                      Navigator.pop(_context);
                                    } catch (e) {
                                      setState(() => isLoading = false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isAccept ? Colors.green : Colors.red,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(isAccept ? "Accept" : "Delete"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmDialog2(
      BuildContext context, String invitationId, bool isAccept) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAccept
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                  ),
                  child: Icon(
                    isAccept ? Icons.check_circle : Icons.delete_outline,
                    color: isAccept ? Colors.green : Colors.red,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  isAccept ? "Accept Invitation?" : "Delete Invitation?",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // Description
                Text(
                  isAccept
                      ? "Do you want to accept this invite?"
                      : "This action will remove the invite permanently.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(_context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isAccept) {
                            await collectionsController.acceptInvitation(
                                invitationId, context);
                          } else {
                            await collectionsController
                                .rejectInvitation(invitationId);
                          }
                          Navigator.pop(_context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAccept ? Colors.green : Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(isAccept ? "Accept" : "Delete"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void _showConfirmDialog(
  //     BuildContext context, String invitationId, bool isAccept) {
  //   showDialog(
  //     context: context,
  //     builder: (_context) {
  //       return AlertDialog(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //         title: Text(isAccept ? "Accept Invitation?" : "Reject Invitation?"),
  //         content: Text(
  //           isAccept
  //               ? "Do you want to accept this invite?"
  //               : "Do you want to delete this invite?",
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Cancel"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               if (isAccept) {
  //                 await collectionsController.acceptInvitation(invitationId, context);
  //               } else {
  //                 await collectionsController.rejectInvitation(invitationId);
  //               }
  //                 Navigator.pop(_context);
  //             },
  //             child: Text(isAccept ? "Accept" : "Delete"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
