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
import '../../image_service/avatarProfile.dart';
import 'slider_addding_finances.dart';

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard>
    with TickerProviderStateMixin {
  bool isLoading = true;

  /// 0.0 = top screen fully hidden
  /// 1.0 = top screen fully visible
  double _panelProgress = 0.0;
  late AnimationController _panelController;

  // Scroll controller for main content
  final ScrollController _scrollController = ScrollController();

  // Height of the "top screen" area
  static const double _maxPanelHeight = 600.0;

  // 🔥 Hint animation
  late AnimationController _hintController;
  late Animation<double> _hintOpacity;
  bool _showHint = true;

  @override
  void initState() {
    super.initState();

    Get.put(CardDueController());

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        setState(() {
          _panelProgress = _panelController.value;
        });
      });

    // 🔥 Hint flicker animation setup
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _hintOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _hintController,
        curve: Curves.easeInOut,
      ),
    );

    _hintController.repeat(reverse: true);

    // Auto-hide hint after a few seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() {
        _showHint = false;
      });
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
      final cardController = Get.find<CardDueController>();
      await Future.wait([
        cardController.fetchCardData(),
        cardController.getBanksListCrediCard(),
        DebtService.fetchDebts(),
      ]);
    } catch (e) {
      // log error if needed
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  bool _hasFinancialData() {
    final hasBudgets = budgetList.isNotEmpty;
    final hasDebts = debts.isNotEmpty;
    return hasBudgets ||
        hasDebts ||
        (CreditCardScreenStrings().showCreditCard.value
            ? creditCardBankList.isNotEmpty
            : false);
  }

  void _navigateToDebtDetailsScreen(Debt debt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DebtDetailsScreen(debt: debt)),
    );
  }

  void _closeTopPanel() {
    _panelController.animateTo(
      0.0,
      curve: Curves.easeOutCubic,
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    // 1️⃣ If panel is OPEN and user scrolls UP, close panel and block list scroll
    if (_panelProgress > 0.0 &&
        notification is ScrollUpdateNotification &&
        (notification.scrollDelta ?? 0) > 0) {
      final double delta = notification.scrollDelta ?? 0;

      if (_scrollController.hasClients) {
        final current = _scrollController.position.pixels;
        final newOffset = (current - delta).clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        );
        if (newOffset != current) {
          _scrollController.jumpTo(newOffset);
        }
      }

      if (_panelProgress != 0.0) {
        _panelController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
      return true;
    }

    // 2️⃣ Handle PULL DOWN at top (overscroll) to open panel
    if (notification.metrics.pixels <= 0 &&
        notification is OverscrollNotification &&
        notification.overscroll < 0) {
      final double drag = -notification.overscroll;
      final double deltaProgress = drag / _maxPanelHeight;

      final double newProgress =
          (_panelProgress + deltaProgress).clamp(0.0, 1.0);

      _panelController.value = newProgress;
      return true;
    }

    // 3️⃣ When finger lifts and panel is partially open, decide open/close
    if (notification is ScrollEndNotification && _panelProgress > 0.0) {
      if (_panelProgress > 0.5) {
        _panelController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      } else {
        _panelController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double panelTopOffset =
        -_maxPanelHeight * (1 - _panelProgress); // from -height → 0
    final double mainTopOffset =
        _panelProgress * _maxPanelHeight; // from 0 → height

    return Scaffold(
      backgroundColor: AppColors.newbg,
      bottomNavigationBar: SafeArea(
        child: BottomNavigations(
          data: 1,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 TOP SCREEN
            Positioned(
              top: panelTopOffset,
              left: 0,
              right: 0,
              height: _maxPanelHeight,
              child: _buildTopPanel(context),
            ),

            // 🔹 MAIN SCREEN
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
                      Container(child: _buildTopSection(context, size)),
                      Container(child: _buildBottomSection(context)),
                    ],
                  ),
                ),
              ),
            ),

            // 🔥 Hint
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
                          horizontal: AppSizes.p12,
                          vertical: AppSizes.p6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.backgroundColor,
                              size: 18,
                            ),
                            SizedBox(width: AppSizes.w6),
                            Text(
                              PlotFinanceStaticData().pullDownHint,
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w500,
                                fontSize: 12,
                                color: AppColors.backgroundColor,
                              ),
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

  // ===================== TOP PANEL (OVERVIEW) =====================

  Widget _buildTopPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.bg1.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: title + close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                PlotFinanceStaticData().overviewTitle,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 22,
                  color: AppColors.primaryColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _closeTopPanel,
              ),
            ],
          ),
          Text(
            PlotFinanceStaticData().overviewSubtitle,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w400,
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: AppSizes.h8),

          // Blue underline bar
          Container(
            height: 3,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          SizedBox(height: AppSizes.h16),

          _buildCreditCardsConnectedCard(context),
          SizedBox(height: AppSizes.h12),

          _buildDueCardsRow(context),
          SizedBox(height: AppSizes.h12),

          _buildBudgetCard(context),
          SizedBox(height: AppSizes.h12),

          _buildSavingsRow(context),
        ],
      ),
    );
  }

  Widget _buildCreditCardsConnectedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.p14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [AppShadows.soft],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            PlotFinanceStaticData().creditCardsConnected,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ),
          Text(
            '5',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w600,
              fontSize: 20,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueCardsRow(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildDueCard(
            context,
            dueText: 'Due Date 10 Dec',
            bank: 'From ICICI Bank',
            showTodayChip: true,
          ),
          SizedBox(width: AppSizes.w12),
          _buildDueCard(
            context,
            dueText: 'Due Date 15 Dec',
            bank: 'From HDFC Bank',
            showTodayChip: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDueCard(
    BuildContext context, {
    required String dueText,
    required String bank,
    required bool showTodayChip,
  }) {
    return Container(
      width: 230,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p14, vertical: AppSizes.p10),
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
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: PlotFinanceStaticData().dueDateLabel,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w400,
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                      TextSpan(
                        text: dueText.split(' ').last,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.h4),
                Text(
                  bank,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: AppSizes.h6),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.close,
                size: 16,
                color: AppColors.grey,
              ),
              const Spacer(),
              if (showTodayChip)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: AppSizes.p4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    PlotFinanceStaticData().todayLabel,
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 11,
                      color: AppColors.redColor,
                    ),
                  ),
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
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.p16),
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

  Widget _buildSavingsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSavingsCard(
            context,
            title: 'Gadget Savings',
            current: 6000,
            target: 20000,
            percent: 0.64,
          ),
        ),
        SizedBox(width: AppSizes.w12),
        Expanded(
          child: _buildSavingsCard(
            context,
            title: 'Vacation Savings',
            current: 6000,
            target: 20000,
            percent: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsCard(
    BuildContext context, {
    required String title,
    required double current,
    required double target,
    required double percent,
  }) {
    final String amountText =
        '₹ ${current.toStringAsFixed(0)} / ₹ ${target.toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p14, vertical: AppSizes.p12),
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
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: AppSizes.h4),
                Text(
                  amountText,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
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
    final int percent = (value * 100).round();

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
              AppColors.primaryColor.withOpacity(0.9),
            ),
          ),
          Text(
            '$percent%',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: 11,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(BuildContext context, Size size) {
    return Container(
      color: AppColors.newbg,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height / 34,
                ),
                Text(
                  PlotFinanceStaticData().moneyConsoleTitle,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
                    fontSize: 20,
                    lineHeight: 28 / 16,
                    color: AppColors.accentColor,
                  ),
                ),
                SizedBox(height: AppSizes.h4),
                Text(
                  PlotFinanceStaticData().moneyConsoleSubtitle,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 14,
                    lineHeight: 20 / 14,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.h16),

          // Comics & Community banner
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Community()),
              );
            },
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: SvgPicture.asset(
                PlotFinanceIcons.comics,
                fit: BoxFit.contain,
                width: MediaQuery.sizeOf(context).width,
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
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CurrencyConverterScreen()),
                  );
                },
                child: AvatarProfileImageZero(
                  url: PlotFinanceIcons.currencyConverter,
                  height: 7.6,
                  width: 4,
                ),
              ),
              SizedBox(height: AppSizes.h20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Budget()),
                  );
                },
                child: AvatarProfileImageZero(
                  url: PlotFinanceIcons.budgetPlanner,
                  height: 6,
                  width: 4,
                ),
              ),
              SizedBox(height: AppSizes.h20),
              AvatarProfileImageZero(
                url: PlotFinanceIcons.reserve,
                height: 6,
                width: 4,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddCreditCardBankScreen()),
                    );
                  },
                  child: Stack(
                    children: [
                      AvatarProfileImageZero(
                        url: PlotFinanceIcons.crediCardBg,
                        height: 5.7,
                        width: 6,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.p12, horizontal: AppSizes.p12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSizes.p4),
                                  decoration: BoxDecoration(
                                      color: AppColors.creditCardComponentColor,
                                      borderRadius: BorderRadius.circular(13)),
                                  child: AvatarProfileImageZero(
                                    url: PlotFinanceIcons.creditcardcomponent,
                                    height: 50,
                                    width: 6,
                                  ),
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
                                  padding: const EdgeInsets.all(AppSizes.p4),
                                  decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          255, 255, 255, 0.08),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSizes.p2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: AppColors.addCreditCardIcon,
                                      size: 20,
                                    ),
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
                //     SvgPicture.asset(
                //   PlotFinanceIcons.crediCardBg,
                //   fit: BoxFit.contain,
                // ),
                SizedBox(height: AppSizes.h16),
                _FinanceToolsCard(
                  height: 100,
                  onTapC: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VegNonVegCalculator()),
                  ),
                  onTapD: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AllCalculatorScreen()),
                  ),
                ),
                SizedBox(height: AppSizes.h24),
                AvatarProfileImageZero(
                  url: PlotFinanceIcons.goalCreation,
                  height: 6,
                  width: 4,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceToolsCard extends StatefulWidget {
  final double height;
  final VoidCallback? onTapC;
  final VoidCallback? onTapD;

  const _FinanceToolsCard({
    super.key,
    required this.height,
    this.onTapC,
    this.onTapD,
  });

  @override
  State<_FinanceToolsCard> createState() => _FinanceToolsCardState();
}

class _FinanceToolsCardState extends State<_FinanceToolsCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: expanded ? widget.height + 60 : widget.height,
      width: MediaQuery.sizeOf(context).width / 2.4,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p14, vertical: AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [AppShadows.soft],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => setState(() => expanded = !expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              PlotFinanceStaticData().financeFusionTitle,
              style: FontManager().getTextStyle(context,
                  color: AppColors.primaryColor,
                  fontSize: 12,
                  lWeight: FontWeight.w400),
            ),
            SizedBox(height: AppSizes.h12),
            if (!expanded)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: AppSizes.p8),
                      decoration: const BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: AvatarProfileImageZero(
                          url: PlotFinanceIcons.calculator,
                          width: 20,
                          height: 32)),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: AppSizes.p8),
                      decoration: const BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: AvatarProfileImageZero(
                          url: PlotFinanceIcons.foodie, width: 20, height: 32)),
                ],
              ),
            if (expanded)
              Column(
                children: [
                  GestureDetector(
                    onTap: widget.onTapD,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p12, vertical: AppSizes.p8),
                      decoration: const BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Row(
                        children: [
                          SvgPicture.asset(PlotFinanceIcons.calculator,
                              height: 24),
                          SizedBox(width: AppSizes.w10),
                          Text(
                            PlotFinanceStaticData().calculatorsTitle,
                            style: FontManager().getTextStyle(context,
                                color: AppColors.foodieFundsTitle,
                                fontSize: 12,
                                lWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.h12),
                  GestureDetector(
                    onTap: widget.onTapC,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p12, vertical: AppSizes.p8),
                      decoration: const BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Row(
                        children: [
                          SvgPicture.asset(PlotFinanceIcons.foodie, height: 24),
                          SizedBox(width: AppSizes.w10),
                          Text(PlotFinanceStaticData().foodieFundsTitle,
                              style: FontManager().getTextStyle(context,
                                  color: AppColors.foodieFundsTitle,
                                  lWeight: FontWeight.w500,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
