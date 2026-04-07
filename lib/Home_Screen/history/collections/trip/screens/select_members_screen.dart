// ─── screens/select_members_screen.dart ──────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import '../../../../../model/collections_model.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'split_amount_screen.dart';

class SelectMembersScreen extends StatefulWidget {
  final List<Transaction> selectedTransactions;
  final double totalAmount;

  const SelectMembersScreen({
    super.key,
    required this.selectedTransactions,
    required this.totalAmount,
  });

  @override
  State<SelectMembersScreen> createState() => _SelectMembersScreenState();
}

class _SelectMembersScreenState extends State<SelectMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final Set<String> _selectedMemberIds = {};

  List<MemberModel> get _filtered =>
      collectionsController.collectionDetails.value!.members
          .where((m) => m.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  void _toggleMember(String id) {
    setState(() {
      if (_selectedMemberIds.contains(id)) {
        _selectedMemberIds.remove(id);
      } else {
        _selectedMemberIds.add(id);
      }
    });
  }

  void _proceedToSplit() {
    List<MemberModel> selectedMembers = [];

    final members =
        collectionsController.collectionDetails.value?.members ?? [];

    selectedMembers = members
        .where((e) => _selectedMemberIds.contains(e.id))
        .map(
          (e) => MemberModel(
            collectionId: e.collectionId,
            id: e.id,
            name: e.name,
            role: e.role,
            userId: e.userId,
            setAmount: e.setAmount,
            amountSpend: e.amountSpend,
          ),
        )
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SplitAmountScreen(
          selectedTransactions: widget.selectedTransactions,
          selectedMembers: selectedMembers,
          totalAmount: widget.totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_downward,
                size: 18, color: AppColors.textPrimary),
          ),
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.all(8),
        ),
        title: Text(
          '${_selectedMemberIds.length} Selected People',
          style: AppTextStyles.heading3,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.space_dashboard_outlined,
                  size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'search Transactions',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textLight, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Total amount display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.totalAmount.toStringAsFixed(2),
              style: AppTextStyles.amountLarge,
            ),
          ),

          // Members list
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 60,
                  color: AppColors.divider,
                ),
                itemBuilder: (ctx, i) {
                  final member = filtered[i];
                  final isSelected = _selectedMemberIds.contains(member.id);
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: MemberAvatar(member: member, size: 40),
                    title: Text(member.name, style: AppTextStyles.labelBold),
                    trailing: GestureDetector(
                      onTap: () => _toggleMember(member.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryDark
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : const Icon(Icons.add,
                                size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom action
          if (_selectedMemberIds.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: PrimaryButton(
                  label: 'Split among ${_selectedMemberIds.length} people',
                  onPressed: _proceedToSplit,
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
