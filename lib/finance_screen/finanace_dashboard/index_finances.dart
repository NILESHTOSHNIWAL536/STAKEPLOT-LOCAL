// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// // import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// // import 'package:flutter_application_code_stakeplot/repository/profileUser.dart';
// // import 'package:flutter_application_code_stakeplot/email_sync/add_credit_card_bank.dart';
// // import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
// // import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
// // import 'package:flutter_application_code_stakeplot/repository/debt_service.dart';
// // import 'package:flutter_application_code_stakeplot/repository/payables_repository.dart';
// // import 'package:get/get.dart';
// // import 'package:skeletonizer/skeletonizer.dart';
// // import '../../Utils/credit_card.dart';
// // import '../../backed_connections/apis_connect.dart';
// // import '../../components/bottomNavigations.dart';
// // import '../../Constants/colorcodes.dart';
// // import '../../controllers/credit_card_controller.dart';
// // import '../Budgets/Budget.dart';
// // import 'FeatureGrid.dart';
// // import 'searchfinance.dart';
// // import 'show_complete_info.dart';
// // import 'slider_addding_finances.dart';
// // import 'topay_toreceive.dart';

// // class FinanceDashboard extends StatefulWidget {
// //   const FinanceDashboard({super.key});

// //   @override
// //   State<FinanceDashboard> createState() => _FinanceDashboardState();
// // }

// // class _FinanceDashboardState extends State<FinanceDashboard> {
// //   bool isLoading = true;
// //   @override
// //   void initState() {
// //     super.initState();
// //     Get.put(CardDueController());
// //     _loadData();
// //     getRemainders(context);
    
// //   }

// //   Future<void> _loadData() async {
// //     try {
// //       final cardController = Get.find<CardDueController>();
// //       await Future.wait([
// //         cardController.fetchCardData(),
// //         cardController.getBanksListCrediCard(),
// //        DebtService.fetchDebts() // Assuming fetchDebts is async
// //       ]);
// //     } catch (e) {
// //     } finally {
// //       setState(() => isLoading = false);
// //     }
// //   }

// //   bool _hasFinancialData() {
// //     final hasBudgets = budgetList.isNotEmpty ; // Check budgetList
// //     final hasDebts = debts.isNotEmpty ; // Check debts
// //     return hasBudgets ||
// //             hasDebts ||
// //             CreditCardScreenStrings().showCreditCard.value
// //         ? creditCardBankList.isNotEmpty
// //         : false;
// //   }

// //   void _navigateToDebtDetailsScreen(Debt debt) async {
// //     await Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (context) => DebtDetailsScreen(debt: debt)),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final Size size = MediaQuery.of(context).size;
// //     return Scaffold(
// //       backgroundColor: AppColors.primaryColor,

// //       bottomNavigationBar: SafeArea(
// //           child: BottomNavigations(
// //         data: 1,
// //       )),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           child: Column(
// //             children: [
// //               // Top Section with custom clipper and search bar

// //               Container(
// //                 color: AppColors.backgroundColor,
               
// //                 height: size.height / 2.15,
// //                 width: MediaQuery.of(context).size.width,
// //                 // color: AppColors.primaryColor,
// //                 child: Stack(
// //                   children: [
// //                     // Background color with a wave shape at the bottom

// //                     Transform.translate(
// //                                           offset: Offset(
// //                       0,
// //                       -size.height *
// //                           0.025), // Responsive offset based on screen height
// //                                           child: AvatarProfileImageZero(
// //                       url: svgIconPath.finance, width: 1, height: 2),
// //                                         ),

// //                     Column(
// //                       mainAxisSize: MainAxisSize.min,
// //                       mainAxisAlignment: MainAxisAlignment.start,
// //                       children: [
// //                         // Main title "Plot your finances"
// //                         const SizedBox(
// //                           height: 25,
// //                         ),
// //                         buildHeadingAndSearchBar(),

// //                         Stack(
// //                           children: [
// //                             Transform.translate(
// //                               offset: Offset(
// //                                   0,
// //                                   -size.height *
// //                                       0.04), // Responsive offset based on screen height
// //                               child: Container(
// //                                 padding:
// //                                     const EdgeInsets.symmetric(horizontal: 10),
// //                                 child: AvatarProfileImageZero(
// //                                     url: svgIconPath.finance_background,
// //                                     width: 1,
// //                                     height: 4.4),
// //                               ),
// //                             ),
// //                             Transform.translate(
// //                               offset: Offset(
// //                                   0,
// //                                   -size.height *
// //                                       0.085), // Responsive offset based on screen height
// //                               child: Container(
// //                                 padding:
// //                                     const EdgeInsets.fromLTRB(5, 10, 10, 5),
// //                                 margin: const EdgeInsets.symmetric(
// //                                     horizontal: 10.0),
// //                                 child: const Center(child: FeatureGrid()),
// //                                 // child: Center(child: _buildFeatureCards(context)),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               // "Heading" section with "View all"

// //               Container(
// //                 color: AppColors.backgroundColor,
// //                 child: Column(
// //                   children: [
// //                     if (getCreditCardBudgetDebts.value)
// //                       Padding(
// //                         padding: const EdgeInsets.symmetric(horizontal: 24.0),
// //                         child: _buildSectionHeader('', () {
// //                           pushnameToRoute(context, ShowCompleteInfo(), false);
// //                         }),
// //                       ),
// //                     Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 10.0),
// //                       child: SliderAdddingFinances(
// //                         // hasData: hasData,
// //                         onDebtTap: _navigateToDebtDetailsScreen,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 10),
// //                     const Padding(
// //                       padding: EdgeInsets.symmetric(horizontal: 24.0),
// //                       child: TopayToreceive(),
// //                     ),
// //                     const SizedBox(height: 100),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //       // Bottom navigation bar
// //     );
// //   }

// //   // Widget for the search bar
// //   Widget _buildSectionHeader(String title, VoidCallback onTap) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           title,
// //           style: FontManager().getTextStyle(context,
// //               lWeight: FontWeight.w500, fontSize: 16, color: AppColors.grey),
// //         ),
// //         GestureDetector(
// //           onTap: onTap,
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //             decoration: BoxDecoration(
// //               color: AppColors.primaryColor,
// //               borderRadius: BorderRadius.circular(8),
// //               border: Border.all(
// //                 color: const Color(0xFFF3F4F6),
// //                 width: 1,
// //               ),
// //               boxShadow: const [
// //                 BoxShadow(
// //                   color: Color.fromRGBO(0, 0, 0, 0.05),
// //                   offset: Offset(0, 1),
// //                   blurRadius: 2,
// //                 ),
// //               ],
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text(
// //                   'View all',
// //                   style: FontManager().getTextStyle(context,
// //                       lWeight: FontWeight.w500,
// //                       fontSize: 14,
// //                       color: AppColors.backgroundColor),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget buildHeadingAndSearchBar() {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 10),
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(30),
// //         image: DecorationImage(
// //           image: AssetImage(svgIconPath.financepayReceive2),
// //           fit: BoxFit.cover,
// //         ),
// //       ),
// //       child: Column(
// //         children: [
// //           const SizedBox(
// //             height: 25,
// //           ),
// //           Center(
// //             child: textStyle(
// //               context: context,
// //               text: 'Plot your finances',
// //               c: AppColors.backgroundColor,
// //               fontsize: 24,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),

// //           const SizedBox(height: 25),

// //           // Search bar located below the title
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 15.0),
// //             child: buildSearchBar(context),
// //           ),
// //           const SizedBox(height: 50),
// //         ],
// //       ),
// //     );
// //   }
// // }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/community_screen.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/all_calculators.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/credit_card.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/currency_convert.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/veg_nonveg.dart';
import 'package:flutter_application_code_stakeplot/repository/profileUser.dart';
import 'package:flutter_application_code_stakeplot/email_sync/add_credit_card_bank.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:flutter_application_code_stakeplot/repository/debt_service.dart';
import 'package:flutter_application_code_stakeplot/repository/payables_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Utils/credit_card.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/bottomNavigations.dart';
import '../../Constants/colorcodes.dart';
import '../../controllers/credit_card_controller.dart';
import '../Budgets/Budget.dart';
import 'searchfinance.dart';
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
                      _buildTopSection(context, size),
                      _buildBottomSection(context),
                    ],
                  ),
                ),
              ),
            ),

            // 🔥 Hint
            if (_showHint && _panelProgress == 0.0)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: FadeTransition(
                      opacity: _hintOpacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Pull down to see overview',
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.white,
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
            color: Colors.black.withOpacity(0.12),
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
                'Overview',
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
            'Focused on Financial Clarity & Growth',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w400,
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),

          // Blue underline bar
          Container(
            height: 3,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 16),

          _buildCreditCardsConnectedCard(context),
          const SizedBox(height: 12),

          _buildDueCardsRow(context),
          const SizedBox(height: 12),

          _buildBudgetCard(context),
          const SizedBox(height: 12),

          _buildSavingsRow(context),
        ],
      ),
    );
  }

  Widget _buildCreditCardsConnectedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Credit Cards Connected',
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
          const SizedBox(width: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
                        text: 'Due Date ',
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
                const SizedBox(height: 4),
                Text(
                  bank,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.close,
                size: 16,
                color: Colors.grey,
              ),
              const Spacer(),
              if (showTodayChip)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Today',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 11,
                      color: Colors.redAccent,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
        const SizedBox(width: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
                const SizedBox(height: 4),
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
          const SizedBox(width: 8),
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

  // ===================== MAIN TOP SECTION =====================

  Widget _buildTopSection(BuildContext context, Size size) {
    return Container(
      color: AppColors.newbg,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Tools',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 24,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Smart tools for your daily needs',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Comics & Community banner
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Community()),
              );
            },
            child: SvgPicture.asset(
              PlotFinanceIcons.comics,
              fit: BoxFit.contain,
              width: MediaQuery.sizeOf(context).width,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== BOTTOM GRID (TOOLS) =====================

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      color: AppColors.newbg,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: _buildToolsGrid(context),
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double spacing = 5;
    final double cardWidth = (screenWidth - spacing * 2) / 2;

    return Column(
      children: [
        // Row 1: Currency + Credit Card (taller)
        Row(
          children: [
            Expanded(
              child: _ImageToolCard(
                svgPath: PlotFinanceIcons.currencyConverter,
                height: 130,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrencyConverterScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: _ImageToolCard(
                svgPath: PlotFinanceIcons.crediCardBg,
                height: 190,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreditCard(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: spacing),

        // Row 2: Budget + Finance Tools
        Row(
          children: [
            Expanded(
              child: _ImageToolCard(
                svgPath: PlotFinanceIcons.budgetPlanner,
                height: 150,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Budget(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: _FinanceToolsCard(
                width: cardWidth,
                onTapC: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VegNonVegCalculator(),
                    ),
                  );
                },
                onTapD: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllCalculatorScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: spacing),

        // Row 3: Reserve + Goal Creation
        Row(
          children: [
            Expanded(
              child: _ImageToolCard(
                svgPath: PlotFinanceIcons.reserve,
                height: 150,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CurrencyConverterScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: _ImageToolCard(
                svgPath: PlotFinanceIcons.goalCreation,
                height: 150,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CurrencyConverterScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ===================== HELPER WIDGETS =====================

/// Simple image-based tool card (matches Figma white cards)
class _ImageToolCard extends StatelessWidget {
  final String svgPath;
  final double height;
  final VoidCallback? onTap;

  const _ImageToolCard({
    super.key,
    required this.svgPath,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
    
      onTap: onTap,
      child: SvgPicture.asset(
        svgPath,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Finance Tools card: collapses like Finance Fusion card but interactive
class _FinanceToolsCard extends StatefulWidget {
  final double width;
  final VoidCallback? onTapC;
  final VoidCallback? onTapD;

  const _FinanceToolsCard({
    super.key,
    required this.width,
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
      curve: Curves.easeOutCubic,
      height: expanded ? 180 : 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          setState(() => expanded = !expanded);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finance Tools',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),

            // Collapsed → 2 icons row
            if (!expanded)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset(
                    PlotFinanceIcons.calculator,
                    height: 40,
                    width: 40,
                  ),
                  SvgPicture.asset(
                    PlotFinanceIcons.foodie,
                    height: 40,
                    width: 40,
                  ),
                ],
              ),

            // Expanded → 2 rows with icon + text
            if (expanded)
              Column(
                children: [
                  GestureDetector(
                    onTap: widget.onTapD, // All Calculators
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          PlotFinanceIcons.calculator,
                          height: 32,
                          width: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'All Calculators',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: widget.onTapC, // Foodie funds / Veg-NonVeg
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          PlotFinanceIcons.foodie,
                          height: 32,
                          width: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Foodie Funds',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
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
