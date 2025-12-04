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

// // class _FinanceDashboardState extends State<FinanceDashboard>
// //     with SingleTickerProviderStateMixin {
// //   bool isLoading = true;

// //   /// 0.0 = top screen fully hidden
// //   /// 1.0 = top screen fully visible
// //   double _panelProgress = 0.0;
// //   late AnimationController _panelController;

// //   // Height of the "top screen" area
// //   static const double _maxPanelHeight = 280.0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     Get.put(CardDueController());

// //     _panelController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 250),
// //     )..addListener(() {
// //         setState(() {
// //           _panelProgress = _panelController.value;
// //         });
// //       });

// //     _loadData();
// //     getRemainders(context);
// //   }

// //   @override
// //   void dispose() {
// //     _panelController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _loadData() async {
// //     try {
// //       final cardController = Get.find<CardDueController>();
// //       await Future.wait([
// //         cardController.fetchCardData(),
// //         cardController.getBanksListCrediCard(),
// //         DebtService.fetchDebts(), // Assuming fetchDebts is async
// //       ]);
// //     } catch (e) {
// //       // log error if needed
// //     } finally {
// //       if (mounted) {
// //         setState(() => isLoading = false);
// //       }
// //     }
// //   }

// //   bool _hasFinancialData() {
// //     final hasBudgets = budgetList.isNotEmpty; // Check budgetList
// //     final hasDebts = debts.isNotEmpty; // Check debts
// //     return hasBudgets ||
// //         hasDebts ||
// //         (CreditCardScreenStrings().showCreditCard.value
// //             ? creditCardBankList.isNotEmpty
// //             : false);
// //   }

// //   void _navigateToDebtDetailsScreen(Debt debt) async {
// //     await Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (context) => DebtDetailsScreen(debt: debt)),
// //     );
// //   }

// //   /// Handle scroll notifications to detect pull down at top
// //   bool _onScrollNotification(ScrollNotification notification) {
// //     // We only care about pulls at top (overscroll negative)
// //     if (notification.metrics.pixels <= 0 &&
// //         notification is OverscrollNotification &&
// //         notification.overscroll < 0) {
// //       final delta = -notification.overscroll; // positive value of pull
// //       final double deltaProgress =
// //           delta / _maxPanelHeight; // convert pixels to progress

// //       double newProgress = (_panelProgress + deltaProgress).clamp(0.0, 1.0);

// //       _panelController.value = newProgress; // sync with animation controller
// //       return true; // we handled this
// //     }

// //     // When user lifts finger, decide to snap open or close
// //     if (notification is ScrollEndNotification) {
// //       if (_panelProgress > 0.5) {
// //         _panelController.animateTo(
// //           1.0,
// //           curve: Curves.easeOutCubic,
// //         ); // snap open
// //       } else {
// //         _panelController.animateTo(
// //           0.0,
// //           curve: Curves.easeOutCubic,
// //         ); // snap closed
// //       }
// //     }

// //     return false;
// //   }

// //   void _closeTopPanel() {
// //     _panelController.animateTo(
// //       0.0,
// //       curve: Curves.easeOutCubic,
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final Size size = MediaQuery.of(context).size;

// //     // Based on panel progress, calculate positions
// //     final double panelTopOffset =
// //         -_maxPanelHeight * (1 - _panelProgress); // from -height → 0
// //     final double mainTopOffset =
// //         _panelProgress * _maxPanelHeight; // from 0 → height

// //     return Scaffold(
// //       backgroundColor: AppColors.primaryColor,
// //       bottomNavigationBar:  SafeArea(
// //         child: BottomNavigations(
// //           data: 1,
// //         ),
// //       ),
// //       body: SafeArea(
// //         child: Stack(
// //           children: [
// //             // 🔹 TOP SCREEN (initially hidden above, slides down)
// //             Positioned(
// //               top: panelTopOffset,
// //               left: 0,
// //               right: 0,
// //               height: _maxPanelHeight,
// //               child: _buildTopPanel(context),
// //             ),

// //             // 🔹 MAIN FINANCE DASHBOARD (moves down when top screen appears)
// //             Positioned.fill(
// //               top: mainTopOffset,
// //               child: NotificationListener<ScrollNotification>(
// //                 onNotification: _onScrollNotification,
// //                 child: SingleChildScrollView(
// //                   physics: const AlwaysScrollableScrollPhysics(),
// //                   child: Column(
// //                     children: [
// //                       _buildTopSection(context, size),
// //                       _buildBottomSection(context),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ===================== UI PARTS =====================

// //   /// The "top screen" that appears when you pull down.
// //   /// You can customise this completely as your special super UI.
// //   Widget _buildTopPanel(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: AppColors.backgroundColor,
// //         borderRadius: const BorderRadius.vertical(
// //           bottom: Radius.circular(20),
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.12),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Close button row
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               textStyle(
// //                 context: context,
// //                 text: 'Quick Finance Snapshot',
// //                 c: AppColors.primaryColor,
// //                 fontsize: 18,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //               IconButton(
// //                 icon: const Icon(Icons.close),
// //                 onPressed: _closeTopPanel,
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 8),
// //           textStyle(
// //             context: context,
// //             text:
// //                 'This panel comes down when you PULL.\nYou still see the main screen below, like 2 screens in a column.',
// //             c: AppColors.grey,
// //             fontsize: 13,
// //           ),
// //           const SizedBox(height: 16),

// //           // Example content — replace with your own cards / stats / grid
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: AppColors.primaryColor.withOpacity(0.06),
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       textStyle(
// //                         context: context,
// //                         text: 'Total Debts',
// //                         c: AppColors.primaryColor,
// //                         fontsize: 14,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                       const SizedBox(height: 4),
// //                       textStyle(
// //                         context: context,
// //                         text: '₹ 1,20,000',
// //                         c: AppColors.primaryColor,
// //                         fontsize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                 child: Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: AppColors.primaryColor.withOpacity(0.06),
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       textStyle(
// //                         context: context,
// //                         text: 'Upcoming EMI',
// //                         c: AppColors.primaryColor,
// //                         fontsize: 14,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                       const SizedBox(height: 4),
// //                       textStyle(
// //                         context: context,
// //                         text: '₹ 8,500 on 10th',
// //                         c: AppColors.primaryColor,
// //                         fontsize: 16,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 12),
// //           Expanded(
// //             child: Align(
// //               alignment: Alignment.bottomCenter,
// //               child: SizedBox(
// //                 width: double.infinity,
// //                 child: ElevatedButton(
// //                   onPressed: () {
// //                     // Example: go to some deep detailed screen
// //                     // pushnameToRoute(context, ShowCompleteInfo(), true);
// //                   },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: AppColors.primaryColor,
// //                     padding: const EdgeInsets.symmetric(vertical: 12),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                   ),
// //                   child: const Text('View Detailed Insights'),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   /// Your original top container with avatar, heading, background and FeatureGrid
// //   Widget _buildTopSection(BuildContext context, Size size) {
// //     return Container(
// //       color: AppColors.backgroundColor,
// //       height: size.height / 2.15,
// //       width: MediaQuery.of(context).size.width,
// //       child: Stack(
// //         children: [
// //           Transform.translate(
// //             offset: Offset(
// //               0,
// //               -size.height * 0.025,
// //             ),
// //             child: AvatarProfileImageZero(
// //               url: svgIconPath.finance,
// //               width: 1,
// //               height: 2,
// //             ),
// //           ),
// //           Column(
// //             mainAxisSize: MainAxisSize.min,
// //             mainAxisAlignment: MainAxisAlignment.start,
// //             children: [
// //               const SizedBox(height: 25),
// //               buildHeadingAndSearchBar(),
// //               Stack(
// //                 children: [
// //                   Transform.translate(
// //                     offset: Offset(0, -size.height * 0.04),
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 10),
// //                       child: AvatarProfileImageZero(
// //                         url: svgIconPath.finance_background,
// //                         width: 1,
// //                         height: 4.4,
// //                       ),
// //                     ),
// //                   ),
// //                   Transform.translate(
// //                     offset: Offset(0, -size.height * 0.085),
// //                     child: Container(
// //                       padding: const EdgeInsets.fromLTRB(5, 10, 10, 5),
// //                       margin: const EdgeInsets.symmetric(horizontal: 10.0),
// //                       child: const Center(child: FeatureGrid()),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   /// Your original bottom section with slider, topay/toreceive etc.
// //   Widget _buildBottomSection(BuildContext context) {
// //     return Container(
// //       color: AppColors.backgroundColor,
// //       child: Column(
// //         children: [
// //           if (getCreditCardBudgetDebts.value)
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 24.0),
// //               child: _buildSectionHeader('', () {
// //                 pushnameToRoute(context, ShowCompleteInfo(), false);
// //               }),
// //             ),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
// //             child: SliderAdddingFinances(
// //               onDebtTap: _navigateToDebtDetailsScreen,
// //             ),
// //           ),
// //           const SizedBox(height: 10),
// //           const Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 24.0),
// //             child: TopayToreceive(),
// //           ),
// //           const SizedBox(height: 100),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSectionHeader(String title, VoidCallback onTap) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           title,
// //           style: FontManager().getTextStyle(
// //             context,
// //             lWeight: FontWeight.w500,
// //             fontSize: 16,
// //             color: AppColors.grey,
// //           ),
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
// //                   style: FontManager().getTextStyle(
// //                     context,
// //                     lWeight: FontWeight.w500,
// //                     fontSize: 14,
// //                     color: AppColors.backgroundColor,
// //                   ),
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
// //           const SizedBox(height: 25),
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
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/profileUser.dart';
import 'package:flutter_application_code_stakeplot/email_sync/add_credit_card_bank.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:flutter_application_code_stakeplot/repository/debt_service.dart';
import 'package:flutter_application_code_stakeplot/repository/payables_repository.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Utils/credit_card.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/bottomNavigations.dart';
import '../../Constants/colorcodes.dart';
import '../../controllers/credit_card_controller.dart';
import '../Budgets/Budget.dart';
import 'FeatureGrid.dart';
import 'searchfinance.dart';
import 'show_complete_info.dart';
import 'slider_addding_finances.dart';
import 'topay_toreceive.dart';

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
  static const double _maxPanelHeight = 280.0;

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
    _hintController.dispose(); // dispose hint controller
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final cardController = Get.find<CardDueController>();
      await Future.wait([
        cardController.fetchCardData(),
        cardController.getBanksListCrediCard(),
        DebtService.fetchDebts(), // Assuming fetchDebts is async
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
    final hasBudgets = budgetList.isNotEmpty; // Check budgetList
    final hasDebts = debts.isNotEmpty; // Check debts
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

  /// ⭐ UPDATED: Scroll handler
  /// - Pull down at top -> open panel (like before)
  /// - While panel is open and user scrolls up -> close panel instead of scrolling under it
  // bool _onScrollNotification(ScrollNotification notification) {
  //   // 1️⃣ If panel is OPEN and user scrolls UP (content moving up, scrollDelta > 0),
  //   //    use that to CLOSE the panel instead of moving the content.
  //   if (_panelProgress > 0.0 &&
  //       notification is ScrollUpdateNotification &&
  //       (notification.scrollDelta ?? 0) > 0) {
  //     final double delta = notification.scrollDelta ?? 0;

  //     // Cancel this scroll movement by jumping back the same distance
  //     if (_scrollController.hasClients) {
  //       final current = _scrollController.position.pixels;
  //       final newOffset = (current - delta).clamp(
  //         _scrollController.position.minScrollExtent,
  //         _scrollController.position.maxScrollExtent,
  //       );
  //       if (newOffset != current) {
  //         _scrollController.jumpTo(newOffset);
  //       }
  //     }

  //     // Use that delta to reduce panel progress (close)
  //     final double deltaProgress = delta / _maxPanelHeight;
  //     final double newProgress =
  //         (_panelProgress - deltaProgress).clamp(0.0, 1.0);
  //     _panelController.value = newProgress;

  //     return true; // we handled it, don't let content scroll "inside" panel
  //   }

  //   // 2️⃣ Handle pull-down overscroll at top to OPEN panel
  //   if (notification.metrics.pixels <= 0 &&
  //       notification is OverscrollNotification &&
  //       notification.overscroll < 0) {
  //     final double delta = -notification.overscroll; // make positive
  //     final double deltaProgress = delta / _maxPanelHeight;

  //     final double newProgress =
  //         (_panelProgress + deltaProgress).clamp(0.0, 1.0);

  //     _panelController.value = newProgress;
  //     return true;
  //   }

  //   // 3️⃣ Snap open/close when finger released if panel is partially open
  //   if (notification is ScrollEndNotification) {
  //     if (_panelProgress > 0.5) {
  //       _panelController.animateTo(
  //         1.0,
  //         curve: Curves.easeOutCubic,
  //       );
  //     } else {
  //       _panelController.animateTo(
  //         0.0,
  //         curve: Curves.easeOutCubic,
  //       );
  //     }
  //   }

  //   return false;
  // }

  bool _onScrollNotification(ScrollNotification notification) {
    // 1️⃣ If panel is OPEN and user scrolls UP, close panel instantly and block list scroll
    if (_panelProgress > 0.0 &&
        notification is ScrollUpdateNotification &&
        (notification.scrollDelta ?? 0) > 0) {
      final double delta = notification.scrollDelta ?? 0;

      // Cancel this scroll movement of the main list
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

      // Snap the panel closed quickly
      if (_panelProgress != 0.0) {
        _panelController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }

      // We handled this gesture: don't let main scroll
      return true;
    }

    // 2️⃣ Handle PULL DOWN at top (overscroll) to open panel
    if (notification.metrics.pixels <= 0 &&
        notification is OverscrollNotification &&
        notification.overscroll < 0) {
      final double drag = -notification.overscroll; // make positive
      final double deltaProgress = drag / _maxPanelHeight;

      final double newProgress =
          (_panelProgress + deltaProgress).clamp(0.0, 1.0);

      _panelController.value = newProgress; // both panel & main move together
      return true; // consume this overscroll for panel movement
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

    return false; // let normal scroll through otherwise
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Based on panel progress, calculate positions
    final double panelTopOffset =
        -_maxPanelHeight * (1 - _panelProgress); // from -height → 0
    final double mainTopOffset =
        _panelProgress * _maxPanelHeight; // from 0 → height

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      bottomNavigationBar: SafeArea(
        child: BottomNavigations(
          data: 1,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 TOP SCREEN (initially hidden above, slides down)
            Positioned(
              top: panelTopOffset,
              left: 0,
              right: 0,
              height: _maxPanelHeight,
              child: _buildTopPanel(context),
            ),

            // 🔹 MAIN FINANCE DASHBOARD (moves down when top screen appears)
            Positioned.fill(
              top: mainTopOffset,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScrollNotification,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTopSection(context, size),
                      _buildBottomSection(context),
                    ],
                  ),
                ),
              ),
            ),

            // 🔥 Flickering "Pull down to see overview" hint
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

  // ===================== UI PARTS =====================

  /// The "top screen" that appears when you pull down.
  /// You can customise this completely.
  Widget _buildTopPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textStyle(
                context: context,
                text: 'Quick Finance Snapshot',
                c: AppColors.primaryColor,
                fontsize: 18,
                fontWeight: FontWeight.w600,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _closeTopPanel,
              ),
            ],
          ),
          const SizedBox(height: 8),
          textStyle(
            context: context,
            text:
                'This panel comes down when you PULL.\nYou still see the main screen below, like 2 screens in a column.',
            c: AppColors.grey,
            fontsize: 13,
          ),
          const SizedBox(height: 16),

          // Example content — replace with your own cards / stats / grid
          Row(
            children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textStyle(
                      context: context,
                      text: 'Total Debts',
                      c: AppColors.primaryColor,
                      fontsize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 4),
                    textStyle(
                      context: context,
                      text: '₹ 1,20,000',
                      c: AppColors.primaryColor,
                      fontsize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textStyle(
                      context: context,
                      text: 'Upcoming EMI',
                      c: AppColors.primaryColor,
                      fontsize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 4),
                    textStyle(
                      context: context,
                      text: '₹ 8,500 on 10th',
                      c: AppColors.primaryColor,
                      fontsize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Example: go to some deep detailed screen
                    // pushnameToRoute(context, ShowCompleteInfo(), true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Detailed Insights'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Your original top container with avatar, heading, background and FeatureGrid
  Widget _buildTopSection(BuildContext context, Size size) {
    return Container(
      color: AppColors.backgroundColor,
      height: size.height / 2.15,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(
              0,
              -size.height * 0.025,
            ),
            child: AvatarProfileImageZero(
              url: svgIconPath.finance,
              width: 1,
              height: 2,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              buildHeadingAndSearchBar(),
              Stack(
                children: [
                  Transform.translate(
                    offset: Offset(0, -size.height * 0.04),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AvatarProfileImageZero(
                        url: svgIconPath.finance_background,
                        width: 1,
                        height: 4.4,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -size.height * 0.085),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 10, 10, 5),
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: const Center(child: FeatureGrid()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Your original bottom section with slider, topay/toreceive etc.
  Widget _buildBottomSection(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.grey,
          ),
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
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.backgroundColor,
                  ),
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
          const SizedBox(height: 25),
          Center(
            child: textStyle(
              context: context,
              text: 'Plot your finances',
              c: AppColors.backgroundColor,
              fontsize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
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
