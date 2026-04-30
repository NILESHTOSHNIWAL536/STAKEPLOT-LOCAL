// ============================================================
//  create_budget_screen.dart
//  Multi-step budget creation wizard (5 pages).
//
//  Steps:
//    0 – Add budget name
//    1 – Add budget amount
//    2 – Select duration
//    3 – Add categories  (select from grid)
//    4 – Allocate amounts per category  (eq-split, editable)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../image_service/avatarProfile.dart';
import 'budget_assets.dart';
import 'budget_controller.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

// ────────────────────────────────────────────────────────────
//  Theme constants  (match your app palette)
// ────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF4A4580);
const _kBg = Color(0xFFF5F0E8);
const _kCard = Colors.white;
const _kText = Color(0xFF1E1E3A);
const _kSubText = Color(0xFF8A8A9A);

// ────────────────────────────────────────────────────────────
//  Root entry-point widget
// ────────────────────────────────────────────────────────────
class CreateBudgetScreen extends StatelessWidget {
  const CreateBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(BudgetController());
    return Scaffold(
      backgroundColor: _kBg,
      body: Obx(() => _buildStep(ctrl, context)),
    );
  }

  Widget _buildStep(BudgetController ctrl, BuildContext context) {
    switch (ctrl.currentStep.value) {
      case 0:
        return _NameStep(ctrl: ctrl);
      case 1:
        return _AmountStep(ctrl: ctrl);
      case 2:
        return _DurationStep(ctrl: ctrl);
      case 3:
        return _CategorySelectStep(ctrl: ctrl);
      case 4:
        return _CategoryAmountStep(ctrl: ctrl);
      default:
        return _NameStep(ctrl: ctrl);
    }
  }
}

// ────────────────────────────────────────────────────────────
//  Shared scaffold with header + content area
// ────────────────────────────────────────────────────────────
class _StepScaffold extends StatelessWidget {
  final BudgetController ctrl;
  final String title;
  final Widget child;
  final Widget? bottomButton;
  final bool showBack;

  const _StepScaffold({
    required this.ctrl,
    required this.title,
    required this.child,
    this.bottomButton,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: title, showBack: showBack, onBack: ctrl.prevStep),
            Expanded(child: child),
            if (bottomButton != null) bottomButton!,
          ],
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.showBack,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
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
          if (showBack)
            GestureDetector(
              onTap: onBack,
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
            )
          else
            const SizedBox(width: 40),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: FontManager().getTextStyle(context,
                  color: Colors.white, fontSize: 18, lWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ── Done / Next button ───────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    this.enabled = true,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: (enabled && !loading) ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimary,
            disabledBackgroundColor: _kPrimary.withOpacity(0.4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: loading
              ? const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2)
              : Text(label,
                  style: FontManager().getTextStyle(context,
                      color: Colors.white,
                      fontSize: 16,
                      lWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
//  STEP 0 — Budget Name
// ────────────────────────────────────────────────────────────
class _NameStep extends StatelessWidget {
  final BudgetController ctrl;
  const _NameStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      ctrl: ctrl,
      title: 'Create Budget',
      showBack: false,
      bottomButton: Obx(() => _PrimaryButton(
            label: 'Next',
            enabled: ctrl.budgetName.value.trim().isNotEmpty,
            onTap: ctrl.nextStep,
          )),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text('Add budget name',
                style: FontManager().getTextStyle(context,
                    color: _kText, fontSize: 22, lWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            // Illustration
            _Illustration(assetKey: 'addName', height: 220),
            const SizedBox(height: 40),
            // Name field
            _RoundedTextField(
              controller: ctrl.nameController,
              hint: 'Enter budget name',
              onChanged: (v) => ctrl.budgetName.value = v,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
//  STEP 1 — Budget Amount
// ────────────────────────────────────────────────────────────
class _AmountStep extends StatelessWidget {
  final BudgetController ctrl;
  const _AmountStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      ctrl: ctrl,
      title: 'Create Budget',
      bottomButton: Obx(() => _PrimaryButton(
            label: 'Next',
            enabled: ctrl.totalAmount.value > 0,
            onTap: ctrl.nextStep,
          )),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text('Add budget amount',
                style: FontManager().getTextStyle(context,
                    color: _kText, fontSize: 22, lWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _Illustration(assetKey: 'addAmount', height: 220),
            const SizedBox(height: 40),
            _RoundedTextField(
              controller: ctrl.amountController,
              hint: 'Enter budget amount',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              prefix: Text('₹ ',
                  style: FontManager().getTextStyle(context,
                      color: _kText, fontSize: 16, lWeight: FontWeight.w600)),
              onChanged: (v) {
                ctrl.totalAmount.value = double.tryParse(v) ?? 0;
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
//  STEP 2 — Select Duration
// ────────────────────────────────────────────────────────────
class _DurationStep extends StatelessWidget {
  final BudgetController ctrl;
  const _DurationStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      ctrl: ctrl,
      title: 'Create Budget',
      bottomButton: _PrimaryButton(
        label: 'Next',
        onTap: ctrl.nextStep,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text('Select duration',
                style: FontManager().getTextStyle(context,
                    color: _kText, fontSize: 22, lWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _Illustration(assetKey: 'selectDuration', height: 220),
            const SizedBox(height: 32),
            Obx(() => Column(
                  children: budgetDurationOptions.map((opt) {
                    final days = opt['value'] as int;
                    final selected = ctrl.selectedDurationDays.value == days;
                    return _DurationTile(
                      label: opt['label'] as String,
                      selected: selected,
                      onTap: () => ctrl.selectedDurationDays.value = days,
                    );
                  }).toList(),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DurationTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kPrimary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: FontManager().getTextStyle(context,
                    color: selected ? _kPrimary : _kText,
                    fontSize: 16,
                    lWeight: selected ? FontWeight.w600 : FontWeight.normal)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? _kPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected ? _kPrimary : _kSubText,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
//  STEP 3 — Category selection grid
// ────────────────────────────────────────────────────────────
class _CategorySelectStep extends StatelessWidget {
  final BudgetController ctrl;
  const _CategorySelectStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      ctrl: ctrl,
      title: 'Create Budget',
      bottomButton: Obx(() => _PrimaryButton(
            label: 'Done',
            enabled: ctrl.selectedCategoryNames.isNotEmpty,
            onTap: ctrl.nextStep,
          )),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text('Add categories',
              style: FontManager().getTextStyle(context,
                  color: _kText, fontSize: 22, lWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _Illustration(assetKey: 'addCategories', height: 160),
          const SizedBox(height: 16),

          // Search-style header bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add categories',
                      style: FontManager().getTextStyle(context,
                          color: _kSubText, fontSize: 15)),
                  Icon(Icons.add, color: _kSubText),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.85,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: budgetCategories.length,
                    itemBuilder: (_, i) {
                      final cat = budgetCategories[i];
                      final name = cat['name'] as String;
                      final selected =
                          ctrl.selectedCategoryNames.contains(name);
                      return _CategoryGridItem(
                        name: name,
                        icon: cat['icon'] as String,
                        color: cat['color'] as String,
                        selected: selected,
                        onTap: () => ctrl.toggleCategory(name),
                      );
                    },
                  )),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  final String name;
  final String icon;
  final String color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryGridItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Color(int.parse(color));
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      selected ? Border.all(color: _kPrimary, width: 2) : null,
                ),
                child: Center(
                  child: _CategoryIcon(assetPath: icon, color: c),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FontManager().getTextStyle(context,
                    fontSize: 10,
                    color: selected ? _kPrimary : _kText,
                    lWeight: selected ? FontWeight.w600 : FontWeight.normal),
              ),
            ],
          ),
          if (selected)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: _kPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 10),
              ),
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
//  STEP 4 — Category amount allocation
// ────────────────────────────────────────────────────────────
class _CategoryAmountStep extends StatelessWidget {
  final BudgetController ctrl;
  const _CategoryAmountStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      ctrl: ctrl,
      title: 'Create Budget',
      bottomButton: Obx(() => _PrimaryButton(
            label: 'Done',
            enabled: ctrl.isDoneEnabled,
            loading: ctrl.isCreating.value,
            onTap: () => ctrl.createBudget(context),
          )),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text('Add categories',
              style: FontManager().getTextStyle(context,
                  color: _kText, fontSize: 22, lWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _Illustration(assetKey: 'addCategories', height: 140),
          const SizedBox(height: 8),

          // Balance indicator
          Obx(() {
            final diff = ctrl.totalAmount.value - ctrl.categorySum;
            final balanced = diff.abs() < 0.01;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ₹${ctrl.totalAmount.value.toStringAsFixed(0)}',
                    style: FontManager()
                        .getTextStyle(context, color: _kSubText, fontSize: 13),
                  ),
                  Text(
                    balanced
                        ? '✓ Balanced'
                        : (diff > 0
                            ? '₹${diff.toStringAsFixed(0)} remaining'
                            : '₹${(-diff).toStringAsFixed(0)} over budget'),
                    style: FontManager().getTextStyle(context,
                        color: balanced ? Colors.green : Colors.redAccent,
                        fontSize: 13,
                        lWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),

          // Category list
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: ctrl.categoryItems.length,
                  itemBuilder: (_, i) => _CategoryAmountTile(
                    ctrl: ctrl,
                    index: i,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

class _CategoryAmountTile extends StatefulWidget {
  final BudgetController ctrl;
  final int index;
  const _CategoryAmountTile({required this.ctrl, required this.index});

  @override
  State<_CategoryAmountTile> createState() => _CategoryAmountTileState();
}

class _CategoryAmountTileState extends State<_CategoryAmountTile> {
  late TextEditingController _textCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final item = widget.ctrl.categoryItems[widget.index];
    _textCtrl = TextEditingController(text: item.amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final item = widget.ctrl.categoryItems[widget.index];

      // Sync text field if not actively editing
      if (!_isEditing) {
        final newText = item.amount.toStringAsFixed(0);
        if (_textCtrl.text != newText) {
          _textCtrl.text = newText;
          _textCtrl.selection = TextSelection.collapsed(offset: newText.length);
        }
      }

      final c = Color(int.parse(item.color));

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Center(child: _CategoryIcon(assetPath: item.icon, color: c)),
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Text(item.name,
                  style: FontManager().getTextStyle(context,
                      color: _kText, fontSize: 15, lWeight: FontWeight.w500)),
            ),
            // Amount chip + edit
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    Text('₹',
                        style: FontManager().getTextStyle(context,
                            color: Colors.white, fontSize: 13)),
                    const SizedBox(width: 2),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _textCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        onTap: () => setState(() => _isEditing = true),
                        onChanged: (v) {
                          widget.ctrl.onCategoryAmountChanged(
                              widget.index, double.tryParse(v) ?? 0);
                        },
                        onEditingComplete: () =>
                            setState(() => _isEditing = false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Remove button
            GestureDetector(
              onTap: () {
                widget.ctrl.selectedCategoryNames.remove(item.name);
                widget.ctrl.categoryItems.removeAt(widget.index);
                // widget.ctrl._redistributeRemaining();
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: _kSubText),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ────────────────────────────────────────────────────────────
//  Shared small widgets
// ────────────────────────────────────────────────────────────

/// Illustration image — falls back to a colored placeholder
/// when the asset path has not been updated yet.
class _Illustration extends StatelessWidget {
  final String assetKey;
  final double height;
  const _Illustration({required this.assetKey, required this.height});

  @override
  Widget build(BuildContext context) {
    final path = budgetStepImages[assetKey] ?? '';
    return SizedBox(
      height: height,
      child: path.isNotEmpty
          ? AvatarProfileImage(
              url: path,
              height: 5,
              width: 5,
            )
          : _placeholder(height),
    );
  }

  Widget _placeholder(double h) => Container(
        height: h,
        decoration: BoxDecoration(
          color: _kPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, color: _kPrimary, size: 48),
        ),
      );
}

/// Category icon — falls back to a generic icon
class _CategoryIcon extends StatelessWidget {
  final String assetPath;
  final Color color;
  const _CategoryIcon({required this.assetPath, required this.color});

  @override
  Widget build(BuildContext context) {
    if (assetPath.isEmpty) {
      return Icon(Icons.category_outlined, color: color, size: 22);
    }
    return Image.asset(
      assetPath,
      width: 24,
      height: 24,
      color: color,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.category_outlined, color: color, size: 22),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final ValueChanged<String> onChanged;

  const _RoundedTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(color: _kText, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _kSubText),
          prefixIcon: prefix != null
              ? Padding(padding: const EdgeInsets.only(left: 16), child: prefix)
              : null,
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
