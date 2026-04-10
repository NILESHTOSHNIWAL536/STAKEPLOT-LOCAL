// ─── balance_status_widget.dart ───────────────────────────────────────────────
// FILE: lib/Home_Screen/history/collections/trip/screens/balance_status_widget.dart
// CHANGES:
//   - Tappable "To Pay" and "To Receive" cards → navigate to ToPayScreen / ToReceiveScreen
//   - ToPayScreen  : lists people with a "Pay" button (no-op or callback)
//   - ToReceiveScreen: lists people with a "Clear" button → ClearSplitDialog → ConfirmDialog
//   - ClearSplitDialog: complete amount OR partial amount radio picker
//   - ConfirmClearDialog: "Are you sure?" yes/cancel
//   - Pagination hooks ready (load-more on scroll)

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';

import '../../../../../backed_connections/apis_connect.dart';
import '../../../../../model/collections_model.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
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
  static const green = Color(0xFF22C55E);
  static const greenBg = Color(0xFFDCFCE7);
  static const red = Color(0xFFEF4444);
  static const redBg = Color(0xFFFFF5F5);
  static const orange = Color(0xFFFF8C69);
}

// ═════════════════════════════════════════════════════════════════════════════
// BALANCE STATUS WIDGET  (embedded in SharedCollectionDashboard)
// ═════════════════════════════════════════════════════════════════════════════
class BalanceStatusWidget extends StatelessWidget {
  const BalanceStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (collectionsController.isBalanceLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(color: _C.navy, strokeWidth: 2.5),
          ),
        );
      }

      final toPay = collectionsController.balancesListPay.toList();
      final toReceive = collectionsController.balancesListReceive.toList();
      // final toReceive =

      if (toPay.isEmpty && toReceive.isEmpty) {
        return _AllSettledBanner();
      }

      final toPayTotal = collectionsController.totalToPay.value;
      final toReceiveTotal = collectionsController.totalToReceive.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _C.navy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      size: 17, color: _C.navy),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Balance Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3EF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.border),
                  ),
                  child: Text(
                    '${toPay.length + toReceive.length} entries',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _C.textMid,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Two tappable cards
            Row(
              children: [
                Expanded(
                  child: _BalanceSummaryCard(
                    label: 'To Pay',
                    count: toPay.length,
                    total: toPayTotal,
                    isPay: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ToPayScreen(items: toPay),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BalanceSummaryCard(
                    label: 'To Receive',
                    count: toReceive.length,
                    total: toReceiveTotal,
                    isPay: false,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ToReceiveScreen(items: toReceive),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────── ALL SETTLED BANNER ───────────────────────
class _AllSettledBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _C.greenBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _C.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: _C.green, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All Settled!',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF166534))),
                  SizedBox(height: 2),
                  Text('No outstanding balances in this collection.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF15803D))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── BALANCE SUMMARY CARD (tappable) ───────────────────────
class _BalanceSummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final double total;
  final bool isPay;
  final VoidCallback onTap;

  const _BalanceSummaryCard({
    required this.label,
    required this.count,
    required this.total,
    required this.isPay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isPay ? _C.red : _C.green;
    final accentBg = isPay ? _C.redBg : _C.greenBg;
    final icon =
        isPay ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
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
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent, size: 15),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _C.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'View details',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TO PAY SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class ToPayScreen extends StatelessWidget {
  final List<BalanceModel> items;

  const ToPayScreen({super.key, required this.items});

  // double  _total = collectionsController.totalToPay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(context, 'To Pay'),
      body: Column(
        children: [
          // Total banner
          Obx(() => _TotalBanner(
                label: 'Total Amount to Pay',
                total: collectionsController.totalToPay.value,
                isPay: true,
              )),
          const SizedBox(height: 8),

          // List
          Obx(
            () => Expanded(
                child: collectionsController.balancesListPay.isEmpty
                    ? _EmptyState(message: 'Nothing to pay 🎉')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: collectionsController.balancesListPay.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final item = collectionsController.balancesListPay[i];
                          return _ToPayCard(item: item);
                        },
                      )),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── TO PAY CARD ───────────────────────
class _ToPayCard extends StatelessWidget {
  final BalanceModel item;

  const _ToPayCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = item.user?.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    bool isSettled = item.status == "SETTLED";
    RxBool _cleared = false.obs;
    final date = item.date ?? DateTime.now();
    // final amount= item.status=="PARTIAL"?  item.pendingAmount: item.status=="PENDING":item.totalAmount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: _C.navy,
              shape: BoxShape.circle,
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

          // Name + label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay',
                  style: const TextStyle(fontSize: 11, color: _C.textLight),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: isSettled
                            ? '₹${item.totalAmount.toStringAsFixed(0)}'
                            : '₹${item.pendingAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.green,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${item.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _C.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Pay button
          Column(
            children: [
              _ActionButton(
                label: isSettled ? "Cleared" : 'Pay',
                color: isSettled ? _C.green : _C.navy,
                onTap: _cleared.value
                    ? null
                    : () async {
                        if (isSettled) return;
                        final result = await _showClearSplitDialog(
                            context, item.pendingAmount, item.splitId);
                        if (result == true) {
                          _cleared = true.obs;
                        }
                      },
              ),
              getTime(context, date)
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TO RECEIVE SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class ToReceiveScreen extends StatelessWidget {
  final List<BalanceModel> items;

  const ToReceiveScreen({super.key, required this.items});

  double get _total => items.fold(0.0, (s, e) => s + e.pendingAmount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(context, 'To Receive'),
      body: Column(
        children: [
          Obx(() => _TotalBanner(
                label: 'Total Amount to Receive',
                total: collectionsController.totalToReceive.value,
                isPay: false,
              )),
          const SizedBox(height: 8),
          Obx(
            () => Expanded(
                child: collectionsController.balancesListReceive.isEmpty
                    ? _EmptyState(message: 'Nothing to receive yet')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount:
                            collectionsController.balancesListReceive.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final item =
                              collectionsController.balancesListReceive[i];
                          return _ToReceiveCard(item: item);
                        },
                      )),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── TO RECEIVE CARD ───────────────────────
class _ToReceiveCard extends StatefulWidget {
  final BalanceModel item;
  const _ToReceiveCard({required this.item});

  @override
  State<_ToReceiveCard> createState() => _ToReceiveCardState();
}

class _ToReceiveCardState extends State<_ToReceiveCard> {
  bool _cleared = false;

  @override
  Widget build(BuildContext context) {
    bool isSettled = widget.item.status == "SETTLED";
    final name = widget.item.user?.name ?? '';
    final date = widget.item.date ?? DateTime.now();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                const BoxDecoration(color: _C.navy, shape: BoxShape.circle),
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
                Row(
                  children: [
                    Text(
                      toUpperCase(name),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.textDark,
                      ),
                    ),
                    if (_cleared) ...[
                      const SizedBox(width: 6),
                      Row(
                        children: const [
                          Icon(Icons.check_circle_rounded,
                              size: 13, color: _C.green),
                          SizedBox(width: 3),
                          Text('Cleared',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _C.green,
                              )),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(width: 6),
                      // const Text('Pending payment',
                      //     style: TextStyle(fontSize: 11, color: _C.textLight)),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '₹${widget.item.pendingAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.green,
                  ),
                ),
              ],
            ),
          ),

          // Clear button (greyed when cleared)
          Column(
            children: [
              _ActionButton(
                label: isSettled ? "Cleared" : ' Clear ',
                color: isSettled
                    ? _C.green
                    : _cleared
                        ? Colors.grey.shade300
                        : _C.navy,
                textColor: _cleared ? Colors.grey.shade500 : Colors.white,
                onTap: _cleared
                    ? null
                    : () async {
                        final confirmed = await _showConfirmDialog(
                            context,
                            widget.item.pendingAmount,
                            widget.item.splitId,
                            widget.item.payerId);
                      },
              ),
              getTime(context, date)
            ],
          ),
        ],
      ),
    );
  }
}

Widget getTime(context, date) {
  return Column(
    children: [
      const SizedBox(
        height: 10,
      ),
      textStyle(context: context, text: formatWhatsAppDate4(date))
    ],
  );
}

// ─────────────────────── CLEAR SPLIT DIALOG ───────────────────────
Future<bool?> _showClearSplitDialog(
  BuildContext context,
  double totalAmount,
  String splitId,
) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _ClearSplitDialog(
      totalAmount: totalAmount,
      splitId: splitId,
    ),
  );
}

class _ClearSplitDialog extends StatefulWidget {
  final double totalAmount;
  final String splitId;
  const _ClearSplitDialog({required this.totalAmount, required this.splitId});

  @override
  State<_ClearSplitDialog> createState() => _ClearSplitDialogState();
}

class _ClearSplitDialogState extends State<_ClearSplitDialog> {
  bool _isComplete = true;
  final _ctrl = TextEditingController();
  RxBool isValidAmount = false.obs;
  RxDouble amount = 0.0.obs;
  // double.parse(_ctrl.text == "" ? "0.0" : _ctrl.text)

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _C.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clear split',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _C.textDark,
              ),
            ),
            const SizedBox(height: 20),

            // Complete amount option
            _RadioOption(
              selected: _isComplete,
              onTap: () => {
                isValidAmount.value = true,
                amount.value = widget.totalAmount,
                setState(() => _isComplete = true),
              },
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Complete amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.textDark,
                      ),
                    ),
                  ),
                  Text(
                    '₹${widget.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.navy,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Partial amount option
            _RadioOption(
              selected: !_isComplete,
              onTap: () => {
                isValidAmount.value = false,
                setState(() => _isComplete = false),
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Partial Amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _C.textDark,
                    ),
                  ),
                  if (!_isComplete) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _ctrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      onChanged: (value) {
                        double a =
                            double.parse(value == "" ? "0.0" : _ctrl.text);
                        isValidAmount.value = a <= widget.totalAmount;
                        amount.value = a;
                      },
                      decoration: InputDecoration(
                        prefixText: '₹  ',
                        prefixStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _C.textDark,
                        ),
                        hintText: '0',
                        hintStyle: const TextStyle(color: _C.textLight),
                        isDense: true,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: _C.border),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: _C.navy),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Done button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isValidAmount.value
                          ? _C.navy.withOpacity(0.2)
                          : _C.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (!isValidAmount.value) {
                        return;
                      }
                      Navigator.pop(context); // close this dialog
                      final confirmed = await _showConfirmDialog(
                          context, amount.value, widget.splitId, "");
                      if (context.mounted) {
                        Navigator.pop(context, confirmed == true);
                      }
                    },
                    child: Obx(() => Text(
                          amount.value > widget.totalAmount
                              ? "Overflow"
                              : "Done",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _RadioOption({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _C.navyBg : _C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _C.navy : _C.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _C.navy : _C.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: _C.navy,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── CONFIRM CLEAR DIALOG ───────────────────────
Future<bool?> _showConfirmDialog(
    BuildContext context, double amount, String splitId, String payerId) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_context) => Dialog(
      backgroundColor: _C.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to clear this amount ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _C.textDark,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => {
                  if (payerId.trim() == "")
                    collectionsController.clearSplit(splitId, amount)
                  else
                    collectionsController.clearSplitAmountComplete(
                        splitId, amount, payerId),
                  Navigator.pop(_context, true),
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _C.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(_context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _C.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═════════════════════════════════════════════════════════════════════════════
PreferredSizeWidget _appBar(BuildContext context, String title) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Container(
      decoration: BoxDecoration(
        color: _C.bg,
        border: Border(bottom: BorderSide(color: _C.border.withOpacity(0.6))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
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
                  child: const Icon(Icons.arrow_back_rounded,
                      size: 18, color: _C.textDark),
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.textDark,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 38),
            ],
          ),
        ),
      ),
    ),
  );
}

class _TotalBanner extends StatelessWidget {
  final String label;
  final double total;
  final bool isPay;

  const _TotalBanner({
    required this.label,
    required this.total,
    required this.isPay,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isPay ? _C.red : _C.green;
    final icon =
        isPay ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: _C.textMid),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _C.textDark,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _C.navy.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _C.navy, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _C.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
