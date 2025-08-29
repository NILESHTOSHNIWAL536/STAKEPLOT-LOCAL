import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> showBudgetDebtCreditCard(BuildContext context2) async {
  int selectedIndex = 0;
  final List<String> titles = ["Credit Card", "Create Budget", "Add Debt"];
  final List<String> svgs =
   [
         svgIconPath.dio1,
         svgIconPath.dio2,
         svgIconPath.dio3,
     ];

  await showDialog(
    context: context2,
    barrierDismissible: false,
    builder: (context) {
      final width = MediaQuery.of(context).size.width;
      final isMobile = width < 450;

      return Center(
        child: SingleChildScrollView(
          child: Dialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 18 : 32,
                    horizontal: isMobile ? 10 : 45,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            
                            Text(
                              "select any option",
                              style: TextStyle(
                                color: Color(0xFF686888),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: Icon(Icons.close, color: Color(0xFF8A7FA7), size: 20)),
                        
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      Container(
  width: MediaQuery.of(context).size.width / 1.1,
  height: 90,
  child: ListView(
    scrollDirection: Axis.horizontal,
    // mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(3, (i) {
      final isActive = selectedIndex == i;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 7.0), // Even spacing
        child: SizedBox(
          width: 125, // Fixed width like the image
          height: 90,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  isActive ? Color(0xFF635D8F) : Colors.white),
              side: MaterialStateProperty.all(BorderSide(
                color: isActive ? Color(0xFF635D8F) : Color(0xFFDEDDF2),
                width: 2,
              )),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              )),
              overlayColor: MaterialStateProperty.all(Color(0xFFE0DDF7)),
              padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(vertical: 8, horizontal: 1)),
            ),
            onPressed: () => setState(() => selectedIndex = i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Use your icon/image, sample below:
                AvatarProfileImage(
                  url: svgs[i],
                  width: 24,
                  height: 24,
                ),
                SizedBox(height: 5),
                Text(
                  titles[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: isActive ? Colors.white : Color(0xFF474575),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }),
  ),
),
                      SizedBox(height: 40),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        // height: 45,
                        width: MediaQuery.of(context).size.width/3,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF635D8F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onPressed: () {
                            String options="";

                                if(selectedIndex==0)
                                {
                                    options="/addcreditCard";
                                }
                                else if(selectedIndex== 1)
                                {
                                    options="/Budget";
                                }else{
                                    options="/debt";
                                }
                              
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context2, "/FinanceDashboard");
                              Navigator.pushNamed(context2, options);
                               
                          },
                          child: Text("Done"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
