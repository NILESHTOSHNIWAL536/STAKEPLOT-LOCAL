import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/finSpace/InterestSelectionScreen.dart';

class MaskNameScreen extends StatefulWidget {
  const MaskNameScreen({Key? key}) : super(key: key);

  @override
  State<MaskNameScreen> createState() => _MaskNameScreenState();
}

class _MaskNameScreenState extends State<MaskNameScreen> {
  final TextEditingController _maskNameController = TextEditingController();

  @override
  void dispose() {
    _maskNameController.dispose();
    super.dispose();
  }

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
                          controller: _maskNameController,
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

class MaskNameFormWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isSmallScreen;
  
  const MaskNameFormWidget({
    Key? key,
    required this.controller,
    required this.isSmallScreen,
  }) : super(key: key);

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
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: Image.network(
                'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/name-hwAsPxkmt5dv6qig1bc8kXvNePC7sU.png', // Using placeholder image
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, size: 40, color: Colors.grey);
                },
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Mask name input field
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Mask Name',
              hintStyle: TextStyle(color: Colors.black54),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              suffixIcon: Icon(Icons.auto_fix_high, color: Colors.indigo),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Description text
          Text(
            'You can create a mask name to keep your identity private, or use the name and interact anonymously. You\'re always in control, and you can update this anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
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
                // Navigator.pushNamed(context, '/interestScreen');
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InterestSelectionScreen()),
                    );
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

// Custom painter for the background wave pattern
class WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw wavy lines
    for (int i = 0; i < 20; i++) {
      final path = Path();
      final startY = size.height * 0.1 + (i * 30);
      
      path.moveTo(0, startY);
      
      for (double x = 0; x < size.width; x += 40) {
        path.quadraticBezierTo(
          x + 20, startY + 15, 
          x + 40, startY
        );
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}