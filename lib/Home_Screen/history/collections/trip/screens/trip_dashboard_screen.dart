// ─── screens/trip_dashboard_screen.dart ──────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/collections_model.dart';
import '../../../transactions_ui_component.dart';
import '../../collections_empty_page.dart';
import '../data/dummy_data.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'select_transactions_sheet.dart';

class TripDashboardScreen extends StatefulWidget {
  const TripDashboardScreen({super.key});

  @override
  State<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends State<TripDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    collectionsController.getAllCollectionsTransactions();
  }

  void _openSelectTransactions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SelectTransactionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bills = DummyData.fixedBills;
    List<BalanceEntry> balances = [];

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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
          onPressed: () {},
        ),
        title: const Text('Goa Trip', style: AppTextStyles.heading3),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search + Add button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyles.bodyMedium,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textLight,
                            size: 20,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          hintText: 'Search transactions...',
                          hintStyle: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _openSelectTransactions,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          !collectionsController.hasTransactions
              ? SliverToBoxAdapter(
                  child: GestureDetector(
                  onTap: _openSelectTransactions,
                  child: emptyTransactionsUI(context),
                ))
              : Column(
                  children: [
                    // Members & Combined Amount Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            // Subtitle row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '4 Members | Active since May 2024',
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Combined amount card
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '₹${DummyData.combinedAmount.toStringAsFixed(0)}',
                                    style: AppTextStyles.amountLarge,
                                  ),
                                  const Text(
                                    'Combined Amount',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  // Horizontal member scroll
                                  SizedBox(
                                    height: 80,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: collectionsController
                                          .collectionDetails
                                          .value!
                                          .members
                                          .length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 10),
                                      itemBuilder: (ctx, i) {
                                        final m = collectionsController
                                            .collectionDetails
                                            .value!
                                            .members[i];
                                        return _MemberSpendCard(member: m);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Balance Status
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Balance Status'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _BalanceStatusCard(
                                    title: 'To Pay',
                                    icon: Icons.arrow_circle_down_outlined,
                                    iconColor: AppColors.errorRed,
                                    bgColor: const Color(0xFFFFF0F0),
                                    entries: balances
                                        .where(
                                            (b) => b.type == BalanceType.toPay)
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _BalanceStatusCard(
                                    title: 'To Receive',
                                    icon: Icons.arrow_circle_up_outlined,
                                    iconColor: AppColors.primaryBlue,
                                    bgColor: const Color(0xFFF0F4FF),
                                    entries: balances
                                        .where((b) =>
                                            b.type == BalanceType.toReceive)
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Fixed Bills
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          SectionHeader(
                            title: 'Fixed Bills',
                            actionLabel: 'View All',
                            onAction: () {},
                          ),
                          ...bills
                              .take(3)
                              .map((b) => FixedBillCard(bill: b))
                              .toList(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Bill'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                side:
                                    const BorderSide(color: AppColors.divider),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                foregroundColor: AppColors.textPrimary,
                              ),
                            ),
                          ),
                         const Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 6),
                            child: Text(
                              'Bills are automatically split between members.',
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Transactions
                    SliverToBoxAdapter(
                      child: const SectionHeader(title: 'Transactions'),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final tx = collectionsController.AllTransactions[i];
                          MemberModel? tagged;

                          return HistoryTransactions(
                            context: context,
                            transaction: tx,
                            index: i,
                            isExpanded: false,
                            fromAutoPay: false,
                            hide: false,
                            hideReview: false,
                            date: "",
                          );
                        },
                        childCount:
                            collectionsController.AllTransactions.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                )
        ],
      ),
    );
  }
}

// ── Private Sub-widgets ───────────────────────────────────────────────────────

class _MemberSpendCard extends StatelessWidget {
  final MemberModel member;
  const _MemberSpendCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final pct = 5500 / 200;
    return SizedBox(
      width: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MemberAvatar(member: member, size: 30),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  member.name,
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodySmall,
              children: [
                TextSpan(
                  text: '${500}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text:
                      '/${collectionsController.selectedCollection.value?.totalAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0, 1),
              minHeight: 5,
              backgroundColor: AppColors.tagBg,
              valueColor: AlwaysStoppedAnimation(Colorcodes.greyLight),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceStatusCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final List<BalanceEntry> entries;

  const _BalanceStatusCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ...entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  MemberAvatar(member: e.member, size: 28),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(e.member.name,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textPrimary)),
                  ),
                  Text(
                    '₹${e.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
