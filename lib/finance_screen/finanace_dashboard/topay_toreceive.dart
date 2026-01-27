


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/finanace_dashboard/pending_users.dart';
import 'package:get/get.dart';

import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Utils/plotFinanceStringsPage.dart';
import '../../backed_connections/apis_connect.dart';
import 'cardBuilders.dart';

class TopayToreceive extends StatelessWidget {
const TopayToreceive({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
  return   Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserListScreen(isPayable: false),
                    ),
                  );
                },
                child: Obx(() => CardBuilders.buildSummaryCard(
                      context,
                      PlotFinanceStaticData().toReceive,
                      lendAmountRemainders,
                      AppColors.primaryColor,
                    )),
              ),
            ),
             SizedBox(width: AppSizes.w16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserListScreen(isPayable: true),
                    ),
                  );
                },
                child: Obx(() => CardBuilders.buildSummaryCard(
                      context,
                     PlotFinanceStaticData().toPay,
                      dueAmountRemainders,
                      const Color.fromARGB(255, 186, 69, 63),
                    )),
              ),
            ),
          ],
        );
  }
}