import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:flutter_application_code_stakeplot/repository/autopay_repository.dart';

import '../../Constants/core/app_padding_sizes.dart';

class AutoPayDetectionScreen extends StatefulWidget {
  const AutoPayDetectionScreen({super.key});

  @override
  State<AutoPayDetectionScreen> createState() => _AutoPayDetectionScreenState();
}

class _AutoPayDetectionScreenState extends State<AutoPayDetectionScreen> {
  bool isLoading = true;
  bool isRefreshing = false;
  List<CardData> cards = [];

  @override
  void initState() {
    super.initState();
    _loadAutoPays();
  }

  Future<void> _loadAutoPays() async {
    if (allAutoPayData.isNotEmpty && cards.isEmpty) {
      setState(() {
        cards = List<CardData>.from(allAutoPayData);
        isLoading = false;
        isRefreshing = true;
      });
    } else {
      setState(() {
        isLoading = cards.isEmpty;
        isRefreshing = cards.isNotEmpty;
      });
    }
    final data = await getAutoPayInfo(flag: false);
    if (!mounted) return;
    setState(() {
      cards = List<CardData>.from(data);
      isLoading = false;
      isRefreshing = false;
    });
  }

  Future<void> _openManualPicker() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionHistoryScreen(fromAutoPay: true),
      ),
    );
    if (created == true) {
      await _loadAutoPays();
    }
  }

  Future<void> _addAutoPay(CardData card) async {
    final success = card.frequency.toLowerCase() == 'daily'
        ? await addRecurringPaymentForDaily(card.id, true)
        : await addRecurringPayment(card.id, true);

    if (!mounted) return;
    snackBarCalled(
      context,
      success ? "Added to recurring payments" : "Failed to add autopay",
    );
    if (success) await _loadAutoPays();
  }

  Future<void> _removeAutoPay(CardData card) async {
    final success = await ignoreRecurringPayment(card.id);

    if (!mounted) return;
    snackBarCalled(
      context,
      success ? "Removed from autopays" : "Failed to remove autopay",
    );
    if (success) await _loadAutoPays();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final detected = cards
        .where((card) => !card.isUserDefined && !card.isActive && !card.isDaily)
        .toList();
    final added = cards
        .where((card) => card.isUserDefined || card.isActive || card.isDaily)
        .toList();

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
            "Autopay",
            style: FontManager().getTextStyle(
              context,
              fontSize: 18,
              lWeight: FontWeight.w700,
              color: colors.onBackground,
            ),
          ),
          actions: [
            IconButton(
              tooltip: "Add from transaction",
              onPressed: _openManualPicker,
              icon: Icon(Icons.add, color: colors.primary, size: 26),
            ),
          ],
          bottom: TabBar(
            labelColor: colors.primary,
            unselectedLabelColor: colors.secondaryText,
            indicatorColor: colors.primary,
            tabs: [
              Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Suggestions (${detected.length})"),
                ),
              ),
              Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("My Autopays (${added.length})"),
                ),
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(color: colors.primary),
              )
            : Stack(
                children: [
                  TabBarView(
                    children: [
                      _AutoPayList(
                        cards: detected,
                        emptyTitle: "No suggestions yet",
                        emptySubtitle:
                            "When 3 or more rent, wifi, bill, or subscription payments repeat, they will show here.",
                        onAdd: _addAutoPay,
                        onRemove: _removeAutoPay,
                        onRefresh: _loadAutoPays,
                        showAdd: true,
                      ),
                      _AutoPayList(
                        cards: added,
                        emptyTitle: "No autopays added",
                        emptySubtitle:
                            "Tap + to add one from your transactions, or add a suggestion.",
                        onAdd: _addAutoPay,
                        onRemove: _removeAutoPay,
                        onRefresh: _loadAutoPays,
                        showAdd: false,
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

class _AutoPayList extends StatelessWidget {
  final List<CardData> cards;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function(CardData card) onAdd;
  final Future<void> Function(CardData card) onRemove;
  final Future<void> Function() onRefresh;
  final bool showAdd;

  const _AutoPayList({
    required this.cards,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onAdd,
    required this.onRemove,
    required this.onRefresh,
    required this.showAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (cards.isEmpty) {
      return RefreshIndicator(
        color: colors.primary,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.p20),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
            Icon(Icons.repeat, color: colors.primary, size: 44),
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
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final card = cards[index];
          return _AutoPayDetectedTile(
            card: card,
            showAdd: showAdd,
            onAdd: () => onAdd(card),
            onRemove: () => onRemove(card),
            onTap: () => _showAutoPayTransactions(context, card),
          );
        },
      ),
    );
  }

  void _showAutoPayTransactions(BuildContext context, CardData card) {
    final colors = context.appColors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _AutoPayTransactionsSheet(card: card),
    );
  }
}

class _AutoPayDetectedTile extends StatelessWidget {
  final CardData card;
  final bool showAdd;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _AutoPayDetectedTile({
    required this.card,
    required this.showAdd,
    required this.onAdd,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final confidence = card.confidenceLabel.isEmpty
        ? "pattern"
        : card.confidenceLabel.toLowerCase();
    final occurrenceText = "${card.occurrencesCount}";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.autorenew, color: colors.primary, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 15,
                            lWeight: FontWeight.w700,
                            color: colors.onBackground,
                          ),
                        ),
                      ),
                      Text(
                        card.amount,
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 14,
                          lWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _InfoChip(text: card.frequency, icon: Icons.event_repeat),
                      _InfoChip(
                          text: "$occurrenceText times", icon: Icons.history),
                      _InfoChip(
                          text: confidence, icon: Icons.verified_outlined),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.narration.isEmpty
                        ? "Last paid on ${card.date}"
                        : card.narration,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 12,
                      lWeight: FontWeight.w500,
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            showAdd
                ? InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  )
                : InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 21,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _AutoPayTransactionsSheet extends StatelessWidget {
  final CardData card;

  const _AutoPayTransactionsSheet({required this.card});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final transactions = card.transactions;
    final fallbackDates = card.occuranceDate;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 18,
                            lWeight: FontWeight.w800,
                            color: colors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${card.occurrencesCount} transactions • ${card.frequency}",
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
                    card.amount,
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 16,
                      lWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: transactions.isNotEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.p16,
                        0,
                        AppSizes.p16,
                        AppSizes.p16,
                      ),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: colors.border,
                      ),
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _AutoPayTransactionRow(transaction: transaction);
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.p16,
                        0,
                        AppSizes.p16,
                        AppSizes.p16,
                      ),
                      itemCount: fallbackDates.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: colors.border,
                      ),
                      itemBuilder: (context, index) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.history,
                          color: colors.primary,
                          size: 22,
                        ),
                        title: Text(
                          "Occurrence ${index + 1}",
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 14,
                            lWeight: FontWeight.w700,
                            color: colors.onBackground,
                          ),
                        ),
                        subtitle: Text(
                          fallbackDates[index],
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 12,
                            lWeight: FontWeight.w500,
                            color: colors.secondaryText,
                          ),
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

class _AutoPayTransactionRow extends StatelessWidget {
  final AutoPayTransactionData transaction;

  const _AutoPayTransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = [
      if (transaction.date.isNotEmpty) transaction.date,
      if (transaction.mode.isNotEmpty) transaction.mode,
    ].join(" • ");

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.receipt_long, color: colors.primary, size: 20),
      ),
      title: Text(
        transaction.narration.isEmpty
            ? transaction.title
            : transaction.narration,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: FontManager().getTextStyle(
          context,
          fontSize: 14,
          lWeight: FontWeight.w700,
          color: colors.onBackground,
        ),
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
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
          color: colors.primary,
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
