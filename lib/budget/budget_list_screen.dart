// ============================================================
//  budget_list_screen.dart
//  "My Budgets" — shows all user budgets as cards.
//  Matches screenshot: Image 2 (My Budgets list).
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Utils/navigateTo.dart';
import 'budget_assets.dart';
import 'budget_controller.dart';
import 'budget_planner_screen.dart';
import 'create_budget_screen.dart';
import 'budget_detail_screen.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

const _kPrimary = Color(0xFF4A4580);
const _kBg = Color(0xFFF5F0E8);
const _kCard = Colors.white;
const _kText = Color(0xFF1E1E3A);
const _kSubText = Color(0xFF8A8A9A);

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  late final BudgetController ctrl;

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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          Expanded(
            child: Text('My Budgets',
                textAlign: TextAlign.center,
                style: FontManager().getTextStyle(context,
                    color: Colors.white,
                    fontSize: 18,
                    lWeight: FontWeight.w600)),
          ),
          GestureDetector(
            onTap: () {
              ctrl.startFreshCreation();
              Get.to(() => const CreateBudgetScreen(),
                  transition: Transition.rightToLeft);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
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
          child: CircularProgressIndicator(color: _kPrimary),
        );
      }
      if (ctrl.budgetList.isEmpty) {
        return _EmptyState(onAdd: () {
          ctrl.startFreshCreation();
          Get.to(() => const CreateBudgetScreen(),
              transition: Transition.rightToLeft);
        });
      }
      return RefreshIndicator(
        color: _kPrimary,
        onRefresh: ctrl.fetchAllBudgets,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          itemCount: ctrl.budgetList.length,
          itemBuilder: (_, i) => _BudgetCard(
            budget: ctrl.budgetList[i],
            onTap: () async {
              await ctrl.fetchBudgetDetail(ctrl.budgetList[i]);
              AppNavigator.pushReplacement(context, BudgetPlannerScreen());
              // Get.to(() => const BudgetDetailScreen(),
              //     transition: Transition.rightToLeft);
            },
            onDelete: () => _confirmDelete(context, ctrl.budgetList[i]),
          ),
        ),
      );
    });
  }

  Future<void> _confirmDelete(
      BuildContext context, Map<String, dynamic> budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Budget'),
        content: Text('Delete "${budget['name']}"?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Delete',
                  style:
                      FontManager().getTextStyle(context, color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      ctrl.deleteBudget(budget['_id'] as String);
    }
  }
}

// ── Budget Card ─────────────────────────────────────────────
class _BudgetCard extends StatelessWidget {
  final Map<String, dynamic> budget;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = budget['name'] as String? ?? '';
    final amount = (budget['amount'] as num?)?.toDouble() ?? 0;
    final spent = (budget['spent'] as num?)?.toDouble() ?? 0;
    final percentage = (budget['percentage'] as num?)?.toInt() ?? 0;
    final daysLeft = (budget['daysLeft'] as num?)?.toInt() ?? 0;
    final illKey = budget['illustration'] as String? ?? 'default';
    final progress = amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            // Illustration (right)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _BudgetIllustration(key: "illKey"),
            ),

            // Content (left)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Icon(_categoryIcon(name), color: _kPrimary, size: 20),
                    const SizedBox(width: 8),
                    Text(name,
                        style: FontManager().getTextStyle(context,
                            color: _kText,
                            fontSize: 16,
                            lWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount + badge
                Row(
                  children: [
                    Text(
                      '₹${_formatNum(amount)}',
                      style: FontManager().getTextStyle(context,
                          color: _kText,
                          fontSize: 20,
                          lWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    _Badge(label: '$percentage% spent'),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress bar
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      color: _kPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Days left
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: _kSubText, size: 14),
                    const SizedBox(width: 4),
                    Text('$daysLeft days left',
                        style: FontManager().getTextStyle(context,
                            color: _kSubText, fontSize: 12)),
                  ],
                ),
              ],
            ),

            // Three-dot menu
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showMenu(context),
                child: const Icon(Icons.more_horiz, color: _kSubText, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text('Delete Budget',
                style: FontManager().getTextStyle(context, color: Colors.red)),
            onTap: () {
              Get.back();
              onDelete();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  IconData _categoryIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('food')) return Icons.restaurant_outlined;
    if (n.contains('travel') || n.contains('trip') || n.contains('vacation'))
      return Icons.directions_car_outlined;
    if (n.contains('grocer')) return Icons.shopping_basket_outlined;
    return Icons.account_balance_wallet_outlined;
  }

  String _formatNum(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Badge ────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE8F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: FontManager().getTextStyle(context,
              color: _kPrimary, fontSize: 11, lWeight: FontWeight.w600)),
    );
  }
}

// ── Budget illustration ──────────────────────────────────────
class _BudgetIllustration extends StatelessWidget {
  final String key2;
  const _BudgetIllustration({required String key}) : key2 = key;

  @override
  Widget build(BuildContext context) {
    final path = budgetListImages[key2] ?? budgetListImages['default'] ?? '';
    if (path.isEmpty) return const SizedBox(width: 90);
    return Image.asset(
      path,
      width: 90,
      height: 90,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox(width: 90),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 72, color: _kPrimary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No budgets yet',
              style: FontManager().getTextStyle(context,
                  color: _kText, fontSize: 18, lWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tap + to create your first budget',
              style: FontManager()
                  .getTextStyle(context, color: _kSubText, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Create Budget'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
