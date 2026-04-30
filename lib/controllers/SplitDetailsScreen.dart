// ─── SplitDetailsScreen.dart ─────────────────────────────────────────────────
// FILE: lib/controllers/SplitDetailsScreen.dart
// CHANGES: Complete UI redesign matching the provided mockups.
//   - Gradient header card with total + paid-by info
//   - Horizontal scrollable transaction chips (shows narration + amount)
//   - Member split list with avatar initials + amount badges
//   - Responsive sizing using MediaQuery

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/collections_model.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

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
  static const orange = Color(0xFFFF8C69);
  static const red = Color(0xFFEF4444);
}

class SplitDetailsScreen extends StatelessWidget {
  final SplitModel split;

  const SplitDetailsScreen({super.key, required this.split});

  @override
  Widget build(BuildContext context) {
    final total = split.splits.fold(0.0, (sum, e) => sum + e.amount);
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.045;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.018),

            // ── GRADIENT HEADER CARD
            _HeaderCard(total: total, split: split, hPad: hPad),

            SizedBox(height: size.height * 0.022),

            // ── TRANSACTIONS SECTION
            if (split.transactionIds.isNotEmpty) ...[
              _SectionTitle(label: 'Linked Transactions', hPad: hPad),
              const SizedBox(height: 10),
              _TransactionsList(split: split, hPad: hPad),
              SizedBox(height: size.height * 0.022),
            ],

            // ── PEOPLE INVOLVED
            _SectionTitle(
              label: 'People Involved',
              hPad: hPad,
              trailing: '${split.splits.length} people',
            ),
            const SizedBox(height: 10),
            _MembersList(split: split, hPad: hPad),
            SizedBox(height: size.height * 0.04),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
                  'Split Details',
                  style: FontManager().getTextStyle(context,
                      fontSize: 17,
                      lWeight: FontWeight.w700,
                      color: _C.textDark),
                ),
                const Spacer(),
                const SizedBox(width: 38), // balance
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── HEADER CARD ───────────────────────
class _HeaderCard extends StatelessWidget {
  final double total;
  final SplitModel split;
  final double hPad;

  const _HeaderCard(
      {required this.total, required this.split, required this.hPad});

  @override
  Widget build(BuildContext context) {
    final name = split.paidByUser?.name ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final date = split.createdAt != null ? _formatDate(split.createdAt!) : '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D2B5B), Color(0xFF4B4D73)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _C.navy.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: FontManager().getTextStyle(context,
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.65),
                          lWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: FontManager().getTextStyle(context,
                          fontSize: 32,
                          lWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.green.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.green.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 13, color: _C.green),
                      const SizedBox(width: 5),
                      Text(
                        split.splitType.isNotEmpty
                            ? _capitalize(split.splitType)
                            : 'Shared',
                        style: FontManager().getTextStyle(context,
                            fontSize: 12,
                            lWeight: FontWeight.w600,
                            color: _C.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            Divider(color: Colors.white.withOpacity(0.12), height: 1),
            const SizedBox(height: 16),

            // Paid by + date
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: FontManager().getTextStyle(context,
                          color: Colors.white,
                          lWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paid by',
                      style: FontManager().getTextStyle(context,
                          fontSize: 11, color: Colors.white.withOpacity(0.55)),
                    ),
                    Text(
                      name,
                      style: FontManager().getTextStyle(context,
                          fontSize: 14,
                          lWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ],
                ),
                const Spacer(),
                if (date.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(width: 5),
                      Text(
                        date,
                        style: FontManager().getTextStyle(context,
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.65)),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const m = [
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
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;
}

// ─────────────────────── SECTION TITLE ───────────────────────
class _SectionTitle extends StatelessWidget {
  final String label;
  final double hPad;
  final String? trailing;

  const _SectionTitle({required this.label, required this.hPad, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FontManager().getTextStyle(context,
                fontSize: 15, lWeight: FontWeight.w700, color: _C.textDark),
          ),
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _C.navyBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trailing!,
                style: FontManager().getTextStyle(context,
                    fontSize: 11, lWeight: FontWeight.w600, color: _C.navy),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────── TRANSACTIONS LIST ───────────────────────
class _TransactionsList extends StatelessWidget {
  final SplitModel split;
  final double hPad;

  const _TransactionsList({required this.split, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: hPad),
      itemCount: split.transactionIds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final tx = split.transactionIds[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _C.navyBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: _C.navy, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.narration ?? 'Transaction',
                      style: FontManager().getTextStyle(context,
                          fontSize: 13,
                          lWeight: FontWeight.w600,
                          color: _C.textDark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tx.transactionTimestamp != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _formatTs(tx.transactionTimestamp.toString()),
                        style: FontManager().getTextStyle(context,
                            fontSize: 11, color: _C.textLight),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${tx.amount.toStringAsFixed(0)}',
                    style: FontManager().getTextStyle(context,
                        fontSize: 14, lWeight: FontWeight.w800, color: _C.navy),
                  ),
                  const SizedBox(height: 3),
                  GestureDetector(
                    onTap: () {
                      if (tx.id.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: tx.id));
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Transaction ID copied'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 11, color: _C.textLight),
                        SizedBox(width: 3),
                        Text(
                          'Copy ID',
                          style: FontManager().getTextStyle(context,
                              fontSize: 10, color: _C.textLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTs(String ts) {
    try {
      final dt = DateTime.parse(ts);
      const m = [
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
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${m[dt.month - 1]} ${dt.year} at $h:$min $ampm';
    } catch (_) {
      return ts;
    }
  }
}

// ─────────────────────── MEMBERS LIST ───────────────────────
class _MembersList extends StatelessWidget {
  final SplitModel split;
  final double hPad;

  const _MembersList({required this.split, required this.hPad});

  static const List<Color> _avatarColors = [
    Color(0xFF2D2B5B),
    Color(0xFF4B4D73),
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
  ];

  @override
  Widget build(BuildContext context) {
    final total = split.splits.fold(0.0, (s, e) => s + e.amount);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: hPad),
      itemCount: split.splits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final s = split.splits[i];
        final name = s.user?.name ?? 'User';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
        final color = _avatarColors[i % _avatarColors.length];
        final pct = total > 0 ? (s.amount / total * 100) : 0.0;
        final isMe = s.userId == split.paidBy;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMe ? _C.navy.withOpacity(0.25) : _C.border,
              width: isMe ? 1.5 : 1,
            ),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: FontManager().getTextStyle(context,
                        color: Colors.white,
                        lWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name + percentage
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: FontManager().getTextStyle(context,
                              fontSize: 14,
                              lWeight: FontWeight.w700,
                              color: _C.textDark),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: _C.navyBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'You',
                              style: FontManager().getTextStyle(context,
                                  fontSize: 10,
                                  lWeight: FontWeight.w700,
                                  color: _C.navy),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pct.toStringAsFixed(1)}% of total',
                      style: FontManager().getTextStyle(context,
                          fontSize: 12, color: _C.textMid),
                    ),
                  ],
                ),
              ),

              // Amount badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _C.greenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₹${s.amount.toStringAsFixed(0)}',
                  style: FontManager().getTextStyle(context,
                      fontSize: 14, lWeight: FontWeight.w800, color: _C.green),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
