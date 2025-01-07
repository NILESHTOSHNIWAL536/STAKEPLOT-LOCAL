import 'package:flutter/material.dart';
//import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NumberPickerController extends GetxController {
  // Reactive variables for the digits
  var firstDigit = 0.obs;
  var secondDigit = 0.obs;
}

class NumberPickerScreen extends StatelessWidget {
  final NumberPickerController controller = Get.put(NumberPickerController());
  Future<Map<String, dynamic>> fetchBankAccountData() async {
    try {
      final response = await http
          .get(Uri.parse('https://your-api-url.com/api/bank_account'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'accountName': data['accountName'],
          'availableBalance': data['availableBalance'],
        };
      } else {
        throw Exception('Failed to load bank account data');
      }
    } catch (e) {
      return {
        'accountName': 'Bank name',
        'availableBalance': 0.0,
      };
    }
  }

  //int _selectedIndex = 0;

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: AppColors.accentColor,
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.accentColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchBankAccountData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }
            final data = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['accountName'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Available Balance',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\u{20B9}${data['availableBalance'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          //crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              // decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.circular(16),
                              //     color: Colors.grey),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // First Digit Picker
                                  SizedBox(
                                    width: 70, // Width of the first picker
                                    height: 110, // Height of the picker
                                    child: CupertinoPicker(
                                      itemExtent: 30, // Height of each item
                                      onSelectedItemChanged: (index) {
                                        controller.firstDigit.value =
                                            index; // Update using GetX
                                      },
                                      children: List<Widget>.generate(
                                        10,
                                        (index) => Center(
                                          child: Text(
                                            index.toString(),
                                            style: TextStyle(
                                                fontSize: 18,
                                                color:
                                                    AppColors.backgroundColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                  // Spacer between pickers
                                  // Second Digit Picker
                                  SizedBox(
                                    width: 70, // Width of the second picker
                                    height: 110, // Height of the picker
                                    child: CupertinoPicker(
                                      itemExtent: 30, // Height of each item
                                      onSelectedItemChanged: (index) {
                                        controller.secondDigit.value =
                                            index; // Update using GetX
                                      },
                                      children: List<Widget>.generate(
                                        10,
                                        (index) => Center(
                                            child: Text(
                                          index.toString(),
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: AppColors.backgroundColor),
                                        )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Obx(
                              // Reactive widget for displaying the selected number
                              () => Text(
                                "Selected: ${controller.firstDigit.value}${controller.secondDigit.value}",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.backgroundColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
