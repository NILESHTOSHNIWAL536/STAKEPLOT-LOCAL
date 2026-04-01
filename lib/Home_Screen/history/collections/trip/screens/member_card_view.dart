import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Constants/colors.dart';
import '../../../../../Constants/font_manager.dart';
import '../../../../../backed_connections/apis_connect.dart';
import '../../../../../model/collections_model.dart';


class BalanceStatusWidget extends StatelessWidget {
  const BalanceStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (collectionsController.isBalanceLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final toPay = collectionsController.balancesList
          .where((e) => e.type == "toPay")
          .toList();

      final toReceive = collectionsController.balancesList
          .where((e) => e.type == "toReceive")
          .toList();

      if (toPay.isEmpty && toReceive.isEmpty) {
        return Center(
          child: Text(
            "No balances available",
            style: FontManager().getTextStyle(
              context,
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            Text(
              "Balance Status",
              style: FontManager().getTextStyle(
                context,
                fontSize: 16,
                lWeight: FontWeight.w700,
                color: AppColors.accentColor,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                /// 🔴 TO PAY
                Expanded(
                  child: _balanceCard(
                    context,
                    title: "To Pay",
                    list: toPay,
                    isPay: true,
                  ),
                ),

                const SizedBox(width: 10),

                /// 🟢 TO RECEIVE
                Expanded(
                  child: _balanceCard(
                    context,
                    title: "To Receive",
                    list: toReceive,
                    isPay: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// 🔥 BALANCE CARD
  Widget _balanceCard(
    BuildContext context, {
    required String title,
    required List<BalanceModel> list,
    required bool isPay,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [
              Icon(
                isPay ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPay ? Colors.red : Colors.green,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 13,
                  lWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// EMPTY STATE
          if (list.isEmpty)
            Text(
              "No data",
              style: FontManager().getTextStyle(
                context,
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),

          /// LIST
          ...list.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPay
                    ? Colors.red.withOpacity(0.08)
                    : Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [

                  /// AVATAR
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _getColorFromHex(
                        item.user?.avatarBackGround),
                    child: Text(
                      item.user?.name
                              .substring(0, 1)
                              .toUpperCase() ??
                          "U",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// NAME
                  Expanded(
                    child: Text(
                      item.user?.name ?? "",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 13,
                        lWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  /// AMOUNT
                  Text(
                    "₹${item.amount.toStringAsFixed(0)}",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 13,
                      lWeight: FontWeight.w600,
                      color: isPay ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 🎨 HEX COLOR → COLOR
  Color _getColorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blueGrey;

    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }
}