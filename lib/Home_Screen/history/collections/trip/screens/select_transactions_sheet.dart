// ─── screens/select_transactions_sheet.dart ──────────────────────────────────
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'select_members_screen.dart';

class SelectTransactionsSheet extends StatefulWidget {
  const SelectTransactionsSheet({super.key});

  @override
  State<SelectTransactionsSheet> createState() =>
      _SelectTransactionsSheetState();
}

class _SelectTransactionsSheetState
    extends State<SelectTransactionsSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late List<Transaction> _transactions;

  @override
  void initState() {
    super.initState();
    // Work on fresh copies so selection state is local
    _transactions = DummyData.transactions
        .map((t) => Transaction(
              id: t.id,
              title: t.title,
              date: t.date,
              amount: t.amount,
              category: t.category,
              addedBy: t.addedBy,
              taggedMemberId: t.taggedMemberId,
              isSelected: false,
            ))
        .toList();
  }

  List<Transaction> get _filtered => _transactions
      .where((t) =>
          t.title.toLowerCase().contains(_query.toLowerCase()) ||
          t.category.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  int get _selectedCount =>
      _transactions.where((t) => t.isSelected).length;

  double get _selectedTotal => _transactions
      .where((t) => t.isSelected)
      .fold(0, (sum, t) => sum + t.amount);

  void _toggleSelect(Transaction tx) {
    setState(() {
      tx.isSelected = !tx.isSelected;
    });
  }

  void _proceedToMembers() {
    final selected =
        _transactions.where((t) => t.isSelected).toList();
    if (selected.isEmpty) return;

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMembersScreen(
          selectedTransactions: selected,
          totalAmount: _selectedTotal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    // Group by month (simplified: all under "June 2025")
    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
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
                    padding: EdgeInsets.zero,
                  ),
                  const Text(
                    'Select Transactions',
                    style: AppTextStyles.heading3,
                  ),
                  GestureDetector(
                    onTap:
                        _selectedCount > 0 ? _proceedToMembers : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedCount > 0
                            ? AppColors.primaryDark
                            : AppColors.tagBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.call_split,
                            size: 16,
                            color: _selectedCount > 0
                                ? Colors.white
                                : AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Split',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _selectedCount > 0
                                  ? Colors.white
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Selection summary bar
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _selectedCount > 0
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primaryDark.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_selectedCount Selected',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Total: ₹${_selectedTotal.toStringAsFixed(2)}',
                            style: AppTextStyles.labelBold.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Group header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('June 2025',
                      style: AppTextStyles.labelBold),
                  Text(
                    '$_selectedCount Selected Transactions',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            // Transaction list
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: filtered.length,
                padding: const EdgeInsets.only(bottom: 20),
                itemBuilder: (ctx, i) {
                  final tx = filtered[i];
                  TripMember? tagged;
                  try {
                    tagged = DummyData.members
                        .firstWhere((m) => m.id == tx.taggedMemberId);
                  } catch (_) {}
                  return TransactionCard(
                    tx: tx,
                    taggedMember: tagged,
                    showCheckbox: true,
                    onTap: () => _toggleSelect(tx),
                  );
                },
              ),
            ),

            // Bottom proceed button
            if (_selectedCount > 0)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: PrimaryButton(
                    label:
                        'Continue with $_selectedCount transaction${_selectedCount > 1 ? 's' : ''}',
                    onPressed: _proceedToMembers,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
