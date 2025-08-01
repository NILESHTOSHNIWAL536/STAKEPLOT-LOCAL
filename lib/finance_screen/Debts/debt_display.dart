import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart'; // Ensure DebtService is imported
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_service.dart';
class DebtDetailsScreen extends StatefulWidget {
  final Debt debt;

  DebtDetailsScreen({required this.debt});

  @override
  _DebtDetailsScreenState createState() => _DebtDetailsScreenState();
}

class _DebtDetailsScreenState extends State<DebtDetailsScreen> {
  bool _isDeleting = false;

   Future<void> deleteDebt() async {
    setState(() {
      _isDeleting = true;
    });

    if (widget.debt.id.isEmpty) {
     
      setState(() {
        _isDeleting = false;
      });
      return;
    }

    final bool success = await DebtService.deleteDebt(widget.debt.id);
     
    if (success) {
      await Future.delayed(Duration(seconds: 2));
       fetchDebts();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
     
    }

    if (mounted) {
      setState(() {
        _isDeleting = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    double labelWidth = 100; // Set a fixed width for labels

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(widget.debt.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: _isDeleting
                ? CircularProgressIndicator(color: Colors.red, strokeWidth: 2)
                : Icon(Icons.delete, color: Colors.red),
            onPressed: _isDeleting
                ? null
                : () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(PlotFinanceStaticData().deleteDebtTitle), // Updated
                        content: Text(PlotFinanceStaticData().deleteDebtPrompt),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(PlotFinanceStaticData().cancelButton),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                           child: Text(
                              PlotFinanceStaticData().deleteButton, // Updated
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      await deleteDebt(); // Pass parent context
                    }
                  },
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.sizeOf(context).width / 1.1,
              decoration: BoxDecoration(
                color: AppColors.mt,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AvatarProfileImage(
                              url: HomePageIcons.manualTransaction,
                              height: 28,
                              width: 28,
                            ),
                            textStyle(
                              context: context,
                              text: " ${widget.debt.name} ",
                              fontsize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                         children: [
                          rowItem(PlotFinanceStaticData().loanTypeLabel, widget.debt.type, labelWidth, context), // Updated
                          SizedBox(height: Colorcodes.paddingSize / 3),
                          rowItem(PlotFinanceStaticData().amountLabel, "₹${widget.debt.amount.toStringAsFixed(2)}", labelWidth, context), // Updated
                          SizedBox(height: Colorcodes.paddingSize / 3),
                          rowItem(PlotFinanceStaticData().interestLabel, "${widget.debt.interest.toString()}", labelWidth, context), // Updated
                          SizedBox(height: Colorcodes.paddingSize / 3),
                          rowItem(PlotFinanceStaticData().durationLabel, "${widget.debt.durationMonths.toString()} months", labelWidth, context), // Updated
                          SizedBox(height: Colorcodes.paddingSize / 3),
                          rowItem(PlotFinanceStaticData().dateLabel, formattedDate(widget.debt.date.toString()), labelWidth, context), // Updated
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rowItem(String label, String value, double labelWidth, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: textStyle(
            context: context,
            text: label,
            fontsize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: textStyle(
            context: context,
            text: value,
            fontsize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String formattedDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  return DateFormat("d MMM yyyy").format(parsedDate);
}