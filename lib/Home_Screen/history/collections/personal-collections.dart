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
import '../../../model/collections_model.dart';
import '../transactions_ui_component.dart';
import 'collection_setting.dart';
import 'trip/screens/select_transactions_sheet.dart';

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

  List<dynamic> _filtered(List<dynamic> transactions) {
    if (_searchQuery.isEmpty) return transactions;
    return transactions.where((tx) {
      final name = (tx.name ?? '').toString().toLowerCase();
      final category = (tx.category ?? '').toString().toLowerCase();
      final amount = (tx.amount ?? '').toString().toLowerCase();
      final date = (tx.transactionTimestamp ?? '').toString().toLowerCase();
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
        return SafeArea(
          child: const Scaffold(
            backgroundColor: Color(0xFFF5F3EF),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2D2B5B),
                strokeWidth: 2.5,
              ),
            ),
          ),
        );
      }

      final filtered = _filtered(data.transactions);

      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F3EF),
          appBar: _appBar(context),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary Card ──
              _summaryCard(context, data),

              // ── Search + Add ──
              _searchRow(context, data.collection.type),

              // ── Section Label ──
              _sectionLabel(filtered.length),

              // ── Transactions List ──
              Expanded(
                child: filtered.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: _TransactionCard(
                              child: HistoryTransactions(
                                context: context,
                                transaction: tx,
                                index: index,
                                isExpanded: false,
                                hide: false,
                                hideReview: false,
                                fromAutoPay: false,
                                date: tx.transactionTimestamp.toString(),
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
    });
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70), // 🔥 height control
      child: Container(
        color: AppColors.newbg,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: AppSizes.p12),
            child: Row(
              children: [
                /// 🔙 BACK
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    backgroundColor: AppColors.backgroundColor,
                    child: Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: AppColors.accentColor,
                    ),
                  ),
                ),

                const Spacer(),

                /// 🏷 TITLE
                Container(
                    // color: AppColors.bg1,
                    width: MediaQuery.of(context).size.width / 2,
                    alignment: Alignment.center,
                    child: Obx(() => Text(
                          collectionsController
                                  .collectionDetails.value?.collection.name ??
                              "Collection",
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 18,
                            lWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ))),

                const Spacer(),

                /// ⚙ FILTER + SETTINGS
                Container(
                  padding: const EdgeInsets.all(AppSizes.p8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _iconButton(HomePageIcons.filterOn),
                      VerticalDashDivider(
                        height: 30,
                        color: AppColors.border,
                        dashGap: 0,
                      ),
                      InkWell(
                        onTap: () {
                          showCollectionSettingsModal(context);
                        },
                        child: _iconButton(HomePageIcons.settings),
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

  void showCollectionSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => const CollectionSettingsModal(),
    );
  }

  Widget _iconButton(String asset) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p8),
      child: Center(
        child: AvatarProfileImageZero(
          url: asset,
          width: 50,
          height: 50,
        ),
      ),
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
          color: const Color(0xFF2D2B5B),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D2B5B).withOpacity(0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // credit / debit row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _statTile(
                      label: "Received",
                      sub: "10 credits",
                      amount: totalCredit,
                      isCredit: true,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 80,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  Expanded(
                    child: _statTile(
                      label: "Spent",
                      sub: "10 debits",
                      amount: totalDebit,
                      isCredit: false,
                    ),
                  ),
                ],
              ),
            ),

            // divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Colors.white.withOpacity(0.12),
                height: 28,
              ),
            ),

            // outstanding row
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
                          color: outstanding > 0
                              ? const Color(0xFFFF8C69)
                              : const Color(0xFF6FEDB1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Outstanding Amount",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.70),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "₹${outstanding.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  Widget _statTile({
    required String label,
    required String sub,
    required double amount,
    required bool isCredit,
  }) {
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
                  size: 16,
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
              color: Colors.white.withOpacity(0.50),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "₹${amount.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── SEARCH ROW ───────────────────────
  Widget _searchRow(BuildContext context, String type) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1832),
                ),
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
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 4,
                  ),
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
                color: const Color(0xFF2D2B5B),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D2B5B).withOpacity(0.3),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Transactions",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1832),
              letterSpacing: 0.2,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2B5B).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count entries",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2B5B),
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2B5B).withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF2D2B5B),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? "No Transactions Yet"
                : 'No results for "$_searchQuery"',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1832),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isEmpty
                ? "Add your first transaction above"
                : "Try a different name, category or date",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
