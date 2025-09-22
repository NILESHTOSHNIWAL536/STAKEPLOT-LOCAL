import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/email_sync/add_credit_card_bank.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../Utils/credit_card.dart';
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
    // final cardController = CardDueController();
    // final hasCreditCards = cardController.cardList?.isNotEmpty ?? false;
    final hasBudgets = budgetList?.isNotEmpty ?? false; // Check budgetList
    final hasDebts = debts?.isNotEmpty ?? false; // Check debts
    return hasBudgets ||
            hasDebts ||
            CreditCardScreenStrings().showCreditCard.value
        ? creditCardBankList.isNotEmpty
        : false;
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
               
                height: size.height / 2.15,
                width: MediaQuery.of(context).size.width,
                // color: AppColors.primaryColor,
                child: Stack(
                  children: [
                    // Background color with a wave shape at the bottom

                    Transform.translate(
                                          offset: Offset(
                      0,
                      -size.height *
                          0.025), // Responsive offset based on screen height
                                          child: AvatarProfileImageZero(
                      url: svgIconPath.finance, width: 1, height: 2),
                                        ),

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
                                      0.04), // Responsive offset based on screen height
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: AvatarProfileImageZero(
                                    url: svgIconPath.finance_background,
                                    width: 1,
                                    height: 4.4),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(
                                  0,
                                  -size.height *
                                      0.085), // Responsive offset based on screen height
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
                    if (getCreditCardBudgetDebts.value)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildSectionHeader('', () {
                          pushnameToRoute(context, ShowCompleteInfo(), false);
                        }),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: SliderAdddingFinances(
                        // hasData: hasData,
                        onDebtTap: _navigateToDebtDetailsScreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: TopayToreceive(),
                    ),
                    const SizedBox(height: 100),
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
              lWeight: FontWeight.w500, fontSize: 16, color: AppColors.grey),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
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
                      lWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.backgroundColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeadingAndSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          image: AssetImage(svgIconPath.financepayReceive2),
          fit: BoxFit.cover,
        ),
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

// CustomClipper for the main card's complex shape. Improved for accuracy.
