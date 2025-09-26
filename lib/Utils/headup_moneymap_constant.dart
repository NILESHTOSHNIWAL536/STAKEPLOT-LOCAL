import 'package:flutter/material.dart';
import '../Constants/colors.dart';
import 'homepageStrings.dart.dart';

final List<Map<String, dynamic>> navigationItems =
  [
    {
      'title': HomepageStringsDart().headsUp,
      'icon': Icons.send,
      'color': AppColors.primaryColor,
      'backgroundColor': AppColors.primaryColor,
    },
    {
      'title': HomepageStringsDart().moneyMap,
      'icon': Icons.currency_rupee_rounded,
      'color': AppColors.primaryColor,
      'backgroundColor': AppColors.primaryColor,
    },
  ];


    IconData getIconForInsight(String title, String message) {
    final lowerMessage = message.toLowerCase();
    const keywordIconMap = {
      'saved': Icons.savings,
      'save': Icons.savings,
      'savings': Icons.savings,
      'shopping': Icons.shopping_cart,
      'shop': Icons.shopping_cart,
      'purchase': Icons.shopping_cart,
      'purchases': Icons.shopping_cart,
      'zomato': Icons.restaurant,
      'swiggy': Icons.restaurant,
      'dining': Icons.restaurant,
      'food': Icons.restaurant,
      'chef': Icons.restaurant,
      'travel': Icons.flight,
      'trip': Icons.flight,
      'journey': Icons.flight,
      'subscription': Icons.subscriptions,
      'subscribe': Icons.subscriptions,
      'warning': Icons.warning,
      'overboard': Icons.warning,
      'overspend': Icons.warning,
      'expensive': Icons.currency_rupee_rounded,
      'cost': Icons.currency_rupee_rounded,
      'spent': Icons.currency_rupee_rounded,
      'category': Icons.category,
      'budget': Icons.account_balance_wallet,
      'pocket': Icons.account_balance_wallet,
      'money': Icons.account_balance_wallet,
    };

    for (final entry in keywordIconMap.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }
    return Icons.info;
  }


  
  Color getColorForInsight(int index) {
    const colors = [
      AppColors.autoPay1,
      AppColors.autoPay2,
      AppColors.autoPay3,
      AppColors.autoPay4,
      AppColors.autoPay5,
    ];
    return colors[index % colors.length];
  }