import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Community_Page/success_post.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/animated/snackbar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                'Personal',
                'Home',
                'Loan Against Property (LAP)',
                'Vehicle',
                'Credit-Card',
                'Gold',
                'Mortgage',
                'Education',
                'Business',
                'Student Loan',
                'Other'
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
            showSuccessTopSnackBar(context,SnackbarData().debtCreatedSuccess);
          }
        } else {
        
        }
      } catch (e) {
       
      }
    } else {
     // Debug statement
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Create Debt'),
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
                  hintText: 'Enter debt name',
                  onChanged: (value) => setState(() => _name = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize),
                CustomFormField(
                  hintText: 'Select Loan Type',
                  readOnly: true,
                  onTap: _showLoanTypeModal,
                  controller: TextEditingController(text: _loanType),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a loan type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize),
                CustomFormField(
                  hintText: 'Enter Debt Amount',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      setState(() => _amount = double.tryParse(value) ?? 0.0),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize),
                CustomFormField(
                  hintText: 'Enter Interest Rate',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      setState(() => _interest = double.tryParse(value) ?? 0.0),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an interest rate';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize),
                CustomFormField(
                  hintText: 'Enter Duration (months)',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {
                    _durationMonths = int.tryParse(value) ?? 0;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter duration';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number for duration';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Colorcodes.paddingSize),

                CustomFormField(
                  hintText: 'Select Date',
                  readOnly: true,
                  onTap: _showDatePicker,
                  controller: TextEditingController(
                      text: '${_date.day}/${_date.month}/${_date.year}'),
                  suffixIcon: Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
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
                    saveDebt();
                    // Debug statement
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(24)),
                    child: Center(
                      child: Text(
                        'Continue',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.bold,
                            fontSize: Colorcodes.paddingSize,
                            color: AppColors.bg5),
                      ),
                    ),
                  ),
                )
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
