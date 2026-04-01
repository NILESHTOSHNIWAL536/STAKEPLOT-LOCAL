// ─── screens/trip_dashboard_screen.dart ──────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/collections_model.dart';
import '../../../../../controllers/SplitDetailsScreen.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'member_card_view.dart';
import 'select_transactions_sheet.dart';
import 'package:get/get.dart';

class TripDashboardScreen extends StatefulWidget {
  const TripDashboardScreen({super.key});

  @override
  State<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends State<TripDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final collectionId =
        collectionsController.collectionDetails.value?.collection.id;
    if (collectionId == null) return;
    await collectionsController.getAllCollectionsTransactions();
    await collectionsController.getBalances(collectionId);
  }

  void _openSelectTransactions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SelectTransactionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        onChanged: (v) => setState(() => _searchQuery = v),
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

          Obx(() {
            final splits = collectionsController.splitsList;
            final members =
                collectionsController.collectionDetails.value?.members ?? [];
            final totalAmount =
                collectionsController.selectedCollection.value?.totalAmount ??
                    0;
            final balances = collectionsController.balancesList;

            if (splits.isEmpty) {
              return SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: _openSelectTransactions,
                  // child: emptyTransactionsUI(context),
                ),
              );
            }

            // Filter splits by search query
            final filteredSplits = _searchQuery.isEmpty
                ? splits
                : splits
                    .where((s) => (s.paidByUser?.name ?? '')
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

            return SliverToBoxAdapter(
              child: Column(
                children: [
                  /// Members & Combined Amount Card
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${members.length} Member${members.length != 1 ? 's' : ''}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 12),

                        /// Combined amount card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 💰 Amount
                              Text(
                                '₹${totalAmount.toStringAsFixed(0)}',
                                style: AppTextStyles.amountLarge.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Combined Amount',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textLight,
                                ),
                              ),

                              const SizedBox(height: 16),

                              /// 👥 Members List
                              if (members.isNotEmpty)
                                SizedBox(
                                  height: 100,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: members.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (ctx, i) {
                                      final m = members[i];
                                      return MemberSpendCardNew(
                                        member: m,
                                        totalAmount: totalAmount,
                                        balances: balances,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Balance Status
                  Obx(() {
                    final toPayEntries = collectionsController.balancesList
                        .where((b) => b.type == 'toPay')
                        .toList();
                    final toReceiveEntries = collectionsController.balancesList
                        .where((b) => b.type == 'toReceive')
                        .toList();

                    if (collectionsController.isBalanceLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (toPayEntries.isEmpty && toReceiveEntries.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Balance Status'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 400;

                              return isMobile
                                  ? Column(
                                      children: [
                                        _ModernBalanceCard(
                                          title: "To Pay",
                                          icon: Icons.arrow_downward,
                                          iconColor: AppColors.errorRed,
                                          bgColor: const Color(0xFFFFF3F3),
                                          balances: toPayEntries,
                                          members: members,
                                        ),
                                        const SizedBox(height: 12),
                                        _ModernBalanceCard(
                                          title: "To Receive",
                                          icon: Icons.arrow_upward,
                                          iconColor: AppColors.paidBadge,
                                          bgColor: const Color(0xFFF3F5FF),
                                          balances: toReceiveEntries,
                                          members: members,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: _ModernBalanceCard(
                                            title: "To Pay",
                                            icon: Icons.arrow_downward,
                                            iconColor: AppColors.errorRed,
                                            bgColor: const Color(0xFFFFF3F3),
                                            balances: toPayEntries,
                                            members: members,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _ModernBalanceCard(
                                            title: "To Receive",
                                            icon: Icons.arrow_upward,
                                            iconColor: AppColors.paidBadge,
                                            bgColor: const Color(0xFFF3F5FF),
                                            balances: toReceiveEntries,
                                            members: members,
                                          ),
                                        ),
                                      ],
                                    );
                            },
                          ),
                        ),
                      ],
                    );
                  }),

                  /// Transactions Header
                  SectionHeader(
                    title: 'Transactions (${filteredSplits.length})',
                    actionLabel: 'Add',
                    onAction: _openSelectTransactions,
                  ),

                  /// Transactions List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSplits.length,
                    itemBuilder: (ctx, i) {
                      final split = filteredSplits[i];
                      final total = _getTotalAmount(split);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SplitDetailsScreen(split: split),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 🔥 TOP ROW (USER + AMOUNT)
                              Row(
                                children: [
                                  /// Avatar
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        AppColors.primaryDark.withOpacity(0.12),
                                    child: Text(
                                      (split.paidByUser?.name ?? "U")
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  /// Name + subtitle
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          split.paidByUser?.name ?? "Unknown",
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Paid for group",
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// 💰 Amount Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "₹${total.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              /// 👥 MEMBERS PREVIEW
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: split.splits.take(3).map((s) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.tagBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "${s.user?.name ?? 'User'} • ₹${s.amount.toStringAsFixed(0)}",
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              /// + More indicator
                              if (split.splits.length > 3)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    "+${split.splits.length - 3} more",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 10),

                              /// 📅 DATE + NAV ICON
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 14, color: AppColors.textLight),
                                  const SizedBox(width: 6),
                                  if (split.createdAt != null)
                                    Text(
                                      _formatDate(split.createdAt!),
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 14, color: AppColors.textLight),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}

double _getTotalAmount(SplitModel split) {
  return split.splits.fold(0, (sum, e) => sum + e.amount);
}

// ── Member Spend Card ──────────────────────────────────────────────────────────
class _MemberSpendCard extends StatelessWidget {
  final MemberModel member;
  final double totalAmount;
  final List<BalanceModel> balances;

  const _MemberSpendCard({
    required this.member,
    required this.totalAmount,
    required this.balances,
  });

  @override
  Widget build(BuildContext context) {
    // Find member's balance
    final memberBalance = balances
        .where((b) => b.userId == member.userId)
        .fold(0.0, (sum, b) => sum + b.balance);

    final pct =
        totalAmount > 0 ? (memberBalance / totalAmount).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      width: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primaryDark.withOpacity(0.15),
                child: Text(
                  member.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark),
                ),
              ),
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
                  text: '₹${memberBalance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: '/${totalAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: AppColors.tagBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Balance Status Card ────────────────────────────────────────────────────────
class _BalanceStatusCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final List<BalanceModel> balances;
  final List<MemberModel> members;

  const _BalanceStatusCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.balances,
    required this.members,
  });

  String _findMemberName(String userId) {
    final m = members.where((m) => m.userId == userId).toList();
    return m.isNotEmpty ? m.first.name : userId;
  }

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
          if (balances.isEmpty)
            Text("None", style: AppTextStyles.bodySmall)
          else
            ...balances.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: iconColor.withOpacity(0.15),
                      child: Text(
                        _findMemberName(b.userId).substring(0, 1).toUpperCase(),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: iconColor),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _findMemberName(b.userId),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₹${b.balance.toStringAsFixed(0)}',
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

class _ModernBalanceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final List<BalanceModel> balances;
  final List<MemberModel> members;

  const _ModernBalanceCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.balances,
    required this.members,
  });

  String _getName(String userId) {
    final m = members.where((m) => m.userId == userId).toList();
    return m.isNotEmpty ? m.first.name : userId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// USERS
          ...balances.map((b) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryDark.withOpacity(0.15),
                      child: Text(
                        _getName(b.userId)[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _getName(b.userId),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      "₹${b.balance.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
