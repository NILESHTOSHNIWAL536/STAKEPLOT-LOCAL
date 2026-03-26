// ─── screens/split_amount_screen.dart ────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'split_confirmation_screen.dart';

class SplitAmountScreen extends StatefulWidget {
  final List<Transaction> selectedTransactions;
  final List<TripMember> selectedMembers;
  final double totalAmount;

  const SplitAmountScreen({
    super.key,
    required this.selectedTransactions,
    required this.selectedMembers,
    required this.totalAmount,
  });

  @override
  State<SplitAmountScreen> createState() =>
      _SplitAmountScreenState();
}

class _SplitAmountScreenState extends State<SplitAmountScreen> {
  late List<SplitEntry> _splitEntries;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initEqualSplit();
  }

  void _initEqualSplit() {
    final count = widget.selectedMembers.length;
    final equalShare =
        double.parse((widget.totalAmount / count).toStringAsFixed(2));

    _splitEntries = widget.selectedMembers
        .map((m) => SplitEntry(
              member: m,
              amount: equalShare,
              isManuallyEdited: false,
            ))
        .toList();

    _controllers = _splitEntries
        .map((e) =>
            TextEditingController(text: e.amount.toStringAsFixed(2)))
        .toList();

    // Attach listeners
    for (var i = 0; i < _controllers.length; i++) {
      final idx = i;
      _controllers[idx].addListener(() => _onAmountChanged(idx));
    }
  }

  void _onAmountChanged(int editedIndex) {
    final text = _controllers[editedIndex].text;
    final newVal = double.tryParse(text);
    if (newVal == null) return;

    setState(() {
      _splitEntries[editedIndex].amount = newVal;
      _splitEntries[editedIndex].isManuallyEdited = true;
      _redistributeRemaining();
    });
  }

  void _redistributeRemaining() {
    final manualTotal = _splitEntries
        .where((e) => e.isManuallyEdited)
        .fold(0.0, (s, e) => s + e.amount);

    final nonManual =
        _splitEntries.where((e) => !e.isManuallyEdited).toList();

    if (nonManual.isEmpty) return; // all manually edited, show leftover

    final remaining = widget.totalAmount - manualTotal;
    if (remaining < 0) return;

    final share =
        double.parse((remaining / nonManual.length).toStringAsFixed(2));

    for (var entry in nonManual) {
      final idx = _splitEntries.indexOf(entry);
      entry.amount = share;
      // Update text without triggering listener
      _controllers[idx].removeListener(() => _onAmountChanged(idx));
      _controllers[idx].text = share.toStringAsFixed(2);
      _controllers[idx].addListener(() => _onAmountChanged(idx));
    }
  }

  double get _currentTotal =>
      _splitEntries.fold(0.0, (s, e) => s + e.amount);

  double get _leftover =>
      double.parse(
          (widget.totalAmount - _currentTotal).toStringAsFixed(2));

  bool get _allManual =>
      _splitEntries.every((e) => e.isManuallyEdited);

  bool get _canProceed => _leftover.abs() < 0.01;

  void _settleAndSplit() {
    if (_leftover.abs() < 0.01) {
      _proceedToConfirmation();
      return;
    }
    // Distribute leftover equally
    setState(() {
      final perPerson =
          double.parse((_leftover / _splitEntries.length).toStringAsFixed(2));
      for (var i = 0; i < _splitEntries.length; i++) {
        _splitEntries[i].amount += perPerson;
        _splitEntries[i].isManuallyEdited = true;
        _controllers[i].text =
            _splitEntries[i].amount.toStringAsFixed(2);
      }
    });
    Future.delayed(
        const Duration(milliseconds: 100), _proceedToConfirmation);
  }

  void _proceedToConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SplitConfirmationScreen(
          selectedTransactions: widget.selectedTransactions,
          splitEntries: _splitEntries,
          totalAmount: widget.totalAmount,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leftover = _leftover;
    final hasLeftover = leftover.abs() >= 0.01;
    final allManual = _allManual;

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
          '${widget.selectedMembers.length} Selected People',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Enter Amounts (Total: ${widget.totalAmount.toStringAsFixed(2)})',
                style: AppTextStyles.bodyMedium,
              ),
            ),

            // Warning banner (leftover)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: hasLeftover && allManual
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.leftoverWarning,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE6C84A), width: 1),
                      ),
                      child: const Text(
                        'There is still some amount left over, please split the amount remained.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A5A00),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Split entries
            Expanded(
              child: ListView.separated(
                itemCount: _splitEntries.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final entry = _splitEntries[i];
                  return _SplitEntryRow(
                    entry: entry,
                    controller: _controllers[i],
                    onReset: () {
                      setState(() {
                        entry.isManuallyEdited = false;
                        _redistributeRemaining();
                      });
                    },
                  );
                },
              ),
            ),

            // Current total & leftover
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        'Current Total: ₹ ${_currentTotal.toStringAsFixed(2)}',
                        style: AppTextStyles.labelBold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _canProceed
                          ? const Color(0xFFEBF9F0)
                          : AppColors.leftoverWarning,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _canProceed
                            ? AppColors.successGreen
                            : const Color(0xFFE6C84A),
                      ),
                    ),
                    child: Text(
                      'Leftover: ₹ ${leftover.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _canProceed
                            ? AppColors.successGreen
                            : const Color(0xFFB8860B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Help text
            if (!_canProceed)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    'Click Settle to split leftover amount equally among all',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Buttons
            PrimaryButton(
              label: 'Settle & Split',
              onPressed: _settleAndSplit,
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Split',
              isOutlined: true,
              onPressed: _canProceed ? _proceedToConfirmation : null,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Split Entry Row ───────────────────────────────────────────────────────────
class _SplitEntryRow extends StatelessWidget {
  final SplitEntry entry;
  final TextEditingController controller;
  final VoidCallback onReset;

  const _SplitEntryRow({
    required this.entry,
    required this.controller,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MemberAvatar(member: entry.member),
        const SizedBox(width: 12),
        Expanded(
          child: Text(entry.member.name, style: AppTextStyles.labelBold),
        ),
        if (entry.isManuallyEdited)
          GestureDetector(
            onTap: onReset,
            child: const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(Icons.refresh,
                  size: 16, color: AppColors.textLight),
            ),
          ),
        Container(
          width: 130,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: entry.isManuallyEdited
                  ? AppColors.primaryBlue
                  : AppColors.divider,
              width: entry.isManuallyEdited ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              const Text('₹', style: AppTextStyles.labelBold),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: AppTextStyles.labelBold,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
