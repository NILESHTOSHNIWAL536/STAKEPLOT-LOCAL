// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/repository/group_Api.dart';
// import 'package:flutter_application_code_stakeplot/components/helper.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_AppBar.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionCalender.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
// import 'package:get/get.dart';
// import 'dart:async';

// /// GLOBALS (kept unchanged)
// final TextEditingController searchController = TextEditingController();
// FocusNode focusNodeSearchFeild = FocusNode();
// final RxBool showFilter = false.obs;

// class TransactionHistoryScreen extends StatefulWidget {
//   final bool fromAutoPay;
//   const TransactionHistoryScreen({super.key, this.fromAutoPay = false});

//   @override
//   State<TransactionHistoryScreen> createState() =>
//       _TransactionHistoryScreenState();
// }

// class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
//   final RxList<Map<String, dynamic>> filteredTransactions =
//       RxList<Map<String, dynamic>>([]);
//   final ScrollController scrollController = ScrollController();
//   final RxList<Map<String, dynamic>> dayWiseTransactions =
//       RxList<Map<String, dynamic>>([]);
//   final RxBool isDateSummaryView = false.obs;
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();

//     /// Existing logic untouched
//     currentPage = 1;
//     showFilter.value = false;
//     accountSelected.value = '';
//     addManually.clear();
//     balanceOutList.clear();
//     maxController.text = "";
//     minController.text = "";
//     startDateController.text = "";
//     endDateController.text = "";

//     getAllTransactionHistory(context, false, false, isRefreshing: true);

//     getDayWiseTransactions(context).then((data) {
//       dayWiseTransactions.assignAll(data);
//     });

//     scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     if (scrollController.position.pixels >=
//         scrollController.position.maxScrollExtent - 50) {
//       getAllTransactionHistory(context, false, false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.sizeOf(context).height;

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: AppColors.backgroundColor,
//         appBar: historyAppBar(context, widget.fromAutoPay),
//         body: SafeArea(
//           child: Column(
//             children: [
//               _buildSearchAndTabsSection(context),
//               Expanded(child: _buildTransactionBody(context, screenHeight)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // UI SECTIONS
//   // ---------------------------------------------------------------------------

//   Widget _buildSearchAndTabsSection(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       width: double.infinity,
//       decoration: BoxDecoration(color: AppColors.primaryColor),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 4),
//           Padding(
//             padding: EdgeInsets.only(
//               left: 10,
//               right: 2,
//               bottom: (groupTransactionList.isEmpty ? 4 : 3),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 _buildSearchField(context),
//                if (!widget.fromAutoPay) _buildToggleDateSummaryBtn(),
//                if (!widget.fromAutoPay) _buildFilterButton(),
//               ],
//             ),
//           ),
//           _buildTabsOrCheckbox(),
//           _buildTagHideButtons(),
//           _buildFilterSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionBody(BuildContext context, double screenHeight) {
//     return Obx(() {
//       double calculatedHeight;

//       if (showFilter.value || redioButton.isNotEmpty) {
//         calculatedHeight = screenHeight / 1.52;
//       } else if (showFilter.value && !isDateSummaryView.value) {
//         calculatedHeight = screenHeight / 1.5;
//       } else {
//         calculatedHeight =
//             (groupTransactionList.isNotEmpty || redioButton.isNotEmpty)
//                 ? screenHeight / 1.35
//                 : screenHeight / 1.25;
//       }

//       return SizedBox(
//         width: double.infinity,
//         height: calculatedHeight,
//         child: IndexedStack(
//           index: isDateSummaryView.value ? 0 : 1,
//           children: [
//             CalendarTransactionScreen(),
//             NotificationListener<ScrollNotification>(
//               onNotification: (scrollNotification) {
//                 if (scrollNotification is ScrollStartNotification) {
//                   FocusScope.of(context).unfocus();
//                 }
//                 return false;
//               },
//               child: SingleChildScrollView(
//                 controller: scrollController,
//                 child: TransactionHistory(
//                   isYearView: false,
//                   isflag: true,
//                   showIcon: false,
//                   expandedPage: false,
//                   fromAutoPay: widget.fromAutoPay,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   // ---------------------------------------------------------------------------
//   // Sub widgets extracted for clarity
//   // ---------------------------------------------------------------------------

//   Widget _buildSearchField(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width / 1.4,
//       height: MediaQuery.of(context).size.width / 10,
//       child: TextField(
//         controller: searchController,
//         focusNode: focusNodeSearchFeild,
//         onChanged: _onSearchChanged,
//         decoration: InputDecoration(
//           hintText: HomepageStringsDart().searchTransactions,
//           hintStyle: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.w500,
//             fontSize: 14,
//             color: AppColors.grey,
//           ),
//           prefixIcon: Icon(Icons.search, color: AppColors.grey),
//           suffixIcon: _buildClearButton(),
//           filled: true,
//           fillColor: AppColors.bg5,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
//         ),
//         style: const TextStyle(color: AppColors.accentColor),
//       ),
//     );
//   }

//   void _onSearchChanged(String value) {
//     isDateSummaryView.value = false;
//     allOrGroupTransactionsName.value = StringConstant.allTransactions;
//     searchItemClicked.value = false;

//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       onChanedAutoTransactionStatus(context);
//     });

//     searchTextController.value = value;
//     searchTextControllerBool.value = !searchTextControllerBool.value;
//   }

//   _buildClearButton() {
//     return searchController.text.isNotEmpty
//         ? IconButton(
//             icon: Icon(Icons.clear, color: AppColors.accentColor),
//             onPressed: () {
//               searchController.clear();
//               searchTextController.value = '';
//               clearTransactions(context: context, f: true);
//               searchTextControllerBool.value = !searchTextControllerBool.value;
//             },
//           )
//         : null;
//   }

//   Widget _buildToggleDateSummaryBtn() {
//     return InkWell(
//       onTap: () => isDateSummaryView.value = !isDateSummaryView.value,
//       child: Obx(
//         () => AvatarProfileImage(
//           url: !isDateSummaryView.value
//               ? HomePageIcons.dayWiseIcon1
//               : HomePageIcons.dayWiseIcon2,
//           width: 70,
//           height: 36,
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterButton() {
//     return InkWell(
//       onTap: () => _toggleFilter(),
//       child: Obx(
//         () => AvatarProfileImage(
//           url: !showFilter.value
//               ? HomePageIcons.filterIcon
//               : HomePageIcons.filterOn,
//           width: 66,
//           height: 30,
//         ),
//       ),
//     );
//   }

//   void _toggleFilter() {
//     showFilter.value = !showFilter.value;

//     if (!showFilter.value) {
//       searchTextController.value = "";
//       searchController.text = "";
//       startDateController.text = "";
//       endDateController.text = "";
//       showDateFilter.value = false;
//       showAmountFilter.value = false;
//       onChanedAutoTransactionStatus(context);
//     }
//   }

//   Widget _buildTabsOrCheckbox() {
//     return Obx(() {
//       if (isDateSummaryView.value) return const SizedBox(height: 10);

//       final showTabs = groupTransactionList.isNotEmpty || showCheckBox.value;

//       return Padding(
//         padding: const EdgeInsets.only(left: 10, right: 2),
//         child: showTabs
//             ? Padding(
//                 padding: const EdgeInsets.only(top: 3),
//                 child: Obx(() => showCheckBox.value
//                     ? _buildCheckBoxButtons()
//                     : getTab(context)),
//               )
//             : const SizedBox(height: 10),
//       );
//     });
//   }

//   Widget _buildCheckBoxButtons() {
//     return Padding(
//       padding: const EdgeInsets.only(right: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _selectButton("Selected (${redioButton.length})"),
//           _cancelButton("Cancel"),
//         ],
//       ),
//     );
//   }

//   Widget _selectButton(String text) {
//     return _coloredButton(text, AppColors.button);
//   }

//   Widget _cancelButton(String text) {
//     return InkWell(
//       onTap: () {
//         showCheckBox.value = false;
//         redioButton.clear();
//         redioButtonIndex.clear();
//         balanceOutList.clear();
//         addManually.clear();
//         HapticFeedback.selectionClick();
//       },
//       child: _coloredButton(text, AppColors.primaryColor,
//           bg: AppColors.backgroundColor),
//     );
//   }

//   Widget _coloredButton(String text, Color color, {Color? bg}) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       width: MediaQuery.of(context).size.width / 2.5,
//       height: MediaQuery.of(context).size.height / 26,
//       decoration: BoxDecoration(
//         color: bg ?? Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Center(
//         child: textStyleImage(
//           context: context,
//           text: text,
//           c: color,
//           fontsize: 14,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   Widget _buildTagHideButtons() {
//     return Obx(() => (redioButton.isNotEmpty && _showTagButtons())
//         ? Padding(
//             padding: const EdgeInsets.only(left: 10, right: 2, top: 8),
//             child: getTagHideButtons(context),
//           )
//         : const SizedBox.shrink());
//   }

//   bool _showTagButtons() {
//     return !isDateSummaryView.value &&
//         allOrGroupTransactionsName.value == StringConstant.allTransactions;
//   }

//   Widget _buildFilterSection() {
//     return Obx(() => (showFilter.value && _showTagButtons())
//         ? filterTransaction(context)
//         : const SizedBox.shrink());
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/collections/create_collection_pages/collection_people_selector.dart';
import 'package:flutter_application_code_stakeplot/repository/group_Api.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_AppBar.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionCalender.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/core/container_border.dart';
import 'collections/collections_list_widget.dart';
import 'recent_transactions.dart';

final TextEditingController searchController = TextEditingController();
FocusNode focusNodeSearchFeild = FocusNode();
final RxBool showFilter = false.obs;
final RxString selectedTab = "All".obs;

class TransactionHistoryScreen extends StatefulWidget {
  final bool fromAutoPay;
  final bool isFromCollection;
  const TransactionHistoryScreen({super.key, this.fromAutoPay = false, this.isFromCollection = false});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  final RxList<Map<String, dynamic>> filteredTransactions =
      RxList<Map<String, dynamic>>([]);
  final ScrollController scrollController = ScrollController();
  final RxList<Map<String, dynamic>> dayWiseTransactions =
      RxList<Map<String, dynamic>>([]);
  final RxBool isDateSummaryView = false.obs;
  Timer? _debounce;

  // ---------------------------------------------------------------------------
  // 🔥 NEW: Search animation variables (ONLY ADDITION)
  // ---------------------------------------------------------------------------
  late AnimationController _searchAnimController;
  late Animation<Offset> _searchSlideAnim;
  late Animation<double> _searchHeightAnim;
  bool isSearchActive = false;
late Animation<double> _searchScaleAnim;

  @override
  void initState() {
    super.initState();

   _searchAnimController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 550), // slower = elastic feel
);

_searchSlideAnim = Tween<Offset>(
  begin: const Offset(0, -0.25),
  end: Offset.zero,
).animate(
  CurvedAnimation(
    parent: _searchAnimController,
    curve: Curves.elasticOut, 
  ),
);

_searchScaleAnim = Tween<double>(
  begin: 0.95,
  end: 1.0,
).animate(
  CurvedAnimation(
    parent: _searchAnimController,
    curve: Curves.elasticOut, // 🔥 bounce
  ),
);

    focusNodeSearchFeild.addListener(() {
      if (focusNodeSearchFeild.hasFocus) {
        _openSearch();
      }
    });
    currentPage = 1;
    showFilter.value = false;
    accountSelected.value = '';
    addManually.clear();
    balanceOutList.clear();
    maxController.text = "";
    minController.text = "";
    startDateController.text = "";
    endDateController.text = "";

    getAllTransactionHistory(context, false, false, isRefreshing: true);

    getDayWiseTransactions(context).then((data) {
      dayWiseTransactions.assignAll(data);
    });

    scrollController.addListener(_onScroll);
  }

 
  void _openSearch() {
    if (isSearchActive) return;
    HapticFeedback.selectionClick();
    isSearchActive = true;
    _searchAnimController.forward();
  }

  void _closeSearch() {
    FocusScope.of(context).unfocus();
    searchController.clear();
    _searchAnimController.reverse();
    isSearchActive = false;

    clearTransactions(context: context, f: true);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 50) {
      getAllTransactionHistory(context, false, false);
    }
  }

  @override
  void dispose() {
    _searchAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = widget.isFromCollection? MediaQuery.sizeOf(context).height/ 1.5:MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus(); 
      isSearchActive = false;
      
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        // appBar: isSearchActive?null: historyAppBar(context, widget.fromAutoPay),
        body: SafeArea(
          child: Container(
            color: AppColors.border,
            child: widget.isFromCollection?
            Column(
              children: [

                _buildSearchFieldForCollection(context, widget.isFromCollection),
                Expanded(child: _buildTransactionBody(context, screenHeight)),
              ],
            ):
          Column(
  children: [
    isSearchActive?
        _buildSearchAndTabsSection(context)
        : historyHeader(context, widget.fromAutoPay),

    Obx(() {
      if (isSearchActive) {
        return const SizedBox.shrink();
      }

      if (showFilter.value || isDateSummaryView.value) {
        return Column(
          children: [
            _buildTabsOrCheckbox(),
            _buildTagHideButtons(),
            _buildFilterSection(),
          ],
        );
      }

      return _buildSearchAndTabsSection(context);
    }),

    Container(
      color: AppColors.border,
      height: isSearchActive?MediaQuery.sizeOf(context).height / 1.14: MediaQuery.sizeOf(context).height / 1.27,
      child: Obx(() {
        return selectedTab.value == "All"
            ? _buildTransactionBody(context, screenHeight)
            : buildCollectionsBody(context);
      }),
    ),
  ],
),

          ),
        ),
      ),
    );
  }
 

Widget _buildBackArrow() {
  return IconButton(
    icon: const Icon(
      Icons.arrow_back_ios_new,
      color: AppColors.accentColor,
      size: 20,
    ),
    onPressed: _closeSearch,
  );
}
Widget _buildTabChip(String title) {
  return Obx(() {
    final isSelected = selectedTab.value == title;

    return GestureDetector(
      onTap: () {
        selectedTab.value = title;

        // OPTIONAL: handle logic
        // if (title == "Collections") { ... }
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3.7,
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: FontManager().getTextStyle(
            context,
            fontSize: 13,
            lWeight: FontWeight.w600,
            color: isSelected
                ? AppColors.backgroundColor
                : AppColors.grey,
          ),
        ),
      ),
    );
  });
}

 Widget historyHeader(BuildContext context, bool fromAutoPay) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p6, vertical: AppSizes.p12),
    decoration: const BoxDecoration(
      color: AppColors.newbg,
      
    ),
    child: SafeArea(
      bottom: false,
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: () {
              clearTransactions(context: context);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(AppSizes.r16),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p6),
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColors.accentColor,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Title
Obx(() {
  final calculatedWidth = showFilter.value || isDateSummaryView.value
      ? MediaQuery.sizeOf(context).width / 1.4
      : MediaQuery.sizeOf(context).width - (fromAutoPay ? 100 : 170);

  return Center(
    child: Container(
      width: calculatedWidth,
      child: Text(
        !fromAutoPay
            ? HomepageStringsDart().historyTitle
            : "Select Transaction",
        style: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.w600,
          fontSize: 18,
          color: AppColors.primaryColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}),

          // Download icon (only when not fromAutoPay)
          if (!fromAutoPay)
          

      // RIGHT ACTION AREA
Obx(() => _buildHeaderRightAction(context)),




        ],
      ),
    ),
  );
}
Widget _buildHeaderRightAction(BuildContext context) {
  if (showFilter.value) {
    return _buildFilterButton();
  }

  if (isDateSummaryView.value) {
    return _buildToggleDateSummaryBtn();
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RecentTransactionsScreen(),
        ),
      );
    },
    child: AutoHintIcon(
      iconUrl: HomePageIcons.recentTransactions,
      text: "Today View",
    ),
  );
}

Widget _buildSearchAndTabsSection(BuildContext context) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    width: double.infinity,
    decoration:  BoxDecoration(color: AppColors.newbg,),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        Padding(
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            bottom: (groupTransactionList.isEmpty ? 4 : 3),
          ),
          child: 
          Row(
            children: [
              
              
               if (isSearchActive) ...[
      _buildBackArrow(),
      Container(
        width: MediaQuery.of(context).size.width / 1.2,
        child: _buildSearchField(context, widget.fromAutoPay),
      ),
    ]
    else ...[
     _buildTabChip("All"),
    _buildTabChip("Collections"),

    
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
              
                child: isSearchActive
                    ? _buildSearchField(context, widget.fromAutoPay)
                    : _buildSearchIcon(),
              ),
              SizedBox(width: 4),

              if (!widget.fromAutoPay && !isSearchActive)
                _buildToggleDateSummaryBtn(),
SizedBox(width: 8),
              if (!widget.fromAutoPay && !isSearchActive)
                _buildFilterButton(),
    ]
            ],
          ),
      
          
        ),

        if (!isSearchActive) _buildTabsOrCheckbox(),
        if (!isSearchActive) _buildTagHideButtons(),
        if (!isSearchActive) _buildFilterSection(),
      ],
    ),
  );
}

Widget _buildSearchIcon() {
  return IconButton(
    icon: const CustomStyledContainer(
      radius: 5.0, // <-- Passing a custom radius
 width: 36,
      height: 36, // <-- Passing a custom radius
   
    child: Icon(Icons.search, color: AppColors.primaryColor, size: 24, ),
  ),
    
   
    onPressed: () {
      setState(() => isSearchActive = true);
      _searchAnimController.forward();
      FocusScope.of(context).requestFocus(focusNodeSearchFeild);
    },
  );
}

 Widget _buildSearchField(BuildContext context, bool fromAutoPay) {
  return AnimatedBuilder(
    animation: _searchAnimController,
    builder: (_, __) {
      return SlideTransition(
        position: _searchSlideAnim,
        child: ScaleTransition(
          scale: _searchScaleAnim, // 🔥 elastic bounce
          child: SizedBox(
            width: 
                 MediaQuery.of(context).size.width / 1.1,
                
            height: MediaQuery.of(context).size.width / 10,
            child: TextField(
              controller: searchController,
              focusNode: focusNodeSearchFeild,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: HomepageStringsDart().searchTransactions,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buildClearButton(),
                filled: true,
                fillColor: AppColors.bg5,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
              ),
              style: const TextStyle(color: AppColors.accentColor),
            ),
          ),
        ),
      );
    },
  );
}

// Change the search field for collection screen
Widget _buildSearchFieldForCollection(BuildContext context, bool isFromCollection) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
       
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.25,
          height: MediaQuery.of(context).size.width / 10,
          child: TextField(
            controller: searchController,
            focusNode: focusNodeSearchFeild,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: HomepageStringsDart().searchTransactions,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _buildClearButton(),
              filled: true,
              fillColor: AppColors.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
            ),
            style: const TextStyle(color: AppColors.accentColor),
          ),
        ),
          const SizedBox(width: 10),
         Container(
          
          child: !isFromCollection
              ? const SizedBox.shrink()
              : GestureDetector(
                onTap: () {
                 
                },
                child: const CustomStyledContainer(
                    radius: 5.0, 
                    height: 36,
                    width: 36,
                    child: Icon(Icons.add, color: AppColors.primaryColor, size: 24, ),
                     ),
              )),
      ],
    ),
  );
}

  void _onSearchChanged(String value) {
    isDateSummaryView.value = false;
    allOrGroupTransactionsName.value = StringConstant.allTransactions;
    searchItemClicked.value = false;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      onChanedAutoTransactionStatus(context);
    });

    searchTextController.value = value;
    searchTextControllerBool.value = !searchTextControllerBool.value;
  }
  _buildClearButton() {
    return searchController.text.isNotEmpty
        ? IconButton(
            icon: Icon(Icons.clear, color: AppColors.accentColor),
            onPressed: () {
              searchController.clear();
              searchTextController.value = '';
              clearTransactions(context: context, f: true);
              searchTextControllerBool.value = !searchTextControllerBool.value;
            },
          )
        : null;
  }
  Widget _buildToggleDateSummaryBtn() {
    return InkWell(
      onTap: () => isDateSummaryView.value = !isDateSummaryView.value,
      child: Obx(
        () =>   CustomStyledContainer(
 radius: 5.0, // <-- Passing a custom radius
 width: 36,
      height: 36,
  child: 
        
        AvatarProfileImage(
          url: isDateSummaryView.value
              ? HomePageIcons.dayWiseIcon1
              : HomePageIcons.dayWiseIcon2,
          width: 70,
          height: 36,
        ),
        )
      )
    );
  }

  Widget _buildFilterButton() {
    return InkWell(
      onTap: () => showFilter.value = !showFilter.value,
      child: Obx(
        () =>  CustomStyledContainer(
  radius: 5.0, // <-- Passing a custom radius
 width: 36,
      height: 36,
  
        child: AvatarProfileImage(
          url: showFilter.value
              ? HomePageIcons.filterIcon
              : HomePageIcons.filterOn,
          width: 66,
          height: 30,
        ),
      ),
      )
    );
  }

  Widget _buildTransactionBody(BuildContext context, double screenHeight) {
    return Obx(() {
      return IndexedStack(
        index: isDateSummaryView.value ? 0 : 1,
        children: [
          CalendarTransactionScreen(),
          SingleChildScrollView(
            controller: scrollController,
            child: TransactionHistory(
              isYearView: false,
              isflag: true,
              showIcon: false,
              expandedPage: false,
              fromAutoPay: widget.fromAutoPay,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTabsOrCheckbox() {
    return Obx(() {
      if (isDateSummaryView.value) return const SizedBox(height: 10);

      final showTabs = groupTransactionList.isNotEmpty || showCheckBox.value;

      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 2),
        child: showTabs
            ? Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Obx(() => showCheckBox.value
                    ? _buildCheckBoxButtons()
                    : getTab(context)),
              )
            : const SizedBox(height: 10),
      );
    });
  }

  Widget _buildCheckBoxButtons() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _coloredButton("Selected (${redioButton.length})", AppColors.primaryColor),
          InkWell(
            onTap: () {
              showCheckBox.value = false;
              redioButton.clear();
              redioButtonIndex.clear();
              balanceOutList.clear();
              addManually.clear();
              HapticFeedback.selectionClick();
            },
            child: _coloredButton(
              "Cancel",
              AppColors.primaryColor,
              bg: AppColors.backgroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _coloredButton(String text, Color color, {Color? bg}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: MediaQuery.of(context).size.width / 2.5,
      height: MediaQuery.of(context).size.height / 26,
      decoration: BoxDecoration(
        color: bg ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: textStyleImage(
          context: context,
          text: text,
          c: color,
          fontsize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTagHideButtons() {
    return Obx(() => (redioButton.isNotEmpty &&
            allOrGroupTransactionsName.value ==
                StringConstant.allTransactions)
        ? Padding(
            padding: const EdgeInsets.only(left: 10, right: 2, top: 8),
            child: getTagHideButtons(context),
          )
        : const SizedBox.shrink());
  }

  Widget _buildFilterSection() {
    return Obx(() => showFilter.value
        ? filterTransaction(context)
        : const SizedBox.shrink());
  }
}
