import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/finSpace/InterestSelectionScreen.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_svg/svg.dart';
 final TextEditingController maskNameController = TextEditingController();

class MaskNameScreen extends StatefulWidget {
  const MaskNameScreen({Key? key}) : super(key: key);

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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background pattern
          // Positioned.fill(
          //   child: CustomPaint(
          //     painter: WavePatternPainter(),
          //   ),
          // ),
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
                  HeaderWidget(),
                  
                  SizedBox(height: screenSize.height * 0.05),
                  
                  // Title with underline
                  Center(child: TitleWidget()),
                  
                  SizedBox(height: screenSize.height * 0.03),
                  
                  // Avatar and form section
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: MaskNameFormWidget(
                          controller: maskNameController,
                          isSmallScreen: isSmallScreen,
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
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Welcome text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Finspace',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        // Skip button
        TextButton(
          onPressed: () {
            // Handle skip action
          },
          child: Text(
            'Skip',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
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
        Text(
          'Choose your Mask Name',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Container(
          width: 180,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blue, Colors.blue.shade100],
            ),
          ),
        ),
      ],
    );
  }
}

class MaskNameFormWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isSmallScreen;

  const MaskNameFormWidget({
    Key? key,
    required this.controller,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  State<MaskNameFormWidget> createState() => _MaskNameFormWidgetState();
}

class _MaskNameFormWidgetState extends State<MaskNameFormWidget> {
  String selectedAvatarInital = MaskedAvatars.profileIcon1; 
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
  ];

 void _showAvatarSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 300, // Adjust height as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select an Avatar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 avatars per row
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: maskedAvatarsList.length,
                  itemBuilder: (context, index) {
                    final avatar = maskedAvatarsList[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatarInital = avatar;
                        });
                        Navigator.pop(context); // Close bottom sheet
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedAvatarInital == avatar
                                ? Colors.blue
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child:AvatarProfileImage(url: avatar, width: 6, height: 6
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    
                   // backgroundColor: Colors.grey.shade200,
                    child:  AvatarProfileImage(url: selectedAvatarInital, width: 6, height: 6)
                    ,
                  
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Mask name input field
          TextField(
            controller: widget.controller,
            textAlign: TextAlign.center,
            readOnly: true,
            decoration: InputDecoration(
              hintText: '',
              hintStyle: TextStyle(color: Colors.black54),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
             suffixIcon: IconButton( // Change to IconButton for tap handling
                icon: Icon(Icons.auto_fix_high, color: Colors.indigo),
                onPressed: () async{
                  
                 await getMaskedNumber(context);
                },
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Description text
          Text(
            'You can create a mask name to keep your identity private, or use the name and interact anonymously. You\'re always in control, and you can update this anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.isSmallScreen ? 12 : 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          
          SizedBox(height: 24),
          
          // Done button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle done action
                
                 Navigator.pushNamed(context, '/interestScreen');
                  
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A4E69),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
