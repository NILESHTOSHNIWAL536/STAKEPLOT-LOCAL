
import 'package:flutter/material.dart';

import '../ManuallyTransactions/collections_manualtransactions.dart';

// ─── Color tokens (mirrors _K inside the widget) ─────────────────────────────
const _primary   = Color(0xFF2D2B5B);
const _accent    = Color(0xFF4B4D73);
const _textDark  = Color(0xFF1A1832);
const _textMid   = Color(0xFF6B7280);
const _border    = Color(0xFFEBEBEB);
const _surface   = Colors.white;
const _bg        = Color(0xFFF5F3EF);

class CollectionsSplitBottomSheet extends StatelessWidget {
  final double amount;
  final String transactionId;

  const CollectionsSplitBottomSheet({
    Key? key,
    required this.amount,
    required this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.92),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ────────────────────────────────────────────────
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Header ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Close
                _NavBtn(
                  icon: Icons.keyboard_arrow_down_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Split Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Allocate ₹${amount.toStringAsFixed(2)} across members',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textMid,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount pill
                _AmountPill(amount: amount),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),

          // ── Scrollable body ─────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              child: CollectionsManualtransactions(
                amount: amount,
                transactionId: transactionId,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Nav close button ─────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Icon(icon, color: _textDark, size: 22),
      ),
    );
  }
}

// ─── Total amount pill ────────────────────────────────────────────────────────
class _AmountPill extends StatelessWidget {
  final double amount;
  const _AmountPill({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '₹${amount.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Convenience launcher ─────────────────────────────────────────────────────
/// Drop-in replacement for your existing [showCustomFriendsModalTransactionHistory].
/// Returns the same [Future<dynamic>] so call-sites stay unchanged.
Future<dynamic> showCollectionSplitSheet(
  BuildContext context, {
  required double amount,
  required String transactionId,
}) {
  return showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => CollectionsSplitBottomSheet(
      amount: amount,
      transactionId: transactionId,
    ),
  );
}