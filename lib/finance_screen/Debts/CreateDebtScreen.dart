import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/animated/snackbar.dart';

import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';

class CreateDebtScreen extends StatefulWidget {
  @override
  _CreateDebtScreenState createState() => _CreateDebtScreenState();
}

class _CreateDebtScreenState extends State<CreateDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  String _loanType = '';
  double _amount = 0.0;
  DateTime _date = DateTime.now();
  double _interest = 0.0;
  String _name = '';
  int _durationMonths = 0; // New field for duration in months

  // ... [Keep the existing methods like _showLoanTypeModal, _showDatePicker, _saveDebt]
  void _showLoanTypeModal() async {
    final selectedLoanType = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.mt,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlotFinanceStaticData().loanType, // Updated
                PlotFinanceStaticData().homeLoan,
                PlotFinanceStaticData().loanAgainstProperty,
                PlotFinanceStaticData().vehicleLoan,
                PlotFinanceStaticData().creditCardLoan,
                PlotFinanceStaticData().goldLoan,
                PlotFinanceStaticData().mortgageLoan,
                PlotFinanceStaticData().educationLoan,
                PlotFinanceStaticData().businessLoan,
                PlotFinanceStaticData().studentLoan,
                PlotFinanceStaticData().otherLoan,
              ].map((loan) {
                return ListTile(
                  title: Text(loan),
                  onTap: () => Navigator.pop(context, loan),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedLoanType != null) {
      setState(() {
        _loanType = selectedLoanType;
      });
    }
  }

  void _showDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _date = selectedDate;
      });
    }
  }

  // void _saveDebt() {
  //   if (_formKey.currentState!.validate()) {
  //     final newDebt = Debt(
  //       loanType: _loanType,
  //       amount: _amount,
  //       date: _date,
  //       interest: _interest,
  //       name: _name,
  //     );
  //     Navigator.pop(context, newDebt);
  //   }
  // }

  void saveDebt() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> debtData = {
        'name': _name,
        'type': _loanType.toLowerCase(),
        'principalAmount': _amount,
        'interestRate': _interest,
        'durationMonths': _durationMonths,
        'startDate': _date.toIso8601String(),
      };
      // Debug statement

      try {
        Map<String, dynamic>? response = await DebtService.createDebt(debtData);

        if (response != null) {
          if (context.mounted) {
            // Ensure the widget is still in the tree
            Navigator.pop(
              context,
              Debt(
                id: response['data']['_id']?.toString() ?? '',
                name: _name,
                type: _loanType,
                amount: _amount,
                interest: _interest,
                durationMonths: _durationMonths,
                date: _date,
              ),
            );
            showSuccessTopSnackBar(context, SnackbarData().debtCreatedSuccess);
          }
        } else {}
      } catch (e) {}
    } else {
      // Debug statement
    }
    createDebtBool.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text((PlotFinanceStaticData().createDebtTitle)),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomFormField(
                  hintText: PlotFinanceStaticData().enterDebtName,
                  onChanged: (value) => setState(() => _name = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      PlotFinanceStaticData().enterDebtName;
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize),
                CustomFormField(
                  hintText: PlotFinanceStaticData().selectLoanType,
                  readOnly: true,
                  onTap: _showLoanTypeModal,
                  controller: TextEditingController(text: _loanType),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return PlotFinanceStaticData().validateLoanType;
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize),
                CustomFormField(
                  hintText: PlotFinanceStaticData().enterDebtAmount, // Updated
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      setState(() => _amount = double.tryParse(value) ?? 0.0),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return PlotFinanceStaticData().validateAmount; // Updated
                    }
                    if (double.tryParse(value) == null) {
                      return PlotFinanceStaticData().validateNumeric; // Updated
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize),
                CustomFormField(
                  hintText: PlotFinanceStaticData().enterInterestRate,
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      setState(() => _interest = double.tryParse(value) ?? 0.0),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return PlotFinanceStaticData().validateInterest;
                    }
                    if (double.tryParse(value) == null) {
                      return PlotFinanceStaticData().validateNumeric;
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize),
                CustomFormField(
                  hintText: PlotFinanceStaticData().enterDuration,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {
                    _durationMonths = int.tryParse(value) ?? 0;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return PlotFinanceStaticData().validateDuration;
                    }
                    if (int.tryParse(value) == null) {
                      return PlotFinanceStaticData().validateDuration;
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize),

                CustomFormField(
                  hintText: PlotFinanceStaticData().selectDate,
                  readOnly: true,
                  onTap: _showDatePicker,
                  controller: TextEditingController(
                      text: '${_date.day}/${_date.month}/${_date.year}'),
                  suffixIcon: Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return PlotFinanceStaticData().validateDate;
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize * 2),
                // ElevatedButton(
                //   onPressed: _saveDebt,
                //   child: Text('Continue'),
                // ),
                // check the issue with continue...
                GestureDetector(
                    onTap: () {
                      // Debug statement
                      if (createDebtBool.value) return;
                      createDebtBool.value = true;
                      saveDebt();
                      // Debug statement
                    },
                    child: Obx(() => createDebtBool.value
                        ? getspinner(context)
                        : getButton(
                            context, PlotFinanceStaticData().continueButton)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Debt {
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final double interest;
  final String name;
  final int durationMonths;

  Debt({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.interest,
    required this.name,
    required this.durationMonths,
  });
  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['_id']?.toString() ?? '',
      name: json['name'],
      type: json['type'],
      amount: (json['principalAmount'] as num).toDouble(),
      interest: (json['interestRate'] as num).toDouble(),
      durationMonths: json['durationMonths'] as int,
      date: DateTime.parse(json['startDate']),
    );
  }

  @override
  String toString() {
    return 'Debt(id: $id,name: $name, principal: $amount)';
  }
}

class CustomFormField extends StatelessWidget {
  static Color fillColor = AppColors.mt;

  static TextStyle defaultHintStyle(BuildContext context, double size) {
    return FontManager().getTextStyle(context,
        fontSize: size, color: AppColors.bg3, lWeight: FontWeight.bold);
  }

  final String hintText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final Widget? suffixIcon;

  const CustomFormField({
    Key? key,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.controller,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      onTap: onTap,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintStyle: defaultHintStyle(context, 14.0),
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        filled: true,
        fillColor: fillColor,
        suffixIcon: suffixIcon,

        // Setting proper border radius
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
