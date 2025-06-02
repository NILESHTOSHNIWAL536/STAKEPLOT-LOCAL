

import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class FinspaceStrings
{

  static final FinspaceStrings _instance = FinspaceStrings._internal();

  // 2. Private constructor
  FinspaceStrings._internal();

  // 3. Factory constructor
  factory FinspaceStrings() => _instance;

   Map<String, List<String>> categories = {
    'Personal Finance': [],
    'Budgeting': [],
    'Debt Management': [],
    'Savings Strategies': [],
    'Investments': [
      'Stocks & Equities',
      'Mutual Funds & SIPs',
      'Cryptocurrency & Blockchain',
      'Real Estate & Property'
    ],
    'Tax Planning & Filing': [],
    'Spending Confessions': [],
    'Behavioural Finance': [],
    'Retirement & Pension Planning': [],
    'Side Hustles & Passive Income': [],
    'Tech Trends in Finance': [],
    'College & Education Funding': [],
    'Scholarships and Stipends': [],
    'Global Market News & Analysis': [],
    'Alternative Investments': [
      'Art',
      'Collectibles',
      'P2P Lending'
    ],
    'Salary Talks': [],
    'Spent Stories': [],
    'Smart Savers': [],
  };


  void fetchConstants() async {
    try {
      final response = await getDataApiCall("${url}/constant/finvu");
      if (getFlagOfResponse(response)) {
        
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};
        categories=data['categories'] ?? categories;
        
      } 
    } catch (e) { 
    }
  }
}