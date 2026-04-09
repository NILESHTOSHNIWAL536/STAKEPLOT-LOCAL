// ============================================================
//  budget_planner_screen.dart
//  "Budget Planner" — top-level screen with + button.
//  Matches screenshot: Image 9 (Vacation Budget header + categories).
//  Entry point: replace your current navigation target with this.
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'budget_controller.dart';
import 'budget_detail_screen.dart';
import 'create_budget_screen.dart';

const _kPrimary = Color(0xFF4A4580);
const _kBg      = Color(0xFFF5F0E8);
const _kCard    = Colors.white;
const _kText    = Color(0xFF1E1E3A);
const _kSubText = Color(0xFF8A8A9A);
const _kDark    = Color(0xFF2A2860);

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  late final BudgetController ctrl;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(BudgetController());
    ctrl.fetchAllBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────
  Widget _buildHeader(BuildContext context) {
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
          const Expanded(
            child: Text('Budget Planner',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
          GestureDetector(
            onTap: () {
              ctrl.startFreshCreation();
              Get.to(() => const CreateBudgetScreen(),
                  transition: Transition.rightToLeft);
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ────────────────────────────────────
  Widget _buildBody() {
    return Obx(() {
      if (ctrl.isLoadingList.value) {
        return const Center(
          child: CircularProgressIndicator(color: _kPrimary));
      }

      if (ctrl.budgetList.isEmpty) {
        return _emptyState();
      }

      final budget = ctrl.budgetList[_selected];
      final name       = budget['name']      as String? ?? '';
      final amount     = (budget['amount']   as num?)?.toDouble() ?? 0;
      final spent      = (budget['spent']    as num?)?.toDouble() ?? 0;
      final remaining  = amount - spent;
      final daysLeft   = (budget['daysLeft'] as num?)?.toInt() ?? 0;
      final progress   = amount > 0
          ? (spent / amount).clamp(0.0, 1.0)
          : 0.0;
      final cats = (budget['categoryBudgets'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ?? [];

      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // Selected budget summary card
          _PlannerTopCard(
            name:      name,
            amount:    amount,
            remaining: remaining,
            daysLeft:  daysLeft,
            progress:  progress,
          ),
          const SizedBox(height: 12),

          // Stats strip
          _StatsStrip(
              spent: spent,
              remaining: remaining,
              daysLeft: daysLeft),
          const SizedBox(height: 20),

          // Category list
          ...cats.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CategoryPlannerRow(cat: c),
          )),

          // Budget selector tabs
          const SizedBox(height: 8),
          _buildBudgetTabs(),
        ],
      );
    });
  }

  Widget _buildBudgetTabs() {
    if (ctrl.budgetList.length <= 1) return const SizedBox.shrink();
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ctrl.budgetList.length,
        itemBuilder: (_, i) {
          final b = ctrl.budgetList[i];
          final sel = _selected == i;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:        sel ? _kPrimary : _kCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                b['name'] as String? ?? '',
                style: TextStyle(
                  color:      sel ? Colors.white : _kSubText,
                  fontSize:   13,
                  fontWeight: sel
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 72,
              color: _kPrimary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No budgets yet',
              style: TextStyle(
                  color: _kText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ctrl.startFreshCreation();
              Get.to(() => const CreateBudgetScreen(),
                  transition: Transition.rightToLeft);
            },
            icon:  const Icon(Icons.add),
            label: const Text('Create Budget'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Planner top card ─────────────────────────────────────────
class _PlannerTopCard extends StatelessWidget {
  final String name;
  final double amount, remaining, progress;
  final int daysLeft;

  const _PlannerTopCard({
    required this.name,
    required this.amount,
    required this.remaining,
    required this.daysLeft,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPrimary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      color:      _kText,
                      fontSize:   17,
                      fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color:        _kBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$daysLeft days',
                    style: const TextStyle(
                        color:    _kSubText,
                        fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('₹${_fmt(amount)}',
              style: const TextStyle(
                  color:      _kText,
                  fontSize:   24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value:           progress,
              minHeight:       8,
              backgroundColor: Colors.grey.shade200,
              color:           _kPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Left ₹${_fmt(remaining)}',
                style: const TextStyle(
                    color:    _kSubText,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)},${(v % 1000).toStringAsFixed(0).padLeft(3, '0')}' : v.toStringAsFixed(0);
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
          _Cell(label: 'Spent',     value: _fmt(spent)),
          _Sep(),
          _Cell(label: 'Left',      value: _fmt(remaining)),
          _Sep(),
          _Cell(label: 'Days left', value: '$daysLeft'),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      v >= 1000 ? '₹${(v / 1000).toStringAsFixed(0)}K' : '₹${v.toStringAsFixed(0)}';
}

class _Cell extends StatelessWidget {
  final String label, value;
  const _Cell({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 10)),
        ],
      ),
    ),
  );
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1, height: 36,
      color: Colors.white.withOpacity(0.2));
}

// ── Category planner row ─────────────────────────────────────
class _CategoryPlannerRow extends StatelessWidget {
  final Map<String, dynamic> cat;
  const _CategoryPlannerRow({required this.cat});

  @override
  Widget build(BuildContext context) {
    final name   = cat['category'] as String? ?? '';
    final budget = (cat['amount'] as num?)?.toDouble() ?? 0;
    final spent  = (cat['spent']  as num?)?.toDouble() ?? 0;
    final left   = budget - spent;
    final prog   = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

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
                const SizedBox(height: 3),
                Text('Spent ${spent.toStringAsFixed(0)} of ${budget.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: _kSubText, fontSize: 11)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           prog,
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
