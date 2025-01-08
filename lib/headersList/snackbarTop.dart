import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';


class TopRightSnackbar extends StatefulWidget {
  final String message;

  const TopRightSnackbar({Key? key, required this.message}) : super(key: key);

  @override
  _TopRightSnackbarState createState() => _TopRightSnackbarState();
}

class _TopRightSnackbarState extends State<TopRightSnackbar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // Start off-screen
      end: Offset.zero, // Slide in
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOutQuad,
      

    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width/1.1
        ),
        margin: const EdgeInsets.only(top: 12.0, right: 10.0), // Adjust the margin as needed
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colorcodes.budgetLightGreen,
          border: Border.all(
            width: .3,
            color: Colorcodes.black,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          widget.message,
          style: FontManager().getTextStyle(
            context,  lWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colorcodes.black
          ),
        ),
      ),
    );
  }
}

void showTopRightSnackbar(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 0,
      right: 0,
      child: TopRightSnackbar(message: message),
    ),
  );

  overlay?.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
