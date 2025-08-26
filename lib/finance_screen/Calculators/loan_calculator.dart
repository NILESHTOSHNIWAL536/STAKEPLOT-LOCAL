import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'dart:convert';
import '../../backed_connections/apiAutomations/curd.dart';

import 'package:google_fonts/google_fonts.dart';

// Your FontManager class (assumed imported)
class FontManager {
  TextStyle getTextStyle(
    BuildContext context, {
    Color color = Colors.black,
    FontWeight lWeight = FontWeight.normal,
    double lineHeight = 1.0,
    double fontSize = 18.0,
  }) {
    return GoogleFonts.urbanist(
      fontSize: fontSize,
      fontWeight: lWeight,
      height: lineHeight,
      color: color,
    );
  }
}

// Sanitize string inputs
String displayString(dynamic str) =>
    (str ?? '').toString().replaceAll(RegExp(r'<.*?>'), '');

class LoanCalculatorScreen extends StatefulWidget {
  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final FontManager fontManager = FontManager();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _emiController = TextEditingController();

  String _selectedCreditScore = '650-700';
  String _loanType = 'Car';
  List<String> creditScores = ['600-650', '650-700', '700-750', '750+'];
  List<String> loanTypes = ['Personal', 'Car', 'Home'];

  Map<String, dynamic> expenses = {};
  int income = 0;
  String apiUrl = url; // Your API domain
  Map<String, dynamic>? loanCalcResponse;

  @override
  void initState() {
    super.initState();
    fetchIncomeAndExpenses();
  }

  Future<void> fetchIncomeAndExpenses() async {
    try {
      final response = await getDataApiCall(
          "$apiUrl/transactionauto/get-income-average-monthly-category-expenses");
      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body)["data"];
        setState(() {
          income = (data['income'] as num?)?.toInt() ?? 0;
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
    int creditScore = mapCreditScore(_selectedCreditScore);
    final jsonData = {
      "income": int.tryParse(_incomeController.text) ?? income,
      "existingEmi": int.tryParse(_emiController.text) ?? 0,
      "loanType": _loanType,
      "creditScore": creditScore,
      "expenses": expenses,
    };
    try {
      final response = await postDataApiCall(
          "$apiUrl/transactionauto/get-loan-calculation", jsonData);
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

  // Customized White Border for InputDecoration
  InputDecoration inputDecoration(String? hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: fontManager.getTextStyle(
          context,
          color: Colors.white70,
          fontSize: 14,
          lWeight: FontWeight.w400),
      fillColor: Colors.white.withOpacity(0.09),
      filled: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
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
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    return Scaffold(
      backgroundColor: const Color(0xffe5e5ef),
      body: Center(
        child: ClipPath(
          clipper: BottomCurveClipper(),
          child: Container(
            width: width * 0.95,
            constraints: BoxConstraints(minHeight: height * 0.75),
            decoration: BoxDecoration(
              color: const Color(0xFF656399),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(38),
                topRight: Radius.circular(38),
                bottomLeft: Radius.elliptical(80, 40),
                bottomRight: Radius.elliptical(80, 40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06, vertical: height * 0.03),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text('Income',
                        style: fontManager.getTextStyle(context,
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 15.3)),
                    SizedBox(height: height * 0.008),
                    TextField(
                      controller: _incomeController,
                      keyboardType: TextInputType.number,
                      style: fontManager.getTextStyle(context,
                          color: Colors.white, fontSize: 15, lWeight: FontWeight.w500),
                      cursorColor: Colors.white,
                      decoration: inputDecoration("₹ 3000.00"),
                    ),
                    SizedBox(height: height * 0.015),
                    Text('Existing Emi',
                        style: fontManager.getTextStyle(context,
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 15.3)),
                    SizedBox(height: height * 0.008),
                    TextField(
                      controller: _emiController,
                      keyboardType: TextInputType.number,
                      style: fontManager.getTextStyle(context,
                          color: Colors.white, fontSize: 15, lWeight: FontWeight.w500),
                      cursorColor: Colors.white,
                      decoration: inputDecoration(""),
                    ),
                    SizedBox(height: height * 0.02),

                    Text('Credit score',
                        style: fontManager.getTextStyle(context,
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 15.3)),
                    SizedBox(height: height * 0.012),
                    Container(
  height: height * 0.06,
  width: MediaQuery.of(context).size.width,
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.09),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white70, width: 1),
  ),
  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: _selectedCreditScore,
      dropdownColor: const Color(0xFF656399),
      icon: const Icon(Icons.expand_more, color: Colors.white),
      style: fontManager.getTextStyle(context,
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
                    child: Text(score, style: TextStyle(color: Colors.white)),
                  ))
          .toList(),
    ),
  ),
),

                    SizedBox(height: height * 0.02),

                    Text('Loan type',
                        style: fontManager.getTextStyle(context,
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 15.3)),
                    SizedBox(height: height * 0.009),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: loanTypes.map((type) {
                        final isSelected = _loanType == type;
                        return Expanded(
                            child: Container(
                          margin: EdgeInsets.symmetric(horizontal: width * 0.013),
                          height: height * 0.055,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.15),
                                width: 1.3),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _loanType = type;
                              });
                            },
                            child: Text(
                              type,
                              style: fontManager.getTextStyle(context,
                                  color:
                                      isSelected ? const Color(0xFF656399) : Colors.white,
                                  lWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
                    SizedBox(height: height * 0.025),

                    Center(
                      child: SizedBox(
                        width: width * 0.37,
                        height: height * 0.052,
                        child: ElevatedButton(
                          onPressed: calculateLoan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF656399),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: fontManager.getTextStyle(
                              context,
                              color: const Color(0xFF656399),
                              lWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          child: const Text('calculate'),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    if (loanCalcResponse != null) ...[
                      Text('Suggested Timeline',
                          style: fontManager.getTextStyle(context,
                              color: Colors.white.withOpacity(0.92),
                              lWeight: FontWeight.w600,
                              fontSize: 16)),
                      SizedBox(height: height * 0.015),
                      ...((loanCalcResponse?['suggestedTimeline'] ?? []) as List<dynamic>)
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
                          Expanded(
                              child: infoBox(
                                  'Max Loan Amount',
                                  displayString(
                                      loanCalcResponse?['maxSuggestedLoanAmount']),
                                  context)),
                        ],
                      ),
                      SizedBox(height: height * 0.011),
                      Row(
                        children: [
                          Expanded(
                              child: infoBox(
                                  'Expected EMI',
                                  displayString(
                                      loanCalcResponse?['expectedEmi']),
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
                                  Icons.radio_button_off,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  displayString(
                                      loanCalcResponse?['bonusInsights'][idx]),
                                  style: fontManager.getTextStyle(
                                    context,
                                    color: Colors.white.withOpacity(0.93),
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
      ),
    );
  }

  Widget suggestionBox(String text, BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 0.5,
          color: Colors.white,
        ),
      ),
      child: Text(
        text,
        style: fontManager.getTextStyle(
          context,
          color: Colors.white,
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
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: fontManager.getTextStyle(
                context,
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                lWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: fontManager.getTextStyle(
                context,
                color: Colors.white,
                fontSize: 14.7,
                lWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 48);
    path.quadraticBezierTo(
        size.width, size.height, size.width - 60, size.height - 16);
    path.quadraticBezierTo(size.width / 2, size.height + 26, 60, size.height - 16);
    path.quadraticBezierTo(0, size.height, 0, size.height - 48);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

