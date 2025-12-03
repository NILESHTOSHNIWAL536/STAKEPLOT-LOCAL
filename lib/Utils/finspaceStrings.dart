

import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

import '../routes/route_constant.dart';

class FinspaceStrings
{

  static final FinspaceStrings _instance = FinspaceStrings._internal();

  // 2. Private constructor
  FinspaceStrings._internal();

  // 3. Factory constructor
  factory FinspaceStrings() => _instance;

   Map<String, List<String>> categories = {
    'Personal Finance': [],
    'Debt Management': [],
    'Savings Strategies': [],
    'Tax Planning & Filing': [],
    'Investments': [
      'Stocks & Equities','Cryptocurrency & Blockchain',
      'Mutual Funds & SIPs',
      'Real Estate & Property'
    ],
    'Spending Confessions': [],
    'Behavioural Finance': [],
    'Smart Savers': [],
    'Alternative Investments': ['Art', 'Collectibles', 'P2P Lending'],
    'Budgeting': [],
    'Retirement & Pension Planning': [],
    'Side Hustles & Passive Income': [],
    'Tech Trends in Finance': [],
    'Salary Talks': [],
    'College & Education Funding': [],
    'Spent Stories': [],
    'Scholarships and Stipends': [],
   
    'Global Market News & Analysis': [],
  };

  bool liveIntegration=true;
  
  void fetchConstants() async {
    try {
      final response = await getDataApiCall(ConstantRoutes.finvuCommunity);
      if (getFlagOfResponse(response)) {
        
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};
        categories=data['categories'] ?? categories;
        liveIntegration= data['liveIntegration'] ?? liveIntegration;
        
      } 
    } catch (e) { 
    }
  }
  
}