import 'package:flutter/material.dart';

import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';
import '../../Constants/colorcodes.dart';
import '../message.dart';

Widget spliDisplay(msg, bool, url, Message message, BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      spliData(message, context),
    ],
  );
}

Widget spliData(Message message, BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(AppSizes.p10),
    width: MediaQuery.of(context).size.width / 1.8,
    decoration: BoxDecoration(
      color: message.isMe ? AppColors.appIcon : AppColors.mt,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16), // Circular radius for top left
        topRight: Radius.circular(16), // Circular radius for top right
        bottomLeft: message.isMe
            ? Radius.circular(16)
            : Radius
                .zero, // Circular radius for bottom left (for other messages)
        bottomRight: message.isMe
            ? Radius.zero
            : Radius.circular(
                16), // No radius for bottom right (for my messages)
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.receipt,
                color: message.isMe
                    ? AppColors.backgroundColor
                    : AppColors.appIcon,
                size: 24),
            SizedBox(width: AppSizes.w10),
            Text(
              message.split['BillName'],
              style: FontManager().getTextStyle(
                context,
                fontSize: 16,
                lWeight: FontWeight.bold,
                color: message.isMe ? AppColors.backgroundColor : AppColors.bg1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.h3),
        Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "₹", // Rupee symbol
                  style: FontManager().getTextStyle(context,
                      color: message.isMe
                          ? AppColors.backgroundColor
                          : AppColors.bg2,
                      fontSize: 16),
                ),
                SizedBox(width: AppSizes.w5),
                Text(
                  "Total expense: " +
                      doubleToFixed(message.split['Amount'].toString()),
                  style: FontManager().getTextStyle(context,
                      fontSize: 12,
                      color: message.isMe
                          ? AppColors.backgroundColor
                          : AppColors.bg2),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.group,
                    color: message.isMe
                        ? AppColors.backgroundColor
                        : AppColors.appIcon,
                    size: 20),
                SizedBox(width: AppSizes.w5),
                Text(
                  "Share: " +
                      doubleToFixed(message.split['Share'].toString())
                          .toString(),
                  style: FontManager().getTextStyle(context,
                      fontSize: 12,
                      color: message.isMe
                          ? AppColors.backgroundColor
                          : AppColors.bg2),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: AppSizes.h5),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.p6),
          child: Row(
            children: [
              Icon(
                message.split['isPaid'] ? Icons.check_circle : Icons.pending,
                color:
                    message.split['isPaid'] ? Colors.green : AppColors.redColor,
                size: 20,
              ),
              SizedBox(width: AppSizes.w5),
              Text(
                message.split['isPaid'] ? "Settled Successfully" : "Pending",
                style: FontManager().getTextStyle(context,
                    fontSize: 12,
                    lWeight: FontWeight.w400,
                    color: message.split['isPaid']
                        ? Colors.green
                        : AppColors.redColor),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
