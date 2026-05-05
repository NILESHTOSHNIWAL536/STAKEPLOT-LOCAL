import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_shadows.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
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

import '../../Constants/core/app_component_sizes.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/core/container_border.dart';
import '../../controllers/collections_controller.dart';
import 'collections/collections_list_widget.dart';
import 'recent_transactions.dart';

final TextEditingController tnxSearchController = TextEditingController();
// FocusNode focusNodeSearchFeild = FocusNode();
final RxBool showFilter = false.obs;
final RxString selectedTab = "All".obs;

class TransactionHistoryScreen extends StatefulWidget {
  final bool fromAutoPay;
  final bool isFromCollection;
  const TransactionHistoryScreen(
      {super.key, this.fromAutoPay = false, this.isFromCollection = false});

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

  late FocusNode focusNodeSearchFeild;
  // ---------------------------------------------------------------------------
  // 🔥 NEW: Search animation variables (ONLY ADDITION)
  // ---------------------------------------------------------------------------
  late AnimationController _searchAnimController;
  late Animation<Offset> _searchSlideAnim;

  bool isSearchActive = false;
  late Animation<double> _searchScaleAnim;
  late Animation<double> _searchOpacityAnim;
  bool get isCollectionsTab =>
      selectedTab.value == HomepageStringsDart().collectionscreate;

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320), // smooth & quick
      reverseDuration: const Duration(milliseconds: 220),
    );

    _searchSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.12), // very subtle slide
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _searchAnimController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _searchScaleAnim = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _searchAnimController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _searchOpacityAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _searchAnimController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
    focusNodeSearchFeild = FocusNode();

    focusNodeSearchFeild.addListener(() {
      if (focusNodeSearchFeild.hasFocus) {
        _openSearch();
      }
    });

    currentPage = 1;
    showFilter.value = false;
    accountSelected.value = '';
    // addManually.clear();
    // balanceOutList.clear();
    maxController.text = "";
    minController.text = "";
    startDateController.text = "";
    endDateController.text = "";

    getAllTransactionHistory(context, false, false, isRefreshing: true);

    getDayWiseTransactions(context).then((data) {
      dayWiseTransactions.assignAll(data);
    });

    scrollController.addListener(_onScroll);
    collectionsController.getCollections();
  }

  void _openSearch() {
    if (isSearchActive) return;
    HapticFeedback.selectionClick();
    setState(() => isSearchActive = true);
    _searchAnimController.forward();
  }

  void _closeSearch() {
    FocusScope.of(context).unfocus();
    tnxSearchController.clear();

    _searchAnimController.reverse().then((_) {
      if (mounted) {
        setState(() => isSearchActive = false);
      }
    });

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
    // tnxSearchController.dispose();
    focusNodeSearchFeild.dispose();
    _searchAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors = context.appColors;
    double screenHeight = widget.isFromCollection
        ? MediaQuery.sizeOf(context).height / 1.5
        : MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        isSearchActive = false;
      },
      child: WillPopScope(
        onWillPop: () async {
          clearTransactions(context: context);
          clearStackHome(context);
          return true;
        },
        child: Scaffold(
          backgroundColor: colors.background,
          // appBar: isSearchActive?null: historyAppBar(context, widget.fromAutoPay),
          body: SafeArea(
            child: Container(
              color: colors.background,
              child: widget.isFromCollection
                  ? Column(
                      children: [
                        _buildSearchFieldForCollection(
                            context, widget.isFromCollection),
                        Expanded(child: _buildTransactionBody(context)),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          color: colors.appBarBackground,
                          child: Column(
                            children: [
                              isSearchActive
                                  ? _buildSearchAndTabsSection(context)
                                  : historyHeader(context, widget.fromAutoPay),
                              Obx(() {
                                if (isSearchActive) {
                                  return const SizedBox.shrink();
                                }
                                if (widget.fromAutoPay) {
                                  return const SizedBox.shrink();
                                }

                                if (showFilter.value ||
                                    isDateSummaryView.value) {
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
                            ],
                          ),
                        ),

                        ///used before expanded 21.04.2026
                        // Container(
                        //   color: AppColors.border,
                        //   height: isSearchActive
                        //       ? AppComponentSizes.h1_14
                        //       : isDateSummaryView.value
                        //           ? AppComponentSizes.h1_1
                        //           : AppComponentSizes.h1_23,
                        //   child: Obx(() {
                        //     return selectedTab.value == "All"
                        //         ? _buildTransactionBody(context, screenHeight)
                        //         : buildCollectionsBody(context);
                        //   }),
                        // ),
                        Expanded(
                          child: Container(
                            color: colors.background,
                            child: Obx(() {
                              return selectedTab.value == "All"
                                  ? _buildTransactionBody(context)
                                  : buildCollectionsBody(context);
                            }),
                          ),
                        )
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackArrow() {
    return GestureDetector(onTap: _closeSearch, child: globalbackArrow());
  }

  Widget _buildTabChip(String title) {
    return Obx(() {
      final isSelected = selectedTab.value == title;
      final colors = context.appColors;

      return GestureDetector(
        onTap: () {
          selectedTab.value = title;

          collectionsController.getCollections();
          collectionsController.getPendingInvitations();

          // OPTIONAL: handle logic
          // if (title == "Collections") { ... }
        },
        child: Container(
          // width: MediaQuery.of(context).size.width / 3.8,
          margin: const EdgeInsets.only(left: AppSizes.p8),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p18, vertical: AppSizes.p12),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surface,
            border:
                Border.all(color: isSelected ? colors.primary : colors.border),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [AppShadows.tabs],
          ),
          child: Center(
            child: Text(
              title,
              style: FontManager().getTextStyle(
                context,
                fontSize: 14,
                lWeight: FontWeight.w400,
                color: isSelected ? Colors.white : colors.secondaryText,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget historyHeader(BuildContext context, bool fromAutoPay) {
    final colors = context.appColors;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: AppSizes.p12),
      decoration: BoxDecoration(
        color: colors.appBarBackground,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            Row(
              children: [
                InkWell(
                  onTap: () {
                    clearTransactions(context: context);
                    clearStackHome(context);
                  },
                  child: globalbackArrow(),
                ),

                SizedBox(width: AppSizes.w12),

                // Title
                Obx(() {
                  final calculatedWidth =
                      showFilter.value || isDateSummaryView.value
                          ? MediaQuery.sizeOf(context).width -
                              (fromAutoPay ? 200 : 220)
                          : MediaQuery.sizeOf(context).width -
                              (fromAutoPay ? 200 : 220);

                  return SizedBox(
                    // color:  AppColors.redColor,
                    width: calculatedWidth,
                    child: Center(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          textAlign: TextAlign.center,
                          !fromAutoPay
                              ? HomepageStringsDart().historyTitle
                              : HomepageStringsDart().selectTnx,
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w500,
                            fontSize: 17,
                            color: colors.onBackground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),

            // Download icon (only when not fromAutoPay)
            if (!fromAutoPay)
              Obx(() => _buildHeaderRightAction(context))
            else
              _buildSearchIcon(),
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
        text: HomepageStringsDart().tnxtodayview,
      ),
    );
  }

  Widget _buildSearchAndTabsSection(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.appBarBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: AppSizes.p10,
                right: 0,
                bottom: (isSearchActive ? 16 : 3),
                top: (isSearchActive ? 16 : 0)),
            child: Row(
              children: [
                if (isSearchActive) ...[
                  _buildBackArrow(),
                  SizedBox(width: AppSizes.w12),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: _buildSearchField(context, widget.fromAutoPay),
                  ),
                ] else ...[
                  _buildTabChip(HomepageStringsDart().allTnx),
                  _buildTabChip(HomepageStringsDart().collectionscreate),
                  SizedBox(width: AppSizes.w10),
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
                  SizedBox(width: AppSizes.w8),
                  if (isCollectionsTab) CreateCollectionButtonInRow(context),
                  if (!widget.fromAutoPay &&
                      !isSearchActive &&
                      !isCollectionsTab)
                    _buildToggleDateSummaryBtn(),
                  SizedBox(width: AppSizes.w14),
                  if (!widget.fromAutoPay &&
                      !isSearchActive &&
                      !isCollectionsTab)
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
    final disabled = isCollectionsTab;
    return IconButton(
      icon: CustomStyledContainer(
        radius: 5.0, // <-- Passing a custom radius
        width: 36,
        height: 36,

        child: AvatarProfileImage(
          url: HomePageIcons.historySearch,
          width: 66,
          height: 30,
        ),
      ),
      onPressed: () {
        if (disabled) return;
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
        return FadeTransition(
          opacity: _searchOpacityAnim,
          child: SlideTransition(
            position: _searchSlideAnim,
            child: ScaleTransition(
              scale: _searchScaleAnim,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.1,
                height: MediaQuery.of(context).size.width / 10,
                child: _buildSearchInput(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchInput(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
        boxShadow: [AppShadows.tabs],
      ),
      child: TextField(
        controller: tnxSearchController,
        focusNode: focusNodeSearchFeild,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: HomepageStringsDart().searchTransactions,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _buildClearButton(),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: AppSizes.p6, horizontal: 15),
        ),
        style: TextStyle(color: colors.onBackground),
      ),
    );
  }

// Change the search field for collection screen
  Widget _buildSearchFieldForCollection(
      BuildContext context, bool isFromCollection) {
    final colors = context.appColors;
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.25,
            height: MediaQuery.of(context).size.width / 10,
            child: TextField(
              controller: tnxSearchController,
              focusNode: focusNodeSearchFeild,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: HomepageStringsDart().searchTransactions,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buildClearButton(),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSizes.p6, horizontal: 15),
              ),
              style: TextStyle(color: colors.onBackground),
            ),
          ),
          SizedBox(width: AppSizes.w10),
          Container(
              child: !isFromCollection
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () {},
                      child: CustomStyledContainer(
                        radius: 5.0,
                        height: 36,
                        width: 36,
                        child: Icon(
                          Icons.add,
                          color: colors.primary,
                          size: 24,
                        ),
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
    final colors = context.appColors;
    return tnxSearchController.text.isNotEmpty
        ? IconButton(
            icon: Icon(Icons.clear, color: colors.onBackground),
            onPressed: () {
              tnxSearchController.clear();
              searchTextController.value = '';
              clearTransactions(context: context, f: true);
              searchTextControllerBool.value = !searchTextControllerBool.value;
            },
          )
        : null;
  }

  Widget _buildToggleDateSummaryBtn() {
    final disabled = isCollectionsTab;

    return InkWell(
        onTap: () {
          if (disabled) return;
          isDateSummaryView.value = !isDateSummaryView.value;
        },
        child: Obx(() => CustomStyledContainer(
              radius: 5.0, // <-- Passing a custom radius
              width: 36,
              height: 36,
              child: AvatarProfileImage(
                url: isDateSummaryView.value
                    ? HomePageIcons.dayWiseIcon1
                    : HomePageIcons.dayWiseIcon2,
                width: 66,
                height: 30,
              ),
            )));
  }

  Widget _buildFilterButton() {
    final disabled = isCollectionsTab;
    return InkWell(
        onTap: () {
          if (disabled) return;
          showFilter.value = !showFilter.value;
        },
        child: Obx(
          () => CustomStyledContainer(
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
        ));
  }

  Widget _buildTransactionBody(BuildContext context) {
    return Obx(() {
      return IndexedStack(
        index: isDateSummaryView.value ? 0 : 1,
        children: [
          const CalendarTransactionScreen(),
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

      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Obx(() => showCheckBox.value
            ? _buildCheckBoxButtons()
            : SizedBox(
                height: AppSizes.h10,
              )),
      );
    });
  }

  // Widget _buildTabsOrCheckbox() {
  //   return Obx(() {
  //     if (isDateSummaryView.value) return const SizedBox(height: 10);

  //     final showTabs = groupTransactionList.isNotEmpty || showCheckBox.value;

  //     return Padding(
  //       padding: const EdgeInsets.only(left:AppSizes.p10, right:AppSizes.p2),
  //       child: showTabs
  //           ? Padding(
  //               padding: const EdgeInsets.only(top: 3),
  //               child: Obx(() => showCheckBox.value
  //                   ? _buildCheckBoxButtons()
  //                   : getTab(context)),
  //             )
  //           :  SizedBox(height: AppSizes.h10),
  //     );
  //   });
  // }

  Widget _buildCheckBoxButtons() {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.p10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _coloredButton("Selected (${redioButton.length})", colors.primary),
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
              colors.primary,
              bg: colors.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _coloredButton(String text, Color color, {Color? bg}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.p4),
      width: MediaQuery.of(context).size.width / 2.5,
      height: MediaQuery.of(context).size.height / 26,
      decoration: BoxDecoration(
        color: bg ?? AppColors.transparentColor,
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
            allOrGroupTransactionsName.value == StringConstant.allTransactions)
        ? Padding(
            padding: const EdgeInsets.only(
                left: AppSizes.p10, right: AppSizes.p2, top: AppSizes.p8),
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
