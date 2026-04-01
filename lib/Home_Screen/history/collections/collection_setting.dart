import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/font_manager.dart';
import '../../../Home_Screen/history/collections/create_collection_data.dart';
import '../../../Home_Screen/history/collections/create_collection_pages/step_select_duration.dart';
import '../../../backed_connections/bankServices/collection_pdf_export.dart';
import '../../../controllers/collections_controller.dart';

class CollectionSettingsModal extends StatefulWidget {
  const CollectionSettingsModal({super.key});

  @override
  State<CollectionSettingsModal> createState() =>
      _CollectionSettingsModalState();
}

class _CollectionSettingsModalState extends State<CollectionSettingsModal> {
  bool _alertEnabled = false;
  final TextEditingController _alertAmountController = TextEditingController();
  final collectionsController = Get.find<CollectionsController>();

  @override
  void dispose() {
    _alertAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F3EF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ── DRAG HANDLE ──
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 16),

          /// ── HEADER ──
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.keyboard_arrow_down,
                      size: 20, color: Color(0xFF2D2B5B)),
                ),
              ),
              Expanded(
                child: Text(
                  "Collection Settings",
                  textAlign: TextAlign.center,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 16,
                    lWeight: FontWeight.w700,
                    color: const Color(0xFF1A1832),
                  ),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),

          const SizedBox(height: 20),

          /// ── ALERT CARD ──
          _alertCard(context),

          const SizedBox(height: 12),

          /// ── EXPORT ──
          _settingsTile(
            context,
            iconAsset: Icons.file_upload_outlined,
            title: "Export Transactions",
            onTap: () => _exportTransactions(context),
          ),

          const SizedBox(height: 10),

          /// ── RENAME ──
          _settingsTile(
            context,
            iconAsset: Icons.edit_outlined,
            title: "Rename Collection",
            onTap: () => _showRenameDialog(context),
          ),

          const SizedBox(height: 10),

          /// ── DURATION ──
          _settingsTile(
            context,
            iconAsset: Icons.access_time_outlined,
            title: "Edit Duration Range",
            onTap: () => _showDurationPopup(context),
          ),

          const SizedBox(height: 14),

          /// ── CLOSE COLLECTION ──
          _dangerTile(
            context,
            icon: Icons.cancel_outlined,
            title: "Close Collection",
            onTap: () => _confirmClose(context),
          ),

          const SizedBox(height: 10),

          /// ── DELETE COLLECTION ──
          _dangerTile(
            context,
            icon: Icons.delete_outline_rounded,
            title: "Delete Collection",
            onTap: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── ALERT CARD ───────────────────────
  Widget _alertCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Alert for Certain Amount",
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 14,
                          lWeight: FontWeight.w600,
                          color: const Color(0xFF1A1832),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _alertEnabled
                            ? "You'll be notified when threshold is reached."
                            : "Notify me when any transaction exceeds ₹ [amount] in this collection.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: _alertEnabled,
                  activeColor: const Color(0xFF2D2B5B),
                  onChanged: (v) => setState(() => _alertEnabled = v),
                ),
              ],
            ),
            if (_alertEnabled) ...[
              const SizedBox(height: 14),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3EF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Text(
                      "₹",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _alertAmountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1832),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter amount threshold",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(Icons.info_outline,
                          size: 18, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────── SETTINGS TILE ───────────────────────
  Widget _settingsTile(
    BuildContext context, {
    required IconData iconAsset,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF2D2B5B).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconAsset, size: 19, color: const Color(0xFF2D2B5B)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w500,
                  color: const Color(0xFF1A1832),
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── DANGER TILE ───────────────────────
  Widget _dangerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFDDDD)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: Colors.red.shade600),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w500,
                  color: Colors.red.shade700,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: Colors.red.shade300),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── RENAME ───────────────────────
  void _showRenameDialog(BuildContext context) {
    final collection = collectionsController.selectedCollection.value;
    final ctrl = TextEditingController(text: collection?.name ?? "");

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _StyledDialog(
        title: "Rename Collection",
        icon: Icons.edit_outlined,
        iconColor: const Color(0xFF2D2B5B),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter a new name for this collection.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            _StyledTextField(
              controller: ctrl,
              hintText: "Collection name",
              prefixIcon: Icons.label_outline_rounded,
            ),
          ],
        ),
        confirmLabel: "Save",
        confirmColor: const Color(0xFF2D2B5B),
        onConfirm: () async {
          Navigator.pop(context);
          final name = ctrl.text.trim();
          if (name.isEmpty) return;
          await collectionsController.updateCollection(
            id: collectionsController.selectedCollection.value!.id,
            name: name,
          );
        },
      ),
    );
  }

  // ─────────────────────── CLOSE ───────────────────────
  void _confirmClose(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _StyledDialog(
        title: "Close Collection",
        icon: Icons.cancel_outlined,
        iconColor: Colors.orange,
        content: const Text(
          "Are you sure you want to close this collection? You won't be able to add new transactions.",
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
        ),
        confirmLabel: "Close Collection",
        confirmColor: Colors.orange,
        onConfirm: () async {
          Navigator.pop(context);
          await collectionsController.closeCollection(
            collectionsController.selectedCollection.value!.id,
          );
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  // ─────────────────────── DELETE ───────────────────────
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _StyledDialog(
        title: "Delete Collection",
        icon: Icons.delete_outline_rounded,
        iconColor: Colors.red,
        content: const Text(
          "This action cannot be undone. All data in this collection will be permanently deleted.",
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
        ),
        confirmLabel: "Delete",
        confirmColor: Colors.red,
        onConfirm: () async {
          Navigator.pop(context);
          await collectionsController.deleteCollection(
            collectionsController.selectedCollection.value!.id,
             context,
          );
        },
      ),
    );
  }

  // ─────────────────────── DURATION ───────────────────────
  void _showDurationPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F3EF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "Edit Duration Range",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1832),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Expanded(
              child: StepSelectDuration(
                onNext: () async {
                  await collectionsController.updateCollection(
                    id: collectionsController.selectedCollection.value!.id,
                    duration: collectionDraft.duration,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── EXPORT ───────────────────────
  void _exportTransactions(BuildContext context) async {
    await exportCollectionPdf(
      context,
      collectionsController.selectedCollection.value!.id,
    );
  }
}

// ─────────────────────── REUSABLE STYLED DIALOG ───────────────────────
class _StyledDialog extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget content;
  final String confirmLabel;
  final Color confirmColor;
  final Future<void> Function() onConfirm;

  const _StyledDialog({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  State<_StyledDialog> createState() => _StyledDialogState();
}

class _StyledDialogState extends State<_StyledDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1832),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 16, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Content
            widget.content,

            const SizedBox(height: 24),

            /// Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xFF1A1832),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            await widget.onConfirm();
                            if (mounted) setState(() => _loading = false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.confirmColor,
                      disabledBackgroundColor:
                          widget.confirmColor.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.confirmLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── STYLED TEXT FIELD ───────────────────────
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autofocus: true,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1A1832),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon, size: 18, color: Colors.grey.shade500),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        ),
      ),
    );
  }
}
