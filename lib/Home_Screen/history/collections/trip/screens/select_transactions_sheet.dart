import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:get/get.dart';
import '../models/collection_helper_models.dart';
import '../widgets/common_widgets.dart';
import 'select_members_screen.dart';

// ── Local tokens ──────────────────────────────────────────────────────────────
class _S {
  static const bg = Color(0xFFF5F3EF);
  static const surface = Colors.white;
  static const navy = Color(0xFF2D2B5B);
  static const navyMid = Color(0xFF4B4D73);
  static const navyBg = Color(0xFFEEEDF8);
  static const border = Color(0xFFEBEBEB);
  static const textDark = Color(0xFF1A1832);
  static const textMid = Color(0xFF6B7280);
  static const textLight = Color(0xFFACACAC);
  static const green = Color(0xFF22C55E);
  static const greenBg = Color(0xFFDCFCE7);
}

// ── Pagination config ─────────────────────────────────────────────────────────
const int _kPageSize = 20;

class SelectTransactionsSheet extends StatefulWidget {
  final String splitType;

  const SelectTransactionsSheet({super.key, this.splitType = 'SHARED'});

  @override
  State<SelectTransactionsSheet> createState() =>
      _SelectTransactionsSheetState();
}

class _SelectTransactionsSheetState extends State<SelectTransactionsSheet> {
  // ── State ────────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _query = '';
  int _currentPage = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    collectionsController.SeletedTransactionsList.clear();
    collectionsController.selectedTransactions.clear();

    // Load first page
    _loadPage(1, reset: true);

    // Attach scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Pagination ────────────────────────────────────────────────────────────
  void _onScroll() {
    if (!_hasMore || _loadingMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger when 200px from the bottom
    if (currentScroll >= maxScroll - 200) {
      _loadPage(_currentPage + 1);
    }
  }

  Future<void> _loadPage(int page, {bool reset = false}) async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);

    try {
      // if (reset) {
      //   collectionsController.AllTransactions.clear();
      // }

      await collectionsController.getAllCollectionsTransactions(
        page: page,
        limit: _kPageSize,
      );

      // Determine if more pages exist
      final loaded = collectionsController.AllTransactions.length;
      _hasMore = (loaded % _kPageSize == 0) && loaded > 0;
      _currentPage = page;
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  double get _selectedTotal =>
      collectionsController.SeletedTransactionsList.fold(
          0.0, (sum, t) => sum + t.amount);

  void _proceedToMembers() {
    List<TransactionForCollections> selected = [];
    for (final obj in collectionsController.SeletedTransactionsList) {
      if (collectionsController.selectedTransactions.contains(obj.id)) {
        selected.add(TransactionForCollections(
          id: obj.id,
          title: obj.narration,
          date: formatWhatsAppDate(obj.transactionTimestamp),
          amount: obj.amount,
          category: obj.category,
          addedBy: obj.narration,
        ));
      }
    }

    if (widget.splitType != 'SHARED') {
      collectionsController.addTransaction(
          collectionId:
              collectionsController.collectionDetails.value?.collection.id ??
                  '',
          transactionIds: collectionsController.selectedTransactions,
          splitType: '',
          context: context,
          clearn: true);
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMembersScreen(
          selectedTransactions: selected,
          totalAmount: _selectedTotal,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (ctx, sheetScrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: _S.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // ── Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),

            _buildHeader(context),
            _buildSearchBar(),
            Obx(() => _buildSelectionBanner()),
            _buildListHeader(),

            // ── Transactions list
            Expanded(
              child: Obx(() {
                final txs = collectionsController.AllTransactions;

                if (collectionsController.isSplitLoading.value && txs.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: _S.navy, strokeWidth: 2.5),
                  );
                }

                if (txs.isEmpty) return _buildEmptyState();

                final filtered = _query.isEmpty
                    ? txs.toList()
                    : txs
                        .where((t) =>
                            (t.narration ?? '')
                                .toLowerCase()
                                .contains(_query.toLowerCase()) ||
                            (t.category ?? '')
                                .toLowerCase()
                                .contains(_query.toLowerCase()))
                        .toList();

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: filtered.length + (_hasMore ? 1 : 0),
                  // padding:const EdgeInsets.only(left: 16, right: 16, bottom: 120),
                  itemBuilder: (ctx, i) {
                    // Load-more spinner at the bottom
                    if (i == filtered.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: _loadingMore
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: _S.navy,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () => _loadPage(_currentPage + 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _S.navyBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Load more',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _S.navy,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      );
                    }

                    final tx = filtered[i];
                    return TransactionCard(tx: tx, showCheckbox: true);
                  },
                );
              }),
            ),

            Obx(() => _buildProceedButton()),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        color: _S.bg,
        border: Border(bottom: BorderSide(color: _S.border.withOpacity(0.6))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _S.surface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _S.border),
              ),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: _S.textDark),
            ),
          ),
          const Expanded(
            child: Text(
              'Select Transactions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _S.textDark,
              ),
            ),
          ),
          widget.splitType == 'SHARED'
              ? Obx(() => _SplitButton(
                    enabled:
                        collectionsController.selectedTransactions.isNotEmpty,
                    onTap: collectionsController.selectedTransactions.isNotEmpty
                        ? _proceedToMembers
                        : null,
                  ))
              : const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ── SEARCH BAR ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _S.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _S.border),
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
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(fontSize: 14, color: _S.textDark),
          decoration: InputDecoration(
            hintText: 'Search transactions…',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.grey.shade400, size: 20),
            suffixIcon: _query.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    child: Icon(Icons.close_rounded,
                        color: Colors.grey.shade400, size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }

  // ── SELECTION BANNER ──────────────────────────────────────────────────────
  Widget _buildSelectionBanner() {
    final count = collectionsController.selectedTransactions.length;
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      child: count > 0
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D2B5B), Color(0xFF4B4D73)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 15, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Obx(() => Text(
                        '${collectionsController.selectedTransactions.length} '
                        'transaction${collectionsController.selectedTransactions.length != 1 ? 's' : ''} '
                        'selected',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${_selectedTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // ── LIST HEADER ───────────────────────────────────────────────────────────
  Widget _buildListHeader() {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
          child: Row(
            children: [
              const Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _S.textDark,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _S.navyBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${collectionsController.AllTransactions.length} available',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _S.navy,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _S.navy.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: _S.navy, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions available',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _S.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Transactions from your bank account\nwill appear here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ── PROCEED BUTTON ────────────────────────────────────────────────────────
  Widget _buildProceedButton() {
    final count = collectionsController.selectedTransactions.length;
    return count > 0
        ? Container(
            decoration: BoxDecoration(
              color: _S.surface,
              border: Border(top: BorderSide(color: _S.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: GestureDetector(
              onTap: _proceedToMembers,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D2B5B), Color(0xFF4B4D73)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D2B5B).withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call_split_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Obx(() => Text(
                          'Continue with '
                          '${collectionsController.selectedTransactions.length} '
                          'transaction${collectionsController.selectedTransactions.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        )),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}

// ─────────────────────── SPLIT BUTTON ───────────────────────
class _SplitButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _SplitButton({required this.enabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF2D2B5B) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.call_split_rounded,
              size: 15,
              color: enabled ? Colors.white : Colors.grey.shade400,
            ),
            const SizedBox(width: 5),
            Text(
              'Split',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
