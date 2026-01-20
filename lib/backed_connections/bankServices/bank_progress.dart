import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

import '../../Constants/core/app_padding_sizes.dart';

class BankProgress extends StatelessWidget {
  final double percent; // Pass value between 0-100
  
  const BankProgress({Key? key, required this.percent}) : super(key: key);

  Color _getProgressColor(double val) {
    if (val < 40) return Colors.red;
    if (val > 70) return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    const int totalDots = 20;
    final double clampedPercent = percent.clamp(0, 100);
    
    return Padding(
       padding: const EdgeInsets.symmetric(vertical: 2),
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

// Example usage widget
class BankProgressDemo extends StatefulWidget {
  @override
  _BankProgressDemoState createState() => _BankProgressDemoState();
}

class _BankProgressDemoState extends State<BankProgressDemo> {
  double _currentProgress = 65.0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Progress Demo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: AppColors.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
             SizedBox(height: AppSizes.h40),
            BankProgress(percent: _currentProgress),
             SizedBox(height: AppSizes.h40),

            // Slider to test different values
            Text(
              'Adjust Progress: ${_currentProgress.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: AppSizes.h20),
            Slider(
              value: _currentProgress,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _currentProgress = value;
                });
              },
            ),
            
            SizedBox(height: AppSizes.h40),
            
            // Test buttons for specific values
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _currentProgress = 25),
                  child: const Text('25% (Red)'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _currentProgress = 55),
                  child: const Text('55% (Orange)'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _currentProgress = 85),
                  child: const Text('85% (Green)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
