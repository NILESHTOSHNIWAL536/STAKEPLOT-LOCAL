
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Constants/app_styles.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/font_manager.dart';
import '../../../backed_connections/apis_connect.dart';
import '../../../components/shared_utils.dart';
import '../../../controllers/collections_controller.dart';
import '../../../image_service/avatarProfile.dart';
import '../../../model/TransactionModel.dart';
import '../../../model/collections_model.dart';
import '../transactions_ui_component.dart';
import 'collection_setting.dart';
import 'trip/screens/select_transactions_sheet.dart';

// ── Local tokens ─────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF5F3EF);
  static const surface = Colors.white;
  static const navy = Color(0xFF2D2B5B);
  static const navyMid = Color(0xFF4B4D73);
  static const navyBg = Color(0xFFEEEDF8);
  static const border = Color(0xFFEBEBEB);
  static const textDark = Color(0xFF1A1832);
  static const textMid = Color(0xFF6B7280);
  static const textLight = Color(0xFFACACAC);
  static const green = Color(0xFF6FEDB1);
  static const orange = Color(0xFFFF8C69);
}

class CollectionSummarySection extends StatefulWidget {
  const CollectionSummarySection({super.key});

  @override
  State<CollectionSummarySection> createState() =>
      _CollectionSummarySectionState();
}

class _CollectionSummarySectionState extends State<CollectionSummarySection> {
  final controller = collectionsController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filtered(List<TransactionModel> transactions) {
    if (_searchQuery.isEmpty) return transactions;
    return transactions.where((tx) {
      final name = (tx.narration).toString().toLowerCase();
      final category = (tx.category).toString().toLowerCase();
      final amount = (tx.amount).toString().toLowerCase();
      final date = (tx.transactionTimestamp).toString().toLowerCase();
      return name.contains(_searchQuery) ||
          category.contains(_searchQuery) ||
          amount.contains(_searchQuery) ||
          date.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.collectionDetails.value;

      if (data == null) {
        return const SafeArea(
          child: Scaffold(
            backgroundColor: _C.bg,
            body: Center(
              child: CircularProgressIndicator(
                color: _C.navy,
                strokeWidth: 2.5,
              ),
            ),
          ),
        );
      }

      final filtered = _filtered(data.transactions);

      return SafeArea(
        child: Scaffold(
          backgroundColor: _C.bg,
          appBar: _appBar(context),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── SUMMARY CARD
              _summaryCard(context, data),

              // ── SEARCH + ADD
              _searchRow(context, data.collection.type),

              // ── SECTION LABEL
              _sectionLabel(filtered.length),

              // ── TRANSACTIONS LIST
              Expanded(
                child: filtered.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return HistoryTransactions(
                            context: context,
                            transaction: tx,
                            index: index,
                            isExpanded: false,
                            hide: false,
                            hideReview: false,
                            fromAutoPay: false,
                            date: tx.transactionTimestamp.toString(),
                            // ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────── APP BAR ───────────────────────
  PreferredSizeWidget _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: _C.bg,
          border: Border(bottom: BorderSide(color: _C.border.withOpacity(0.6))),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _C.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: _C.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: _C.textDark,
                    ),
                  ),
                ),

                const Spacer(),

                // Title
                Obx(() => Text(
                      collectionsController
                              .collectionDetails.value?.collection.name ??
                          "Collection",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 17,
                        lWeight: FontWeight.w700,
                        color: _C.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )),

                const Spacer(),

                // Actions
                Container(
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AppBarIconBtn(
                        asset: HomePageIcons.filterOn,
                        onTap: null,
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: _C.border,
                      ),
                      _AppBarIconBtn(
                        asset: HomePageIcons.settings,
                        onTap: () => _showCollectionSettingsModal(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCollectionSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const CollectionSettingsModal(),
    );
  }

  // ─────────────────────── SUMMARY CARD ───────────────────────
  Widget _summaryCard(BuildContext context, CollectionDetailsModel data) {
    final totalCredit = data.collection.totalCredit;
    final totalDebit = data.collection.totalDebit;
    final outstanding = data.collection.outStandingAmount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D2B5B), Color(0xFF3D3A70)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _C.navy.withOpacity(0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── CREDIT / DEBIT ROW
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: "Received",
                      sub:
                          "${data.transactions.where((t) => (t.type ?? '') == 'credit').length} credits",
                      amount: totalCredit,
                      isCredit: true,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 90,
                    color: Colors.white.withOpacity(0.12),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: "Spent",
                      sub:
                          "${data.transactions.where((t) => (t.type ?? '') != 'credit').length} debits",
                      amount: totalDebit,
                      isCredit: false,
                    ),
                  ),
                ],
              ),
            ),

            // ── DIVIDER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Colors.white.withOpacity(0.10),
                height: 28,
              ),
            ),

            // ── OUTSTANDING ROW
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: outstanding > 0 ? _C.orange : _C.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Outstanding Amount",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: outstanding > 0
                          ? _C.orange.withOpacity(0.15)
                          : _C.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "₹${outstanding.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: outstanding > 0 ? _C.orange : _C.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── SEARCH ROW ───────────────────────
  Widget _searchRow(BuildContext context, String type) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, color: _C.textDark),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: _searchController.clear,
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.grey.shade400,
                            size: 18,
                          ),
                        )
                      : null,
                  hintText: "Search transactions…",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => openSelectTransactions(context, type),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _C.navy,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _C.navy.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── SECTION LABEL ───────────────────────
  Widget _sectionLabel(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Transactions",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.textDark,
              letterSpacing: 0.2,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _C.navy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count ${count == 1 ? 'entry' : 'entries'}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _C.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── EMPTY STATE ───────────────────────
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: _C.navy.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: _C.navy,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _searchQuery.isEmpty
                ? "No Transactions Yet"
                : 'No results for "$_searchQuery"',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _C.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isEmpty
                ? "Add your first transaction using the + button"
                : "Try searching a different name or category",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── STAT TILE ───────────────────────
class _StatTile extends StatelessWidget {
  final String label;
  final String sub;
  final double amount;
  final bool isCredit;

  const _StatTile({
    required this.label,
    required this.sub,
    required this.amount,
    required this.isCredit,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isCredit ? const Color(0xFF6FEDB1) : const Color(0xFFFF8C69);

    return Padding(
      padding:
          EdgeInsets.only(left: isCredit ? 0 : 20, right: isCredit ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  size: 15,
                  color: accent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "₹${amount.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── APP BAR ICON BTN ───────────────────────
class _AppBarIconBtn extends StatelessWidget {
  final String asset;
  final VoidCallback? onTap;

  const _AppBarIconBtn({required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p8),
        child: AvatarProfileImageZero(url: asset, width: 50, height: 50),
      ),
    );
  }
}

// ─────────────────────── TRANSACTION CARD WRAPPER ───────────────────────
class _TransactionCard extends StatelessWidget {
  final Widget child;
  const _TransactionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBEB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

// ─────────────────────── BOTTOM SHEET HELPER ───────────────────────
void openSelectTransactions(BuildContext context, String type) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SelectTransactionsSheet(splitType: type),
  );
}
