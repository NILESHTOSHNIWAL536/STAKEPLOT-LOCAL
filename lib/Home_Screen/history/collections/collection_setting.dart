import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/controllers/access-permissions.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/font_manager.dart';
import '../../../Home_Screen/history/collections/create_collection_data.dart';
import '../../../Home_Screen/history/collections/create_collection_pages/step_select_duration.dart';
import '../../../Utils/collections_helper.dart';
import '../../../Utils/navigateTo.dart';
import '../../../backed_connections/apis_connect.dart';
import '../../../backed_connections/bankServices/collection_pdf_export.dart';
import '../../../controllers/collections_controller.dart';
import '../../../model/collections_model.dart';
import 'create_collection_pages/create_collection_flow.dart';

// ── Local design tokens ───────────────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF5F3EF);
  static const surface = Colors.white;
  static const navy = Color(0xFF2D2B5B);
  static const navyBg = Color(0xFFEEEDF8);
  static const border = Color(0xFFEBEBEB);
  static const textDark = Color(0xFF1A1832);
  static const textMid = Color(0xFF6B7280);
  static const textLight = Color(0xFFACACAC);
  static const red = Color(0xFFEF4444);
  static const redBg = Color(0xFFFFF5F5);
  static const redBorder = Color(0xFFFFDDDD);
}

class CollectionSettingsModal extends StatefulWidget {
  const CollectionSettingsModal({super.key});

  @override
  State<CollectionSettingsModal> createState() =>
      _CollectionSettingsModalState();
}

class _CollectionSettingsModalState extends State<CollectionSettingsModal>
    with SingleTickerProviderStateMixin {
  bool _alertEnabled = false;
  final TextEditingController _alertAmountController = TextEditingController();
  final collectionsController = Get.find<CollectionsController>();
  late AnimationController _expandAnim;
  late Animation<double> _expandFade;
  RxString selectedDuration = "".obs;

  @override
  void initState() {
    super.initState();
    userController.fetchUserInfo();
    _expandAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _expandFade = CurvedAnimation(parent: _expandAnim, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _alertAmountController.dispose();
    _expandAnim.dispose();
    super.dispose();
  }

  // bool can(String action) => hasPermission(
  //     type: collectionsController.collectionDetails.value!.collection.type,
  //     role: collectionsController.currentUser?.role,
  //     action: action);

  bool can(String action) {
    final details = collectionsController.collectionDetails.value;
    final role = collectionsController.currentUser?.role;
    bool status =
        collectionsController.collectionDetails.value?.collection.status ==
            "CLOSED";

    if (details == null || role == null) return false;

    return hasPermission(
        type: details.collection.type,
        role: role,
        action: action,
        status: status);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                // ── ALERT CARD
                _alertCard(context),
                const SizedBox(height: 8),

                // ── ACCESS PERMISSIONS

                // ── SETTINGS GROUP
                _buildSectionLabel("Actions"),
                const SizedBox(height: 8),
                if (can("rename"))
                  _settingsTile(context,
                      icon: Icons.edit_outlined,
                      title: "Rename Collection",
                      subtitle: "Change display name",
                      onTap: () => _showRenameDialog(context)),
                if (can("personLimit"))
                  _settingsTile(context,
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Person Limit",
                      subtitle: "Set spending limits",
                      onTap: () => _showLimitDialog(
                          context, collectionsController.currentUser)),
                if (can("duration"))
                  _settingsTile(context,
                      icon: Icons.access_time_outlined,
                      title: "Edit Duration Range",
                      subtitle: "Adjust active period",
                      onTap: () => _showDurationPopup(context)),

                if (can("export"))
                  _settingsTile(context,
                      icon: Icons.file_upload_outlined,
                      title: "Export Transactions",
                      subtitle: "Download as PDF",
                      onTap: () => _exportTransactions(context)),

                if (can("accessPermission")) ...[
                  AccessPermissionsWidget(),
                  const SizedBox(height: 8),
                ],

                // ── DANGER GROUP
                if (can("close") || can("delete") || can("exit")) ...[
                  const SizedBox(height: 8),
                  _buildSectionLabel("Danger Zone"),
                  const SizedBox(height: 8),
                ],
                if (can("close"))
                  _dangerTile(context,
                      icon: Icons.cancel_outlined,
                      title: "Close Collection",
                      subtitle: "Stop new transactions",
                      onTap: () => _confirmClose(context)),
                if (can("reopen"))
                  _dangerTile(context,
                      icon: Icons.delete_outline_rounded,
                      title: "Reopen Collection",
                      subtitle: "Permanently Get Back all data",
                      onTap: () => _confirmReopen(context)),

                if (can("delete"))
                  _dangerTile(context,
                      icon: Icons.delete_outline_rounded,
                      title: "Delete Collection",
                      subtitle: "Permanently remove all data",
                      onTap: () => _confirmDelete(context, "delete")),
                if (can("exit"))
                  _dangerTile(context,
                      icon: Icons.logout_rounded,
                      title: "Exit Collection",
                      subtitle: "Leave this collection",
                      onTap: () => _confirmDelete(context, "exit")),

                getOwner(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getOwner() {
    final CollectionDetailsModel? details =
        collectionsController.collectionDetails.value;

    if (details == null) return const SizedBox.shrink();

    final bool isShared = details.collection.type == "SHARED";
    final bool hasMembers = details.members.isNotEmpty;

    final String? ownerName = isShared && hasMembers
        ? details.members
            .firstWhereOrNull((m) => m.userId == details.collection.ownerId)
            ?.name
        : null;

    String? name = ownerName == collectionsController.currentUser?.name
        ? "You"
        : ownerName;

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: textStyle(
          text: name == null ? "" : "Collection Created by $name",
          context: context,
          fontsize: 11,
          fontWeight: FontWeight.w300,
          c: _T.red,
        ),
      ),
    );
  }

  // ─────────────────────── DRAG HANDLE ───────────────────────
  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── HEADER ───────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: _T.bg,
        border: Border(bottom: BorderSide(color: _T.border.withOpacity(0.6))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _T.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _T.border),
              ),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: _T.textDark),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Collection Settings",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 16,
                    lWeight: FontWeight.w700,
                    color: _T.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Manage your collection",
                  style: TextStyle(fontSize: 12, color: _T.textLight),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _T.navyBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.settings_outlined, size: 18, color: _T.navy),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── SECTION LABEL ───────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _T.textLight,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ─────────────────────── ALERT CARD ───────────────────────
  Widget _alertCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _alertEnabled ? _T.navy.withOpacity(0.25) : _T.border,
          width: _alertEnabled ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _alertEnabled ? _T.navy : _T.navyBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 19,
                    color: _alertEnabled ? Colors.white : _T.navy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Amount Alert",
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 14,
                          lWeight: FontWeight.w600,
                          color: _T.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _alertEnabled
                            ? "Notifying when threshold is reached"
                            : "Get notified when a transaction exceeds limit",
                        style: TextStyle(
                            fontSize: 12, color: _T.textMid, height: 1.3),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _alertEnabled,
                  activeColor: _T.navy,
                  onChanged: (v) {
                    setState(() => _alertEnabled = v);
                    v ? _expandAnim.forward() : _expandAnim.reverse();
                  },
                ),
              ],
            ),
            // ── Expandable Input
            SizeTransition(
              sizeFactor: _expandFade,
              child: FadeTransition(
                opacity: _expandFade,
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _T.bg,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: _T.navy.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _T.navyBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                "₹",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _T.navy,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _alertAmountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: const TextStyle(
                                fontSize: 14,
                                color: _T.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter threshold amount",
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w400,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── SETTINGS TILE ───────────────────────
  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _T.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _T.navyBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: _T.navy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 14,
                        lWeight: FontWeight.w600,
                        color: _T.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: _T.textMid),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _T.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.chevron_right_rounded,
                    size: 18, color: _T.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────── DANGER TILE ───────────────────────
  Widget _dangerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _T.redBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _T.redBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: Colors.red.shade600),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 14,
                        lWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          TextStyle(fontSize: 12, color: Colors.red.shade400),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.chevron_right_rounded,
                    size: 18, color: Colors.red.shade300),
              ),
            ],
          ),
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
      builder: (_context) => _StyledDialog(
        title: "Rename Collection",
        icon: Icons.edit_outlined,
        iconColor: _T.navy,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter a new name for this collection.",
              style: TextStyle(fontSize: 13, color: _T.textMid, height: 1.5),
            ),
            const SizedBox(height: 14),
            _StyledTextField(
              controller: ctrl,
              hintText: "Collection name",
              prefixIcon: Icons.label_outline_rounded,
            ),
          ],
        ),
        confirmLabel: "Save Changes",
        confirmColor: _T.navy,
        onConfirm: () async {
          final name = ctrl.text.trim();
          if (name.isEmpty) return;
          await collectionsController.updateCollection(
            id: collectionsController.selectedCollection.value!.id,
            context: context,
            name: name,
          );
          Navigator.pop(_context);
        },
      ),
    );
  }

  // ─────────────────────── CLOSE ───────────────────────
  void _confirmClose(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_CONTEXT) => _StyledDialog(
        title: "Close Collection",
        icon: Icons.cancel_outlined,
        iconColor: Colors.orange,
        content: Text(
          "Are you sure you want to close this collection? You won't be able to add new transactions.",
          style: TextStyle(fontSize: 13, color: _T.textMid, height: 1.5),
        ),
        confirmLabel: "Close Collection",
        confirmColor: Colors.orange,
        onConfirm: () async {
          AppNavigator.pop(_CONTEXT);
          await collectionsController.closeCollection(
            collectionsController.selectedCollection.value!.id,
            context,
          );
        },
      ),
    );
  }

  // ─────────────────────── DELETE ───────────────────────
  void _confirmDelete(BuildContext context, String type) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_context) => _StyledDialog(
        title: type == "exit" ? "Exit Collection" : "Delete Collection",
        icon: type == "exit"
            ? Icons.logout_rounded
            : Icons.delete_outline_rounded,
        iconColor: Colors.red,
        content: Text(
          type == "delete"
              ? "This action cannot be undone. All data in this collection will be permanently deleted."
              : "Are you sure you want to exit this collection? You will lose access to all transactions and details.",
          style: TextStyle(fontSize: 13, color: _T.textMid, height: 1.5),
        ),
        confirmLabel: type == "delete" ? "Delete" : "Exit Collection",
        confirmColor: Colors.red,
        onConfirm: () async {
          AppNavigator.pop(_context);
          await collectionsController.deleteCollection(
              collectionsController.selectedCollection.value!.id,
              context,
              type);
        },
      ),
    );
  }

  Widget _durationChip(String label, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Obx(() => chipCollection(
            label,
            context,
            isSelected: selectedDuration.value == label,
          )),
    );
  }

  void _confirmReopen(BuildContext context) {
    selectedDuration.value = collectionDraft.duration ?? "";

    void select(String value) {
      selectedDuration.value = value;
      collectionDraft.duration = value;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_context) => Obx(() => _StyledDialog(
            title: "Reopen Collection",
            icon: Icons.refresh,
            iconColor: Colors.green,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Are you sure you want to reopen this collection?",
                  style:
                      TextStyle(fontSize: 13, color: _T.textMid, height: 1.5),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
                  child: Column(
                    children: [
                      _durationChip("Until I change", select),
                      _durationChip("3 Months", select),
                      _durationChip("6 Months", select),
                      _durationChip("1 Year", select),
                    ],
                  ),
                ),
              ],
            ),

            // 🔥 Disable button visually (if your dialog supports it)
            confirmLabel: "Reopen",
            confirmColor:
                selectedDuration.value.isEmpty ? Colors.grey : Colors.green,

            onConfirm: () async {
              if (selectedDuration.value.isEmpty) {
                snackBarCalled(context, "Please select a duration to reopen.");
                return;
              }

              AppNavigator.pop(_context);

              await collectionsController.updateCollection(
                  id: collectionsController.selectedCollection.value!.id,
                  active: true,
                  duration: selectedDuration.value,
                  context: context);
            },
          )),
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
          color: _T.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _T.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _T.border),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: _T.textDark),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Edit Duration Range",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _T.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: StepSelectDuration(
                onNext: () async {
                  await collectionsController.updateCollection(
                      id: collectionsController.selectedCollection.value!.id,
                      duration: collectionDraft.duration,
                      context: context);
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
      collectionsController.collectionDetails.value!,
      collectionsController.splitsList,
      collectionsController.balancesListPay,
      collectionsController.balancesListReceive,
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

class _StyledDialogState extends State<_StyledDialog>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon + Title + Close
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 11),
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _T.textDark,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 16, color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Divider(color: Colors.grey.shade100, height: 24),
              // ── Content
              widget.content,
              const SizedBox(height: 24),
              // ── Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: _T.textDark,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        color: _T.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _T.navy.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autofocus: true,
        style: const TextStyle(
          fontSize: 14,
          color: _T.textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _T.navyBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(prefixIcon, size: 15, color: _T.navy),
          ),
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

List<Map<String, dynamic>> buildInviteList(List<Map<String, dynamic>> members) {
  return members.map((m) {
    return {
      "friendId": m["id"],
      "role": (m["role"] ?? "VIEW").toString().toUpperCase(),
    };
  }).toList();
}

void _showLimitDialog(
  BuildContext context,
  MemberModel? member,
) {
  final ctrl = TextEditingController(
    text: member?.setAmount.toString(),
  );
  final collectionsController = Get.find<CollectionsController>();

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_context) => _StyledDialog(
      title: "Set Amount Limit",
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFF2D2B5B),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Set the maximum spending limit for this member.",
            style: TextStyle(fontSize: 13, color: _T.textMid, height: 1.5),
          ),
          const SizedBox(height: 14),
          _StyledTextField(
            controller: ctrl,
            hintText: "Enter amount",
            prefixIcon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      confirmLabel: "Save Limit",
      confirmColor: const Color(0xFF2D2B5B),
      onConfirm: () async {
        final value = ctrl.text.trim();
        if (value.isEmpty) return;
        final collectionId =
            collectionsController.collectionDetails.value!.collection.id;
        await collectionsController.updateMemberRole(
          collectionId: collectionId,
          userId: member?.userId ?? "",
          body: {
            "limitAmount": double.tryParse(value) ?? 0,
          },
        );
        Navigator.pop(_context);
      },
    ),
  );
}
