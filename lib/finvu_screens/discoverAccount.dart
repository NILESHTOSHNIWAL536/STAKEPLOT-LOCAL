import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import '../Constants/theme_helper.dart';
import '../controllers/fipmetrics-controller.dart';
import '../loginservices/login.dart';
import 'integration.dart';

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

// ── Screen ────────────────────────────────────────────────────────────────

class DiscoverAccount extends StatefulWidget {
  const DiscoverAccount({Key? key}) : super(key: key);

  @override
  _DiscoverAccountState createState() => _DiscoverAccountState();
}

class _DiscoverAccountState extends State<DiscoverAccount> {
  final TextEditingController _search = TextEditingController();
  final Rx<_StatusFilter> _activeFilter = _StatusFilter.all.obs;

  static const _kPopularIds = ['SBI', 'HDFC', 'ICICI', 'AXIS'];

  FipMetricsController? get _metrics =>
      Get.isRegistered<FipMetricsController>() ? FipMetricsController.to : null;

  List<FinvuFIPInfo> get _filtered {
    final q = _search.text.toLowerCase();
    return fipDis.where((b) {
      final matchQ = q.isEmpty ||
          (b.productName?.toString().toLowerCase().contains(q) ?? false) ||
          b.fipId.toLowerCase().contains(q);
      final status = _metrics?.healthFor(b.fipId) ?? FipHealthStatus.unknown;
      return matchQ && _activeFilter.value.matchesStatus(status);
    }).toList();
  }

  List<FinvuFIPInfo> get _popularBanks => fipDis
      .where(
          (b) => _kPopularIds.any((id) => b.fipId.toUpperCase().contains(id)))
      .take(4)
      .toList();

  @override
  void initState() {
    super.initState();
    bankImageAndid.clear();
    _load();
    getFetch.value = false;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() async {
    fipDis = await finvuManager.fipsAllFIPOptions();
    fipDisOrginal
      ..clear()
      ..addAll(fipDis);
    for (final b in fipDis) {
      bankImageAndid[b.fipId] = b.productIconUri.toString();
    }
    getBanks.value = !getBanks.value;
  }

  void _toggle(bool? value, FinvuFIPInfo bank) {
    if (value == true) {
      if (!isSeletedBankAccout.contains(bank.fipId)) {
        isSeletedBankAccout.clear();
        listOfBankAccount.clear();

        isSeletedBankAccout.add(bank.fipId);
        listOfBankAccount.add(bank);
        // isSeletedBankAccout.add(bank.fipId);
        // listOfBankAccount.add(bank);
      }
    } else {
      // isSeletedBankAccout.remove(bank.fipId);
      // listOfBankAccount.removeWhere((b) => b.fipId == bank.fipId);
      isSeletedBankAccout.clear();
      listOfBankAccount.clear();
    }
    fipIdSeleted.value = bank.fipId;
    addBank.value = !addBank.value;
    addCheck.value = !addCheck.value;
  }

  void _continue() {
    if (listOfBankAccount.isEmpty) {
      snackBarCalledfail(context, SnackbarData().pickOneBank, Colorcodes.red);
      return;
    }
    storeMapOfImagesInBackend();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                LinkingAccount(listOfBankAccount: listOfBankAccount)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              addBank.value;
              final n = isSeletedBankAccout.length;
              return n > 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                      child: Text('$n bank${n > 1 ? 's' : ''} selected',
                          style: FontManager().getTextStyle(context,
                              fontSize: 12,
                              color: context.appColors.secondaryText)),
                    )
                  : const SizedBox(height: 6);
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: GestureDetector(
                onTap: _continue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      color: context.appColors.primary,
                      borderRadius: BorderRadius.circular(14)),
                  child: Center(
                    child: Text('Continue',
                        style: FontManager().getTextStyle(context,
                            fontSize: 16,
                            lWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ),
            ),
            const BottomBar(),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            _TopBar(onBack: () {
              logoutAndDisconnect();
              Navigator.pop(context);
            }),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 2),
              child: Text('Select the banks you use most frequently',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w600,
                      fontSize: 16,
                      color: context.appColors.onBackground)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
              child: Row(children: [
                Icon(Icons.info_outline_rounded,
                    size: 13, color: context.appColors.secondaryText),
                SizedBox(width: 4),
                Text('Unable to support joint account holders',
                    style: FontManager().getTextStyle(context,
                        fontSize: 12,
                        color: context.appColors.secondaryText)),
              ]),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchField(
                  controller: _search, onChanged: (_) => setState(() {})),
            ),
            const SizedBox(height: 14),

            // List
            Expanded(
              child: Obx(() {
                getBanks.value;
                addCheck.value;
                _activeFilter.value;
                final showPopular = _search.text.isEmpty;
                final list = _filtered;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Popular grid
                      if (showPopular && _popularBanks.isNotEmpty) ...[
                        Text('Popular Banks',
                            style: FontManager().getTextStyle(context,
                                fontSize: 14,
                                lWeight: FontWeight.w600,
                                color: context.appColors.primary)),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(
                              _popularBanks.length.clamp(0, 4), (i) {
                            final b = _popularBanks[i];
                            final sel = isSeletedBankAccout.contains(b.fipId);
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _toggle(!sel, b),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? context.appColors.primary
                                            .withOpacity(0.08)
                                        : context.appColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: sel
                                            ? context.appColors.primary
                                            : context.appColors.border,
                                        width: sel ? 1.5 : 0.8),
                                  ),
                                  child: Column(children: [
                                    _BankLogo(bankData: b, size: 34),
                                    const SizedBox(height: 5),
                                    Text(
                                      _shortName(b),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: FontManager().getTextStyle(context,
                                          fontSize: 11,
                                          lWeight: FontWeight.w500,
                                          color: sel
                                              ? context.appColors.primary
                                              : context.appColors.onSurface),
                                    ),
                                  ]),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Filter pills
                      if (showPopular) ...[
                        _FilterPillRow(
                            active: _activeFilter.value,
                            onTap: (f) => _activeFilter.value = f),
                        const SizedBox(height: 10),
                      ],

                      // Bank list
                      if (list.isEmpty)
                        Center(
                            child: Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Text('No banks found',
                                    style: FontManager().getTextStyle(context,
                                        fontSize: 14,
                                        color: context.appColors.secondaryText))))
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: context.appColors.border, width: 0.8),
                          ),
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: list.length,
                            separatorBuilder: (_, __) => Divider(
                                height: 1,
                                thickness: 0.5,
                                color: context.appColors.divider,
                                indent: 56),
                            itemBuilder: (_, i) {
                              final bank = list[i];
                              final sel =
                                  isSeletedBankAccout.contains(bank.fipId);
                              final msgs =
                                  _metrics?.discoveryMessages(bank.fipId) ?? [];
                              return _BankRow(
                                bankData: bank,
                                isSelected: sel,
                                metrics: _metrics,
                                messages: msgs,
                                onTap: () => _toggle(!sel, bank),
                                onCheckChanged: (v) => _toggle(v, bank),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _shortName(FinvuFIPInfo b) {
    final n = b.productName?.toString() ?? b.fipId;
    final w = n.trim().split(RegExp(r'\s+'));
    if (w.isNotEmpty && w[0].length <= 6) return w[0];
    return n.length > 8 ? '${n.substring(0, 7)}…' : n;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Bank row — health badge + expandable warning messages
// ══════════════════════════════════════════════════════════════════════════════

class _BankRow extends StatefulWidget {
  final FinvuFIPInfo bankData;
  final bool isSelected;
  final FipMetricsController? metrics;
  final List<FipUserMessage> messages;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckChanged;

  const _BankRow(
      {required this.bankData,
      required this.isSelected,
      required this.metrics,
      required this.messages,
      required this.onTap,
      required this.onCheckChanged});

  @override
  State<_BankRow> createState() => _BankRowState();
}

class _BankRowState extends State<_BankRow> {
  bool _expanded = false;

  FipUserMessage? get _topMsg {
    if (widget.messages.isEmpty) return null;
    final err =
        widget.messages.where((m) => m.severity == FipMessageSeverity.error);
    final warn =
        widget.messages.where((m) => m.severity == FipMessageSeverity.warning);
    if (err.isNotEmpty) return err.first;
    if (warn.isNotEmpty) return warn.first;
    return widget.messages.first;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.metrics?.healthFor(widget.bankData.fipId) ??
        FipHealthStatus.unknown;
    final latency = widget.metrics?.avgLatencyFor(widget.bankData.fipId) ?? 0;
    final badge = _BadgeConfig.from(status);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: widget.isSelected
            ? context.appColors.primary.withOpacity(0.08)
            : Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main row
            Row(
              children: [
                _BankLogo(bankData: widget.bankData, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bankData.productName?.toString() ??
                            widget.bankData.fipId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontManager().getTextStyle(context,
                            fontSize: 14,
                            lWeight: FontWeight.w500,
                            color: context.appColors.onSurface),
                      ),
                      if (status != FipHealthStatus.unknown) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _StatusBadge(cfg: badge),
                            if (latency > 0 &&
                                status != FipHealthStatus.down) ...[
                              const SizedBox(width: 6),
                              Text('${latency.toStringAsFixed(0)} ms',
                                  style: FontManager().getTextStyle(context,
                                      fontSize: 11,
                                      color: context.appColors.secondaryText)),
                            ],
                            if (widget.messages.isNotEmpty) ...[
                              const Spacer(),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _expanded = !_expanded),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_expanded ? 'Less' : 'Details',
                                        style: FontManager().getTextStyle(
                                            context,
                                            fontSize: 11,
                                            lWeight: FontWeight.w500,
                                            color: context.appColors.primary)),
                                    Icon(
                                      _expanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      size: 14,
                                      color: context.appColors.primary,
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
                    value: widget.isSelected, onChanged: widget.onCheckChanged),
              ],
            ),

            // Inline top msg (collapsed, non-healthy only)
            if (!_expanded &&
                _topMsg != null &&
                status != FipHealthStatus.healthy) ...[
              const SizedBox(height: 8),
              _InlineMsg(message: _topMsg!),
            ],

            // Expanded full list
            if (_expanded && widget.messages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Divider(
                  height: 1,
                  thickness: 0.5,
                  color: context.appColors.divider),
              const SizedBox(height: 8),
              ...widget.messages.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _InlineMsg(message: m),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Inline message chip ───────────────────────────────────────────────────

class _InlineMsg extends StatelessWidget {
  final FipUserMessage message;
  const _InlineMsg({required this.message});

  @override
  Widget build(BuildContext context) {
    final c = _MsgStyle.from(message.severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border, width: 0.7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(c.icon, size: 14, color: c.iconColor)),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.title,
                    style: FontManager().getTextStyle(context,
                        fontSize: 12,
                        lWeight: FontWeight.w600,
                        color: c.titleColor)),
                const SizedBox(height: 2),
                Text(message.detail,
                    style: FontManager().getTextStyle(context,
                        fontSize: 11, color: c.detailColor, lineHeight: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MsgStyle {
  final Color bg, border, iconColor, titleColor, detailColor;
  final IconData icon;
  const _MsgStyle(
      {required this.bg,
      required this.border,
      required this.icon,
      required this.iconColor,
      required this.titleColor,
      required this.detailColor});

  factory _MsgStyle.from(FipMessageSeverity s) {
    switch (s) {
      case FipMessageSeverity.error:
        return const _MsgStyle(
            bg: Color(0xFFFFEBEE),
            border: Color(0xFFEF9A9A),
            icon: Icons.error_outline_rounded,
            iconColor: Color(0xFFE53935),
            titleColor: Color(0xFFC62828),
            detailColor: Color(0xFFB71C1C));
      case FipMessageSeverity.warning:
        return const _MsgStyle(
            bg: Color(0xFFFFF8E1),
            border: Color(0xFFFFCC80),
            icon: Icons.warning_amber_rounded,
            iconColor: Color(0xFFFB8C00),
            titleColor: Color(0xFFE65100),
            detailColor: Color(0xFFBF360C));
      case FipMessageSeverity.info:
        return const _MsgStyle(
            bg: Color(0xFFE3F2FD),
            border: Color(0xFF90CAF9),
            icon: Icons.info_outline_rounded,
            iconColor: Color(0xFF1976D2),
            titleColor: Color(0xFF0D47A1),
            detailColor: Color(0xFF1565C0));
    }
  }
}

// ── Status badge ──────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _BadgeConfig cfg;
  const _StatusBadge({required this.cfg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              decoration:
                  BoxDecoration(color: cfg.dot, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(cfg.label,
              style: FontManager().getTextStyle(context,
                  fontSize: 11, lWeight: FontWeight.w500, color: cfg.text)),
        ],
      ),
    );
  }
}

class _BadgeConfig {
  final String label;
  final Color bg, border, dot, text;
  const _BadgeConfig(
      {required this.label,
      required this.bg,
      required this.border,
      required this.dot,
      required this.text});

  factory _BadgeConfig.from(FipHealthStatus s) {
    switch (s) {
      case FipHealthStatus.healthy:
        return const _BadgeConfig(
            label: 'Live',
            bg: Color(0xFFE8F5E9),
            border: Color(0xFFA5D6A7),
            dot: Color(0xFF43A047),
            text: Color(0xFF2E7D32));
      case FipHealthStatus.degraded:
        return const _BadgeConfig(
            label: 'Slow',
            bg: Color(0xFFFFF8E1),
            border: Color(0xFFFFCC80),
            dot: Color(0xFFFB8C00),
            text: Color(0xFFE65100));
      case FipHealthStatus.down:
        return const _BadgeConfig(
            label: 'Down',
            bg: Color(0xFFFFEBEE),
            border: Color(0xFFEF9A9A),
            dot: Color(0xFFE53935),
            text: Color(0xFFC62828));
      case FipHealthStatus.unknown:
        return const _BadgeConfig(
            label: 'Unknown',
            bg: Color(0xFFF5F5F5),
            border: Color(0xFFE0E0E0),
            dot: Color(0xFFBDBDBD),
            text: Color(0xFF9E9E9E));
    }
  }
}

// ── Filter pills ──────────────────────────────────────────────────────────

class _FilterPillRow extends StatelessWidget {
  final _StatusFilter active;
  final ValueChanged<_StatusFilter> onTap;
  const _FilterPillRow({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _StatusFilter.values.map((f) {
          final isActive = f == active;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.appColors.primary
                      : context.appColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isActive
                          ? context.appColors.primary
                          : context.appColors.border,
                      width: 0.8),
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
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(f.label,
                        style: FontManager().getTextStyle(context,
                            fontSize: 12,
                            lWeight: FontWeight.w500,
                            color: isActive
                                ? Colors.white
                                : context.appColors.onSurface)),
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

// ── Shared widgets ────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_sharp),
              color: context.appColors.onBackground,
              onPressed: onBack,
              padding: EdgeInsets.zero),
          const Spacer(),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                border: Border.all(color: context.appColors.border),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.question_mark_rounded,
                size: 16, color: context.appColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: context.appColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded,
              size: 20, color: context.appColors.secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(fontSize: 14, color: context.appColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Search banks...',
                hintStyle:
                    TextStyle(fontSize: 14, color: context.appColors.hintText),
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

class _CheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _CheckBox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value ? context.appColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: value ? context.appColors.primary : context.appColors.border,
              width: 1.5),
        ),
        child: value
            ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
            : null,
      ),
    );
  }
}

class _BankLogo extends StatelessWidget {
  final FinvuFIPInfo bankData;
  final double size;
  const _BankLogo({required this.bankData, required this.size});

  static const _pairs = [
    [Color(0xFFE8F0FE), Color(0xFF1A56C4)],
    [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    [Color(0xFFFCE4EC), Color(0xFF880E4F)],
    [Color(0xFFFFF3E0), Color(0xFFE65100)],
    [Color(0xFFEDE7F6), Color(0xFF4527A0)],
    [Color(0xFFE0F2F1), Color(0xFF00695C)],
  ];

  List<Color> get _colors {
    final h = bankData.fipId.codeUnits.fold(0, (a, b) => a + b);
    return _pairs[h % _pairs.length];
  }

  String get _initials {
    final n = bankData.productName?.toString() ?? bankData.fipId;
    final w = n.trim().split(RegExp(r'\s+'));
    if (w.length >= 2) return '${w[0][0]}${w[1][0]}'.toUpperCase();
    return n.substring(0, n.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final uri = bankData.productIconUri?.toString() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: SizedBox(
        width: size,
        height: size,
        child: uri.isNotEmpty
            ? Image.network(uri,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _fallback(context))
            : _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) => Container(
      color: _colors[0],
      alignment: Alignment.center,
      child: Text(_initials,
          style: FontManager().getTextStyle(context,
              fontSize: size * 0.3,
              lWeight: FontWeight.w600,
              color: _colors[1])));
}
