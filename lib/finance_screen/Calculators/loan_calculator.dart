import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';

import 'dart:convert';
import '../../backed_connections/apiAutomations/curd.dart';

// Your FontManager class (assumed imported)

// Sanitize string inputs
String displayString(dynamic str) =>
    (str ?? '').toString().replaceAll(RegExp(r'<.*?>'), '');

class LoanCalculatorScreen extends StatefulWidget {
  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _emiController = TextEditingController();

  String _selectedCreditScore = '650-700';
  String _loanType = 'Car';
  List<String> creditScores = ['<600', '600-650', '650-700', '700-750', '750+'];
  List<String> loanTypes = ['Personal', 'Car', 'Home'];

  Map<String, dynamic> expenses = {};
  int income = 0;
  String apiUrl = url; // Your API domain
  Map<String, dynamic>? loanCalcResponse;
  bool _isInfoVisible = false; // Controls visibility of the container
  double _opacity = 0.0; // Controls the fade effect
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInfoVisible = true;
          _opacity = 1.0; // Fade in
        });
        // Start timer to fade out after 5 seconds
        _timer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _opacity = 0.0; // Fade out
            });
          }
        });
      }
    });
    // _incomeController.clear();
    // _emiController.clear();
    // fetchIncomeAndExpenses();
  }

  Future<void> fetchIncomeAndExpenses() async {
    try {
      final response = await getDataApiCall(BankTransactionRoutes.getIncomeAndCategorySpent);
      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body)["data"];

        setState(() {
          income = (data['income'] is String)
              ? int.tryParse(data['income']) ?? 0
              : (data['income'] as num?)?.toInt() ?? 0;
          expenses = Map<String, dynamic>.from(
              data['averageCategorySpendingOfTwoMonths'] ?? {});
          _incomeController.text = income.toString();
        });
      }
    } catch (err) {
      // handle error here
    }
  }

  int mapCreditScore(String val) {
    switch (val) {
      case '<600':
        return 500;
      case '600-650':
        return 625;
      case '650-700':
        return 675;
      case '700-750':
        return 725;
      case '750+':
        return 800;
      default:
        return 650;
    }
  }

  Future<void> calculateLoan() async {
    // int creditScore = mapCreditScore(_selectedCreditScore);
    final jsonData = {
      "income": int.tryParse(_incomeController.text) ?? income,
      "existingEmi": int.tryParse(_emiController.text) ?? 0,
      "loanType": _loanType.toLowerCase(),
      "creditScore": _selectedCreditScore,
      "expenses": expenses,
    };
    try {
      final response = await postDataApiCall(
       BankTransactionRoutes.getLoanCalculation, jsonData);
      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body)['data'];

        setState(() {
          loanCalcResponse = data;
        });
      }
    } catch (err) {
      // handle error here
    }
  }

  num safeNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  // Customized White Border for InputDecoration
  InputDecoration inputDecoration(String? hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: FontManager().getTextStyle(context,
          color: Colors.white70, fontSize: 14, lWeight: FontWeight.w400),
      fillColor: const Color.fromARGB(59, 255, 255, 255),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70, width: 1)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Scrollbar(
            // thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isInfoVisible = true;
                        _opacity = 1.0; // Fade in
                      });
                      _timer?.cancel();

                      _timer = Timer(Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _opacity = 0.0; // Fade out
                          });
                        }
                      });
                    },
                    child: Text(
                      "Loan Affordability ",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w800,
                        fontSize: 40,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  AnimatedOpacity(
                    opacity: _opacity,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    onEnd: () {
                      // Hide container after fade-out completes
                      if (_opacity == 0.0 && mounted) {
                        setState(() {
                          _isInfoVisible = false;
                         
                        });
                      }
                    },
                    child: _isInfoVisible
                        ? Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                "This calculator helps you determine how much loan you can afford based on your income, existing EMIs, and credit score. Understand your borrowing capacity and plan your finances effectively.",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: AppColors.backgroundColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),

                  //  const SizedBox(height: 10),
                  Text('Income (Per month)',
                      style: FontManager().getTextStyle(context,
                          color: AppColors.accentColor, fontSize: 15.3)),
                  SizedBox(height: height * 0.02),
                  TextField(
                      controller: _incomeController,
                      keyboardType: TextInputType.number,
                      style: FontManager().getTextStyle(context,
                          color: AppColors.accentColor,
                          fontSize: 15,
                          lWeight: FontWeight.w500),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        hintText: '₹ 3000.00',
                        hintStyle: TextStyle(
                          color: AppColors.greyCard,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.greyCard,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors
                                .primaryColor, // Change color on focus if you like
                            width: 1,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                      )),

                  SizedBox(height: height * 0.026),
                  Text('Existing Emi',
                      style: FontManager().getTextStyle(context,
                          color: AppColors.accentColor, fontSize: 15.3)),
                  SizedBox(height: height * 0.02),
                  TextField(
                      controller: _emiController,
                      keyboardType: TextInputType.number,
                      style: FontManager().getTextStyle(context,
                          color: AppColors.accentColor,
                          fontSize: 15,
                          lWeight: FontWeight.w500),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        hintText: '₹ 1000.00',
                        hintStyle: TextStyle(
                          color: AppColors.greyCard,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.greyCard,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors
                                .primaryColor, // Change color on focus if you like
                            width: 1,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                      )),

                  SizedBox(height: height * 0.026),
                  Text('Credit score',
                      style: FontManager().getTextStyle(context,
                          color: AppColors.accentColor, fontSize: 15.3)),
                  SizedBox(height: height * 0.02),
                  Container(
                    height: height * 0.06,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.greyCard,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.05),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCreditScore,
                        dropdownColor: const Color(0xFF656399),
                        icon:
                            const Icon(Icons.expand_more, color: Colors.white),
                        style: FontManager().getTextStyle(context,
                            color: Colors.white, fontSize: 15.2),
                        onChanged: (String? newVal) {
                          setState(() {
                            if (newVal != null) _selectedCreditScore = newVal;
                          });
                        },
                        items: creditScores
                            .map<DropdownMenuItem<String>>(
                                (score) => DropdownMenuItem<String>(
                                      value: score,
                                      child: Text(score,
                                          style: FontManager().getTextStyle(
                                              context,
                                              color: AppColors.accentColor,
                                              fontSize: 14)),
                                    ))
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.026),
                  Text('Loan type',
                      style: FontManager().getTextStyle(context,
                          color: AppColors.accentColor, fontSize: 15.3)),
                  SizedBox(height: height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: loanTypes.map((type) {
                      final isSelected = _loanType == type;
                      return Expanded(
                          child: Container(
                        margin: EdgeInsets.symmetric(horizontal: width * 0.013),
                        height: height * 0.055,
                        decoration: BoxDecoration(
                          color: !isSelected
                              ? Colors.white
                              : AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xFFF3F4F6),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _loanType = type;
                            });
                          },
                          child: Text(
                            type,
                            style: FontManager().getTextStyle(context,
                                color: !isSelected
                                    ? const Color(0xFF656399)
                                    : Colors.white,
                                lWeight: FontWeight.w700,
                                fontSize: 15.4),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.center,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ));
                    }).toList(),
                  ),
                  SizedBox(height: height * 0.02),
                  Center(
                    child: SizedBox(
                      width: width * 0.37,
                      height: height * 0.052,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_incomeController.text.trim().isEmpty) {
                            snackBarCalledfail(
                                context, "Please enter your income");

                            return;
                          }
                          if (_emiController.text.trim().isEmpty) {
                            snackBarCalledfail(
                                context, "Please enter your existing EMI");

                            return;
                          }
                          if (_selectedCreditScore.isEmpty) {
                            snackBarCalledfail(
                                context, "Please select a credit score");

                            return;
                          }
                          if (_loanType.isEmpty) {
                            snackBarCalledfail(
                                context, "Please select a loan type");

                            return;
                          }

                          calculateLoan();
                        },

                        // onPressed: calculateLoan,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: FontManager().getTextStyle(
                            context,
                            color: AppColors.backgroundColor,
                            lWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        child: const Text('Calculate'),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  if (loanCalcResponse != null) ...[
                    Text('Suggested Timeline',
                        style: FontManager().getTextStyle(context,
                            color: AppColors.primaryColor,
                            lWeight: FontWeight.w600,
                            fontSize: 16)),
                    SizedBox(height: height * 0.015),
                    ...((loanCalcResponse?['suggestedTimeline'] ?? [])
                            as List<dynamic>)
                        .map(
                      (timeline) => Padding(
                        padding: EdgeInsets.only(bottom: height * 0.016),
                        child: suggestionBox(displayString(timeline), context),
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Row(
                      children: [
                        Expanded(
                            child: infoBox(
                                'Safe EMI Range',
                                displayString(
                                    loanCalcResponse?['safeEmiRange']),
                                context)),
                        SizedBox(width: width * 0.025),
                        safeNum(loanCalcResponse?['maxSuggestedLoanAmount']) > 0
                            ? Expanded(
                                child: infoBox(
                                    'Max Loan Amount',
                                    displayString(loanCalcResponse?[
                                        'maxSuggestedLoanAmount']),
                                    context))
                            : SizedBox.shrink(),
                      ],
                    ),
                    SizedBox(height: height * 0.011),
                    Row(
                      children: [
                        Expanded(
                            child: infoBox(
                                'Expected EMI',
                                displayString(loanCalcResponse?['expectedEmi']),
                                context)),
                        SizedBox(width: width * 0.025),
                        Expanded(
                            child: infoBox(
                                'Interest Bracket',
                                displayString(
                                    loanCalcResponse?['interestBracket']),
                                context)),
                      ],
                    ),
                    SizedBox(height: height * 0.03),
                    ...List.generate(
                      (loanCalcResponse?['bonusInsights'] ?? []).length,
                      (idx) => Padding(
                        padding:
                            EdgeInsets.only(bottom: height * 0.015, left: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 3, right: 10),
                              child: Icon(
                                Icons.radio_button_checked,
                                color: AppColors.accentColor,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                displayString(
                                    loanCalcResponse?['bonusInsights'][idx]),
                                style: FontManager().getTextStyle(
                                  context,
                                  color: AppColors.accentColor,
                                  lWeight: FontWeight.w400,
                                  fontSize: 14,
                                  lineHeight: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget suggestionBox(String text, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(59, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.greyCard,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: FontManager().getTextStyle(
          context,
          color: AppColors.accentColor,
          lWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget infoBox(String title, String value, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(59, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.greyCard,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: FontManager().getTextStyle(context,
                color: AppColors.primaryColor,
                fontSize: 12,
                lWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: FontManager().getTextStyle(context,
                color: AppColors.accentColor,
                fontSize: 14.7,
                lWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
