import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
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
                'Personal Loan',
                'Home Loan',
                'Loan Against Property (LAP)',
                'Vehicle Loan',
                'Credit Card Loan',
                'Gold Loan',
                'Mortgage',
                'Education Loan',
                'Business Loan',
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

  void _saveDebt() {
    if (_formKey.currentState!.validate()) {
      final newDebt = Debt(
        loanType: _loanType,
        amount: _amount,
        date: _date,
        interest: _interest,
        name: _name,
      );
      Navigator.pop(context, newDebt);
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
                  hintText: 'Enter your name',
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
                SizedBox(height: Colorcodes.paddingSize*2),
                // ElevatedButton(
                //   onPressed: _saveDebt,
                //   child: Text('Continue'),
                // ),
                GestureDetector(
                  onTap:_saveDebt,
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
  final String loanType;
  final double amount;
  final DateTime date;
  final double interest;
  final String name;

  Debt({
    required this.loanType,
    required this.amount,
    required this.date,
    required this.interest,
    required this.name,
  });
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
