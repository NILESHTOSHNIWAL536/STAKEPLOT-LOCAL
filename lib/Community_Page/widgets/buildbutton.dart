

 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/poll_screen.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Profile/Saved.dart';
import '../../Constants/core/app_padding_sizes.dart';



// Widget buildWelcomeRow(context) {
    
//       final CommunityScreenStrings strings = CommunityScreenStrings();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//          padding: const EdgeInsets.only(left:AppSizes.p10, right:AppSizes.p10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     strings.welcomeBack,
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.w500,
//                         fontSize: 16,
//                         color: AppColors.welcomeBack),
//                   ),
//                   Text(
//                     strings.finspace,
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.w700,
//                         fontSize: 16,
//                         color: AppColors.finSpaceColor),
//                   ),
//                 ],
//               ),
//               Align(
//                 alignment: Alignment.topRight,
//                 child: Row(
//                   children: [
//                     InkWell(
//                       onTap: () {
//                          ismaskedUsers.value=true;
//                          Navigator.pushNamed(context, '/TribeChats');
//                       },
//                       child: AvatarProfileImage(
//                         url: LikeComment.chatMessage,
//                         height: 26,
//                         width: 26,
//                       ),
//                     ),
//                     Container(
                     
//                       child: GestureDetector(
//                         onTap: () async {
//                           navigatorToMyOwnPage(context);
//                         },
//                         child: AvatarProfile2 (
//                           url: ControllerManagement.userController.avatar.value,
//                           width: 9,
//                           height: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 6,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left:AppSizes.p10, right:AppSizes.p10),
//           child: GestureDetector(
//             onTap: () {
//               // Navigator.pushNamed(context, '/TribeSearch');
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => TribeSearch(isMasked: true),
//                 ),
//               );
//             },
//             child: Material(
//               child: Container(
//                 width: MediaQuery.sizeOf(context).width/1.07,
//                 height: MediaQuery.sizeOf(context).width *(32/348),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                     filled: true,
//                     enabled: false,
//                     hintText: strings.searchHint,
//                     fillColor: AppColors.backgroundColor,
//                     hintStyle: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.normal,
//                         fontSize: 14,
//                         color: AppColors.accentColor),
//                     prefixIcon: Icon(Icons.search),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
          
//           ),
//         ),
       
       
//       ],
//     );
//   }


class ArenaHeader extends StatefulWidget {
  final int initialTab; // 0 = Comic, 1 = Polls
  final ValueChanged<int>? onTabChanged;

  const ArenaHeader({
    Key? key,
    this.initialTab = 1,
    this.onTabChanged,
  }) : super(key: key);

  @override
  State<ArenaHeader> createState() => _ArenaHeaderState();
}

class _ArenaHeaderState extends State<ArenaHeader> {
  late int selectedTabIndex;

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 46, 30, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            Color(0xFF8E91D9),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(context),
          SizedBox(height: AppSizes.h14),
          _buildTabs(context),
        ],
      ),
    );
  }

  // ================= TOP ROW =================

  Widget _buildTopRow(BuildContext context) {
    return Row(
      children: [
        Text(
          "Arena",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w700,
            fontSize: 28,
            color: AppColors.backgroundColor,
          ),
        ),
        const Spacer(),

       
      ],
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p6),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.backgroundColor, size: 26),
      ),
    );
  }

  // ================= TABS =================

  Widget _buildTabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width/1.8,
          padding: const EdgeInsets.all(AppSizes.p4),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withOpacity(0.25),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // mainAxisSize: MainAxisSize.min,
            children: [
              _tabItem(context, title: "Comic", index: 0),
              _tabItem(context, title: "Polls", index: 1),
              
            ],
          ),
        ),
         Row(
           children: [
            selectedTabIndex==1?
             _circleIcon(Icons.add, () {
              // add action
              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PollScreen()
            ),
          );
                     })
                     :const SizedBox.shrink(),
                     SizedBox(width: AppSizes.w16),
                     _circleIcon(Icons.bookmark, () {
              // bookmark action
                Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Saved()
            ),
          );
                     }),
           ],
         ),
      ],
    );
  }

  Widget _tabItem(
    BuildContext context, {
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
        widget.onTabChanged?.call(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: AppSizes.p12),
        
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundColor : AppColors.transparentColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: FontManager().getTextStyle(
            context,
            fontSize: 16,
            lWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.backgroundColor.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}



class ArenaHeaderForSaved extends StatefulWidget {
  final int initialTab; // 0 = Comic, 1 = Polls
  final ValueChanged<int>? onTabChanged;

  const ArenaHeaderForSaved({
    Key? key,
    this.initialTab = 1,
    this.onTabChanged,
  }) : super(key: key);

  @override
  State<ArenaHeaderForSaved> createState() => _ArenaHeaderForSavedState();
}

class _ArenaHeaderForSavedState extends State<ArenaHeaderForSaved> {
  late int selectedTabIndex;

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 46, 30, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            Color(0xFF8E91D9),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(context),
          SizedBox(height: AppSizes.h14),
          _buildTabs(context),
        ],
      ),
    );
  }

  // ================= TOP ROW =================

  Widget _buildTopRow(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          
          child: Icon(Icons.arrow_back, 
          color: AppColors.backgroundColor,
          size: 24,
          )),
          SizedBox(width: MediaQuery.sizeOf(context).width/4,),
        Text(
          "Saved",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w700,
            fontSize: 28,
            color: AppColors.backgroundColor,
          ),
        ),
        const Spacer(),

       
      ],
    );
  }


  // ================= TABS =================

  Widget _buildTabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width/1.8,
          padding: const EdgeInsets.all(AppSizes.p4),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withOpacity(0.25),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // mainAxisSize: MainAxisSize.min,
            children: [
              _tabItem(context, title: "Comic", index: 0),
              _tabItem(context, title: "Polls", index: 1),
              
            ],
          ),
        ),
        
      ],
    );
  }

  Widget _tabItem(
    BuildContext context, {
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
        widget.onTabChanged?.call(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: AppSizes.p12),
        
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundColor : AppColors.transparentColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: FontManager().getTextStyle(
            context,
            fontSize: 16,
            lWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.backgroundColor.withOpacity(0.7),
              
          ),
        ),
      ),
    );
  }
}
