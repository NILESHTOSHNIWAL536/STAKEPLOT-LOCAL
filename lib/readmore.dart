// import "package:flutter/material.dart";
// import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
// import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
// import "package:readmore/readmore.dart";

// class Readmore extends StatelessWidget {
//   String str;
//   String tName;
//   Readmore({Key? key, required this.str,required this.tName}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(
//           height: 6,
//         ),
//         ReadMoreText(
//           tName.toString() +""+str.toString(),
//           style: FontManager().getTextStyle(context,
//               lWeight: FontWeight.w500,
//               fontSize: 14,
//               lineHeight: 1.2, // Approximating line-height: normal
//             letterSpacing: 0.24,
//               color: AppColors.accentColor),
//           trimMode: TrimMode.Line,
//           trimLines: 2,
//           colorClickableText: AppColors.accentColor,
//           trimCollapsedText: 'Show more',
//           trimExpandedText: 'Show less',
//           moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//           lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(
//           height: 6,
//         ),
//       ],
//     );
//   }
// }

import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";

class Readmore extends StatefulWidget {
  final String str;
  final String tName;

  const Readmore({Key? key, required this.str, required this.tName}) : super(key: key);

  @override
  _ReadmoreState createState() => _ReadmoreState();
}

class _ReadmoreState extends State<Readmore> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const int trimLines = 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            // Create TextSpan for rich text
            final textSpan = TextSpan(
              children: [
                TextSpan(
                  text: "${widget.tName}" +" ",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.bg1,
                  ),
                ),
                TextSpan(
                  text: "${widget.str}",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.accentColor,
                    lineHeight: 1.2, // Approximating line-height: normal
            letterSpacing: 0.24,

                  ),
                ),
              ],
            );

            // Create a TextPainter to measure text
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
              maxLines: isExpanded ? null : trimLines,
              ellipsis: '...',
            )..layout(maxWidth: constraints.maxWidth);

            final isOverflowing = textPainter.didExceedMaxLines;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               RichText(
                  text: textSpan,
                  maxLines: isExpanded ? null : trimLines,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (isOverflowing && !isExpanded)
                  GestureDetector(
                    onTap: () => setState(() => isExpanded = true),
                    child: Text(
                      'Show more',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
                if (isExpanded)
                  GestureDetector(
                    onTap: () => setState(() => isExpanded = false),
                    child: Text(
                      'Show less',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}