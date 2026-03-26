// ─── screens/split_confirmation_screen.dart ──────────────────────────────────
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class SplitConfirmationScreen extends StatelessWidget {
  final List<Transaction> selectedTransactions;
  final List<SplitEntry> splitEntries;
  final double totalAmount;

  const SplitConfirmationScreen({
    super.key,
    required this.selectedTransactions,
    required this.splitEntries,
    required this.totalAmount,
  });

  void _confirmSplit(BuildContext context) {
    // Print the split result (replace with actual API call)
    debugPrint('=== SPLIT RESULT ===');
    debugPrint(
        'Transactions: ${selectedTransactions.map((t) => t.id).join(', ')}');
    debugPrint('Total Amount: $totalAmount');
    for (final entry in splitEntries) {
      debugPrint(
          '  ${entry.member.name} => ₹${entry.amount.toStringAsFixed(2)}');
    }
    debugPrint('===================');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_outline,
                color: AppColors.successGreen, size: 28),
            SizedBox(width: 10),
            Text('Split Confirmed!', style: AppTextStyles.heading3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Split of ₹${totalAmount.toStringAsFixed(2)} confirmed among ${splitEntries.length} members.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...splitEntries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    MemberAvatar(member: e.member, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child:
                          Text(e.member.name, style: AppTextStyles.labelBold),
                    ),
                    Text(
                      '₹${e.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.amountMedium.copyWith(
                        fontSize: 15,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
        child: Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*1.5,
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
                      const Text('Total Amount',
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        '₹${totalAmount.toStringAsFixed(2)}',
                        style: AppTextStyles.amountLarge,
                      ),
                      const Divider(height: 24, color: AppColors.divider),
                      Text(
                        '${selectedTransactions.length} Transaction${selectedTransactions.length > 1 ? 's' : ''} • ${splitEntries.length} Members',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Transactions included
                const Text('Included Transactions',
                    style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                ...selectedTransactions.map(
                  (tx) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
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
                ...splitEntries.map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        MemberAvatar(member: e.member),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(e.member.name,
                              style: AppTextStyles.labelBold),
                        ),
                        Text(
                          '₹${e.amount.toStringAsFixed(2)}',
                          style: AppTextStyles.amountMedium.copyWith(
                              color: AppColors.primaryBlue, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Confirm button
                PrimaryButton(
                  label: 'Confirm Split',
                  onPressed: () => _confirmSplit(context),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Go Back & Edit',
                  isOutlined: true,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
