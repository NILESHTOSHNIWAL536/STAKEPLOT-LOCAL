import 'package:flutter/material.dart';

class TextInputWidget extends StatelessWidget {
  final TextEditingController controller1;
  final TextEditingController controller2;
  final String hintText1;
  final String hintText2;

  TextInputWidget({
    Key? key,
    required this.controller1,
    required this.controller2,
    required this.hintText1,
    required this.hintText2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller1,
          decoration: InputDecoration(
            hintText: hintText1,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          ),
        ),
        const SizedBox(height: 16.0), // Add spacing between inputs
        TextField(
          controller: controller2,
          decoration: InputDecoration(
            hintText: hintText2,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          ),
        ),
      ],
    );
  }
}
