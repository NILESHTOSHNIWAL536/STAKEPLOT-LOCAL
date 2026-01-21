import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/AdjustAmountScreen.dart';
import '../Home_Screen/home_screen_state/home_page.dart';
import 'package:flutter_application_code_stakeplot/constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';

import 'font_manager.dart';


class InsightsCarouselScreen extends StatefulWidget {
  @override
  _InsightsCarouselScreenState createState() => _InsightsCarouselScreenState();
}
  
class _InsightsCarouselScreenState extends State<InsightsCarouselScreen> {
  PageController controller = PageController();
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
        
          child: Column(
           
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Spacer(),
              // CARD AREA
              SizedBox(
                height: MediaQuery.of(context).size.height *0.65, 
              
                child: PageView(
                  controller: controller,
                  onPageChanged: (index) {
                    setState(() => pageIndex = index);
                  },
                  children: [
              highestSpendingMonthCard(),
              topCategoriesCard(),
              mostActiveDayCard(),
              ],
              
                ),
              ),
          
              Container(
                child: SizedBox(
                height: MediaQuery.of(context).size.height / 66, // ≈ 12px
                ),
              ),
          
          
              // DOT INDICATORS (JUST BELOW CARD)
              Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: pageIndex == index ? 12 : 8,
            height: pageIndex == index ? 12 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pageIndex == index
                  ?  AppColors.primaryColor
                  : Colors.grey,
            ),
          );
          }),
          ),
          
            ],
          ),
        ),
     ) );
    
  }

  // ─────────── CARD 1 ───────────
  Widget highestSpendingMonthCard() {
  return Container(
 height: MediaQuery.of(context).size.height / 2,

    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
     
      mainAxisSize: MainAxisSize.min,
      children: [
        
        /// TITLE
        Padding(
          padding: const EdgeInsets.only(top:10),
          child: Text(
            "Highest spending month",
            style:  FontManager().getTextStyle(context, 
                      fontSize: 24, 
                      color: AppColors.accentColor,
                      lWeight: FontWeight.w600,
                    
                     
                     
                      ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(
  height: MediaQuery.of(context).size.height / 33, // ≈ 24px
),

        /// MONTH NAME
        Padding(
          padding: const EdgeInsets.only(top:20),
          child:  Text(
            "January",
            style:  FontManager().getTextStyle(context, 
                    fontSize: 24, 
                    color: AppColors.primaryColor,
                    lWeight: FontWeight.w600,
            ),
          ),
        ),
SizedBox(
  height: MediaQuery.of(context).size.height / 40, // ≈ 20px
),


        /// BAR GRAPH (Dummy UI like image)
        SizedBox(
         height: MediaQuery.of(context).size.height / 6.6, // ≈ 120px

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              bar(60,false),
              bar(80,false),
              bar(100,false),
              bar(130,true),   // highlighted bar as in image
              bar(95,false),
              bar(85,false),
              bar(60,false),
            ],
          ),
        ),

      SizedBox(
  height: MediaQuery.of(context).size.height / 30, // ≈ 20px
),

        /// SUBTEXT
         Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            "You have spent 18% more than your monthly average spending in this month.",
            style: FontManager().getTextStyle(context, 
                    fontSize: 16, 
                    color: AppColors.grey,
                    lWeight: FontWeight.w400,
            ),
          textAlign: TextAlign.center,
          ),
        ),

      SizedBox(
  height: MediaQuery.of(context).size.height / 40, // ≈ 20px
),

        

        /// NEXT BUTTON
        ///
        Padding(
          padding: const EdgeInsets.only(top:18),
          child: 
          SizedBox(
            width: double.infinity,
          height: MediaQuery.of(context).size.height / 18.5, // ≈ 50px

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:AppColors.primaryColor,
                foregroundColor: AppColors.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
            if (pageIndex < 2) {
              controller.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
          
              child: Text("Next", style:  FontManager().getTextStyle(context, 
                    fontSize: 16, 
                    color: AppColors.backgroundColor,
                    lWeight: FontWeight.w600,
            ),
            ),
          ),
        ))
      ],
    ),
  );
}
Widget bar(double height, bool active) {
  return Container(
   width: MediaQuery.of(context).size.width / 15.5, // ≈ 26px

    height: height,
    decoration: BoxDecoration(
      color: active ? const Color(0xff494972) : AppColors.newgrey,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

 
  // ─────────── CARD 2 ───────────
  Widget topCategoriesCard() {
  return Container(
    height: MediaQuery.of(context).size.height / 2,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
    
        /// TITLE
        Padding(
          padding: const EdgeInsets.only(top:15),
          child: Text(
            "Top 3 spending categories",
                 style: FontManager().getTextStyle(context, 
                    fontSize: 24, 
                    color: AppColors.accentColor,
                    lWeight: FontWeight.w600,
            ),
          
          ),
        ),
    
        const SizedBox(height: 22),
    
        /// CATEGORY TILES
        categoryRow(
        icon: AvatarProfileImageZero(url: Finance.groceries,width:10,height:20),
          title: "Groceries",
          progress: 0.65,
        ),
        const SizedBox(height: 15),
    
        categoryRow(
          icon : AvatarProfileImageZero(url: Finance.transport, width: 10, height: 20),
          title: "Transport",
          progress: 0.55,
        ),
        const SizedBox(height: 15),
    
        categoryRow(
          icon : AvatarProfileImageZero(url:Finance.entertainment, width: 10, height: 20),
          title: "Entertainment",
          progress: 0.45,
        ),
        
    
        const SizedBox(height: 15),
    
        /// FOOTER TEXT
         Text(
          "Together they makeup 50% of total spends.",
          style:  FontManager().getTextStyle(context, 
                    fontSize: 16, 
                    color: AppColors.grey,
                    lWeight: FontWeight.w400,
            ),
        ),
    
        const SizedBox(height:15),
    
        /// NEXT BUTTON
        Padding(
          padding: const EdgeInsets.only(top:10),
          child: SizedBox(
            width: double.infinity,
                         height: MediaQuery.of(context).size.height / 18.5,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.backgroundColor, // font color
             
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                controller.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child:  Text(
                "Next",
                style:FontManager().getTextStyle(context, 
                    fontSize: 16, 
                    color: AppColors.backgroundColor,
                    lWeight: FontWeight.w600,
            ),
            ),
          ),
                  ),
        ),])
  );
  
}
Widget categoryRow({
  required Widget icon,
  required String title,
  required double progress,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    height: MediaQuery.of(context).size.height / 11.5,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.grey),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
      
           icon,
        
        // const SizedBox(width: 20),
    
        Text(
          title,
          style: FontManager().getTextStyle(context, 
                    fontSize: 16, 
                    color: AppColors.primaryColor,
                    lWeight: FontWeight.w400,
            ),
        ),
        // const SizedBox(width: 10),
        
        SizedBox(
              width: MediaQuery.of(context).size.width / 3.7,   // ≈ 108px
              height: MediaQuery.of(context).size.height / 80, // ≈ 10px
        
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.newgrey,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.primaryColor),
            ),
          ),
        ),
      ],
    ),
    );
  
}



  // ─────────── CARD 3 (Scrollable & longer) ───────────
  Widget mostActiveDayCard() {
  return Container(
  height: MediaQuery.of(context).size.height / 2,
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical:20),
      child: Column(
        children: [
      
          /// TITLE
          Text(
            "Most active spending day",
            style:  FontManager().getTextStyle(context, 
                      fontSize: 24, 
                      color: AppColors.accentColor,
                      lWeight: FontWeight.w600,
              ),
            textAlign: TextAlign.center,
          ),
      
          const SizedBox(height: 30),
      
      Container(
       
        width:153,height:153,
        child: AvatarProfileImageZero(
      url: 'assets/icons/financeScreen/calender.svg',
      width: 153, 
      height: 153,
        ),
      ),
      
      const SizedBox(height: 10),
      
          /// DAY TEXT
           Text(
            "Friday",
            style:  FontManager().getTextStyle(context, 
                      fontSize: 24, 
                      color: AppColors.primaryColor,
                      lWeight: FontWeight.w600,
              ),
          ),
      
          const SizedBox(height: 20),
      
          /// DESCRIPTION
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "This is your peak-spend day.\n"
              "Set a reserve now—and take control\n"
              "before it takes over.",
              textAlign: TextAlign.center,
              style: FontManager().getTextStyle(context, 
                      fontSize: 16, 
                      color: AppColors.grey,
                      lWeight: FontWeight.w400,
              ),
            ),
          ),
      
         const SizedBox(height:20),
      
          /// BUTTONS
          Padding(
            padding: const EdgeInsets.only(top:10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
                  SizedBox(
                    
              width: MediaQuery.of(context).size.width / 3.0,   // ≈ 133px
              height: MediaQuery.of(context).size.height / 19.5, // ≈ 43px
            
            
                    child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: BorderSide(color: AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
                    ),
                ),
                onPressed: () {
                    Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>  HomePage(),
            ),
                    );
                },
                child: Text(
                    "Skip",
                    style: FontManager().getTextStyle(context, 
                        fontSize: 16, 
                        color: AppColors.primaryColor,
                        lWeight: FontWeight.w600,
                ),
                ),
                    ),
                  ),
                  
                  
                
               
                
                  
                SizedBox(
                  
              width: MediaQuery.of(context).size.width / 3.0,   // ≈ 133px
              height: MediaQuery.of(context).size.height / 19.5, // ≈ 43px
            
            
                  child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                        ),
                        onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdjustAmountScreen(),
                    ),
                  );
                        },
                        child:  Text(
                  "Setup",
                  style: FontManager().getTextStyle(context, 
                        fontSize: 16, 
                        color: AppColors.backgroundColor,
                        lWeight: FontWeight.w600,
                ),
                        ),
                  ),
                ),
                  
              ],
            ),
          ),
      
          const SizedBox(height: 12),
      
          /// FOOTER TEXT
         Text(
            "Get +5 strides on achieving it.",
            style: FontManager().getTextStyle(context, 
                      fontSize: 12, 
                      color: AppColors.primaryColor,
                      lWeight: FontWeight.w400,
              ),
          ),
        ],
      ),
    ),
  );
}
}