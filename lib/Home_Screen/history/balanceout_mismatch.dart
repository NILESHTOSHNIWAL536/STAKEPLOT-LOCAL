import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/balanceout.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:get/get.dart';

class GetMisMatchSlider extends StatefulWidget {
   BuildContext parentContext;
   List<TransactionModel> transactions;
   bool isValid;
   double netAmount;
   bool isAlreadyIncluded;
   String id;

   GetMisMatchSlider({super.key,required this.parentContext,required this.id,required this.isAlreadyIncluded,required this.isValid,required this.netAmount,required this.transactions});

  @override
  State<GetMisMatchSlider> createState() => _GetMisMatchSliderState();
}

class _GetMisMatchSliderState extends State<GetMisMatchSlider> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  

  @override
  Widget build(BuildContext context) {

    final List<Widget> slides =  [
       Column(
        children: [
          getListOfTransactions(widget.parentContext, widget.transactions, widget.isValid, widget. netAmount, widget. isAlreadyIncluded, widget. id),
          BalanceOutMismatchUI(),
        ]),
       BalanceOutExample(),
  ];

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height/1.7,
          width: MediaQuery.of(context).size.width,
          child: PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: slides[index],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentPage == index ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: currentPage == index
                    ? Colors.deepOrange
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}




class BalanceOutExample extends StatelessWidget {
  BalanceOutExample({super.key});
  final fontManager = FontManager();

  @override
  Widget build(BuildContext context) {

   return Container(
     child: getExample(context),
   );

  }


  Widget getExample(context){
    return ListView(
      // mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          const SizedBox(height: 15),
              Text(
                "💡 Example:",
                style: fontManager.getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ..._buildExampleLines(context),
      ],
    );
  }

  List<Widget> _buildExampleLines(BuildContext context) {
    return [
      _exampleLine(context, "You selected these:"),
      // const SizedBox(height: 10),
      _exampleLine(context, "+₹1000 credit"),
      _exampleLine(context, "-₹800 debit"),
      _exampleLine(context, "-₹200 debit"),
      _exampleLine(context, "+₹500 credit"),
      const SizedBox(height: 15),
      _exampleLine(context, "✅ If ₹1000 is the highest, then ₹800 + ₹200 = ₹1000 → Valid, Balanced Amount = 500",
          color: AppColors.creditColor),
      _exampleLine(context, "❌  If value excluded then the highest amount → Doesn't balance",
          color: AppColors.debitColor),
    ];
  }

  Widget _exampleLine(BuildContext context, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        text,
        style: fontManager.getTextStyle(
          context,
          lWeight: FontWeight.w400,
          fontSize: 14,
          lineHeight: 1.2,
          color: color ?? AppColors.now,
        ),
      ),
    );
  }

}
class BalanceOutMismatchUI extends StatelessWidget {
  BalanceOutMismatchUI({super.key});
  final fontManager = FontManager();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
   

    return Container(
      // color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child:  GetDeis(context),
        ),
      ),
    );
  }

  Widget GetDeis(context)
  {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Oops! The shared amounts don't add up correctly.",
                style: fontManager.getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Colorcodes.redDeleteIcon.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "In Balance Out, the highest amount selected is considered the main transaction. The rest of the amounts must add up exactly to it.",
                style: fontManager.getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "👉 Please review and enter values that add up correctly.",
                style: fontManager.getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Colors.deepOrange,
                ),
              ),
 
            ],
          );
  }


  
}

