import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:intl/intl.dart';
import '../../repository/transactions_repository.dart';

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
          height: MediaQuery.sizeOf(context).height/3,
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
                    child: const Text(
                      "Cancel",
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text(
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
              SizedBox(
                height: MediaQuery.sizeOf(context).height/4,
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
  // Future<void> _selectCupertinoDate(
  //     BuildContext context, TextEditingController controller) async {
  //   DateTime tempPickedDate = DateTime.now();

  //   await showModalBottomSheet(
  //     context: context,
  //     backgroundColor: AppColors.backgroundColor,
  //     builder: (BuildContext builder) {
  //       return Container(
  //         height: MediaQuery.sizeOf(context).height/3,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(12),
  //           color: AppColors.backgroundColor,
  //         ),
  //         child: Column(
  //           children: [
  //             // ✅ Action row with Cancel & Done
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 TextButton(
  //                   child: Text(
  //                     "Cancel",
  //                   ),
  //                   onPressed: () => Navigator.pop(context),
  //                 ),
  //                 TextButton(
  //                   child: Text(
  //                     "Done ✅",
  //                   ),
  //                   onPressed: () {
  //                     controller.text =
  //                         DateFormat('yyyy/MM/dd').format(tempPickedDate);

  //                     if (checkRangeofDate(context)) {
  //                       onChanedAutoTransactionStatus(context);
  //                     }

  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //               ],
  //             ),
  //             const Divider(height: 0),
  //             Container(
  //               height: MediaQuery.sizeOf(context).height/4,
  //               child: CupertinoDatePicker(
  //                 mode: CupertinoDatePickerMode.date,
  //                 initialDateTime: DateTime.now(),
  //                 minimumDate: DateTime(2024),
  //                 maximumDate: DateTime.now(),
  //                 onDateTimeChanged: (DateTime newDate) {
  //                   tempPickedDate = newDate;
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      
      color: AppColors.newbg,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          height: MediaQuery.sizeOf(context).height/24,
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
              
              width: MediaQuery.sizeOf(context).width/2.4,
                child: TextField(
                  controller: startDateController,
                  readOnly: true,
                  onTap: () =>
                      _selectCupertinoDate(context, startDateController),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    hintText: 'Start date',
                    filled: true,
                    fillColor: AppColors.newbg,
                  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 0.8,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 1.2,
    ),
  ),

  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 0.8,
    ),
  ),
                    hintStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                    suffixIcon:  Icon(Icons.calendar_today, size: 18, color: AppColors.grey,),
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 4,
                color: AppColors.filterBorders,
              ),
              SizedBox(
              
              width: MediaQuery.sizeOf(context).width/2.4,
                child: TextField(
                  controller: endDateController,
                  readOnly: true,
                  onTap: () => _selectCupertinoDate(context, endDateController),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    hintText: 'End date',
                    filled: true,
                    fillColor: AppColors.newbg,
                   enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 0.8,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 1.2,
    ),
  ),

  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(
      color: AppColors.filterBorders,
      width: 0.8,
    ),
  ),
                    hintStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                    suffixIcon:  Icon(Icons.calendar_today, size: 18, color: AppColors.grey,),
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
