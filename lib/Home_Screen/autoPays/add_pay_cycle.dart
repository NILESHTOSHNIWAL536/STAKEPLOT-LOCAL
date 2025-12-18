import 'package:flutter/material.dart';

import '../history/transactionHistoryScreen.dart';

class AddPaycycleFromTransactionsScreen extends StatelessWidget {
  const AddPaycycleFromTransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
     
      
      child: const TransactionHistoryScreen(
        
        fromAutoPay: true,
      ),
    );
  }
}
