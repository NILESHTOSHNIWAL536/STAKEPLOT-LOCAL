import 'package:flutter/material.dart';

class MultipleRadioExample extends StatefulWidget {
  @override
  _MultipleRadioExampleState createState() => _MultipleRadioExampleState();
}

class _MultipleRadioExampleState extends State<MultipleRadioExample> {
  String selectedColor = 'Red';
  String selectedSize = 'Small';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multiple Radio Groups')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Choose a color:"),
            Row(
              children: [
                Radio<String>(
                  value: 'Red',
                  groupValue: selectedColor,
                  onChanged: (value) {
                    setState(() {
                      selectedColor = value!;
                    });
                  },
                ),
                Text('Red'),
                Radio<String>(
                  value: 'Blue',
                  groupValue: selectedColor,
                  onChanged: (value) {
                    setState(() {
                      selectedColor = value!;
                    });
                  },
                ),
                Text('Blue'),
              ],
            ),
            SizedBox(height: 20),
            Text("Choose a size:"),
            Row(
              children: [
                Radio<String>(
                  value: 'Small',
                  groupValue: selectedSize,
                  onChanged: (value) {
                    setState(() {
                      selectedSize = value!;
                    });
                  },
                ),
                Text('Small'),
                Radio<String>(
                  value: 'Large',
                  groupValue: selectedSize,
                  onChanged: (value) {
                    setState(() {
                      selectedSize = value!;
                    });
                  },
                ),
                Text('Large'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}