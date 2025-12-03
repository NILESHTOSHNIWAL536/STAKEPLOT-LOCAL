import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:intl/intl.dart';

class DateRangeField extends StatelessWidget {
  const DateRangeField({Key? key}) : super(key: key);

  Future<void> _selectCupertinoDate(
      BuildContext context, TextEditingController controller) async {
    DateTime tempPickedDate = DateTime.now();

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.backgroundColor,
          ),
          child: Column(
            children: [
              // ✅ Action row with Cancel & Done
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Text(
                      "Cancel",
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: Text(
                      "Done ✅",
                    ),
                    onPressed: () {
                      controller.text =
                          DateFormat('yyyy/MM/dd').format(tempPickedDate);

                      if (checkRangeofDate(context)) {
                        onChanedAutoTransactionStatus(context);
                      }

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Divider(height: 0),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  minimumDate: DateTime(2024),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colorcodes.white,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: startDateController,
                  readOnly: true,
                  onTap: () =>
                      _selectCupertinoDate(context, startDateController),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    hintText: 'Start date (yyyy/mm/dd)',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 2,
                color: Colors.grey[300],
              ),
              Expanded(
                child: TextField(
                  controller: endDateController,
                  readOnly: true,
                  onTap: () => _selectCupertinoDate(context, endDateController),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    hintText: 'End date (yyyy/mm/dd)',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
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
