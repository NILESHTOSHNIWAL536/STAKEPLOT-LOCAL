// ============================================================
//  budget_detail_screen.dart
//  "Budget Planner" + "Trip to Goa" detail view.
//  Matches screenshots: Image 1 (Trip to Goa) & Image 9 (Budget Planner).
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'budget_controller.dart';

const _kPrimary  = Color(0xFF4A4580);
const _kBg       = Color(0xFFF5F0E8);
const _kCard     = Colors.white;
const _kText     = Color(0xFF1E1E3A);
const _kSubText  = Color(0xFF8A8A9A);
const _kDark     = Color(0xFF2A2860);

class BudgetDetailScreen extends StatelessWidget {
  const BudgetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl   = Get.find<BudgetController>();
    final budget = ctrl.selectedBudget.value;

    if (budget == null) {
      return const Scaffold(
          body: Center(child: Text('No budget selected')));
    }

    final name       = budget['name']        as String? ?? '';
    final amount     = (budget['amount']     as num?)?.toDouble() ?? 0;
    final spent      = (budget['spent']      as num?)?.toDouble() ?? 0;
    final daysLeft   = (budget['daysLeft']   as num?)?.toInt()    ?? 0;
    final remaining  = amount - spent;
    final progress   = amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
    final cats = (budget['categoryBudgets'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ?? [];

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────
            SliverToBoxAdapter(
              child: _buildHeader(context, name),
            ),

            // ── Summary card ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SummaryCard(
                  name:      name,
                  amount:    amount,
                  spent:     spent,
                  remaining: remaining,
                  progress:  progress,
                  daysLeft:  daysLeft,
                  cats:      cats,
                ),
              ),
            ),

            // ── Stats strip ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _StatsStrip(
                    spent: spent,
                    remaining: remaining,
                    daysLeft: daysLeft),
              ),
            ),

            // ── Chart section ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expenses chart',
                        style: TextStyle(
                            color:      _kText,
                            fontSize:   17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Obx(() => _ChartCard(
                          data:      ctrl.chartData,
                          maxAmount: spent,
                          isLoading: ctrl.isLoadingDetail.value,
                        )),
                  ],
                ),
              ),
            ),

            // ── Category breakdown ───────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: const Text('Category Breakdown',
                    style: TextStyle(
                        color:      _kText,
                        fontSize:   17,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: _CategoryRow(cat: cats[i]),
                ),
                childCount: cats.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5A5490), Color(0xFF4A4580)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 20),
            ),
          ),
          Expanded(
            child: Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ── Summary card ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String name;
  final double amount, spent, remaining, progress;
  final int    daysLeft;
  final List<Map<String, dynamic>> cats;

  const _SummaryCard({
    required this.name,
    required this.amount,
    required this.spent,
    required this.remaining,
    required this.progress,
    required this.daysLeft,
    required this.cats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color:      _kText,
                            fontSize:   18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('₹${_fmt(amount)} Total amount',
                        style: const TextStyle(
                            color: _kSubText, fontSize: 13)),
                  ],
                ),
              ),
              // Travellers illustration placeholder
              Container(
                width: 80, height: 60,
                decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.luggage_outlined,
                    color: _kPrimary, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value:           progress,
              minHeight:       7,
              backgroundColor: Colors.grey.shade200,
              color:           _kPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Spent / remaining tags
          Row(
            children: [
              _InfoTag(label: 'Spent ₹${_fmt(spent)}'),
              const SizedBox(width: 10),
              _InfoTag(label: 'Remaining ₹${_fmt(remaining)}'),
            ],
          ),
          const SizedBox(height: 14),

          // Days left + categories
          Row(
            children: [
              _IconInfoBox(
                icon:  Icons.calendar_today_outlined,
                label: '$daysLeft days left',
              ),
              const SizedBox(width: 12),
              if (cats.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:        _kBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('Categories',
                            style: TextStyle(
                                color:    _kSubText,
                                fontSize: 12)),
                        const SizedBox(width: 8),
                        ...cats.take(4).map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              width:  28, height: 28,
                              decoration: BoxDecoration(
                                color:        _kPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(Icons.category_outlined,
                                  size: 14, color: _kPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '${(v / 1000).toStringAsFixed(0)},${(v % 1000).toStringAsFixed(0).padLeft(3, '0')}';
    return v.toStringAsFixed(0);
  }
}

class _InfoTag extends StatelessWidget {
  final String label;
  const _InfoTag({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: _kBg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label,
        style: const TextStyle(color: _kSubText, fontSize: 12)),
  );
}

class _IconInfoBox extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _IconInfoBox({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color:        _kBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: _kSubText),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(color: _kText, fontSize: 13)),
      ],
    ),
  );
}

// ── Stats strip ──────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final double spent, remaining;
  final int daysLeft;
  const _StatsStrip({
    required this.spent,
    required this.remaining,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        _kDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StatCell(label: 'Spent',     value: '₹${_fmt(spent)}'),
          _Divider(),
          _StatCell(label: 'Left',      value: '₹${_fmt(remaining)}'),
          _Divider(),
          _StatCell(label: 'Days left', value: '$daysLeft'),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹${v.toStringAsFixed(0)}';
  }
}

class _StatCell extends StatelessWidget {
  final String label, value;
  const _StatCell({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color:      Colors.white,
                  fontSize:   16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color:    Colors.white60,
                  fontSize: 11)),
        ],
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1, height: 40,
      color: Colors.white.withOpacity(0.2));
}

// ── Chart card ───────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double maxAmount;
  final bool   isLoading;

  const _ChartCard({
    required this.data,
    required this.maxAmount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          )
        ],
      ),
      child: isLoading
          ? const SizedBox(
              height: 140,
              child: Center(
                child: CircularProgressIndicator(
                    color: _kPrimary, strokeWidth: 2),
              ))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:        _kBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '₹${_fmtMax()}',
                        style: const TextStyle(
                            color:      _kText,
                            fontSize:   13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                SizedBox(
                  height: 140,
                  child: data.isEmpty
                      ? const Center(
                          child: Text('No data yet',
                              style: TextStyle(color: _kSubText)))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: data.map((d) {
                            final amt  = (d['amount'] as num?)?.toDouble() ?? 0;
                            final day  = d['day'] as String? ?? '';
                            final maxV = _max();
                            final frac = maxV > 0 ? (amt / maxV) : 0.0;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 3),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: FractionallySizedBox(
                                        heightFactor: frac.clamp(
                                            0.05, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:        _kPrimary,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    6),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(day,
                                        style: const TextStyle(
                                            color:    _kSubText,
                                            fontSize: 10)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
    );
  }

  double _max() => data.fold(0.0,
      (m, d) => ((d['amount'] as num?)?.toDouble() ?? 0) > m
          ? (d['amount'] as num).toDouble()
          : m);

  String _fmtMax() {
    final m = _max();
    if (m >= 1000) return '₹${(m / 1000).toStringAsFixed(0)},${(m % 1000).toStringAsFixed(0).padLeft(3, '0')}';
    return '₹${m.toStringAsFixed(0)}';
  }
}

// ── Category row ─────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final Map<String, dynamic> cat;
  const _CategoryRow({required this.cat});

  @override
  Widget build(BuildContext context) {
    final name    = cat['category'] as String? ?? '';
    final budget  = (cat['amount']  as num?)?.toDouble() ?? 0;
    final spent   = (cat['spent']   as num?)?.toDouble() ?? 0;
    final left    = budget - spent;
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width:  42, height: 42,
            decoration: BoxDecoration(
              color:        _kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant_outlined,
                color: _kPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color:      _kText,
                            fontSize:   14,
                            fontWeight: FontWeight.w600)),
                    Text('₹${left.toStringAsFixed(0)} left',
                        style: const TextStyle(
                            color:      _kPrimary,
                            fontSize:   13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Spent ${spent.toStringAsFixed(0)} of ${budget.toStringAsFixed(0)}',
                  style:
                      const TextStyle(color: _kSubText, fontSize: 11),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           progress,
                    minHeight:       5,
                    backgroundColor: Colors.grey.shade200,
                    color:           _kPrimary,
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
