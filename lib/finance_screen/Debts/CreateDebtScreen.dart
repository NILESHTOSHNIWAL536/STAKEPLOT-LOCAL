// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
// import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
// import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
// import 'package:flutter_application_code_stakeplot/animated/snackbar.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

// import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_service.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:get/get.dart';

// class CreateDebtScreen extends StatefulWidget {
//   @override
//   _CreateDebtScreenState createState() => _CreateDebtScreenState();
// }

// class _CreateDebtScreenState extends State<CreateDebtScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _loanType = '';
//   double _amount = 0.0;
//   DateTime _date = DateTime.now();
//   double _interest = 0.0;
//   String _name = '';
//   int _durationMonths = 0; // New field for duration in months

//   // ... [Keep the existing methods like _showLoanTypeModal, _showDatePicker, _saveDebt]
//   void _showLoanTypeModal() async {
//     final selectedLoanType = await showModalBottomSheet<String>(
//       context: context,
//       backgroundColor: AppColors.mt,
//       builder: (context) {
//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 PlotFinanceStaticData().loanType, // Updated
//                 PlotFinanceStaticData().homeLoan,
//                 PlotFinanceStaticData().loanAgainstProperty,
//                 PlotFinanceStaticData().vehicleLoan,
//                 PlotFinanceStaticData().creditCardLoan,
//                 PlotFinanceStaticData().goldLoan,
//                 PlotFinanceStaticData().mortgageLoan,
//                 PlotFinanceStaticData().educationLoan,
//                 PlotFinanceStaticData().businessLoan,
//                 PlotFinanceStaticData().studentLoan,
//                 PlotFinanceStaticData().otherLoan,
//               ].map((loan) {
//                 return ListTile(
//                   title: Text(loan),
//                   onTap: () => Navigator.pop(context, loan),
//                 );
//               }).toList(),
//             ),
//           ),
//         );
//       },
//     );

//     if (selectedLoanType != null) {
//       setState(() {
//         _loanType = selectedLoanType;
//       });
//     }
//   }

//   void _showDatePicker() async {
//     final selectedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (selectedDate != null) {
//       setState(() {
//         _date = selectedDate;
//       });
//     }
//   }

//   // void _saveDebt() {
//   //   if (_formKey.currentState!.validate()) {
//   //     final newDebt = Debt(
//   //       loanType: _loanType,
//   //       amount: _amount,
//   //       date: _date,
//   //       interest: _interest,
//   //       name: _name,
//   //     );
//   //     Navigator.pop(context, newDebt);
//   //   }
//   // }

//   void saveDebt() async {
//     if (_formKey.currentState!.validate()) {
//       Map<String, dynamic> debtData = {
//         'name': _name,
//         'type': _loanType.toLowerCase(),
//         'principalAmount': _amount,
//         'interestRate': _interest,
//         'durationMonths': _durationMonths,
//         'startDate': _date.toIso8601String(),
//       };
//       // Debug statement

//       try {
//         Map<String, dynamic>? response = await DebtService.createDebt(debtData);

//         if (response != null) {
//           if (context.mounted) {
//             // Ensure the widget is still in the tree
//             Navigator.pop(
//               context,
//               Debt(
//                 id: response['data']['_id']?.toString() ?? '',
//                 name: _name,
//                 type: _loanType,
//                 amount: _amount,
//                 interest: _interest,
//                 durationMonths: _durationMonths,
//                 date: _date,
//               ),
//             );
//             snackBarCalled(context, SnackbarData().debtCreatedSuccess);
//           }
//         } else {}
//       } catch (e) {}
//     } else {
//       // Debug statement
//     }
//     createDebtBool.value = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         title: Text((PlotFinanceStaticData().createDebtTitle)),
//       ),
//       resizeToAvoidBottomInset: true,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Container(
//               width: MediaQuery.sizeOf(context).width/1.2,
//               height: MediaQuery.sizeOf(context).height/1.6,
//               padding: EdgeInsets.symmetric(horizontal: 12.0,vertical: 12.0),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                       color: AppColors.backgroundColor, // background: #FFF
//                       borderRadius: BorderRadius.circular(16), // border-radius: 16px
//                       border: Border.all(
//                         color: Color(0xFFF3F4F6), // border: 1px solid #F3F4F6
//                         width: 1,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Color.fromRGBO(0, 0, 0, 0.05), // rgba(0, 0, 0, 0.05)
//                           offset: Offset(0, 1), // x: 0, y: 1
//                           blurRadius: 2, // similar to 2px blur
//                         ),
//                       ],
//                     ),

//               child: Column(

//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 12.0,vertical: 12.0),
//                     child: Text(PlotFinanceStaticData().createDebtTitle,style: FontManager().getTextStyle(context,fontSize: 20,color: AppColors.primaryColor,lWeight: FontWeight.w600),),
//                   ),
//                   Container(
//                     width: MediaQuery.sizeOf(context).width/1.2,
//                     height: MediaQuery.sizeOf(context).height/2.2,
//                     padding: EdgeInsets.symmetric(horizontal: 12.0,vertical: 12.0),

//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                             Text(
//       PlotFinanceStaticData().debtNameLabel, // Add a new string in PlotFinanceStaticData, e.g., "Debt Name"
//       style: FontManager().getTextStyle(
//         context,
//         fontSize: 14.0,
//         color: AppColors.primaryColor,
//         lWeight: FontWeight.w400,
//       ),
//     ),
//     SizedBox(height: 8.0),
//                           CustomFormField(
//                             hintText: PlotFinanceStaticData().enterDebtName,
//                             onChanged: (value) => setState(() => _name = value),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 PlotFinanceStaticData().enterDebtName;
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(height: Colorcodes.paddingSize),
//                            Text(
//       PlotFinanceStaticData().loanTypeLabel, // Add a new string, e.g., "Loan Type"
//       style: FontManager().getTextStyle(
//         context,
//         fontSize: 14.0,
//         color: AppColors.primaryColor,
//         lWeight: FontWeight.w400,
//       ),
//     ),
//     SizedBox(height: 8.0),
//                           CustomFormField(
//                             hintText: PlotFinanceStaticData().selectLoanType,
//                             readOnly: true,
//                             onTap: _showLoanTypeModal,
//                             controller: TextEditingController(text: _loanType),
//                             suffixIcon: Icon(Icons.arrow_drop_down),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return PlotFinanceStaticData().validateLoanType;
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(height: Colorcodes.paddingSize),
//                            Text(
//       PlotFinanceStaticData().debtAmountLabel2, // Add a new string, e.g., "Debt Amount"
//       style: FontManager().getTextStyle(
//         context,
//         fontSize: 14.0,
//         color: AppColors.primaryColor,
//         lWeight: FontWeight.w400,
//       ),
//     ),
//     SizedBox(height: 8.0),
//                           CustomFormField(
//                             hintText: PlotFinanceStaticData().enterDebtAmount, // Updated
//                             keyboardType: TextInputType.number,
//                             onChanged: (value) =>
//                                 setState(() => _amount = double.tryParse(value) ?? 0.0),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return PlotFinanceStaticData().validateAmount; // Updated
//                               }
//                               if (double.tryParse(value) == null) {
//                                 return PlotFinanceStaticData().validateNumeric; // Updated
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(height: Colorcodes.paddingSize),
//                            Text(
//       PlotFinanceStaticData().interestRateLabel2, // Add a new string, e.g., "Interest Rate"
//       style: FontManager().getTextStyle(
//         context,
//         fontSize: 14.0,
//         color: AppColors.primaryColor,
//         lWeight: FontWeight.w400,
//       ),
//     ),
//     SizedBox(height: 8.0),
//                           CustomFormField(
//                             hintText: PlotFinanceStaticData().enterInterestRate,
//                             keyboardType: TextInputType.number,
//                             onChanged: (value) =>
//                                 setState(() => _interest = double.tryParse(value) ?? 0.0),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return PlotFinanceStaticData().validateInterest;
//                               }
//                               if (double.tryParse(value) == null) {
//                                 return PlotFinanceStaticData().validateNumeric;
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(height: Colorcodes.paddingSize),
//                            Text(
//       PlotFinanceStaticData().durationLabel, // Add a new string, e.g., "Duration (Months)"
//       style: FontManager().getTextStyle(
//         context,
//         fontSize: 14.0,
//         color: AppColors.primaryColor,
//         lWeight: FontWeight.w400,
//       ),
//     ),
//     SizedBox(height: 8.0),
//                           CustomFormField(
//                             hintText: PlotFinanceStaticData().enterDuration,
//                             keyboardType: TextInputType.number,
//                             onChanged: (value) => setState(() {
//                               _durationMonths = int.tryParse(value) ?? 0;
//                             }),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return PlotFinanceStaticData().validateDuration;
//                               }
//                               if (int.tryParse(value) == null) {
//                                 return PlotFinanceStaticData().validateDuration;
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(height: Colorcodes.paddingSize),
//                        Text(
//       PlotFinanceStaticData().dateLabel, // Add a new string, e.g., "Start Date"
//       style: FontManager().getTextStyle(
//         context,
//         fontSize: 14.0,
//         color: AppColors.primaryColor,
//         lWeight: FontWeight.w400,
//       ),
//     ),
//     SizedBox(height: 8.0),
//                           CustomFormField(
//                             hintText: PlotFinanceStaticData().selectDate,
//                             readOnly: true,
//                             onTap: _showDatePicker,
//                             controller: TextEditingController(
//                                 text: '${_date.day}/${_date.month}/${_date.year}'),
//                             suffixIcon: Icon(Icons.calendar_today),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return PlotFinanceStaticData().validateDate;
//                               }
//                               return null;
//                             },
//                           ),

//                         ],
//                       ),
//                     ),
//                   ),
//                     GestureDetector(
//                               onTap: () {
//                                 // Debug statement
//                                 if (createDebtBool.value) return;
//                                 createDebtBool.value = true;
//                                 saveDebt();
//                                 // Debug statement
//                               },
//                               child: Obx(() => createDebtBool.value
//                                   ? getspinner(context)
//                                   : getButton(
//                                       context, PlotFinanceStaticData().continueButton)))
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Debt {
//   final String id;
//   final String type;
//   final double amount;
//   final DateTime date;
//   final double interest;
//   final String name;
//   final int durationMonths;

//   Debt({
//     required this.id,
//     required this.type,
//     required this.amount,
//     required this.date,
//     required this.interest,
//     required this.name,
//     required this.durationMonths,
//   });
//   factory Debt.fromJson(Map<String, dynamic> json) {
//     return Debt(
//       id: json['_id']?.toString() ?? '',
//       name: json['name'],
//       type: json['type'],
//       amount: (json['principalAmount'] as num).toDouble(),
//       interest: (json['interestRate'] as num).toDouble(),
//       durationMonths: json['durationMonths'] as int,
//       date: DateTime.parse(json['startDate']),
//     );
//   }

//   @override
//   String toString() {
//     return 'Debt(id: $id,name: $name, principal: $amount)';
//   }
// }

// class CustomFormField extends StatelessWidget {
//   static Color fillColor = AppColors.mt;

//   static TextStyle defaultHintStyle(BuildContext context, double size) {
//     return FontManager().getTextStyle(context,
//         fontSize: size, color: AppColors.bg3, lWeight: FontWeight.w400);
//   }

//   final String hintText;
//   final TextInputType keyboardType;
//   final Function(String)? onChanged;
//   final String? Function(String?)? validator;
//   final bool readOnly;
//   final VoidCallback? onTap;
//   final TextEditingController? controller;
//   final Widget? suffixIcon;

//   const CustomFormField({
//     Key? key,
//     required this.hintText,
//     this.keyboardType = TextInputType.text,
//     this.onChanged,
//     this.validator,
//     this.readOnly = false,
//     this.onTap,
//     this.controller,
//     this.suffixIcon,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       readOnly: readOnly,
//       onTap: onTap,
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         hintStyle: defaultHintStyle(context, 14.0),
//         hintText: hintText,
//         contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
//         filled: true,
//         fillColor: fillColor,
//         suffixIcon: suffixIcon,

//         // Setting proper border radius
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.0),
//           borderSide: BorderSide(color: AppColors.border),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.0),
//           borderSide: BorderSide(color: AppColors.border),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.0),
//           borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
//         ),
//       ),
//       onChanged: onChanged,
//       validator: validator,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/animated/snackbar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_display.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_service.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/financeWidgets.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// Import FinanceWidgets
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
  int _durationMonths = 0;
  // final RxList<Debt> _debts = <Debt>[].obs; // Reactive list to store debts

  @override
  void initState() {
    super.initState();
    _fetchDebts(); // Fetch debts when screen initializes
  }

  // Fetch debts from API
  void _fetchDebts() async {
    final debts2 = await DebtService.fetchDebts();
    debts.assignAll(debts2); // Update reactive list
  }

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
                PlotFinanceStaticData().loanType,
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

      try {
        Map<String, dynamic>? response = await DebtService.createDebt(debtData);

        if (response != null) {
          if (context.mounted) {
            final newDebt = Debt(
              id: response['data']['_id']?.toString() ?? '',
              name: _name,
              type: _loanType,
              amount: _amount,
              interest: _interest,
              durationMonths: _durationMonths,
              date: _date,
            );
            debts.add(newDebt); // Add new debt to the reactive list
            Navigator.pop(context, newDebt);
            snackBarCalled(context, SnackbarData().debtCreatedSuccess);
          }
        }
      } catch (e) {
        if (context.mounted) {
          snackBarCalled(context, 'Failed to create debt');
        }
      }
    }
    createDebtBool.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text("Create Debt"),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display existing debts
              Text(
                "Recent History",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  color: AppColors.grey,
                  lWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FinanceWidgets.debtsPicture(
                context,
                debts,
                (Debt debt) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DebtDetailsScreen(debt: debt),
                    ),
                  ).then((_) => _fetchDebts()); // Refresh debts after returning
                },
              ),
              SizedBox(height: 16.0), // Space between debts and form
              // Form container
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                ),
                child: Container(
                  width: MediaQuery.sizeOf(context).width / 1.2,
                  height: MediaQuery.sizeOf(context).height / 1.6,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 12.0),
                          child: Text(
                            PlotFinanceStaticData().createDebtTitle,
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 20,
                              color: AppColors.accentColor,
                              lWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.sizeOf(context).width / 1.2,
                          height: MediaQuery.sizeOf(context).height / 2.2,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 12.0),
                          child: Scrollbar(
                            thumbVisibility: true, // Always show the scrollbar
                            thickness: 4.0, // Adjust thickness
                            radius: Radius.circular(8.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    PlotFinanceStaticData().debtNameLabel,
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14.0,
                                      color: AppColors.accentColor,
                                      lWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  CustomFormField(
                                    hintText:
                                        PlotFinanceStaticData().enterDebtName,
                                    onChanged: (value) =>
                                        setState(() => _name = value),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return PlotFinanceStaticData()
                                            .enterDebtName; // Fixed validator
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: Colorcodes.paddingSize),
                                  Text(
                                    PlotFinanceStaticData().loanTypeLabel,
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14.0,
                                      color: AppColors.accentColor,
                                      lWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  CustomFormField(
                                    hintText:
                                        PlotFinanceStaticData().selectLoanType,
                                    readOnly: true,
                                    onTap: _showLoanTypeModal,
                                    controller:
                                        TextEditingController(text: _loanType),
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return PlotFinanceStaticData()
                                            .validateLoanType;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: Colorcodes.paddingSize),
                                  Text(
                                    PlotFinanceStaticData()
                                        .debtAmountLabel2, // Use debtAmountLabel2
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14.0,
                                      color: AppColors.accentColor,
                                      lWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  CustomFormField(
                                    hintText:
                                        PlotFinanceStaticData().enterDebtAmount,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => setState(() =>
                                        _amount =
                                            double.tryParse(value) ?? 0.0),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return PlotFinanceStaticData()
                                            .validateAmount;
                                      }
                                      if (double.tryParse(value) == null) {
                                        return PlotFinanceStaticData()
                                            .validateNumeric;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: Colorcodes.paddingSize),
                                  Text(
                                    PlotFinanceStaticData()
                                        .interestRateLabel2, // Use interestRateLabel2
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14.0,
                                      color: AppColors.accentColor,
                                      lWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  CustomFormField(
                                    hintText: PlotFinanceStaticData()
                                        .enterInterestRate,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => setState(() =>
                                        _interest =
                                            double.tryParse(value) ?? 0.0),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return PlotFinanceStaticData()
                                            .validateInterest;
                                      }
                                      if (double.tryParse(value) == null) {
                                        return PlotFinanceStaticData()
                                            .validateNumeric;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: Colorcodes.paddingSize),
                                  Text(
                                    PlotFinanceStaticData().durationLabel,
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14.0,
                                      color: AppColors.accentColor,
                                      lWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  CustomFormField(
                                    hintText:
                                        PlotFinanceStaticData().enterDuration,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => setState(() {
                                      _durationMonths =
                                          int.tryParse(value) ?? 0;
                                    }),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return PlotFinanceStaticData()
                                            .validateDuration;
                                      }
                                      if (int.tryParse(value) == null) {
                                        return PlotFinanceStaticData()
                                            .validateDuration;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: Colorcodes.paddingSize),
                                  Text(
                                    PlotFinanceStaticData().dateLabel,
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14.0,
                                      color: AppColors.accentColor,
                                      lWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  CustomFormField(
                                    hintText:
                                        PlotFinanceStaticData().selectDate,
                                    readOnly: true,
                                    onTap: _showDatePicker,
                                    controller: TextEditingController(
                                        text:
                                            '${_date.day}/${_date.month}/${_date.year}'),
                                    suffixIcon: Icon(Icons.calendar_today),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return PlotFinanceStaticData()
                                            .validateDate;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (createDebtBool.value) return;
                            createDebtBool.value = true;
                            saveDebt();
                          },
                          child: Obx(() => createDebtBool.value
                              ? getspinner(context)
                              : getButton(context,
                                  PlotFinanceStaticData().continueButton)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      amount: (json['principalAmount'] as num?)?.toDouble() ?? 0.0,
      interest: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 0,
      date: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Debt(id: $id, name: $name, principal: $amount)';
  }
}

class CustomFormField extends StatelessWidget {
  static Color fillColor = AppColors.mt;

  static TextStyle defaultHintStyle(BuildContext context, double size) {
    return FontManager().getTextStyle(context,
        fontSize: size, color: AppColors.bg3, lWeight: FontWeight.w400);
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
