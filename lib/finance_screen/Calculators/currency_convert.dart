import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
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
  final TextEditingController searchController = TextEditingController();
  String result = "";
  bool isLoading = false;
  bool isFetchingCurrencies = true;
  List<String> recentConversions = [];
  List<MapEntry<String, String>> filteredCurrencies = [];
  bool _isDialogOpen =
      false; // Track dialog state to prevent multiple instances

  @override
  void initState() {
    super.initState();
    fetchCurrencies();
    loadPreferences();
    searchController.addListener(_filterCurrencies);
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentConversions = prefs.getStringList('recentConversions') ?? [];
    });
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentConversions', recentConversions);
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
          filteredCurrencies = currencies.entries.toList();
          isFetchingCurrencies = false;
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

  void _filterCurrencies() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCurrencies = currencies.entries
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
        // final date = data["date"];

        setState(() {
          result =
              "$amount ${baseCurrency!.toUpperCase()} = ${converted.toStringAsFixed(2)} ${targetCurrency!.toUpperCase()}";
          recentConversions.insert(0,
              "$amount ${baseCurrency!.toUpperCase()} → ${converted.toStringAsFixed(2)} ${targetCurrency!.toUpperCase()} ");
          if (recentConversions.length > 3) recentConversions.removeLast();
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
      final temp = baseCurrency;
      baseCurrency = targetCurrency;
      targetCurrency = temp;
    });
    savePreferences();
  }

  void _showSnackBar(String message) {
    snackBarCalledfail(context, message);
  }

  // Custom dialog for searchable currency selection
  Future<void> _showCurrencyPickerDialog(
      BuildContext context, bool isBaseCurrency) async {
    if (_isDialogOpen) return; // Prevent multiple dialogs
    _isDialogOpen = true;

    TextEditingController dialogSearchController = TextEditingController();
    List<MapEntry<String, String>> dialogFilteredCurrencies =
        currencies.entries.toList();

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                isBaseCurrency
                    ? "Select Base Currency"
                    : "Select Target Currency",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.primaryColor,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: dialogSearchController,
                      decoration: InputDecoration(
                        hintText: "Search currency...",
                        hintStyle: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.normal,
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          dialogFilteredCurrencies = currencies.entries
                              .where((entry) =>
                                  entry.key
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  entry.value
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height / 3,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: dialogFilteredCurrencies.length,
                        itemBuilder: (context, index) {
                          final entry = dialogFilteredCurrencies[index];
                          return ListTile(
                            title: Text(
                              "${entry.key.toUpperCase()} - ${entry.value}",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.normal,
                                fontSize: 14,
                                color: AppColors.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              setState(() {
                                if (isBaseCurrency) {
                                  baseCurrency = entry.key;
                                } else {
                                  targetCurrency = entry.key;
                                }
                                savePreferences();
                              });
                              Navigator.pop(dialogContext);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    "Cancel",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.normal,
                      fontSize: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      _isDialogOpen = false; // Reset dialog state
      // dialogSearchController.dispose(); // Dispose controller after dialog closes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: isFetchingCurrencies
            ? Spinner()
            : SingleChildScrollView(
                child: Padding(
                  
                  padding: const EdgeInsets.symmetric(vertical: 22,horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      const SizedBox(height: 24),
                      Container(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: AppColors.backgroundColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Text(
                                "Currency Converter",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AvatarProfileImageZero(
                                url: 'assets/icons/financeScreen/currency.svg',
                                width: 1,
                                height: 1.5
                            ),
                  
                            Container(
                              width: MediaQuery.sizeOf(context).width * 0.8,
                              padding: const EdgeInsets.all(16),
                              // decoration: BoxDecoration(
                              //  color: Color(0xFF60628C),
                              //   borderRadius: BorderRadius.circular(16),
                              //   border: Border.all(color: AppColors.backgroundColor),
                              //   boxShadow: [
                              //     BoxShadow(
                              //       color: Colors.grey.withOpacity(0.1),
                              //       spreadRadius: 2,
                              //       blurRadius: 8,
                              //       offset: const Offset(0, 2),
                              //     ),
                              //   ],
                              // ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Base Currency Picker
                                  Text(
                                    "Base Currency",
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.normal,
                                      fontSize: 14,
                                      color: Colors
                                          .white, // Adjust color to match your theme
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  InkWell(
                                    onTap: () =>
                                        _showCurrencyPickerDialog(context, true),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor:
                                            Color.fromRGBO(255, 255, 255, 0.23),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 4),
                                      ),
                                      child: Text(
                                        baseCurrency != null
                                            ? "${baseCurrency!.toUpperCase()} - ${currencies[baseCurrency] ?? ''}"
                                            : "From Currency",
                                        style: FontManager().getTextStyle(
                                          context,
                                          lWeight: FontWeight.normal,
                                          fontSize: 14,
                                          color: baseCurrency != null
                                              ? AppColors.primaryColor
                                              : AppColors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Swap Button
                                  Center(
                                    child: GestureDetector(
                                      onTap: swapCurrencies,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            // shape: BoxShape.circle,
                                            // color: AppColors.primaryColor,
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: Colors.grey.withOpacity(0.2),
                                            //     spreadRadius: 1,
                                            //     blurRadius: 4,
                                            //     offset: const Offset(0, 2),
                                            //   ),
                                            // ],
                                            ),
                                        child: const Icon(
                                          Icons.swap_vert,
                                          color: Colors.white,
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
                                      color: Colors
                                          .white, // Adjust color to match your theme
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Target Currency Picker
                                  InkWell(
                                    onTap: () =>
                                        _showCurrencyPickerDialog(context, false),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor:
                                            Color.fromRGBO(255, 255, 255, 0.23),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 4),
                                      ),
                                      child: Text(
                                        targetCurrency != null
                                            ? "${targetCurrency!.toUpperCase()} - ${currencies[targetCurrency] ?? ''}"
                                            : "To Currency",
                                        style: FontManager().getTextStyle(
                                          context,
                                          lWeight: FontWeight.normal,
                                          fontSize: 14,
                                          color: targetCurrency != null
                                              ? AppColors.primaryColor
                                              : AppColors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Amount",
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.normal,
                                      fontSize: 14,
                                      color: Colors
                                          .white, // Adjust color to match your theme
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Amount Field
                                  TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          Color.fromRGBO(255, 255, 255, 0.23),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      errorText:
                                          amountController.text.isNotEmpty &&
                                                  double.tryParse(amountController
                                                          .text
                                                          .trim()) ==
                                                      null
                                              ? "Invalid number"
                                              : null,
                                    ),
                                    onChanged: (value) => setState(() {}),
                                  ),
                                  const SizedBox(height: 20),
                                  // Convert Button
                  
                                  // Inside the Column within the build method's Container
                                  if (result.isNotEmpty)
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(255, 255, 255, 0.23),
                                        ),
                                        child: Text(
                                          result,
                                          style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: AppColors.backgroundColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                  // Result Display
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: isLoading ||
                                              baseCurrency == null ||
                                              targetCurrency == null ||
                                              amountController.text
                                                  .trim()
                                                  .isEmpty ||
                                              double.tryParse(amountController
                                                      .text
                                                      .trim()) ==
                                                  null
                                          ? null
                                          : convertCurrency,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 12),
                                        backgroundColor:
                                            AppColors.backgroundColor,
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
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                    ),
                                  ),
                  
                                  if (recentConversions.isNotEmpty)
                                    Container(
                                      decoration: BoxDecoration(
                                        // color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Recent Conversions",
                                            style: FontManager().getTextStyle(
                                              context,
                                              lWeight: FontWeight.normal,
                                              fontSize: 14,
                                              color: AppColors.backgroundColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...recentConversions
                                              .map((conversion) => Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4,
                                                        horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 0.23),
                                                    ),
                                                    child: Text(
                                                      conversion,
                                                      style: FontManager()
                                                          .getTextStyle(
                                                        context,
                                                        lWeight:
                                                            FontWeight.normal,
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .backgroundColor,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                  
                            const SizedBox(height: 24),
                            // Recent Conversions
                          ],
                        ),
                      ),
                    ]),
                )));
  }

  // @override
  // void dispose() {
  //   // Avoid calling setState in dispose
  //   clearPreferences();
  //   amountController.dispose();
  //   searchController.dispose();
  //   super.dispose();
  // }
}
