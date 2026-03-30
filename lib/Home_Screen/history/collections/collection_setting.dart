// import 'package:flutter/material.dart';

// import '../../../Constants/colors.dart';
// import '../../../Constants/core/app_padding_sizes.dart';
// import '../../../Constants/font_manager.dart';

// class CollectionSettingsModal extends StatefulWidget {
//   const CollectionSettingsModal({super.key});

//   @override
//   State<CollectionSettingsModal> createState() =>
//       _CollectionSettingsModalState();
// }

// class _CollectionSettingsModalState extends State<CollectionSettingsModal> {
//   bool alertEnabled = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//       decoration: const BoxDecoration(
//         color: AppColors.backgroundColor,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           /// DRAG / CLOSE
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.keyboard_arrow_down),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               Expanded(
//                 child: Text(
//                   "Collection Settings",
//                   textAlign: TextAlign.center,
//                   style: FontManager().getTextStyle(
//                     context,
//                     fontSize: 16,
//                     lWeight: FontWeight.w700,
//                     color: AppColors.accentColor,
//                   ),
//                 ),
//               ),
//               SizedBox(width: AppSizes.w40),
//             ],
//           ),

//           SizedBox(height: AppSizes.h12),

//           /// ALERT SECTION
//           _alertCard(context),

//           SizedBox(height: AppSizes.h12),
//           _simpleTile(
//             context,
//             icon: Icons.file_upload_rounded,
//             title: "Export Transactions",
//             onTap: () {},
//           ),

//           _simpleTile(
//             context,
//             icon: Icons.edit,
//             title: "Rename Collection",
//             onTap: () {},
//           ),

//           _simpleTile(
//             context,
//             icon: Icons.access_time_filled,
//             title: "Edit Duration Range",
//             onTap: () {},
//           ),

//           SizedBox(height: AppSizes.h6),

//           _dangerTile(
//             context,
//             icon: Icons.close,
//             title: "Close Collection",
//             onTap: () {},
//           ),

//           _dangerTile(
//             context,
//             icon: Icons.delete_rounded,
//             title: "Delete Collection",
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   /// ---------------- ALERT CARD ----------------
//   Widget _alertCard(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(AppSizes.p14),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.border),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   "Alert for Certain Amount",
//                   style: FontManager().getTextStyle(
//                     context,
//                     fontSize: 14,
//                     lWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               Switch(
//                 value: alertEnabled,
//                 inactiveThumbColor: AppColors.backgroundColor,
//                 inactiveTrackColor: AppColors.border,
//                 activeColor: AppColors.primaryColor,
//                 onChanged: (v) {
//                   setState(() => alertEnabled = v);
//                 },
//               ),
//             ],
//           ),
//           SizedBox(height: AppSizes.h6),
//           Text(
//             "Notify me when any transaction exceeds ₹[amount] in this collection.",
//             style: FontManager().getTextStyle(
//               context,
//               fontSize: 12,
//               color: AppColors.grey,
//             ),
//           ),
//           if (alertEnabled) ...[
//             SizedBox(height: AppSizes.h10),
//             TextField(
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.currency_rupee, size: 18),
//                 hintText: "Enter amount threshold",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   /// ---------------- NORMAL TILE ----------------
//   Widget _simpleTile(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: AppSizes.p6),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.border),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: AppColors.border,
//           child: Icon(icon, size: 18, color: AppColors.primaryColor),
//         ),
//         title: Text(
//           title,
//           style: FontManager().getTextStyle(
//             context,
//             fontSize: 14,
//             lWeight: FontWeight.w500,
//             color: AppColors.accentColor,
//           ),
//         ),
//         onTap: onTap,
//       ),
//     );
//   }

//   /// ---------------- DANGER TILE ----------------
//   Widget _dangerTile(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: AppSizes.p6),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.redColor),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: AppColors.redColor.withOpacity(0.1),
//           child: Icon(icon, size: 18, color: AppColors.redColor),
//         ),
//         title: Text(
//           title,
//           style: FontManager().getTextStyle(
//             context,
//             fontSize: 14,
//             lWeight: FontWeight.w500,
//             color: AppColors.redColor,
//           ),
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/font_manager.dart';
import '../../../Home_Screen/history/collections/create_collection_data.dart';
import '../../../Home_Screen/history/collections/create_collection_pages/create_collection_flow.dart';
import '../../../Home_Screen/history/collections/create_collection_pages/step_select_duration.dart';
import '../../../backed_connections/bankServices/collection_pdf_export.dart';
import '../../../backed_connections/bankServices/pdf.dart';
import '../../../controllers/collections_controller.dart';

class CollectionSettingsModal extends StatefulWidget {
  const CollectionSettingsModal({super.key});

  @override
  State<CollectionSettingsModal> createState() =>
      _CollectionSettingsModalState();
}

class _CollectionSettingsModalState extends State<CollectionSettingsModal> {
  bool alertEnabled = false;

  final collectionsController = Get.find<CollectionsController>();

  @override
  Widget build(BuildContext context) {
    final collection = collectionsController.selectedCollection.value;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// HEADER
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  "Collection Settings",
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 16,
                    lWeight: FontWeight.w700,
                    color: AppColors.accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),

          const SizedBox(height: 12),

          /// ALERT
          _alertCard(context),

          const SizedBox(height: 12),

          /// EXPORT
          _simpleTile(
            context,
            icon: Icons.file_upload_rounded,
            title: "Export Transactions",
            onTap: () => _exportTransactions(context),
          ),

          /// RENAME
          _simpleTile(
            context,
            icon: Icons.edit,
            title: "Rename Collection",
            onTap: () => _showRenameDialog(
              context,
              collection?.name ?? "",
            ),
          ),

          /// DURATION
          _simpleTile(
            context,
            icon: Icons.access_time_filled,
            title: "Edit Duration Range",
            onTap: () => _showDurationPopup(context),
          ),

          const SizedBox(height: 6),

          /// CLOSE
          _dangerTile(
            context,
            icon: Icons.close,
            title: "Close Collection",
            onTap: () => _confirmClose(context),
          ),

          /// DELETE
          _dangerTile(
            context,
            icon: Icons.delete,
            title: "Delete Collection",
            onTap: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  /// ---------------- ALERT ----------------
  Widget _alertCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Alert for Certain Amount",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 14,
                    lWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: alertEnabled,
                onChanged: (v) => setState(() => alertEnabled = v),
              ),
            ],
          ),
          if (alertEnabled)
            const TextField(
              decoration: InputDecoration(
                hintText: "Enter amount threshold",
              ),
            ),
        ],
      ),
    );
  }

  /// ---------------- RENAME ----------------
  void _showRenameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Collection"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await collectionsController.updateCollection(
                id: collectionsController.selectedCollection.value!.id,
                name: controller.text,
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// ---------------- CLOSE ----------------
  void _confirmClose(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Close Collection"),
        content: const Text("Are you sure you want to close this collection?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await collectionsController.closeCollection(
                collectionsController.selectedCollection.value!.id,
              );
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  /// ---------------- DELETE ----------------
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Collection"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await collectionsController.deleteCollection(
                collectionsController.selectedCollection.value!.id,
                context: context,
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// ---------------- DURATION ----------------
  void _showDurationPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: StepSelectDuration(
          onNext: () async {
            await collectionsController.updateCollection(
              id: collectionsController.selectedCollection.value!.id,
              duration: collectionDraft.duration,
            );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  /// ---------------- EXPORT ----------------
  void _exportTransactions(BuildContext context) async {
    // await getPdf3(context, "1".obs, "month".obs);
    await exportCollectionPdf(
      context,
      collectionsController.selectedCollection.value!.id,
    );
  }

  /// ---------------- TILE ----------------
  Widget _simpleTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _dangerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(color: Colors.red)),
      onTap: onTap,
    );
  }
}
