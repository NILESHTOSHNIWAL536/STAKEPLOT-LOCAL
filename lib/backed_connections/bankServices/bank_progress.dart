import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

import '../../Constants/core/app_padding_sizes.dart';

class BankProgress extends StatelessWidget {
  final double percent; // Pass value between 0-100
  
  const BankProgress({Key? key, required this.percent}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    const int totalDots = 20;
    final double clampedPercent = percent.clamp(0, 100);
    
    return Padding(
       padding: const EdgeInsets.symmetric(vertical: AppSizes.p2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            SizedBox(height: AppSizes.h10),
           textStyle (
               context: context,
               text: "Connected Banks",
              fontsize: 16,
              c:AppColors.primaryColor,
              fontWeight: FontWeight.bold,
          ),
          SizedBox(height: AppSizes.h1),
          
        ],
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;
  
  ArrowPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final Path path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

