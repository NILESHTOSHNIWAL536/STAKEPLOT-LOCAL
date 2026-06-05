import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_padding_sizes.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/salary_income_model.dart';
import 'package:flutter_application_code_stakeplot/repository/salary_income_repository.dart';

class SalaryIncomeScreen extends StatefulWidget {
  const SalaryIncomeScreen({super.key});

  @override
  State<SalaryIncomeScreen> createState() => _SalaryIncomeScreenState();
}

class _SalaryIncomeScreenState extends State<SalaryIncomeScreen> {
  bool isLoading = true;
  bool isRefreshing = false;
  List<SalaryIncomeSource> suggestions = [];
  List<SalaryIncomeSource> accounts = [];

  @override
  void initState() {
    super.initState();
    _loadSalaryIncome();
  }

  Future<void> _loadSalaryIncome() async {
    setState(() {
      isLoading = suggestions.isEmpty && accounts.isEmpty;
      isRefreshing = suggestions.isNotEmpty || accounts.isNotEmpty;
    });

    final results = await Future.wait([
      getSalarySuggestions(),
      getConfirmedSalaryAccounts(),
    ]);

    if (!mounted) return;
    setState(() {
      suggestions = results[0];
      accounts = results[1];
      isLoading = false;
      isRefreshing = false;
    });
  }

  Future<void> _confirm(SalaryIncomeSource source) async {
    final success = await confirmSalaryIncome(source.id);
    if (!mounted) return;
    snackBarCalled(
      context,
      success ? "Salary source confirmed" : "Could not confirm salary source",
    );
    if (success) await _loadSalaryIncome();
  }

  Future<void> _ignore(SalaryIncomeSource source) async {
    final success = await ignoreSalaryIncome(source.id);
    if (!mounted) return;
    snackBarCalled(
      context,
      success ? "Suggestion ignored" : "Could not ignore suggestion",
    );
    if (success) await _loadSalaryIncome();
  }

  Future<void> _delete(SalaryIncomeSource source) async {
    final success = await deleteSalaryIncome(source.id);
    if (!mounted) return;
    snackBarCalled(
      context,
      success ? "Salary source deleted" : "Could not delete salary source",
    );
    if (success) await _loadSalaryIncome();
  }

  Future<void> _recalculate() async {
    setState(() => isRefreshing = true);
    await recalculateSalaryIncome();
    await _loadSalaryIncome();
  }

  Future<void> _edit(SalaryIncomeSource source) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _SalaryEditSheet(source: source),
    );
    if (changed == true) await _loadSalaryIncome();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.appBarBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: colors.onBackground, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Salary income",
            style: FontManager().getTextStyle(
              context,
              fontSize: 18,
              lWeight: FontWeight.w700,
              color: colors.onBackground,
            ),
          ),
          actions: [
            IconButton(
              tooltip: "Recalculate",
              onPressed: _recalculate,
              icon: Icon(Icons.sync, color: colors.primary, size: 24),
            ),
          ],
          bottom: TabBar(
            labelColor: colors.primary,
            unselectedLabelColor: colors.secondaryText,
            indicatorColor: colors.primary,
            tabs: [
              Tab(child: Text("Suggestions (${suggestions.length})")),
              Tab(child: Text("Confirmed (${accounts.length})")),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator(color: colors.primary))
            : Stack(
                children: [
                  TabBarView(
                    children: [
                      _SalaryIncomeList(
                        items: suggestions,
                        emptyTitle: "No salary suggestions yet",
                        emptySubtitle:
                            "Recurring credit transactions from the last 6 months will appear here.",
                        onRefresh: _loadSalaryIncome,
                        onConfirm: _confirm,
                        onEdit: _edit,
                        onDelete: _delete,
                        onIgnore: _ignore,
                        showConfirm: true,
                      ),
                      _SalaryIncomeList(
                        items: accounts,
                        emptyTitle: "No confirmed salary accounts",
                        emptySubtitle:
                            "Confirm a detected income source to track salary history and next expected credit date.",
                        onRefresh: _loadSalaryIncome,
                        onConfirm: _confirm,
                        onEdit: _edit,
                        onDelete: _delete,
                        onIgnore: _ignore,
                        showConfirm: false,
                      ),
                    ],
                  ),
                  if (isRefreshing)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        color: colors.primary,
                        backgroundColor: colors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _SalaryIncomeList extends StatelessWidget {
  final List<SalaryIncomeSource> items;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final Future<void> Function(SalaryIncomeSource source) onConfirm;
  final Future<void> Function(SalaryIncomeSource source) onEdit;
  final Future<void> Function(SalaryIncomeSource source) onDelete;
  final Future<void> Function(SalaryIncomeSource source) onIgnore;
  final bool showConfirm;

  const _SalaryIncomeList({
    required this.items,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.onConfirm,
    required this.onEdit,
    required this.onDelete,
    required this.onIgnore,
    required this.showConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (items.isEmpty) {
      return RefreshIndicator(
        color: colors.primary,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.p20),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
            Icon(Icons.payments_outlined, color: colors.primary, size: 44),
            const SizedBox(height: 14),
            Text(
              emptyTitle,
              textAlign: TextAlign.center,
              style: FontManager().getTextStyle(
                context,
                fontSize: 17,
                lWeight: FontWeight.w700,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              textAlign: TextAlign.center,
              style: FontManager().getTextStyle(
                context,
                fontSize: 13,
                lWeight: FontWeight.w500,
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.p14),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final source = items[index];
          return _SalaryIncomeTile(
            source: source,
            showConfirm: showConfirm,
            onConfirm: () => onConfirm(source),
            onEdit: () => onEdit(source),
            onDelete: () => onDelete(source),
            onIgnore: () => onIgnore(source),
            onViewTransactions: () => _showTransactions(context, source),
          );
        },
      ),
    );
  }

  void _showTransactions(BuildContext context, SalaryIncomeSource source) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _SalaryTransactionsSheet(source: source),
    );
  }
}

class _SalaryIncomeTile extends StatelessWidget {
  final SalaryIncomeSource source;
  final bool showConfirm;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onIgnore;
  final VoidCallback onViewTransactions;

  const _SalaryIncomeTile({
    required this.source,
    required this.showConfirm,
    required this.onConfirm,
    required this.onEdit,
    required this.onDelete,
    required this.onIgnore,
    required this.onViewTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.p14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.onBackground.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.credit.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance_wallet_outlined,
                    color: colors.credit, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      source.sourceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 15,
                        lWeight: FontWeight.w800,
                        color: colors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Next expected: ${source.nextExpectedText}",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 12,
                        lWeight: FontWeight.w600,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                source.predictedAmountText,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  lWeight: FontWeight.w800,
                  color: colors.credit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _InfoChip(
                text: "${source.confidenceText} confidence",
                icon: Icons.verified_outlined,
              ),
              _InfoChip(
                text: "Avg ${source.averageMonthlyIncomeText}",
                icon: Icons.trending_up,
              ),
              _InfoChip(
                text: "Last ${source.lastCreditedText}",
                icon: Icons.event_available,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewTransactions,
                  icon: const Icon(Icons.receipt_long, size: 17),
                  label: const Text("Transactions"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: "Edit",
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: colors.primary),
              ),
              IconButton(
                tooltip: showConfirm ? "Ignore" : "Delete",
                onPressed: showConfirm ? onIgnore : onDelete,
                icon: Icon(
                  showConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.delete_outline,
                  color: colors.error,
                ),
              ),
              if (showConfirm)
                IconButton(
                  tooltip: "Confirm",
                  onPressed: onConfirm,
                  icon: Icon(Icons.check_circle, color: colors.credit),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalaryEditSheet extends StatefulWidget {
  final SalaryIncomeSource source;

  const _SalaryEditSheet({required this.source});

  @override
  State<_SalaryEditSheet> createState() => _SalaryEditSheetState();
}

class _SalaryEditSheetState extends State<_SalaryEditSheet> {
  late final TextEditingController sourceController;
  late final TextEditingController amountController;
  late final TextEditingController dayController;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    sourceController = TextEditingController(text: widget.source.sourceName);
    amountController = TextEditingController(
      text: widget.source.predictedAmount.toStringAsFixed(0),
    );
    dayController =
        TextEditingController(text: widget.source.expectedCreditDay.toString());
  }

  @override
  void dispose() {
    sourceController.dispose();
    amountController.dispose();
    dayController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(amountController.text.trim());
    final day = int.tryParse(dayController.text.trim());
    setState(() => saving = true);
    final success = await updateSalaryIncome(widget.source.id, {
      'sourceName': sourceController.text.trim(),
      if (amount != null) 'predictedAmount': amount,
      if (day != null) 'expectedCreditDay': day.clamp(1, 31),
    });
    if (!mounted) return;
    Navigator.pop(context, success);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, bottomInset + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Text(
              "Edit salary source",
              style: FontManager().getTextStyle(
                context,
                fontSize: 18,
                lWeight: FontWeight.w800,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 14),
            _EditField(label: "Source name", controller: sourceController),
            const SizedBox(height: 10),
            _EditField(
              label: "Predicted amount",
              controller: amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _EditField(
              label: "Expected credit day",
              controller: dayController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _EditField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.onBackground),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.secondaryText),
        filled: true,
        fillColor: colors.inputBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }
}

class _SalaryTransactionsSheet extends StatelessWidget {
  final SalaryIncomeSource source;

  const _SalaryTransactionsSheet({required this.source});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final height = MediaQuery.sizeOf(context).height * 0.72;
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 14),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      source.sourceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 18,
                        lWeight: FontWeight.w800,
                        color: colors.onBackground,
                      ),
                    ),
                  ),
                  Text(
                    source.rangeText,
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 13,
                      lWeight: FontWeight.w800,
                      color: colors.credit,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Text(
                "${source.transactions.length} credits matched",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 12,
                  lWeight: FontWeight.w600,
                  color: colors.secondaryText,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: source.transactions.length,
                separatorBuilder: (_, __) => Divider(color: colors.border),
                itemBuilder: (context, index) {
                  final transaction = source.transactions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.credit.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.south_west,
                          color: colors.credit, size: 20),
                    ),
                    title: Text(
                      transaction.narration,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 14,
                        lWeight: FontWeight.w700,
                        color: colors.onBackground,
                      ),
                    ),
                    subtitle: Text(
                      [transaction.date, transaction.mode]
                          .where((item) => item.isNotEmpty)
                          .join(" - "),
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 12,
                        lWeight: FontWeight.w500,
                        color: colors.secondaryText,
                      ),
                    ),
                    trailing: Text(
                      transaction.amount,
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 13,
                        lWeight: FontWeight.w800,
                        color: colors.credit,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _InfoChip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.secondaryText),
          const SizedBox(width: 4),
          Text(
            text,
            style: FontManager().getTextStyle(
              context,
              fontSize: 11,
              lWeight: FontWeight.w600,
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
