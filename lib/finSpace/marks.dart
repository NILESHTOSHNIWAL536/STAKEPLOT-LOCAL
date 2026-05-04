import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finSpace/InterestSelectionScreen.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:get/get.dart';

import '../Constants/core/app_padding_sizes.dart';

final TextEditingController maskNameController = TextEditingController();

class MaskNameScreen extends StatefulWidget {
  bool isupdate = false;
  MaskNameScreen({Key? key, this.isupdate = false}) : super(key: key);

  @override
  State<MaskNameScreen> createState() => _MaskNameScreenState();
}

class _MaskNameScreenState extends State<MaskNameScreen> {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          AvatarProfileImage(
            url: FinSpaceIcons.bgMarks,
            height: 1,
            width: 1,
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with welcome text and skip button
                  HeaderWidget(update: widget.isupdate),

                  SizedBox(height: screenSize.height * 0.05),

                  // Title with underline
                  Center(child: TitleWidget()),

                  SizedBox(height: screenSize.height * 0.05),

                  // Avatar and form section
                  Container(
                    height: MediaQuery.sizeOf(context).height / 1.8,
                    child: Center(
                      child: SingleChildScrollView(
                        child: MaskNameFormWidget(
                          controller: maskNameController,
                          isSmallScreen: isSmallScreen,
                          flag: widget.isupdate,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  bool update;
  HeaderWidget({Key? key, required this.update}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Welcome text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome to',
                // style: TextStyle(
                //   fontSize: 16,
                //   color: Colors.black54,
                //   fontWeight: FontWeight.w400,
                // ),
                style: FontManager2().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54)),
            Text('Finspace',
                style: FontManager2().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.accentColor)),
          ],
        ),

        // Skip button
        TextButton(
          onPressed: () {
            // Handle skip action
            if (update) {
              Navigator.pop(context);
            } else
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InterestSelectionScreen()),
              );
          },
          child: Text('Skip',
              style: FontManager2().getTextStyle(context,
                  lWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black54)),
        ),
      ],
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Choose your ',
                style: FontManager2().getTextStyle(context,
                    lWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black54)),
            Text('Mask Name',
                style: FontManager2().getTextStyle(context,
                    lWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.finSpaceColor)),
          ],
        ),
        // Container(
        //   width: 180,
        //   height: 2,
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [Colors.blue.shade100, Colors.blue, Colors.blue.shade100],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class MaskNameFormWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isSmallScreen;
  bool flag = false;
  MaskNameFormWidget({
    Key? key,
    required this.controller,
    required this.isSmallScreen,
    this.flag = false,
  }) : super(key: key);

  @override
  State<MaskNameFormWidget> createState() => _MaskNameFormWidgetState();
}

class _MaskNameFormWidgetState extends State<MaskNameFormWidget> {
  final List<String> maskedAvatarsList = [
    MaskedAvatars.profileIcon1,
    MaskedAvatars.profileIcon2,
    MaskedAvatars.profileIcon3,
    MaskedAvatars.profileIcon4,
    MaskedAvatars.profileIcon5,
    MaskedAvatars.profileIcon6,
    MaskedAvatars.profileIcon7,
    MaskedAvatars.profileIcon8,
    MaskedAvatars.profileIcon9,
    MaskedAvatars.profileIcon10,
    MaskedAvatars.profileIcon12,
  ];

  @override
  void initState() {
    super.initState();
    if (!maskedAvatarsList.contains(userController.avatar.value)) {
      userController.avatar.value = maskedAvatarsList[0];
    }
  }

  void _showAvatarSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(AppSizes.p16),
            height: MediaQuery.sizeOf(context).height /
                2.5, // Adjust height as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select an Avatar',
                  style: FontManager().getTextStyle(context,
                      fontSize: 18,
                      lWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                SizedBox(height: AppSizes.h16),
                Container(
                  height: MediaQuery.sizeOf(context).height / 3.3,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4 avatars per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final avatarv =
                          "assets/icons/maskAvatars/mask${index + 1}.png";
                      return GestureDetector(
                        onTap: () {
                          userController.avatar.value = avatarv;
                          Navigator.pop(context); // Close bottom sheet
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: userController.avatar.value == avatarv
                                  ? Colors.blue
                                  : AppColors.transparentColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: AvatarProfileImagePng(
                              url: avatarv, width: 6, height: 6),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.85,
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          // CircleAvatar(
          //   radius: 40,
          //   backgroundColor: Colors.grey.shade200,
          //   child: ClipOval(
          //     child: Image.network(
          //       'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/name-hwAsPxkmt5dv6qig1bc8kXvNePC7sU.png', // Using placeholder image
          //       width: 80,
          //       height: 80,
          //       fit: BoxFit.cover,
          //       errorBuilder: (context, error, stackTrace) {
          //         return Icon(Icons.person, size: 40, color: Colors.grey);
          //       },
          //     ),
          //   ),
          // ),
          GestureDetector(
            onTap: () => _showAvatarSelectionSheet(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.backgroundColor,
                  child: Obx(() => AvatarProfileImagePng(
                      url: userController.avatar.value, width: 4, height: 4)),
                ),
                Positioned(
                  bottom: 7,
                  right: 7,
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.p2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.primaryColor, width: 1),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColors.primaryColor,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSizes.h6),

          // Mask name input field
          Center(
            child: Container(
              child: Row(
                //  mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //  SizedBox(width:90),
                  Obx(() => Container(
                        width: screenSize.width / 3,
                        child: Text(maskedNameLocal.value,
                            style: FontManager2().getTextStyle(context,
                                lWeight: FontWeight.w500,
                                fontSize: widget.isSmallScreen ? 12 : 14,
                                lineHeight: 1.4,
                                color: AppColors.bg1)),
                      )),
                  SizedBox(width: AppSizes.w8),
                  IconButton(
                    icon: Icon(Icons.auto_fix_high,
                        color: AppColors.finSpaceColor),
                    onPressed: () async {
                      await getMaskedNumber(context);
                    },
                  ),
                ],
              ),
              // child: TextField(
              //   controller: widget.controller,
              //   textAlign: TextAlign.center,
              //   readOnly: true,
              //   decoration: InputDecoration(
              //     hintText: '',
              //     hintStyle: FontManager2().getTextStyle(context,
              //         lWeight: FontWeight.w600,
              //         fontSize: 14,
              //         color: AppColors.bg1),
              //     border: InputBorder.none,
              //     enabledBorder: InputBorder.none,
              //     focusedBorder: InputBorder.none,
              //     contentPadding:
              //         EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 0),
              //     suffixIcon: Padding(
              //       padding: EdgeInsets.only(right:AppSizes.p4, bottom: 2),
              //       child: IconButton(
              //         icon: Icon(Icons.auto_fix_high,
              //             color: AppColors.finSpaceColor),
              //         onPressed: () async {
              //           await getMaskedNumber(context);
              //         },
              //       ),
              //     ),
              //   ),
              // ),
            ),
          ),

          SizedBox(height: AppSizes.h6),

          // Description text
          Text(
              'Create a masked name to interact within the community while keeping your identity private.',
              style: FontManager2().getTextStyle(context,
                  lWeight: FontWeight.w500,
                  fontSize: widget.isSmallScreen ? 12 : 14,
                  lineHeight: 1.4,
                  color: AppColors.bg1)),

          SizedBox(height: AppSizes.h6),
          Text(
              'This name is only visible inside the community section — for discussions, comments, and polls. When you split bills, share posts, or engage in other features outside the community, your masked name isn’t used. Those activities remain linked to your actual Stakeplot profile.',

              // textAlign: TextAlign.center,
              // style: TextStyle(
              //   fontSize: widget.isSmallScreen ? 12 : 14,
              //   color: Colors.black54,
              //   height: 1.4,
              // ),
              style: FontManager2().getTextStyle(context,
                  lWeight: FontWeight.w500,
                  fontSize: widget.isSmallScreen ? 12 : 14,
                  lineHeight: 1.4,
                  color: Colors.black54)),

          // Done button
          SizedBox(
            width: MediaQuery.sizeOf(context).width / 4,
            child: ElevatedButton(
              onPressed: () {
                // Handle done action

                var body = {
                  "maskedName": maskNameController.text,
                  "avatarType": userController.avatar.value
                };
                addMyIntreastAndName(context, body, true, widget.flag);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A4E69),
                foregroundColor: AppColors.backgroundColor,
                padding: EdgeInsets.symmetric(vertical: AppSizes.p12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Done',
                  style: FontManager2().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.backgroundColor)),
            ),
          ),
        ],
      ),
    );
  }
}
