// ─── screens/trip_dashboard_screen.dart ──────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/collections_model.dart';
import '../../../../../controllers/SplitDetailsScreen.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'member_card_view.dart';
import 'member_spend_amount.dart';
import 'select_transactions_sheet.dart';
import 'package:get/get.dart';

class SharedCollectionDashboard extends StatefulWidget {
  const SharedCollectionDashboard({super.key});

  @override
  State<SharedCollectionDashboard> createState() =>
      _SharedCollectionDashboardState();
}

class _SharedCollectionDashboardState extends State<SharedCollectionDashboard> {
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
    (collectionsController.currentUser?.role == "VIEW")
        ? snackBarCalledfail(context, "You have view only access")
        : showModalBottomSheet(
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
                          child: MembersSpendSection(),
                        ),
                      ],
                    ),
                  ),

                  /// Balance Status
                  const SizedBox(height: 20),
                  BalanceStatusWidget(),

                  /// Transactions Header
                  SectionHeader(
                    title: 'Transactions (${filteredSplits.length}) ',
                    actionLabel:
                        (collectionsController.currentUser?.role == "VIEW")
                            ? "View Only"
                            : 'Add',
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
