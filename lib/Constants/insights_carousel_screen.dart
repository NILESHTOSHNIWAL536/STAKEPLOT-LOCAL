import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';


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
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: Column(
          children: [

            // ─────────── Carousel Pages ───────────
          
Expanded(
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
    
        // CARD AREA
        Center(
          child: SizedBox(
            height: 520,
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
        ),
    
        const SizedBox(height: 12),
    
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
            ? const Color(0xff494972)
            : Colors.grey.shade400,
      ),
    );
  }),
),

      ],
    ),
  ),
),

      

          
          ],    
         ),
     ) );
    
  }

  // ─────────── CARD 1 ───────────
  Widget highestSpendingMonthCard() {
  return Container(
    height:400,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// TITLE
        Text(
          "Highest spending month",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.accentColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        /// MONTH NAME
        Padding(
          padding: const EdgeInsets.only(top:20),
          child: const Text(
            "January",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:AppColors.primaryColor,
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// BAR GRAPH (Dummy UI like image)
        SizedBox(
          height: 120,
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

        const SizedBox(height: 25),

        /// SUBTEXT
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            "You have spent 18% more than your monthly average spending in this month.",
            style: TextStyle(fontSize: 14, color: Colors.black54,height: 1.4),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 25),

        

        /// NEXT BUTTON
        Padding(
          padding: const EdgeInsets.only(top:18),
          child: SizedBox(
            width: double.infinity,
            height:50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:AppColors.primaryColor,
                foregroundColor: Colors.white,
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
          
              child: const Text("Next", style: TextStyle(fontSize: 16,),),
            ),
          ),
        )
      ],
    ),
  );
}
Widget bar(double height, bool active) {
  return Container(
    width: 26,
    height: height,
    decoration: BoxDecoration(
      color: active ? const Color(0xff494972) : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

 
  // ─────────── CARD 2 ───────────
  Widget topCategoriesCard() {
  return Container(
    height: 420,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        /// TITLE
        Padding(
          padding: const EdgeInsets.only(top:10),
          child: Text(
            "Top 3 spending categories",
                 style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.accentColor,
          ),
          
          ),
        ),

        const SizedBox(height: 22),

        /// CATEGORY TILES
        Padding(
          padding: const EdgeInsets.only(top:10),
          child: categoryRow(
            icon: Icons.shopping_basket_outlined,
            title: "Groceries",
            progress: 0.65,
          ),
        ),
        const SizedBox(height: 14),

        categoryRow(
          icon: Icons.directions_car_outlined,
          title: "Transport",
          progress: 0.55,
        ),
        const SizedBox(height: 14),

        categoryRow(
          icon: Icons.movie_outlined,
          title: "Entertainment",
          progress: 0.45,
        ),
        

        const SizedBox(height: 20),

        /// FOOTER TEXT
        const Text(
          "Together they makeup 50% of total spends.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),

        const Spacer(),

        /// NEXT BUTTON
        Padding(
          padding: const EdgeInsets.only(bottom:8),
          child: SizedBox(
            width: double.infinity,
                 height:50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white, // font color
                padding: const EdgeInsets.symmetric(vertical: 14),
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
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        
      ],
    ),
  );
  
}
Widget categoryRow({
  required IconData icon,
  required String title,
  required double progress,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    height: 65,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Color(0xFF979496)),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primaryColor),
        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.accentColor,
            ),
          ),
        ),

        SizedBox(
          width: 70,
        
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xff494972)),
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
    height: 420,
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [

        /// TITLE
        const Text(
          "Most active spending day",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xff2C2C54),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 30),

        /// CALENDAR IMAGE (SVG PLACEHOLDER)
     SizedBox(
  height: 153,
  width: 153,
  child: Image.asset(
    'assets/icons/financeScreen/calender.svg',
    fit: BoxFit.contain,
  ),
),

    const SizedBox(height: 16),

        /// DAY TEXT
        const Text(
          "Friday",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff2C2C54),
          ),
        ),

        const SizedBox(height: 14),

        /// DESCRIPTION
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "This is your peak-spend day.\n"
            "Set a reserve now—and take control\n"
            "before it takes over.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),

        const Spacer(),

        /// BUTTONS
        Row(
          children: [
            // Expanded(
            //   child: OutlinedButton(
            //     style: OutlinedButton.styleFrom(
            //       foregroundColor: AppColors.primaryColor,
            //       side: BorderSide(color: AppColors.primaryColor),
            //       padding: const EdgeInsets.symmetric(vertical: 14),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(14),
            //       ),
            //     ),
            //     onPressed: () {},
            //     child: const Text(
            //       "Skip",
            //       style: TextStyle(fontWeight: FontWeight.w600),
            //     ),
            //   ),
            // ),



            Expanded(
  child: OutlinedButton(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryColor,
      side: BorderSide(color: AppColors.primaryColor),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
     onPressed: () {},
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => HomePage(),
    //     ),
    //   );
    // },
    child: const Text(
      "Skip",
      style: TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
),

            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Setup",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// FOOTER TEXT
        const Text(
          "Get +5 strides on achieving it.",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xff6B6B8E),
          ),
        ),
      ],
    ),
  );
}
}