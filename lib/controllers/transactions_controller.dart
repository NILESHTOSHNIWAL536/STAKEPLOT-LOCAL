import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionController extends GetxController {

  // ================================
  // SEARCH
  // ================================

  late final TextEditingController searchController;
  late final FocusNode searchFocus;

  final isSearchActive = false.obs;
  

  // ================================
  // FILTER + TABS
  // ================================

  final showFilter = false.obs;
  final selectedTab = "All".obs;
  final isDateSummaryView = false.obs;

  // ================================
  // LIFECYCLE
  // ================================

  @override
  void onInit() {
    super.onInit();

    searchController = TextEditingController();
    searchFocus = FocusNode();

    /// Automatically activate search UI when focused
    searchFocus.addListener(() {
      isSearchActive.value = searchFocus.hasFocus;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocus.dispose();
    super.onClose();
  }

  // ================================
  // ACTIONS (VERY IMPORTANT)
  // ================================

  void openSearch() {
    isSearchActive.value = true;
    searchFocus.requestFocus();
  }

  void closeSearch() {
    searchController.clear();
    searchFocus.unfocus();
    isSearchActive.value = false;
  }

  void toggleFilter() {
    showFilter.toggle();
  }

  void toggleDateSummary() {
    isDateSummaryView.toggle();
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }
  
}
