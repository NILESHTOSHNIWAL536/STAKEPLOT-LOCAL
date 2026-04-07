import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/collections_model.dart';
import '../../../../../Utils/socket_connect.dart';
import '../../../../../controllers/SplitDetailsScreen.dart';
import '../../../../../routes/index_route.dart';
import '../utils/app_theme.dart';
import 'member_card_view.dart';
import 'member_spend_amount.dart';
import 'select_transactions_sheet.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SharedCollectionDashboard extends StatefulWidget {
  const SharedCollectionDashboard({super.key});

  @override
  State<SharedCollectionDashboard> createState() =>
      _SharedCollectionDashboardState();
}

class _SharedCollectionDashboardState extends State<SharedCollectionDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final socket = SocketService().getSocket();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    SocketService().initSocket(API.urlWithLocallHost);
    final socket = SocketService().getSocket();
    setUpSocketListener(socket);
  }

  void setUpSocketListener(IO.Socket socket) {
    String roomId =
        collectionsController.collectionDetails.value?.collection.id ?? '';
    socket.onConnect((_) {
      socket.emit("joinRoom", roomId);
      socket.emit("collectionRoom", roomId);
    });

    socket.on("collection", (data) {
      collectionsController.socketMessage(data,context);
    });
  }

  Future<void> _loadDashboardData() async {
    final collectionId =collectionsController.collectionDetails.value?.collection.id;
    if (collectionId == null) return;
    await collectionsController.getBalances(collectionId);
    await collectionsController.getSplits(collectionId);
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
      body: RefreshIndicator(
        color: AppColors.primaryDark,
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            // ── SEARCH + ADD BAR
            SliverToBoxAdapter(
              child: _SearchAddBar(
                controller: _searchController,
                onSearch: (v) => setState(() => _searchQuery = v),
                onAdd: _openSelectTransactions,
              ),
            ),

            Obx(() {
              final splits = collectionsController.splitsList;
              final members =
                  collectionsController.collectionDetails.value?.members ?? [];

              if (splits.isEmpty) {
                return SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: _openSelectTransactions,
                    child: _EmptyDashboard(onAdd: _openSelectTransactions),
                  ),
                );
              }

              final filteredSplits = _searchQuery.isEmpty
                  ? splits
                  : splits
                      .where((s) => (s.paidByUser?.name ?? '')
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── MEMBERS & COMBINED AMOUNT CARD
                    _CombinedAmountCard(members: members),

                    const SizedBox(height: 16),

                    // ── BALANCE STATUS
                    const BalanceStatusWidget(),

                    const SizedBox(height: 20),

                    // ── TRANSACTIONS HEADER
                    _SectionHeader(
                      title: 'Transactions',
                      count: filteredSplits.length,
                      isViewOnly:
                          collectionsController.currentUser?.role == "VIEW",
                      onAdd: _openSelectTransactions,
                    ),

                    // ── SPLIT CARDS
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredSplits.length,
                      padding: const EdgeInsets.only(bottom: 32),
                      itemBuilder: (ctx, i) {
                        final split = filteredSplits[i];
                        return _SplitCard(
                          split: split,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SplitDetailsScreen(split: split),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── SEARCH + ADD BAR ───────────────────────
class _SearchAddBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onAdd;

  const _SearchAddBar({
    required this.controller,
    required this.onSearch,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEBEBEB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                style: AppTextStyles.bodyMedium,
                onChanged: onSearch,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textLight, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  hintText: 'Search splits...',
                  hintStyle:
                      const TextStyle(color: AppColors.textLight, fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── COMBINED AMOUNT CARD ───────────────────────
class _CombinedAmountCard extends StatelessWidget {
  final List<MemberModel> members;

  const _CombinedAmountCard({required this.members});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Members pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEBEBEB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.group_outlined,
                    size: 15, color: AppColors.textLight),
                const SizedBox(width: 6),
                Text(
                  '${members.length} Member${members.length != 1 ? 's' : ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Combined amount card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEBEBEB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const MembersSpendSection(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── SECTION HEADER ───────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isViewOnly;
  final VoidCallback onAdd;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.isViewOnly,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1832),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const Spacer(),
          if (!isViewOnly)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_rounded, color: Colors.white, size: 15),
                    SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    'View Only',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────── SPLIT CARD ───────────────────────
class _SplitCard extends StatelessWidget {
  final SplitModel split;
  final VoidCallback onTap;

  const _SplitCard({required this.split, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final total = split.splits.fold(0.0, (s, e) => s + e.amount);
    final name = split.paidByUser?.name ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEBEBEB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP ROW
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D2B5B), Color(0xFF4B4D73)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D2B5B).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1832),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Paid for group',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF2D2B5B),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            if (split.splits.isNotEmpty) ...[
              const SizedBox(height: 14),
              // ── MEMBER CHIPS
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: split.splits.take(3).map((s) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3EF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEBEBEB)),
                    ),
                    child: Text(
                      '${s.user?.name ?? 'User'} • ₹${s.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (split.splits.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '+${split.splits.length - 3} more people',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4B4D73),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 12),

            // ── FOOTER
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFFACACAC)),
                const SizedBox(width: 5),
                Text(
                  split.createdAt != null ? _formatDate(split.createdAt!) : '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFACACAC),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3EF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B4D73),
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: Color(0xFF4B4D73)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ─────────────────────── EMPTY DASHBOARD ───────────────────────
class _EmptyDashboard extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyDashboard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_split_rounded,
              color: AppColors.primaryDark,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Splits Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1832),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add transactions and split them\nwith your group members.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade500, height: 1.5),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D2B5B), Color(0xFF4B4D73)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D2B5B).withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Add First Transaction',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

double _getTotalAmount(SplitModel split) {
  return split.splits.fold(0, (sum, e) => sum + e.amount);
}
