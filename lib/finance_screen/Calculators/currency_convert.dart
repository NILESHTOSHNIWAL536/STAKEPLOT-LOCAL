// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/veg_nonveg.dart';
// import 'package:flutter_application_code_stakeplot/loader.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class CurrencyConverterScreen extends StatefulWidget {
//   const CurrencyConverterScreen({super.key});

//   @override
//   State<CurrencyConverterScreen> createState() =>
//       _CurrencyConverterScreenState();
// }

// class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
//   Map<String, String> currencies = {};
//   String? baseCurrency;
//   String? targetCurrency;
//   final TextEditingController amountController = TextEditingController();
//   final TextEditingController baseSearchController = TextEditingController();
//   final TextEditingController targetSearchController = TextEditingController();
//   String result = "";
//   bool isLoading = false;
//   bool isFetchingCurrencies = true;
//   List<String> recentConversions = [];
//   List<MapEntry<String, String>> filteredBaseCurrencies = [];
//   List<MapEntry<String, String>> filteredTargetCurrencies = [];
//   bool isBaseSearchActive = false;
//   bool isTargetSearchActive = false;

//   @override
//   void initState() {
//     super.initState();

//     fetchCurrencies();
//     loadPreferences();
//     baseSearchController.addListener(_filterBaseCurrencies);
//     targetSearchController.addListener(_filterTargetCurrencies);
//   }

//   Future<void> loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       recentConversions = prefs.getStringList('recentConversions') ?? [];
//       baseCurrency = prefs.getString('baseCurrency');
//       targetCurrency = prefs.getString('targetCurrency');
//       baseSearchController.text = "";
//       targetSearchController.text = "";
//       // if (baseCurrency != null) {
//       //   baseSearchController.text =
//       //       "${baseCurrency!.toUpperCase()} - ${currencies[baseCurrency] ?? ''}";
//       // }
//       // if (targetCurrency != null) {
//       //   targetSearchController.text =
//       //       "${targetCurrency!.toUpperCase()} - ${currencies[targetCurrency] ?? ''}";
//       // }
//     });
//   }

//   Future<void> savePreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('recentConversions', recentConversions);
//     if (baseCurrency != null)
//       await prefs.setString('baseCurrency', baseCurrency!);
//     if (targetCurrency != null)
//       await prefs.setString('targetCurrency', targetCurrency!);
//   }

//   Future<void> clearPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('baseCurrency');
//     await prefs.remove('targetCurrency');
//   }

//   Future<void> fetchCurrencies() async {
//     try {
//       final response = await http.get(Uri.parse(
//           "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json"));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         setState(() {
//           currencies = data
//               .map((key, value) => MapEntry(key.toString(), value.toString()));
//           filteredBaseCurrencies = currencies.entries.toList();
//           filteredTargetCurrencies = currencies.entries.toList();
//           isFetchingCurrencies = false;
//           // Update search fields if currencies were previously selected
//           if (baseCurrency != null) {
//             baseSearchController.text =
//                 "${baseCurrency!.toUpperCase()} - ${currencies[baseCurrency] ?? ''}";
//           }
//           if (targetCurrency != null) {
//             targetSearchController.text =
//                 "${targetCurrency!.toUpperCase()} - ${currencies[targetCurrency] ?? ''}";
//           }
//         });
//       } else {
//         _showSnackBar("Failed to load currencies.");
//         setState(() => isFetchingCurrencies = false);
//       }
//     } catch (e) {
//       _showSnackBar("Error fetching currencies: $e");
//       setState(() => isFetchingCurrencies = false);
//     }
//   }

//   void _filterBaseCurrencies() {
//     final query = baseSearchController.text.toLowerCase();
//     setState(() {
//       isBaseSearchActive = query.isNotEmpty;
//       filteredBaseCurrencies = currencies.entries
//           .where((entry) =>
//               entry.key.toLowerCase().contains(query) ||
//               entry.value.toLowerCase().contains(query))
//           .toList();
//     });
//   }

//   void _filterTargetCurrencies() {
//     final query = targetSearchController.text.toLowerCase();
//     setState(() {
//       isTargetSearchActive = query.isNotEmpty;
//       filteredTargetCurrencies = currencies.entries
//           .where((entry) =>
//               entry.key.toLowerCase().contains(query) ||
//               entry.value.toLowerCase().contains(query))
//           .toList();
//     });
//   }

//   Future<void> convertCurrency() async {
//     if (baseCurrency == null ||
//         targetCurrency == null ||
//         amountController.text.trim().isEmpty) {
//       _showSnackBar("Please select currencies and enter an amount.");
//       return;
//     }

//     final amount = double.tryParse(amountController.text.trim());
//     if (amount == null) {
//       _showSnackBar("Please enter a valid number.");
//       return;
//     }

//     setState(() {
//       isLoading = true;
//       result = "";
//     });

//     try {
//       final url =
//           "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$baseCurrency.json";
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (!data.containsKey(baseCurrency) ||
//             !data[baseCurrency].containsKey(targetCurrency)) {
//           _showSnackBar("Conversion failed: Invalid currency.");
//           return;
//         }

//         final rate = data[baseCurrency][targetCurrency];
//         final converted = amount * rate;

//         setState(() {
//           result =
//               "$amount ${baseCurrency!.toUpperCase()} = ${converted.toStringAsFixed(2)} ${targetCurrency!.toUpperCase()}";
//           recentConversions.insert(0,
//               "$amount ${baseCurrency!.toUpperCase()} → ${converted.toStringAsFixed(2)} ${targetCurrency!.toUpperCase()} ");
//           if (recentConversions.length > 3) recentConversions.removeLast();
//           savePreferences();
//         });
//       } else {
//         _showSnackBar("Error fetching conversion.");
//       }
//     } catch (e) {
//       _showSnackBar("Error: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void swapCurrencies() {
//     setState(() {
//       // Store both values before swapping
//       final tempBase = baseCurrency;
//       final tempTarget = targetCurrency;

//       // Swap the currency codes
//       baseCurrency = tempTarget;
//       targetCurrency = tempBase;

//       // Update the search field texts using the temporary values
//       baseSearchController.text = tempTarget != null
//           ? "${tempTarget.toUpperCase()} - ${currencies[tempTarget] ?? ''}"
//           : "";
//       targetSearchController.text = tempBase != null
//           ? "${tempBase.toUpperCase()} - ${currencies[tempBase] ?? ''}"
//           : "";

//       // Hide suggestion lists
//       isBaseSearchActive = false;
//       isTargetSearchActive = false;

//       // Save swapped currencies to SharedPreferences
//       savePreferences();
//     });
//   }

//   void _showSnackBar(String message) {
//     snackBarCalledfail(context, message);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryColor,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Transform.translate(
//                 offset: Offset(0,
//                     MediaQuery.sizeOf(context).height * 0.03), // 30/640 = 0.047
//                 child: Container(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         width: MediaQuery.sizeOf(context).width / 1.6,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             IconButton(
//                               icon: Icon(
//                                 Icons.arrow_back,
//                                 color: AppColors.backgroundColor,
//                               ),
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                             ),
//                             Text(
//                               "Currency Converter",
//                               style: FontManager().getTextStyle(
//                                 context,
//                                 lWeight: FontWeight.w600,
//                                 fontSize: 18,
//                                 color: AppColors.backgroundColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   height: 150,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         const Color(0xE6061F35),
//                         const Color(0x00061F35),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               //
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Transform.translate(
//                 offset: Offset(0,
//                     MediaQuery.sizeOf(context).height * 0.1), // 80/640 = 0.125
//                 // SvgPicture.asset(
//                 //     'assets/icons/financeScreen/currency.svg',
//                 //     width: double.infinity,   // Full width
//                 //     height: double.infinity,  // Full height
//                 //     //  fit: BoxFit.cover,        // Make it cover the whole screen
//                 //   ),
//                 child: CustomPaint(
//                   painter: CustomShapePainter(),
//                 ),
//               ),
//             ),
//             Transform.translate(
//               offset: Offset(
//                   0, MediaQuery.sizeOf(context).height * 0.1), // 80/640 = 0.125
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Container(
//                   height: MediaQuery.sizeOf(context).height / 1.3,
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Base Currency Picker
//                       Text(
//                         "Base Currency",
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.normal,
//                           fontSize: 14,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       // Search Field for Base Currency
//                       TextField(
//                         controller: baseSearchController,
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w600,
//                           fontSize: 14,
//                           color: AppColors
//                               .backgroundColor, // Set text color to white
//                         ),
//                         decoration: InputDecoration(
//                           isDense: true,
//                           filled: true,
//                           fillColor: Color(0x3AFFFFFF),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 1,
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 1,
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 1,
//                             ),
//                           ),
//                           hintText: "Search currency...",
//                           hintStyle: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.normal,
//                             fontSize: 14,
//                             color: AppColors.backgroundColor,
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 16),
//                         ),
//                         onTap: () {
//                           setState(() {
//                             isBaseSearchActive = true;
//                             _filterBaseCurrencies();
//                           });
//                         },
//                       ),
//                       // Suggestions for Base Currency
//                       if (isBaseSearchActive &&
//                           filteredBaseCurrencies.isNotEmpty)
//                         Container(
//                           constraints: BoxConstraints(
//                             maxHeight: 150,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                             border: Border.all(color: Colors.white),
//                           ),
//                           child: ListView.builder(
//                             shrinkWrap: true,
//                             itemCount: filteredBaseCurrencies.length,
//                             itemBuilder: (context, index) {
//                               final entry = filteredBaseCurrencies[index];
//                               return ListTile(
//                                 title: Text(
//                                   "${entry.key.toUpperCase()} - ${entry.value}",
//                                   style: FontManager().getTextStyle(
//                                     context,
//                                     lWeight: FontWeight.normal,
//                                     fontSize: 14,
//                                     color: AppColors.primaryColor,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 onTap: () {
//                                   setState(() {
//                                     baseCurrency = entry.key;
//                                     baseSearchController.text =
//                                         "${entry.key.toUpperCase()} - ${entry.value}";
//                                     isBaseSearchActive = false;
//                                     savePreferences();
//                                   });
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       const SizedBox(height: 12),
//                       // Swap Button
//                       Center(
//                         child: GestureDetector(
//                           onTap: swapCurrencies,
//                           child: Container(
//                             padding: const EdgeInsets.all(10),
//                             child: const Icon(
//                               Icons.swap_vert,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       // Target Currency Picker
//                       Text(
//                         "Converted Currency",
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.normal,
//                           fontSize: 14,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       // Search Field for Target Currency
//                       TextField(
//                         controller: targetSearchController,
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w600,
//                           fontSize: 14,
//                           color: AppColors
//                               .backgroundColor, // Set text color to white
//                         ),
//                         decoration: InputDecoration(
//                           isDense: true,
//                           filled: true,
//                           fillColor: Color.fromRGBO(255, 255, 255, 0.23),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 1,
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 1,
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 1,
//                             ),
//                           ),
//                           hintText: "Search currency",
//                           hintStyle: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.normal,
//                             fontSize: 14,
//                             color: AppColors.backgroundColor,
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 16),
//                         ),
//                         onTap: () {
//                           setState(() {
//                             isTargetSearchActive = true;
//                             _filterTargetCurrencies();
//                           });
//                         },
//                       ),
//                       // Suggestions for Target Currency
//                       if (isTargetSearchActive &&
//                           filteredTargetCurrencies.isNotEmpty)
//                         Container(
//                           constraints: BoxConstraints(
//                             maxHeight: 150,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                             border: Border.all(color: Colors.white),
//                           ),
//                           child: ListView.builder(
//                             shrinkWrap: true,
//                             itemCount: filteredTargetCurrencies.length,
//                             itemBuilder: (context, index) {
//                               final entry = filteredTargetCurrencies[index];
//                               return ListTile(
//                                 title: Text(
//                                   "${entry.key.toUpperCase()} - ${entry.value}",
//                                   style: FontManager().getTextStyle(
//                                     context,
//                                     lWeight: FontWeight.normal,
//                                     fontSize: 14,
//                                     color: AppColors.primaryColor,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 onTap: () {
//                                   setState(() {
//                                     targetCurrency = entry.key;
//                                     targetSearchController.text =
//                                         "${entry.key.toUpperCase()} - ${entry.value}";
//                                     isTargetSearchActive = false;
//                                     savePreferences();
//                                   });
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       const SizedBox(height: 16),
//                       // Amount Field
//                       Text(
//                         "Amount",
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.normal,
//                           fontSize: 14,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextField(
//                         controller: amountController,
//                         keyboardType: TextInputType.number,
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.normal,
//                           fontSize: 14,
//                           color: AppColors
//                               .backgroundColor, // Set text color to white
//                         ),
//                         textInputAction: TextInputAction.done,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Color.fromRGBO(255, 255, 255, 0.23),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 1,
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 1,
//                             ),
//                           ),
//                           hintText: "Enter amount",
//                           hintStyle: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.w500,
//                             fontSize: 14,
//                             color: AppColors.backgroundColor,
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(6),
//                             borderSide: const BorderSide(
//                               color: Colors.white,
//                               width: 1,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 12, horizontal: 16),
//                           errorText: amountController.text.isNotEmpty &&
//                                   double.tryParse(
//                                           amountController.text.trim()) ==
//                                       null
//                               ? "Invalid number"
//                               : null,
//                         ),
//                         onChanged: (value) => setState(() {}),
//                       ),
//                       const SizedBox(height: 30),
//                       // Result Display
//                       if (result.isNotEmpty)
//                         Center(
//                           child: Container(
//                             width: MediaQuery.sizeOf(context).width / 1.1,
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 12, horizontal: 8),
//                             decoration: BoxDecoration(
//                               color: const Color.fromRGBO(255, 255, 255, 0.231),
//                               border: Border.all(
//                                 color: Colors.white,
//                                 width: 1,
//                               ),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               result,
//                               style: FontManager().getTextStyle(
//                                 context,
//                                 lWeight: FontWeight.w500,
//                                 fontSize: 14,
//                                 color: AppColors.backgroundColor,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       const SizedBox(height: 24),
//                       // Convert Button
//                       Center(
//                         child: ElevatedButton(
//                           onPressed: isLoading ||
//                                   baseCurrency == null ||
//                                   targetCurrency == null ||
//                                   amountController.text.trim().isEmpty ||
//                                   double.tryParse(
//                                           amountController.text.trim()) ==
//                                       null
//                               ? null
//                               : convertCurrency,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 14, horizontal: 12),
//                             backgroundColor: AppColors.backgroundColor,
//                             foregroundColor: AppColors.primaryColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             elevation: 0,
//                           ),
//                           child: isLoading
//                               ? Spinner()
//                               : Text(
//                                   "Convert",
//                                   style: FontManager().getTextStyle(
//                                     context,
//                                     lWeight: FontWeight.w600,
//                                     fontSize: 14,
//                                     color: AppColors.primaryColor,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       // Recent Conversions
//                       if (recentConversions.isNotEmpty)
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Recent Conversions",
//                                 style: FontManager().getTextStyle(
//                                   context,
//                                   lWeight: FontWeight.normal,
//                                   fontSize: 16,
//                                   color: AppColors.backgroundColor,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: recentConversions
//                                     .map((conversion) => Center(
//                                           child: Container(
//                                             width: MediaQuery.sizeOf(context)
//                                                     .width /
//                                                 1.4,
//                                             margin: const EdgeInsets.only(
//                                                 bottom: 6),
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 8, horizontal: 8),
//                                             decoration: BoxDecoration(
//                                               color: Color.fromRGBO(
//                                                   255, 255, 255, 0.23),
//                                               borderRadius:
//                                                   BorderRadius.circular(6),
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 conversion,
//                                                 style:
//                                                     FontManager().getTextStyle(
//                                                   context,
//                                                   lWeight: FontWeight.normal,
//                                                   fontSize: 14,
//                                                   color:
//                                                       AppColors.backgroundColor,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ))
//                                     .toList(),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // @override
//   // void dispose() {
//   //   baseSearchController.dispose();
//   //   targetSearchController.dispose();
//   //   amountController.dispose();
//   //   super.dispose();
//   // }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/veg_nonveg.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  Map<String, String> currencies = {};
  String? baseCurrency;
  String? targetCurrency;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController baseSearchController = TextEditingController();
  final TextEditingController targetSearchController = TextEditingController();
  String result = "";
  bool isLoading = false;
  bool isFetchingCurrencies = true;
  List<String> recentConversions = [];
  List<MapEntry<String, String>> filteredBaseCurrencies = [];
  List<MapEntry<String, String>> filteredTargetCurrencies = [];
  bool isBaseSearchActive = false;
  bool isTargetSearchActive = false;

  // Track last conversion inputs
  String? lastBaseCurrency;
  String? lastTargetCurrency;
  String? lastAmount;
  bool _isInfoVisible = false; // Controls visibility of the container
  double _opacity = 0.0; // Controls the fade effect
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    fetchCurrencies();
    loadPreferences();
    baseSearchController.addListener(_filterBaseCurrencies);
    targetSearchController.addListener(_filterTargetCurrencies);
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
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentConversions = prefs.getStringList('recentConversions') ?? [];
      baseCurrency = prefs.getString('baseCurrency');
      targetCurrency = prefs.getString('targetCurrency');
      baseSearchController.text = "";
      targetSearchController.text = "";
    });
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentConversions', recentConversions);
    if (baseCurrency != null)
      await prefs.setString('baseCurrency', baseCurrency!);
    if (targetCurrency != null)
      await prefs.setString('targetCurrency', targetCurrency!);
  }

  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('baseCurrency');
    await prefs.remove('targetCurrency');
  }

  Future<void> fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse(
          "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          currencies = data
              .map((key, value) => MapEntry(key.toString(), value.toString()));
          filteredBaseCurrencies = currencies.entries.toList();
          filteredTargetCurrencies = currencies.entries.toList();
          isFetchingCurrencies = false;
          if (baseCurrency != null) {
            baseSearchController.text =
                "${baseCurrency!.toUpperCase()} - ${currencies[baseCurrency] ?? ''}";
          }
          if (targetCurrency != null) {
            targetSearchController.text =
                "${targetCurrency!.toUpperCase()} - ${currencies[targetCurrency] ?? ''}";
          }
        });
      } else {
        _showSnackBar("Failed to load currencies.");
        setState(() => isFetchingCurrencies = false);
      }
    } catch (e) {
      _showSnackBar("Error fetching currencies: $e");
      setState(() => isFetchingCurrencies = false);
    }
  }

  void _filterBaseCurrencies() {
    final query = baseSearchController.text.toLowerCase();
    setState(() {
      isBaseSearchActive = query.isNotEmpty;
      filteredBaseCurrencies = currencies.entries
          .where((entry) =>
              entry.key.toLowerCase().contains(query) ||
              entry.value.toLowerCase().contains(query))
          .toList();
    });
  }

  void _filterTargetCurrencies() {
    final query = targetSearchController.text.toLowerCase();
    setState(() {
      isTargetSearchActive = query.isNotEmpty;
      filteredTargetCurrencies = currencies.entries
          .where((entry) =>
              entry.key.toLowerCase().contains(query) ||
              entry.value.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> convertCurrency() async {
    if (baseCurrency == null ||
        targetCurrency == null ||
        amountController.text.trim().isEmpty) {
      _showSnackBar("Please select currencies and enter an amount.");
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null) {
      _showSnackBar("Please enter a valid number.");
      return;
    }

    // Check if inputs have changed since the last conversion
    if (baseCurrency == lastBaseCurrency &&
        targetCurrency == lastTargetCurrency &&
        amountController.text.trim() == lastAmount) {
      // _showSnackBar("No changes to convert again.");
      return;
    }

    setState(() {
      isLoading = true;
      result = "";
    });

    try {
      final url =
          "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$baseCurrency.json";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data.containsKey(baseCurrency) ||
            !data[baseCurrency].containsKey(targetCurrency)) {
          _showSnackBar("Conversion failed: Invalid currency.");
          return;
        }

        final rate = data[baseCurrency][targetCurrency];
        final converted = amount * rate;

        setState(() {
          result =
              "$amount ${baseCurrency!.toUpperCase()} = ${converted.toStringAsFixed(2)} ${targetCurrency!.toUpperCase()}";
          recentConversions.insert(0,
              "$amount ${baseCurrency!.toUpperCase()} → ${converted.toStringAsFixed(2)} ${targetCurrency!.toUpperCase()} ");
          if (recentConversions.length > 3) recentConversions.removeLast();

          // Update last conversion inputs
          lastBaseCurrency = baseCurrency;
          lastTargetCurrency = targetCurrency;
          lastAmount = amountController.text.trim();

          savePreferences();
        });
      } else {
        _showSnackBar("Error fetching conversion.");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void swapCurrencies() {
    setState(() {
      final tempBase = baseCurrency;
      final tempTarget = targetCurrency;
      baseCurrency = tempTarget;
      targetCurrency = tempBase;
      baseSearchController.text = tempTarget != null
          ? "${tempTarget.toUpperCase()} - ${currencies[tempTarget] ?? ''}"
          : "";
      targetSearchController.text = tempBase != null
          ? "${tempBase.toUpperCase()} - ${currencies[tempBase] ?? ''}"
          : "";
      isBaseSearchActive = false;
      isTargetSearchActive = false;
      savePreferences();
    });
  }

  void _showSnackBar(String message) {
    snackBarCalledfail(context, message);
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: GestureDetector(
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
                    "Currency Converter ",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w800,
                      fontSize: 40,
                      color: AppColors.primaryColor,
                    ),
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
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              "This calculator helps you convert amounts between different currencies using real-time exchange rates. Stay updated with global currency values.",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 14,
                                color: AppColors.backgroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Base Currency",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: baseSearchController,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        hintText: 'Search Currency',
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
                      ),
                      onTap: () {
                        setState(() {
                          isBaseSearchActive = true;
                          _filterBaseCurrencies();
                        });
                      },
                    ),
                    const SizedBox(height: 4),
                    if (isBaseSearchActive && filteredBaseCurrencies.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 150,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredBaseCurrencies.length,
                          itemBuilder: (context, index) {
                            final entry = filteredBaseCurrencies[index];
                            return ListTile(
                              title: Text(
                                "${entry.key.toUpperCase()} - ${entry.value}",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: AppColors.backgroundColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                setState(() {
                                  baseCurrency = entry.key;
                                  baseSearchController.text =
                                      "${entry.key.toUpperCase()} - ${entry.value}";
                                  isBaseSearchActive = false;
                                  savePreferences();
                                });
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
                        onTap: swapCurrencies,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.swap_vert,
                            color: AppColors.accentColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Converted Currency",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: targetSearchController,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        hintText: 'Search Currency',
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
                      ),
                      onTap: () {
                        setState(() {
                          isTargetSearchActive = true;
                          _filterTargetCurrencies();
                        });
                      },
                    ),
                    SizedBox(height: 4),
                    if (isTargetSearchActive &&
                        filteredTargetCurrencies.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 150,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredTargetCurrencies.length,
                          itemBuilder: (context, index) {
                            final entry = filteredTargetCurrencies[index];
                            return ListTile(
                              title: Text(
                                "${entry.key.toUpperCase()} - ${entry.value}",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: AppColors.backgroundColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                setState(() {
                                  targetCurrency = entry.key;
                                  targetSearchController.text =
                                      "${entry.key.toUpperCase()} - ${entry.value}";
                                  isTargetSearchActive = false;
                                  savePreferences();
                                });
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      "Amount",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        hintText: 'Enter Amount',
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
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 30),
                    if (result.isNotEmpty)
                      Center(
                        child: Container(
                          width: MediaQuery.sizeOf(context).width / 1.1,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
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
                          child: Text(
                            result,
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: isLoading ||
                                baseCurrency == null ||
                                targetCurrency == null ||
                                amountController.text.trim().isEmpty ||
                                double.tryParse(amountController.text.trim()) ==
                                    null
                            ? null
                            : convertCurrency,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? Spinner()
                            : Text(
                                "Convert",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.backgroundColor,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (recentConversions.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recent Conversions",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: recentConversions
                                  .map((conversion) => Center(
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width /
                                                  1.4,
                                          margin:
                                              const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.backgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Color(0xFFF3F4F6),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.05),
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              conversion,
                                              style: FontManager().getTextStyle(
                                                context,
                                                lWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: AppColors.accentColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
