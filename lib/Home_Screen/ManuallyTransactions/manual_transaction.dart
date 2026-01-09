

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/friends_bill_split.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/manual_transaction_repository.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/image_service/profile.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../Constants/core/app_shadows.dart';
import '../../components/shared_utils.dart';
import '../../routes/index_route.dart';
import 'custom_keyboard.dart';

bool isDebit = true;
bool showKeyboard = true;

class ModalContent extends StatefulWidget {
  final bool isDebit;
  const ModalContent(this.isDebit, {Key? key}) : super(key: key);

  @override
  _ModalContentState createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent>
   with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<ModalContent>{
  String? selectedCategory;
  String? selectedSubCategory;
  final TextEditingController _amountController = TextEditingController();
  double? amount;
  String? fin;
  final TextEditingController categoryFieldController = TextEditingController();
  bool isCategoryFieldExpanded = false;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredCategories = [];
  late ConfettiController _confettiController;
  late AnimationController _iconAnimationController;
 
  String? selectedCategory2;
  String? selectedSubCategory2;
  bool _isAmountFieldFocused = true;
  final FocusNode _amountFocusNode = FocusNode();
  late IO.Socket socket;
  

  // scroll control and key to compute offset
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _categoryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getAllTransaction(context);

    // initial filtered categories based on tab (cash-in or cash-out)
    _populateInitialFilteredCategories();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    socket = IO.io(API.urlWithLocallHost,
        IO.OptionBuilder().setTransports(['websocket']).build());
    setUpSocketListener();
  }

  void _populateInitialFilteredCategories() {
    // If cash-in (widget.isDebit == false): show only Income category & its subs
    // If cash-out (widget.isDebit == true): show all categories excluding Income, include custom categories
    filteredCategories = [];
    if (!widget.isDebit) {
      // cash-in: only Income category and its subcategories (if exists)
      if (categories.containsKey('Income')) {
        final subs = categories['Income']!;
        // show as the category entry (isCategory true), and also list subcategories as separate entries if desired
        filteredCategories.add({
          'category': 'Income',
          'subcategories': subs,
          'isCategory': true,
        });
        // also add each subcategory as an explicit sub-entry (keeps search working)
        for (var sub in subs) {
          filteredCategories.add({
            'category': 'Income',
            'subcategory': sub,
            'isCategory': false,
          });
        }
      } else {
        // fallback: if no explicit 'Income' present, show nothing
        filteredCategories = [];
      }
    } else {
      // cash-out: show all categories except 'Income'
      filteredCategories = categories.entries
          .where((e) => e.key.toLowerCase() != 'income')
          .map((entry) => {
                'category': entry.key,
                'subcategories': entry.value,
                'isCategory': true,
              })
          .toList();

      // include custom categories (if any) for cash-out
      for (var custom in customCategoryList) {
        filteredCategories.add({
          'category': custom['name'],
          'subcategory': '',
          'isCategory': true,
          'isCustom': true,
          'imageUrl': custom['imageUrl'],
        });
      }
    }
  }

  // Add transaction
  setUpSocketListener() {
    socket.on("disconnect", (data) => {socket.close()});
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _scrollController.dispose();
    _confettiController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  // helper: whether to include a category (used during search)
  bool _shouldIncludeCategory(String categoryName) {
    // cash-in -> only include 'Income'
    if (!widget.isDebit) {
      return categoryName.toLowerCase() == 'income';
    }
    // cash-out -> exclude 'Income'
    return categoryName.toLowerCase() != 'income';
  }

  void filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        // repopulate initial filter list based on tab
        _populateInitialFilteredCategories();
      } else {
        filteredCategories = [];
        categories.forEach((category, subcategories) {
          // respect include/exclude rule
          if (!_shouldIncludeCategory(category)) {
            return; // skip this entire category
          }

          // Check if category matches the query
          if (category.toLowerCase().contains(query.toLowerCase())) {
            filteredCategories.add({
              'category': category,
              'subcategories': subcategories,
              'isCategory': true,
            });
          }

          // Check if any subcategory matches the query
          for (var subcategory in subcategories) {
            if (subcategory.toLowerCase().contains(query.toLowerCase())) {
              filteredCategories.add({
                'category': category,
                'subcategory': subcategory,
                'isCategory': false,
              });
            }
          }
        });

        // For cash-out only, include custom categories that match search
        if (widget.isDebit) {
          for (var customCategory in customCategoryList) {
            final name = (customCategory['name'] ?? '').toString();
            if (name.toLowerCase().contains(query.toLowerCase())) {
              filteredCategories.add({
                'category': name,
                'subcategory': '',
                'isCategory': true,
                'isCustom': true,
                'imageUrl': customCategory['imageUrl'],
              });
            }
          }
        }
      }
    });
  }

  void resetToInitialScreen() {
    setState(() {
      selectedCategory = null;
      selectedSubCategory = null;
      isCategoryFieldExpanded = false;
      _isAmountFieldFocused = false;

      _populateInitialFilteredCategories();
    });
  }
void _onKeyTap(String value) {
  final text = _amountController.text;

  // Allow digits
  if (RegExp(r'^\d$').hasMatch(value)) {
    _append(value);
    return;
  }

  // Allow only ONE decimal point
  if (value == '.') {
    if (!text.contains('.')) {
      _append(value);
    }
    return;
  }

  

}

void _append(String value) {
  setState(() {
    _amountController.text += value;
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length),
    );
  });
}


void _onBackspace() {
  if (_amountController.text.isEmpty) return;

  setState(() {
    _amountController.text = _amountController.text
        .substring(0, _amountController.text.length - 1);
  });
}

  // Helper to scroll the category widget to the top of the visible scroll area (with padding)
  Future<void> _scrollCategoryToTop({double topPadding = 6.0}) async {
    try {
      if (_categoryKey.currentContext == null) return;

      final RenderBox categoryBox =
          _categoryKey.currentContext!.findRenderObject() as RenderBox;
      final Offset categoryGlobal = categoryBox.localToGlobal(Offset.zero);

      final RenderBox scrollBox =
          _scrollController.position.context.storageContext.findRenderObject()
              as RenderBox;
      final Offset scrollGlobal = scrollBox.localToGlobal(Offset.zero);

      final double dy = categoryGlobal.dy - scrollGlobal.dy;

      double target = _scrollController.offset + dy - topPadding;

      final double min = _scrollController.position.minScrollExtent;
      final double max = _scrollController.position.maxScrollExtent;
      if (target < min) target = min;
      if (target > max) target = max;

      await _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      if (_categoryKey.currentContext != null) {
        await Scrollable.ensureVisible(
          _categoryKey.currentContext!,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    }
  }

  // Wait until keyboard opens (viewInsets.bottom > 0) or timeout, then scroll category to top.
  Future<void> _waitForKeyboardThenScroll({double topPadding = 6.0}) async {
    if (_categoryKey.currentContext == null) return;

    const int maxTries = 10;
    const Duration step = Duration(milliseconds: 40);
    int tries = 0;

    while (tries < maxTries) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      if (bottomInset > 0) break; // keyboard visible
      tries++;
      await Future.delayed(step);
    }

    await Future.delayed(const Duration(milliseconds: 8));
    await _scrollCategoryToTop(topPadding: topPadding);
  }

  // UPDATED toggleCategoryField to scroll the category into view when expanded or when keyboard present
  void toggleCategoryField() {
    setState(() {
      isCategoryFieldExpanded = !isCategoryFieldExpanded;
      _isAmountFieldFocused = false;
      // when opening, ensure the filtered list is correct for tab
      if (isCategoryFieldExpanded) {
        _populateInitialFilteredCategories();
      }
    });

    // schedule scroll after frame so layout is updated
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      if (bottomInset > 0) {
        await _scrollCategoryToTop(topPadding: 6.0);
        return;
      }
      await _waitForKeyboardThenScroll(topPadding: 6.0);
    });
  }

  

  

  void _submitAmount() {
    final value = _amountController.text.trim();

    if (value.isEmpty || value.contains(".") || value.contains("-")) {
    snackBarCalledfail(context, "Enter a valid amount");
    return;
  }

    setState(() {
      amount = double.tryParse(value);

      if (!isDebit) {
        selectedCategory = "Income";
        categoryFieldController.text = "Income";
      }

      fin = '$selectedCategory ($selectedSubCategory)';
      _isAmountFieldFocused = false;
    });

    FocusScope.of(context).unfocus();
  }

   @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Important: call super.build when using AutomaticKeepAliveClientMixin
    super.build(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                color: AppColors.border,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: 
                   showKeyboard? 
                   GestureDetector(
                     behavior: HitTestBehavior.opaque,
  onTap: showKeyboard
      ? () {
          setState(() => showKeyboard = false);
        }
      : null,
                     child: Column(
                      //  mainAxisSize: MainAxisSize.min,
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         if ((selectedCategory == null &&
                                 selectedSubCategory == null) ||
                             !widget.isDebit) ...[
                               GestureDetector(
                              behavior: HitTestBehavior.translucent,
                                                      onTap: () {
                                                        setState(() => showKeyboard = true);
                                                      },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: AmountWidget(),
                              )),
                                                      
                                                          const SizedBox(height: 16),
                           (showKeyboard)?
                                                       GestureDetector(
                                                                               behavior: HitTestBehavior.translucent,
                                                                               onTap: () {
                                                                                 setState(() => showKeyboard = false);
                                                                               },
                                                                               child: CustomNumericKeyboard(
                                                   onKeyTap: _onKeyTap,
                                                   onBackspace: _onBackspace,
                                                   onSubmit: () {
                                                     _submitAmount();
                                                     setState(() => showKeyboard = false);
                                                   },
                                                   onDismiss: () {
                                                     setState(() => showKeyboard = false);
                                                   },
                                                                               ),
                                                       ):const SizedBox.shrink(),
                          
                         ],
                        
                        
                         ],
                      
                       
                     ),
                   ):
                
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((selectedCategory == null &&
                                selectedSubCategory == null) ||
                            !widget.isDebit) ...[
                          Column(
                                  children: [
                                    // ✅ Amount widget NOT wrapped
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  setState(() => showKeyboard = true);
                                },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: AmountWidget(),
                                      )),
                                
                                    const SizedBox(height: 16),
                                
                                    // ✅ Outside tap dismiss only when keyboard open
                                    if (showKeyboard)
                                      GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  setState(() => showKeyboard = false);
                                },
                                child: Column(
                                  children: [
                                    CustomNumericKeyboard(
                                      onKeyTap: _onKeyTap,
                                      onBackspace: _onBackspace,
                                      onSubmit: () {
                                        _submitAmount();
                                        setState(() => showKeyboard = false);
                                      },
                                      onDismiss: () {
                                        setState(() => showKeyboard = false);
                                      },
                                    ),
                                  ],
                                ),
                                      ),
                                  ],
                                ),
                          const SizedBox(height: 16),
                        ],
                        if (amount != null) ...[
                          Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: categoryWidget(),
                          ),
                        ],
                         const SizedBox(height: 6),
                       
                        if (isCategoryFieldExpanded) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: categoryExpandedWidget(),
                        ),
                        // getListOfCustomCategory(),
                      ],
                        if (selectedCategory != null &&
                            selectedSubCategory == null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: subcategoryWidget(),
                          ),
                        ],
                        if (fin != null) ...[
                          Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: widget.isDebit ? SplitLendButton() : const SizedBox.shrink(),
                          ),
                          continueButton(),
                        ],
                     
                      ],
                    ),
                  ),
                
                ),
              ),
            ),
    );
  }

 
  Widget AmountWidget() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
        AppShadows.soft
        ],
        border: AppBorders.soft
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isDebit ? 'Add Cash Out' : "Add Cash in",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.accentColor,
            ),
          ),
          const SizedBox(height: 8),

          AppDividers.soft,

          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      AppBorders.soft
                ),
                child: Center(
                  child: AvatarProfileImage(
                    url: HomePageIcons.addAmount,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IgnorePointer(
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                   onTap: () {
                    setState(() {
                       showKeyboard = true;
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextField(
                      controller: _amountController,
                      // keyboardType: TextInputType.number,
                      readOnly: true, // 👈 IMPORTANT
                  showCursor: true,
                  
                  

                  
                      textInputAction: TextInputAction.done,
                      autofocus: _isAmountFieldFocused,
                      inputFormatters: allowDecimalInput(),
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 16,
                        color: AppColors.accentColor,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        hintText: HomepageStringsDart().enterAmount,
                        hintStyle: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.normal,
                          fontSize: 16,
                          color: AppColors.accentColor.withOpacity(0.45),
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          amount = double.tryParse(value);
                          if (!widget.isDebit) {
                            selectedCategory = "Income";
                            categoryFieldController.text = "Income";
                          }
                          fin = null;
                          _isAmountFieldFocused = false;
                        });
                      },
                      onEditingComplete: () {
                        fin = '$selectedCategory ($selectedSubCategory)';
                        FocusScope.of(context).unfocus();
                      },
                      onSubmitted: (value) {
                        _submitAmount();
                      },
                    ),
                  ),
                ),
              ),
            
            ],
          ),
        ],
      ),
    );
  }

  // Category input (card-style like AmountWidget)
  Widget categoryWidget() {
    return Container(
      key: _categoryKey,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
         AppShadows.soft
        ],
        border: AppBorders.soft
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HomepageStringsDart().selectCategory ,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          AppDividers.soft,

          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.048,
                width: MediaQuery.of(context).size.height * 0.048,
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(10),
                  border: AppBorders.soft
                ),
                child: const Center(child: Icon(Icons.search, color: AppColors.accentColor)),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextField(
                  controller: categoryFieldController,
                  readOnly: !widget.isDebit,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.normal,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: HomepageStringsDart().selectCategory,
                    hintStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.normal,
                      fontSize: 16,
                      color: AppColors.accentColor.withOpacity(0.45),
                    ),
                    border: InputBorder.none,
                  ),
                  onTap: () {
                    if (!isCategoryFieldExpanded) {
                      if (widget.isDebit) {
                        toggleCategoryField();
                      } else {
                        setState(() {
                          selectedCategory = "Income";
                          selectedSubCategory = null;
                          categoryFieldController.text = "Income";
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
                          if (bottomInset > 0) {
                            await _scrollCategoryToTop(topPadding: 6.0);
                          } else {
                            await _waitForKeyboardThenScroll(topPadding: 6.0);
                          }
                        });
                      }
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
                        if (bottomInset > 0) {
                          await _scrollCategoryToTop(topPadding: 6.0);
                        } else {
                          await _waitForKeyboardThenScroll(topPadding: 6.0);
                        }
                      });
                    }
                  },
                  onChanged: (value) => filterCategories(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Expanded category list but inside a card-like container to match AmountWidget look
  Widget categoryExpandedWidget() {
    return Container(
      // no top margin so expanded list sits flush under category card
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          AppShadows.soft
        ],
        border:  AppBorders.soft,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: filteredCategories.isEmpty
          ? Center(
              child: Text(
                'No categories found',
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.normal,
                  fontSize: 14,
                  color: AppColors.accentColor.withOpacity(0.6),
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              // physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredCategories.length,
              itemBuilder: (BuildContext context, int index) {
                final item = filteredCategories[index];
                final isCategory = item['isCategory'] as bool;
                final category = (item['category'] ?? '') as String;
                final isCustom = item['isCustom'] ?? false;
                String urlPath = "";

                if (isCustom) {
                  urlPath = item['imageUrl'] ?? '';
                } else if (isCategory) {
                  try {
                    urlPath =
                        Categories.link + BudgetCategories.listofCategories[category]!;
                  } catch (e) {
                    urlPath = '';
                  }
                } else {
                  urlPath = BudgetSubCategories.listofSubCategories[item['subcategory']] ??
                      "assets/icons/subCategoryIcons/default.svg";
                }

                return ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  minVerticalPadding: 0,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  leading: SizedBox(
                    height: 36,
                    width: 36,
                    child: AvatarProfileImage(
                      url: urlPath,
                      width: 4,
                      height: 4,
                    ),
                  ),
                  title: Text(
                    isCategory ? category : '${item['subcategory']} ($category)',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.bg3,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (isCategory) {
                        if (isCustom) {
                          selectedCategory = category;
                          selectedSubCategory = "";
                          selectedCategory2 = selectedCategory;
                          selectedSubCategory2 = selectedSubCategory;
                          isCategoryFieldExpanded = false;
                          categoryFieldController.text = category;
                          fin = '$selectedCategory (None)';
                          _isAmountFieldFocused = false;
                          FocusScope.of(context).unfocus();
                          resetToInitialScreen();
                        } else {
                          selectedCategory = category;
                          selectedSubCategory = null;
                          selectedCategory2 = selectedCategory;
                          selectedSubCategory2 = selectedSubCategory;
                          categoryFieldController.text = category;
                          isCategoryFieldExpanded = false;
                          _isAmountFieldFocused = false;
                          FocusScope.of(context).unfocus();
                        }
                      } else {
                        selectedCategory = item['category'];
                        selectedSubCategory = item['subcategory'];
                        selectedCategory2 = selectedCategory;
                        selectedSubCategory2 = selectedSubCategory;
                        categoryFieldController.text =
                            '$selectedCategory ($selectedSubCategory)';
                        isCategoryFieldExpanded = false;
                        fin = '$selectedCategory ($selectedSubCategory)';
                        _isAmountFieldFocused = false;
                        FocusScope.of(context).unfocus();
                        resetToInitialScreen();
                      }
                    });
                  },
                );
              },
            ),
    );
  }

  Widget getListOfCustomCategory() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border:  AppBorders.soft
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: customCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          final category = customCategoryList[index];
          final categoryName = category['name'] ?? '';
          final imageUrl = category['imageUrl'] ?? '';

          return ListTile(
            leading: SizedBox(
              height: 40,
              width: 40,
              child: AvatarProfileImage(
                url: imageUrl,
                width: 4,
                height: 4,
              ),
            ),
            title: Text(
              categoryName,
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.normal,
                fontSize: 16,
                color: AppColors.accentColor,
              ),
            ),
            onTap: () {
              setState(() {
                selectedCategory = categoryName;
                categoryFieldController.text = categoryName;
                isCategoryFieldExpanded = false;
                _isAmountFieldFocused = false;
                FocusScope.of(context).unfocus();
              });
            },
          );
        },
      ),
    );
  }

  Widget subcategoryWidget() {
    if (selectedCategory == null || !categories.containsKey(selectedCategory)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          AppShadows.soft
        ],
        border:  AppBorders.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Subcategory",
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          AppDividers.soft,
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: categories[selectedCategory]!.map((subCategory) {
              final urlPath = BudgetSubCategories.listofSubCategories[subCategory] ??
                  "assets/icons/subCategoryIcons/default.svg";

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSubCategory = subCategory;
                    selectedSubCategory2 = subCategory;

                    categoryFieldController.text =
                        '$selectedCategory ($selectedSubCategory)';
                    fin = '$selectedCategory ($selectedSubCategory)';
                    selectedCategory2 = selectedCategory;

                    _isAmountFieldFocused = false;
                    FocusScope.of(context).unfocus();
                    resetToInitialScreen();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border:  AppBorders.soft
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileImage(url: urlPath),
                      const SizedBox(width: 8),
                      Text(
                        toUpperCase(subCategory),
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.normal,
                          fontSize: 14,
                          color: AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget SplitLendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            Navigator.pop(context);
            FocusScope.of(context).unfocus();
            if (isLend.value) {
              addedUser.clear();
              addedMembers.clear();
            }
            isSplit.value = true;
            isLend.value = false;

            final result = await showCustomFriendsModal(context, amount ?? 0.0, false);

            setState(() {
              _isAmountFieldFocused = false;
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2.4,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.button,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                HomepageStringsDart().billSplit,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
            if (isSplit.value) {
              addedUser.clear();
              addedMembers.clear();
            }
            isSplit.value = false;
            isLend.value = true;

            await showCustomFriendsModal(context, amount ?? 0.0, true);
            addLendUserAmount(
              context,
              amount.toString(),
              addedMembers,
              selectedCategory2.toString(),
              selectedSubCategory2.toString(),
            );
            Navigator.pop(context);
            setState(() {
              _isAmountFieldFocused = false;
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2.4,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.button,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                HomepageStringsDart().lendMoney,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget continueButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                if (cashInAndOut.value) return;
                cashInAndOut.value = true;

                addTransaction(
                  amount.toString(),
                  selectedSubCategory2.toString(),
                  selectedCategory2.toString(),
                  context,
                  "cash",
                );
              },
              child: Obx(() => cashInAndOut.value
                  ? getspinner(context)
                  : getButton(context, HomepageStringsDart().addButton)),
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> showCustomFriendsModal(
    BuildContext context,
    double totalAmount,
    bool isLendMode,
  ) async {
    return await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: NewFriendsUi(
            totalAmount: totalAmount,
            userId: userController.userId.value,
            userName: userController.userName.value,
            userAvatar: userController.avatar.value,
            isLendMode: isLendMode,
            category: selectedCategory2,
            subcategory: selectedSubCategory2,
          ),
        );
      },
    );
  }
}
