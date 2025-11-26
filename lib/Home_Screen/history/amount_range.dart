import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/helper.dart';

class AmountRangeField extends StatelessWidget {
  const AmountRangeField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colorcodes.white,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: TextField(
                controller: minController,
                inputFormatters: allowDecimalInput(),
                // keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                // keyboardType: TextInputType.numberWithOptions(
                //     signed: true, decimal: true),
                // inputFormatters: <TextInputFormatter>[
                //   FilteringTextInputFormatter.digitsOnly,
                // ],

                // textInputAction: TextInputAction.done,

                onSubmitted: (c) {
                  if (checkRangeofAmount(context)) {
                    onChanedAutoTransactionStatus(context);
                  }
                },
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  hintText: 'Enter min amount',
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
                ),
              ),
            ),
            // Spacer or line between fields
            Container(
              width: 24,
              height: 2,
              color: Colors.grey[300],
            ),
            // Second TextField
            Expanded(
              child: TextField(
                controller: maxController,
                inputFormatters: allowDecimalInput(),
                onSubmitted: (c) {
                  if (checkRangeofAmount(context)) {
                    onChanedAutoTransactionStatus(context);
                  }
                },
                textInputAction: TextInputAction.done,
                // keyboardType: TextInputType.numberWithOptions(
                //     signed: true, decimal: true),
                // inputFormatters: <TextInputFormatter>[
                //   FilteringTextInputFormatter.digitsOnly,
                // ],

                // keyboardType: TextInputType.number,
                // textInputAction: TextInputAction.done,

                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  hintText: 'Enter max amount',
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
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:keyboard_actions/keyboard_actions.dart';

// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/routes.dart';

// import '../../backed_connections/apis_connect.dart';
// import '../helper.dart';

// class AmountRangeField extends StatelessWidget {
//   AmountRangeField({Key? key}) : super(key: key);

//   final FocusNode _minFocusNode = FocusNode();
//   final FocusNode _maxFocusNode = FocusNode();

//   KeyboardActionsConfig _keyboardActionsConfig(BuildContext context) {
//     return KeyboardActionsConfig(
//       keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
//       keyboardBarColor: const Color(0xFFCAD1D9), // Apple-like toolbar color
//       actions: [
//         KeyboardActionsItem(
//           focusNode: _minFocusNode,
//           toolbarButtons: [
//             (node) => _buildDoneButton(context, node),
//           ],
//         ),
//         KeyboardActionsItem(
//           focusNode: _maxFocusNode,
//           toolbarButtons: [
//             (node) => _buildDoneButton(context, node),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildDoneButton(BuildContext context, FocusNode node) {
//     return GestureDetector(
//       onTap: () {
//         node.unfocus(); // Hide keyboard
//         if (checkRangeofAmount(context)) {
//           onChanedAutoTransactionStatus(context);
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12.0),
//         child: const Text(
//           "Done",
//           style: TextStyle(
//             color: Color(0xFF0978ED), // Done button color
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       color: Colorcodes.white,
//       child: Center(
//         child: Container(
//           width: MediaQuery.of(context).size.width / 1.1,
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
//           child: KeyboardActions(
//             config: _keyboardActionsConfig(context),
//             disableScroll: true,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Min Amount Field
//                 Expanded(
//                   child: TextField(
//                     controller: minController,
//                     focusNode: _minFocusNode,
//                     keyboardType: TextInputType.number,
//                     textInputAction: TextInputAction.done,
//                     onSubmitted: (c) {
//                       if (checkRangeofAmount(context)) {
//                         onChanedAutoTransactionStatus(context);
//                       }
//                     },
//                     decoration: InputDecoration(
//                       contentPadding:
//                           const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                       hintText: 'Enter min amount',
//                       filled: true,
//                       fillColor: Colors.grey[100],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide.none,
//                       ),
//                       hintStyle: const TextStyle(fontSize: 13),
//                     ),
//                   ),
//                 ),
//                 // Spacer/line
//                 Container(
//                   width: 24,
//                   height: 2,
//                   color: Colors.grey[300],
//                 ),
//                 // Max Amount Field
//                 Expanded(
//                   child: TextField(
//                     controller: maxController,
//                     focusNode: _maxFocusNode,
//                     keyboardType: TextInputType.number,
//                     textInputAction: TextInputAction.done,
//                     onSubmitted: (c) {
//                       if (checkRangeofAmount(context)) {
//                         onChanedAutoTransactionStatus(context);
//                       }
//                     },
//                     decoration: InputDecoration(
//                       contentPadding:
//                           const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                       hintText: 'Enter max amount',
//                       filled: true,
//                       fillColor: Colors.grey[100],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide.none,
//                       ),
//                       hintStyle: const TextStyle(fontSize: 13),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
