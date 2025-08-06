// import 'package:flutter/material.dart';

// class BankProgress extends StatelessWidget {
//   final double percent; // Pass value between 0-100

//   const BankProgress({Key? key, required this.percent}) : super(key: key);

//   Color _getProgressColor(num val) {
//     if (val < 40) return Colors.red;
//     if (val > 70) return Colors.green;
//     return Colors.orange;
//   }

//   @override
//   Widget build(BuildContext context) {
//     const int totalDots = 20;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Bank Current Status",
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.black54,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 20),
//         Container(
//           width: MediaQuery.of(context).size.width/1.1,
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final barWidth = MediaQuery.of(context).size.width/1.34;
//               final dotSize = barWidth / (totalDots); // +2 for better padding
//               final effectivePercent = percent.clamp(0, 100);
//               final double progress = (effectivePercent / 100.0) * (totalDots - 1); // 0..(dots-1)    
//               // Position the percentage indicator
//               final double indicatorLeft = (progress * dotSize)
//                   .clamp(0, barWidth - dotSize); // Prevent overflow
              
//               return SizedBox(
//                 height: dotSize * 3,
//                 width: barWidth,
//                 child: Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     // Dotted Progress Bar
//                     Positioned(
//                       top: dotSize,
//                       left: 0,
//                       right: 0,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: List.generate(totalDots, (i) {
//                           return Padding(
//                             padding:EdgeInsets.symmetric(horizontal: dotSize * 0.08),
//                             child: Container(
//                               width: dotSize,
//                               height: dotSize,
//                               decoration: BoxDecoration(
//                                 color: i <= progress
//                                     ? _getProgressColor(effectivePercent)
//                                     : Colors.grey[300],
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                     // Percentage Indicator
//                     Positioned(
//                       left: indicatorLeft+9,
//                       top: -28,
//                       child: Column(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(7),
//                             // margin: EdgeInsets.only(bottom: 20),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: _getProgressColor(effectivePercent),
//                                 width: 3,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                     color: Colors.black.withOpacity(0.08),
//                                     blurRadius: 4,
//                                     offset: Offset(0, 1)),
//                               ],
//                             ),
//                             child: Text(
//                               "${effectivePercent.toStringAsFixed(0)}%",
//                               style: TextStyle(
//                                   color: _getProgressColor(effectivePercent),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13),
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Icon(Icons.arrow_drop_down,
//                               color: _getProgressColor(effectivePercent)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

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
           const SizedBox(height: 10),
           textStyle (
               context: context,
               text: "Bank Current Status",
              fontsize: 16,
              c:AppColors.primaryColor,
              fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth;
                final double dotSize = 7.0;              
                // Calculate how many dots should be filled
                final double progressRatio = clampedPercent / 100.0;
                final int filledDots = (progressRatio * totalDots).floor();
                
                // Calculate indicator position
                final double indicatorPosition = progressRatio * (availableWidth - dotSize-28);
                
                return SizedBox(
                  height: 80,
                  width: availableWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Progress dots
                      Positioned(
                        top: 50,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(totalDots, (index) {
                            Color dotColor;
                            double opacity = 1.0;
                            
                            if (index <= filledDots) {
                              // Fully filled dot
                              dotColor = _getProgressColor(clampedPercent);
                            } else if (index > filledDots) {
                              // Partially filled dot
                              dotColor = _getProgressColor(clampedPercent);
                              opacity = 0.2;
                            } else {
                              // Empty dot
                              dotColor = Colors.grey[300]!;
                            }
                            return Transform.rotate(
                              angle: .5,
                              child: Container(
                                width: dotSize,
                                height: dotSize+5,
                                decoration: BoxDecoration(
                                  color: dotColor.withOpacity(opacity),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      
                      // Percentage indicator
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: indicatorPosition,
                        top: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Percentage bubble
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  // borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getProgressColor(clampedPercent),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getProgressColor(clampedPercent),
                                  shape: BoxShape.circle,
                                  // borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getProgressColor(clampedPercent),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child:  textStyleOnly2(
                                    context: context,
                                    text: "${clampedPercent.toStringAsFixed(0)}%",
                                    fontsize: 10 ,
                                    color: Colorcodes.white,
                                    fontWeight: FontWeight.w500,
       
              
                                  ),
                                ),
                              ),
                            ),
                            
                            // Arrow pointing down
                            const SizedBox(height: 2),
                            CustomPaint(
                              size: const Size(12, 8),
                              painter: ArrowPainter(
                                color: _getProgressColor(clampedPercent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Progress labels
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         "0%",
          //         style: TextStyle(
          //           fontSize: 12,
          //           color: Colors.grey[600],
          //         ),
          //       ),
          //       Text(
          //         "50%",
          //         style: TextStyle(
          //           fontSize: 12,
          //           color: Colors.grey[600],
          //         ),
          //       ),
          //       Text(
          //         "100%",
          //         style: TextStyle(
          //           fontSize: 12,
          //           color: Colors.grey[600],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         "0%",
          //         style: TextStyle(
          //           fontSize: 12,
          //           color: Colors.grey[600],
          //         ),
          //       ),
          //       Text(
          //         "50%",
          //         style: TextStyle(
          //           fontSize: 12,
          //           color: Colors.grey[600],
          //         ),
          //       ),
          //       Text(
          //         "100%",
          //         style: TextStyle(
          //           fontSize: 12,
          //           color: Colors.grey[600],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
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
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            BankProgress(percent: _currentProgress),
            const SizedBox(height: 40),
            
            // Slider to test different values
            Text(
              'Adjust Progress: ${_currentProgress.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
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
            
            const SizedBox(height: 40),
            
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
