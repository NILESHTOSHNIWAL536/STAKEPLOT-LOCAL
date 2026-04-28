import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/community_screen.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_shadows.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/email_sync/credit_cards.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/all_calculators.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/credit_card.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/currency_convert.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/veg_nonveg.dart';
import 'package:flutter_application_code_stakeplot/email_sync/add_credit_card_bank.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:flutter_application_code_stakeplot/repository/debt_service.dart';
import 'package:flutter_application_code_stakeplot/repository/payables_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Utils/credit_card.dart';
import '../../Utils/plotFinanceStringsPage.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/bottomNavigations.dart';
import '../../controllers/credit_card_controller.dart';
import '../../email_sync/display_credit_card.dart';
import '../../image_service/avatarProfile.dart';
import '../../repository/reserve_repository.dart';
import 'reserve.dart';
import 'reserve_flow.dart';
import 'slider_addding_finances.dart';

// ─── Skeleton shimmer widget ───────────────────────────────────────────────
class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer(
      {required this.width, required this.height, this.radius = 12});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: const [
              Color(0xFFEEEEEE),
              Color(0xFFF8F8F8),
              Color(0xFFEEEEEE),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton for tools grid ───────────────────────────────────────────────
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final half = (w - 54) / 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _Shimmer(width: half, height: w * 0.44),
              const SizedBox(height: 14),
              _Shimmer(width: half, height: w * 0.34),
              const SizedBox(height: 14),
              _Shimmer(width: half, height: w * 0.34),
            ],
          ),
          const SizedBox(width: 14),
          Column(
            children: [
              _Shimmer(width: half, height: w * 0.32),
              const SizedBox(height: 14),
              _Shimmer(width: half, height: w * 0.28),
              const SizedBox(height: 14),
              _Shimmer(width: half, height: w * 0.34),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard>
    with TickerProviderStateMixin {
  bool isLoading = true;

  double _panelProgress = 0.0;
  late AnimationController _panelController;

  final ScrollController _scrollController = ScrollController();

  // Pull‑to‑reveal panel max height (responsive)
  double get _maxPanelHeight => MediaQuery.of(context).size.height * 0.72;

  // Hint animation
  late AnimationController _hintController;
  late Animation<double> _hintOpacity;
  bool _showHint = true;
  List<Map<String, dynamic>> reserveList = [];
  bool isReserveLoading = true;
  @override
  void initState() {
    super.initState();
    Get.put(CardDueController());

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(() {
        setState(() => _panelProgress = _panelController.value);
      });

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _hintOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _hintController, curve: Curves.easeInOut));
    _hintController.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _showHint = false);
      _hintController.stop();
    });

    _loadData();
    getRemainders(context);
  }

  @override
  void dispose() {
    _panelController.dispose();
    _scrollController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        cardController.fetchCardData(),
        cardController.getBanksListCrediCard(),
        DebtService.fetchDebts(),
      ]);
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isReserveLoading = false;
        });
      }
    }
  }

  void _navigateToDebtDetailsScreen(Debt debt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DebtDetailsScreen(debt: debt)),
    );
  }

  void _closeTopPanel() {
    _panelController.animateTo(0.0, curve: Curves.easeOutCubic);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    final ph = _maxPanelHeight;

    if (_panelProgress > 0.0 &&
        notification is ScrollUpdateNotification &&
        (notification.scrollDelta ?? 0) > 0) {
      if (_scrollController.hasClients) {
        final cur = _scrollController.position.pixels;
        final next = (cur - (notification.scrollDelta ?? 0)).clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        );
        if (next != cur) _scrollController.jumpTo(next);
      }
      if (_panelProgress != 0.0) {
        _panelController.animateTo(0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic);
      }
      return true;
    }

    if (notification.metrics.pixels <= 0 &&
        notification is OverscrollNotification &&
        notification.overscroll < 0) {
      final delta = -notification.overscroll;
      final next = (_panelProgress + delta / ph).clamp(0.0, 1.0);
      _panelController.value = next;
      return true;
    }

    if (notification is ScrollEndNotification && _panelProgress > 0.0) {
      _panelController.animateTo(
        _panelProgress > 0.4 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ph = _maxPanelHeight;
    final panelTopOffset = -ph * (1 - _panelProgress);
    final mainTopOffset = _panelProgress * ph;

    return Scaffold(
      backgroundColor: AppColors.newbg,
      bottomNavigationBar: SafeArea(child: BottomNavigations(data: 1)),
      body: SafeArea(
        child: Stack(
          children: [
            // ── TOP OVERVIEW PANEL ────────────────────────────────────────
            Positioned(
              top: panelTopOffset,
              left: 0,
              right: 0,
              height: ph,
              child: _buildTopPanel(context, size),
            ),

            // ── MAIN SCROLLABLE CONTENT ───────────────────────────────────
            Positioned.fill(
              top: mainTopOffset,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScrollNotification,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopSection(context, size),
                      isLoading
                          ? const _SkeletonGrid()
                          : _buildBottomSection(context),
                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),

            // ── PULL HINT ─────────────────────────────────────────────────
            if (_showHint && _panelProgress == 0.0)
              Positioned(
                top: AppSizes.p8,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: FadeTransition(
                      opacity: _hintOpacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p12, vertical: AppSizes.p6),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.backgroundColor, size: 18),
                            SizedBox(width: AppSizes.w6),
                            Text(
                              PlotFinanceStaticData().pullDownHint,
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: AppColors.backgroundColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TOP PANEL — Overview (pull‑to‑reveal)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopPanel(BuildContext context, Size size) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20, size.height * 0.02, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PlotFinanceStaticData().overviewTitle,
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w700,
                            fontSize: 22,
                            color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        PlotFinanceStaticData().overviewSubtitle,
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w400,
                            fontSize: 13,
                            color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.newbg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.keyboard_arrow_up_rounded,
                        size: 20, color: Colors.black54),
                  ),
                  onPressed: _closeTopPanel,
                ),
              ],
            ),
          ),

          // ── Blue accent bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Container(
                    height: 3,
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10))),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Scrollable content ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _buildCCConnectedCard(context),
                  const SizedBox(height: 12),
                  _buildDueCardsRow(context, size),
                  const SizedBox(height: 12),
                  _buildBudgetCard(context),
                  const SizedBox(height: 12),
                  _buildSavingsRow(context, size),
                  const SizedBox(height: 12),
                   _buildReserveRow(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCCConnectedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [AppShadows.soft],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.credit_card_rounded,
                    size: 20, color: Color(0xFF3B5BDB)),
              ),
              const SizedBox(width: 12),
              Text(
                PlotFinanceStaticData().creditCardsConnected,
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.primaryColor),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF37344F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('5',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDueCardsRow(BuildContext context, Size size) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildDueCard(context, size,
              dueText: 'Due Date 10 Dec',
              bank: 'From ICICI Bank',
              showTodayChip: true),
          SizedBox(width: AppSizes.w12),
          _buildDueCard(context, size,
              dueText: 'Due Date 15 Dec',
              bank: 'From HDFC Bank',
              showTodayChip: false),
        ],
      ),
    );
  }

  Widget _buildDueCard(BuildContext context, Size size,
      {required String dueText,
      required String bank,
      required bool showTodayChip}) {
    final cardW = size.width * 0.56;
    return Container(
      width: cardW,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [AppShadows.soft],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: PlotFinanceStaticData().dueDateLabel,
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w400,
                          fontSize: 11,
                          color: AppColors.grey),
                    ),
                    TextSpan(
                      text: dueText.split(' ').last,
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.primaryColor),
                    ),
                  ]),
                ),
                Text(bank,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.primaryColor)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.close, size: 15, color: AppColors.grey),
              if (showTodayChip)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(PlotFinanceStaticData().todayLabel,
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w600,
                          fontSize: 10,
                          color: AppColors.redColor)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [AppShadows.soft],
      ),
      child: SliderAdddingFinances(
        onDebtTap: _navigateToDebtDetailsScreen,
      ),
    );
  }

  Widget _buildSavingsRow(BuildContext context, Size size) {
    final cardW = (size.width - 54) / 2;
    return Row(
      children: [
        _buildSavingsCard(context, cardW,
            title: 'Gadget Savings',
            current: 6000,
            target: 20000,
            percent: 0.64),
        SizedBox(width: AppSizes.w12),
        _buildSavingsCard(context, cardW,
            title: 'Vacation Savings',
            current: 6000,
            target: 20000,
            percent: 0.30),
      ],
    );
  }

  Widget _buildReserveRow(BuildContext context) {
    if (isReserveLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reserveList.isEmpty) {
      return const Text("No reserves yet");
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: reserveList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final item = reserveList[index];

          final amount = (item['amount'] as num?)?.toDouble() ?? 0;
          final suggested = (item['suggested_limit'] as num?)?.toDouble() ?? 0;
          final days = (item['duration_days'] as num?)?.toInt() ?? 0;
          final status = item['status'] ?? "";

          return _reserveCard(
            context,
            amount: amount,
            suggested: suggested,
            days: days,
            status: status,
          );
        },
      ),
    );
  }

  Widget _reserveCard(
    BuildContext context, {
    required double amount,
    required double suggested,
    required int days,
    required String status,
  }) {
    final percent = amount == 0 ? 0.0 : (suggested / amount).clamp(0, 1);

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [AppShadows.soft],
      ),
      child: Row(
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reserve",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹ ${amount.toStringAsFixed(0)}",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  "$days days",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 11,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Suggested ₹ ${suggested.toStringAsFixed(0)}",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 11,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  status,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 10,
                    color: status == "ACTIVE" ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // RIGHT (progress)
          SizedBox(
            height: 40,
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent.toDouble(),
                  strokeWidth: 4,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
                Text(
                  "${(percent * 100).toInt()}%",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 10,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCard(
    BuildContext context,double width, {
    required String title,
    required double current,
    required double target,
    required double percent,
  }) {
    final String amountText =
        '₹ ${current.toStringAsFixed(0)} / ₹ ${target.toStringAsFixed(0)}';
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [AppShadows.soft],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.primaryColor)),
                const SizedBox(height: 4),
                Text(
                  '₹${current.toInt()} / ₹${target.toInt()}',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize: 11,
                      color: AppColors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.w8),
          _buildCircularPercent(context, percent),
        ],
      ),
    );
  }

  Widget _buildCircularPercent(BuildContext context, double value) {
    return SizedBox(
      height: 44,
      width: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 4,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor.withOpacity(0.9)),
          ),
          Text('${(value * 100).round()}%',
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w600,
                  fontSize: 10,
                  color: AppColors.primaryColor)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  MAIN CONTENT
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopSection(BuildContext context, Size size) {
    return Container(
      color: AppColors.newbg,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(22, size.height * 0.03, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PlotFinanceStaticData().moneyConsoleTitle,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 20,
                      lineHeight: 28 / 16,
                      color: AppColors.accentColor),
                ),
                SizedBox(height: AppSizes.h4),
                Text(
                  PlotFinanceStaticData().moneyConsoleSubtitle,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize: 14,
                      lineHeight: 20 / 14,
                      color: AppColors.grey),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.h16),
          InkWell(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Community())),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: SvgPicture.asset(
                PlotFinanceIcons.comics,
                fit: BoxFit.contain,
                width: size.width,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      color: AppColors.newbg,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: _buildToolsGrid(context),
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LEFT COLUMN ──────────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const CurrencyConverterScreen())),
                child: AvatarProfileImageZero(
                    url: PlotFinanceIcons.currencyConverter,
                    height: 7.6,
                    width: 4),
              ),
              SizedBox(height: AppSizes.h20),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Budget())),
                child: AvatarProfileImageZero(
                    url: PlotFinanceIcons.budgetPlanner,
                    height: 6,
                    width: 4),
              ),
              SizedBox(height: AppSizes.h20),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReserveFlow())),
                child: AvatarProfileImageZero(
                    url: PlotFinanceIcons.reserve, height: 6, width: 4),
              ),
            ],
          ),

          // ── RIGHT COLUMN ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Credit Card tile
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DisplayCreditCard())),
                  child: Stack(
                    children: [
                      AvatarProfileImageZero(
                          url: PlotFinanceIcons.crediCardBg,
                          height: 5.7,
                          width: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.p12,
                            horizontal: AppSizes.p12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSizes.p4),
                                  decoration: BoxDecoration(
                                      color: AppColors
                                          .creditCardComponentColor,
                                      borderRadius:
                                          BorderRadius.circular(13)),
                                  child: AvatarProfileImageZero(
                                      url: PlotFinanceIcons
                                          .creditcardcomponent,
                                      height: 50,
                                      width: 6),
                                ),
                                SizedBox(width: AppSizes.w6),
                                Text(
                                  PlotFinanceStaticData()
                                      .creditCardContainerTitle,
                                  style: FontManager().getTextStyle(context,
                                      color: AppColors.backgroundColor,
                                      fontSize: 12,
                                      lWeight: FontWeight.w400),
                                ),
                                SizedBox(width: AppSizes.w16),
                                Container(
                                  padding:
                                      const EdgeInsets.all(AppSizes.p4),
                                  decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          255, 255, 255, 0.08),
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSizes.p2),
                                    decoration: const BoxDecoration(
                                        color: AppColors.backgroundColor,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.add,
                                        color: AppColors.addCreditCardIcon,
                                        size: 20),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              PlotFinanceStaticData().linkAndManage,
                              style: FontManager().getTextStyle(context,
                                  color: AppColors.linkManage,
                                  fontSize: 12,
                                  lWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizes.h16),

                // ── Finance Fusion card ─────────────────────────────────
                _FinanceFusionCard(
                  onTapCalculator: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => AllCalculatorScreen())),
                  onTapFoodie: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const VegNonVegCalculator())),
                ),

                SizedBox(height: AppSizes.h24),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreateDebtScreen()),
                    );
                  },
                  child: AvatarProfileImageZero(
                    url: PlotFinanceIcons.goalCreation,
                    height: 6,
                    width: 4,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  FINANCE FUSION CARD
//  Default: two icon buttons side-by-side
//  On tap: expands to show labelled rows (same as before) — then tap again
//          to collapse back to icon view
// ═══════════════════════════════════════════════════════════════════════════
class _FinanceFusionCard extends StatefulWidget {
  final VoidCallback onTapCalculator;
  final VoidCallback onTapFoodie;

  const _FinanceFusionCard({
    required this.onTapCalculator,
    required this.onTapFoodie,
  });

  @override
  State<_FinanceFusionCard> createState() => _FinanceFusionCardState();
}

class _FinanceFusionCardState extends State<_FinanceFusionCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cardW = MediaQuery.of(context).size.width / 2.4;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: cardW,
        // collapsed = icons only (~100px), expanded = labelled rows (~168px)
        height: _expanded ? 168 : 100,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [AppShadows.soft],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with expand chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  PlotFinanceStaticData().financeFusionTitle,
                  style: FontManager().getTextStyle(context,
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      lWeight: FontWeight.w500),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: AppColors.grey),
                ),
              ],
            ),
            SizedBox(height: AppSizes.h10),

            // ── COLLAPSED: icon buttons ──────────────────────────────────
            if (!_expanded)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _IconBtn(
                      icon: PlotFinanceIcons.calculator,
                      onTap: widget.onTapCalculator,
                    ),
                    _IconBtn(
                      icon: PlotFinanceIcons.foodie,
                      onTap: widget.onTapFoodie,
                    ),
                  ],
                ),
              ),

            // ── EXPANDED: labelled rows ──────────────────────────────────
            if (_expanded)
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    _LabelledRow(
                      icon: PlotFinanceIcons.calculator,
                      label: PlotFinanceStaticData().calculatorsTitle,
                      onTap: widget.onTapCalculator,
                    ),
                    SizedBox(height: AppSizes.h10),
                    _LabelledRow(
                      icon: PlotFinanceIcons.foodie,
                      label: PlotFinanceStaticData().foodieFundsTitle,
                      onTap: widget.onTapFoodie,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Small icon-only button ──────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: SvgPicture.asset(icon, height: 28, width: 20),
      ),
    );
  }
}

// ── Labelled row (expanded state) ───────────────────────────────────────────
class _LabelledRow extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _LabelledRow(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(icon, height: 22),
            SizedBox(width: AppSizes.w10),
            Flexible(
              child: Text(label,
                  style: FontManager().getTextStyle(context,
                      color: AppColors.foodieFundsTitle,
                      fontSize: 12,
                      lWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}