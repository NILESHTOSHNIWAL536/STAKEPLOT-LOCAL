// ─── screens/split_confirmation_screen.dart ──────────────────────────────────
import 'package:flutter/material.dart';
import '../../../../../backed_connections/apis_connect.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class SplitConfirmationScreen extends StatefulWidget {
  final List<Transaction> selectedTransactions;
  final List<SplitEntry> splitEntries;
  final double totalAmount;

  const SplitConfirmationScreen({
    super.key,
    required this.selectedTransactions,
    required this.splitEntries,
    required this.totalAmount,
  });

  @override
  State<SplitConfirmationScreen> createState() =>
      _SplitConfirmationScreenState();
}

class _SplitConfirmationScreenState extends State<SplitConfirmationScreen> {
  bool _isSubmitting = false;

  Future<void> _confirmSplit(BuildContext context) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final List<Map<String, dynamic>> members = widget.splitEntries.map((e) {
      return {
        "userId": e.member.userId,
        "amount": e.amount,
      };
    }).toList();

    final collectionId =
        collectionsController.collectionDetails.value!.collection.id;
    final transactionIds =
        List<String>.from(collectionsController.selectedTransactions);

    await collectionsController.addTransaction(
        collectionId: collectionId,
        splitType: "CUSTOM",
        transactionIds: transactionIds,
        customSplits: members,
        context: context,
        clearn: true);

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.textPrimary),
          ),
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.all(8),
        ),
        title: const Text('Confirm Split', style: AppTextStyles.heading3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Amount', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    '₹${widget.totalAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.amountLarge,
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  Text(
                    '${widget.selectedTransactions.length} Transaction${widget.selectedTransactions.length > 1 ? 's' : ''} • ${widget.splitEntries.length} Members',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Transactions included
            const Text('Included Transactions', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            ...widget.selectedTransactions.map(
              (tx) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.title, style: AppTextStyles.labelBold),
                          Text(tx.date, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      '-₹${tx.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Split breakdown
            const Text('Split Breakdown', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            ...widget.splitEntries.map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    MemberAvatar(member: e.member),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          Text(e.member.name, style: AppTextStyles.labelBold),
                    ),
                    Text(
                      '₹${e.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.amountMedium
                          .copyWith(color: AppColors.primaryBlue, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Confirm button
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    label: 'Confirm Split',
                    onPressed: () => _confirmSplit(context),
                  ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Go Back & Edit',
              isOutlined: true,
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
