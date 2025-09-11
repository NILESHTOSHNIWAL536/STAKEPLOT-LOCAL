import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/email_sync/add_credit_card_bank.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../backed_connections/apis_connect.dart';
import '../bottomNavigations.dart';
import '../colorcodes.dart';
import '../controllers/credit_card_controller.dart';
import '../finance_screen/Budgets/Budget.dart';
import './FeatureGrid.dart';

import 'searchfinance.dart';

import 'show_complete_info.dart';
import 'slider_addding_finances.dart';
import 'topay_toreceive.dart';

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();

    fetchDebts();
    Get.put(CardDueController());
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cardController = Get.find<CardDueController>();
      await Future.wait([
        cardController.fetchCardData(),
        cardController.getBanksListCrediCard(),
        fetchDebts(), // Assuming fetchDebts is async
      ]);
    } catch (e) {
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _hasFinancialData() {
    final cardController = CardDueController();
    final hasCreditCards = cardController.cardList?.isNotEmpty ?? false;

    final hasBudgets = budgetList?.isNotEmpty ?? false; // Check budgetList
    final hasDebts = debts?.isNotEmpty ?? false; // Check debts
    return hasCreditCards || hasBudgets || hasDebts;
  }

  void _navigateToDebtDetailsScreen(Debt debt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DebtDetailsScreen(debt: debt)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool hasData = isLoading ? false : _hasFinancialData();
    return Scaffold(
      backgroundColor: AppColors.primaryColor,

      bottomNavigationBar: SafeArea(
          child: BottomNavigations(
        data: 1,
      )),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Section with custom clipper and search bar

              Container(
                color: AppColors.backgroundColor,
                padding: const EdgeInsets.all(0),
                height: size.height / 2.1,
                width: MediaQuery.of(context).size.width,
                // color: AppColors.primaryColor,
                child: Stack(
                  children: [
                    // Background color with a wave shape at the bottom

                    Center(
                        child: Transform.translate(
                      offset: Offset(
                          0,
                          -size.height *
                              0.025), // Responsive offset based on screen height
                      child: AvatarProfileImageZero(
                          url: svgIconPath.finance, width: 1, height: 2),
                    )),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Main title "Plot your finances"
                        const SizedBox(
                          height: 25,
                        ),
                        buildHeadingAndSearchBar(),

                        Stack(
                          children: [
                            Transform.translate(
                              offset: Offset(
                                  0,
                                  -size.height *
                                      0.225), // Responsive offset based on screen height
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: AvatarProfileImageZero(
                                    url: svgIconPath.finance_background,
                                    width: 1,
                                    height: 1.6),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(
                                  0,
                                  -size.height *
                                      0.075), // Responsive offset based on screen height
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(5, 10, 10, 5),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: const Center(child: FeatureGrid()),
                                // child: Center(child: _buildFeatureCards(context)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // "Heading" section with "View all"

              Container(
                color: AppColors.backgroundColor,
                child: Column(
                  children: [
                    if (hasData)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildSectionHeader('', () {
                          pushnameToRoute(context, ShowCompleteInfo(), false);
                        }),
                      ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    //   child: _buildSectionHeader('', () {
                    //     // showBudgetDebtCreditCard(context);
                    //     pushnameToRoute(context, ShowCompleteInfo(), false);
                    //     // pushnameToRoute(context, SelectAnyOptionScreen(),false);
                    //   }),
                    // ),
                    // const SizedBox(height: 16),
                    Skeletonizer(
                      enabled: isLoading,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SliderAdddingFinances(
                          hasData: hasData,
                          onDebtTap: _navigateToDebtDetailsScreen,
                        ),
                      ),
                    ),

                    // isLoading
                    //     ? Center(child: Spinner())
                    //     : Padding(
                    //         padding: EdgeInsets.symmetric(horizontal: 10.0),
                    //         child: SliderAdddingFinances(
                    //           hasData: hasData,
                    //           onDebtTap: _navigateToDebtDetailsScreen,
                    //         ),
                    //       ),

                    // "Heading to Recieve / to Pay" section
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: TopayToreceive(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom navigation bar
    );
  }

  // Widget for the search bar
  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.accentColor),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFF3F4F6),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View all',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.primaryColor),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget for the horizontal scrollable grid of cards

  // Individual square card with an optional dashed border

  // Widget for the bottom navigation bar

  Widget buildHeadingAndSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          image: AssetImage(svgIconPath.financepayReceive2),
          fit: BoxFit.cover,
        ),
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [
        //     Color(0x061F35E5)
        //         .withOpacity(0.4), // top color with opacity
        //     Color(0xFF061F35)
        //         .withOpacity(0.2), // bottom softer
        //     Color(0xFF061F35)
        //         .withOpacity(0.1), // bottom softer
        //   ],
        // ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          Center(
            child: textStyle(
              context: context,
              text: 'Plot your finances',
              c: Colors.white,
              fontsize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          // Search bar located below the title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: buildSearchBar(context),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

// CustomClipper for the header wave. Improved to match the image's curve.
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);

    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.95);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.88);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.8);
    var secondEndPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

// CustomClipper for the main card's complex shape. Improved for accuracy.
class CardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.15);

    var firstControlPoint = Offset(size.width * 0.15, size.height * -0.1);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.15);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.8, size.height * 0.3);
    var secondEndPoint = Offset(size.width, size.height * 0.15);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
