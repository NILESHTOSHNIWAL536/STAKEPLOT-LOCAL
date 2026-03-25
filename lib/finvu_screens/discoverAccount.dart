import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';

import '../controllers/fipmetrics-controller.dart';
import '../loginservices/login.dart';
import 'integration.dart';
import 'shareAccountLogin.dart';

// ── Filter options ─────────────────────────────────────────────────────────

enum _StatusFilter { all, live, slow, down }

extension _StatusFilterExt on _StatusFilter {
  String get label {
    switch (this) {
      case _StatusFilter.all:
        return 'All';
      case _StatusFilter.live:
        return 'Live';
      case _StatusFilter.slow:
        return 'Slow';
      case _StatusFilter.down:
        return 'Down';
    }
  }

  Color? get dotColor {
    switch (this) {
      case _StatusFilter.all:
        return null;
      case _StatusFilter.live:
        return const Color(0xFF43A047);
      case _StatusFilter.slow:
        return const Color(0xFFFB8C00);
      case _StatusFilter.down:
        return const Color(0xFFE53935);
    }
  }

  bool matchesStatus(FipHealthStatus s) {
    switch (this) {
      case _StatusFilter.all:
        return true;
      case _StatusFilter.live:
        return s == FipHealthStatus.healthy;
      case _StatusFilter.slow:
        return s == FipHealthStatus.degraded;
      case _StatusFilter.down:
        return s == FipHealthStatus.down;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Screen
// ══════════════════════════════════════════════════════════════════════════════

class DiscoverAccount extends StatefulWidget {
  const DiscoverAccount({Key? key}) : super(key: key);

  @override
  _DiscoverAccountState createState() => _DiscoverAccountState();
}

class _DiscoverAccountState extends State<DiscoverAccount> {
  final TextEditingController _search = TextEditingController();
  final Rx<_StatusFilter> _activeFilter = _StatusFilter.all.obs;

  FipMetricsController? get _metrics =>
      Get.isRegistered<FipMetricsController>() ? FipMetricsController.to : null;

  List<FinvuFIPInfo> get _filteredList {
    final q = _search.text.toLowerCase();
    return fipDis.where((b) {
      final matchQ = q.isEmpty ||
          b.productName.toString().toLowerCase().contains(q) ||
          b.fipId.toLowerCase().contains(q);
      final status = _metrics?.healthFor(b.fipId) ?? FipHealthStatus.unknown;
      return matchQ && _activeFilter.value.matchesStatus(status);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    bankImageAndid.clear();
    _loadBanks();
    getFetch.value = false;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _loadBanks() async {
    fipDis = await finvuManager.fipsAllFIPOptions();
    fipDisOrginal
      ..clear()
      ..addAll(fipDis);
    for (final b in fipDis) {
      bankImageAndid[b.fipId] = b.productIconUri.toString();
    }
    getBanks.value = !getBanks.value;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: getAppBar(context),
      extendBody: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(
                FinvuStrings().pickAtLeastOne,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.bg1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(
                controller: _search,
                onChanged: (_) {
                  Future.delayed(
                    const Duration(milliseconds: 250),
                    () => getBanks.value = !getBanks.value,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => _FilterPills(
                  active: _activeFilter.value,
                  onTap: (f) => _activeFilter.value = f,
                )),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                getBanks.value;
                addCheck.value;
                _activeFilter.value;
                final list = _filteredList;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No banks found',
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 14,
                        color: AppColors.bg3,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final bank = list[i];
                    final messages =
                        _metrics?.discoveryMessages(bank.fipId) ?? [];
                    return _BankRow(
                      bankData: bank,
                      isSelected: isSeletedBankAccout.contains(bank.fipId),
                      metrics: _metrics,
                      messages: messages,
                      onTap: () => _toggle(
                        !isSeletedBankAccout.contains(bank.fipId),
                        bank,
                      ),
                      onCheckChanged: (val) => _toggle(val, bank),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              addBank.value;
              final n = isSeletedBankAccout.length;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: n > 0
                    ? Padding(
                        key: ValueKey(n),
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          '$n bank${n > 1 ? 's' : ''} selected',
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 12,
                            color: AppColors.bg3,
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey(0), height: 8),
              );
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    count.value = 0;
                    count.refresh();
                    _onContinue();
                  },
                  child: getButton(context, 'Continue'),
                ),
              ),
            ),
            const BottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  void _toggle(bool? value, FinvuFIPInfo bankData) {
    if (value == true) {
      if (!isSeletedBankAccout.contains(bankData.fipId)) {
        isSeletedBankAccout.add(bankData.fipId);
        listOfBankAccount.add(bankData);
      }
    } else {
      isSeletedBankAccout.remove(bankData.fipId);
      listOfBankAccount.removeWhere((item) => item.fipId == bankData.fipId);
    }
    fipIdSeleted.value = bankData.fipId;
    addBank.value = !addBank.value;
    addCheck.value = !addCheck.value;
  }

  void _onContinue() {
    if (listOfBankAccount.isEmpty) {
      snackBarCalledfail(context, SnackbarData().pickOneBank, Colorcodes.red);
      return;
    }
    storeMapOfImagesInBackend();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LinkingAccount(listOfBankAccount: listOfBankAccount),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Bank row card  — health badge + discovery user messages
// ══════════════════════════════════════════════════════════════════════════════

class _BankRow extends StatefulWidget {
  final FinvuFIPInfo bankData;
  final bool isSelected;
  final FipMetricsController? metrics;
  final List<FipUserMessage> messages;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckChanged;

  const _BankRow({
    required this.bankData,
    required this.isSelected,
    required this.metrics,
    required this.messages,
    required this.onTap,
    required this.onCheckChanged,
  });

  @override
  State<_BankRow> createState() => _BankRowState();
}

class _BankRowState extends State<_BankRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.metrics?.healthFor(widget.bankData.fipId) ??
        FipHealthStatus.unknown;
    final latency = widget.metrics?.avgLatencyFor(widget.bankData.fipId) ?? 0;
    final cfg = _BadgeConfig.from(status);

    // Pick the worst message to show inline (error > warning > info)
    final FipUserMessage? topMsg = _topMessage(widget.messages);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppColors.primaryColor.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primaryColor.withOpacity(0.4)
                : const Color(0xFFE5E5EA),
            width: widget.isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main row ────────────────────────────────────────────────────
            Row(
              children: [
                _Logo(bankData: widget.bankData),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bank name
                      Text(
                        widget.bankData.productName.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),

                      if (status != FipHealthStatus.unknown) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Health badge
                            _StatusBadge(cfg: cfg),

                            // Latency
                            if (latency > 0 &&
                                status != FipHealthStatus.down) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${latency.toStringAsFixed(0)} ms',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ],

                            // Expand toggle if there are messages
                            if (widget.messages.isNotEmpty) ...[
                              const Spacer(),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _expanded = !_expanded),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _expanded ? 'Less' : 'Details',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      _expanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      size: 14,
                                      color: AppColors.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _CheckBox(
                  value: widget.isSelected,
                  onChanged: widget.onCheckChanged,
                  activeColor: AppColors.primaryColor,
                ),
              ],
            ),

            // ── Inline top message (always visible when not expanded) ────────
            if (!_expanded &&
                topMsg != null &&
                status != FipHealthStatus.healthy) ...[
              const SizedBox(height: 8),
              _InlineMessage(message: topMsg),
            ],

            // ── Expanded message list ────────────────────────────────────────
            if (_expanded && widget.messages.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(
                  height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 8),
              ...widget.messages.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _InlineMessage(message: m),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  /// Returns the highest-severity message: error > warning > info
  FipUserMessage? _topMessage(List<FipUserMessage> msgs) {
    if (msgs.isEmpty) return null;
    final errors = msgs.where((m) => m.severity == FipMessageSeverity.error);
    final warnings =
        msgs.where((m) => m.severity == FipMessageSeverity.warning);
    if (errors.isNotEmpty) return errors.first;
    if (warnings.isNotEmpty) return warnings.first;
    return msgs.first;
  }
}

// ── Inline user message chip ──────────────────────────────────────────────

class _InlineMessage extends StatelessWidget {
  final FipUserMessage message;
  const _InlineMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = _msgColors(message.severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 0.7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(colors.icon, size: 14, color: colors.iconColor),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.detail,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.detailColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _MsgColors _msgColors(FipMessageSeverity s) {
    switch (s) {
      case FipMessageSeverity.error:
        return _MsgColors(
          bg: const Color(0xFFFFEBEE),
          border: const Color(0xFFEF9A9A),
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFE53935),
          titleColor: const Color(0xFFC62828),
          detailColor: const Color(0xFFB71C1C),
        );
      case FipMessageSeverity.warning:
        return _MsgColors(
          bg: const Color(0xFFFFF8E1),
          border: const Color(0xFFFFCC80),
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFFB8C00),
          titleColor: const Color(0xFFE65100),
          detailColor: const Color(0xFFBF360C),
        );
      case FipMessageSeverity.info:
        return _MsgColors(
          bg: const Color(0xFFE3F2FD),
          border: const Color(0xFF90CAF9),
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF1976D2),
          titleColor: const Color(0xFF0D47A1),
          detailColor: const Color(0xFF1565C0),
        );
    }
  }
}

class _MsgColors {
  final Color bg, border, iconColor, titleColor, detailColor;
  final IconData icon;
  const _MsgColors({
    required this.bg,
    required this.border,
    required this.icon,
    required this.iconColor,
    required this.titleColor,
    required this.detailColor,
  });
}

// ── Status badge ──────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _BadgeConfig cfg;
  const _StatusBadge({required this.cfg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cfg.border, width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: cfg.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            cfg.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: cfg.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.name,
              style: TextStyle(fontSize: 14, color: AppColors.bg1),
              decoration: InputDecoration(
                hintText: FinvuStrings().searchForBanks,
                hintStyle: TextStyle(fontSize: 14, color: AppColors.bg3),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

// ── Filter pills ──────────────────────────────────────────────────────────

class _FilterPills extends StatelessWidget {
  final _StatusFilter active;
  final ValueChanged<_StatusFilter> onTap;
  const _FilterPills({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _StatusFilter.values.map((f) {
          final isActive = f == active;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryColor : AppColors.button,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primaryColor : AppColors.border,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f.dotColor != null) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white70 : f.dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      f.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : AppColors.bg2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Logo with initials fallback ──────────────────────────────────────────

class _Logo extends StatelessWidget {
  final FinvuFIPInfo bankData;
  const _Logo({required this.bankData});

  static const _pairs = [
    [Color(0xFFE8F0FE), Color(0xFF1A56C4)],
    [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    [Color(0xFFFCE4EC), Color(0xFF880E4F)],
    [Color(0xFFFFF3E0), Color(0xFFE65100)],
    [Color(0xFFEDE7F6), Color(0xFF4527A0)],
    [Color(0xFFE0F2F1), Color(0xFF00695C)],
    [Color(0xFFFCE8E6), Color(0xFFC5221F)],
  ];

  List<Color> _colorPair() {
    final hash = bankData.fipId.codeUnits.fold(0, (a, b) => a + b);
    return _pairs[hash % _pairs.length];
  }

  String _initials() {
    final name = bankData.productName?.toString() ?? bankData.fipId;
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final uri = bankData.productIconUri?.toString() ?? '';
    final colors = _colorPair();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 46,
        height: 46,
        child: uri.isNotEmpty
            ? Image.network(
                uri,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _fallback(colors),
              )
            : _fallback(colors),
      ),
    );
  }

  Widget _fallback(List<Color> colors) => Container(
        color: colors[0],
        alignment: Alignment.center,
        child: Text(
          _initials(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors[1],
          ),
        ),
      );
}

// ── Custom checkbox ───────────────────────────────────────────────────────

class _CheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color activeColor;
  const _CheckBox(
      {required this.value,
      required this.onChanged,
      required this.activeColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value ? activeColor : const Color(0xFFD1D1D6),
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
            : null,
      ),
    );
  }
}

// ── Badge config ──────────────────────────────────────────────────────────

class _BadgeConfig {
  final String label;
  final Color bg, border, dot, text;

  const _BadgeConfig({
    required this.label,
    required this.bg,
    required this.border,
    required this.dot,
    required this.text,
  });

  factory _BadgeConfig.from(FipHealthStatus status) {
    switch (status) {
      case FipHealthStatus.healthy:
        return const _BadgeConfig(
          label: 'Live',
          bg: Color(0xFFE8F5E9),
          border: Color(0xFFA5D6A7),
          dot: Color(0xFF43A047),
          text: Color(0xFF2E7D32),
        );
      case FipHealthStatus.degraded:
        return const _BadgeConfig(
          label: 'Slow',
          bg: Color(0xFFFFF8E1),
          border: Color(0xFFFFCC80),
          dot: Color(0xFFFB8C00),
          text: Color(0xFFE65100),
        );
      case FipHealthStatus.down:
        return const _BadgeConfig(
          label: 'Down',
          bg: Color(0xFFFFEBEE),
          border: Color(0xFFEF9A9A),
          dot: Color(0xFFE53935),
          text: Color(0xFFC62828),
        );
      case FipHealthStatus.unknown:
        return const _BadgeConfig(
          label: 'Unknown',
          bg: Color(0xFFF5F5F5),
          border: Color(0xFFE0E0E0),
          dot: Color(0xFFBDBDBD),
          text: Color(0xFF9E9E9E),
        );
    }
  }
}
