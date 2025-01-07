import 'package:flutter/material.dart';
import './success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
//import 'dart:io';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';

class PollScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPollPosted;
  final Map<String, dynamic> userInfo;

  PollScreen({required this.onPollPosted, required this.userInfo});

  @override
  _PollScreenState createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  final TextEditingController _questionController = TextEditingController();
  List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  String? question;
  bool pollSubmitted = false;
  List<String>? options;
  Map<String, int>? votes;
  List<bool> _showCross = [];
  @override
  void initState() {
    super.initState();
    // Initialize with two default controllers
    _optionControllers = [TextEditingController(), TextEditingController()];
    _showCross = [false, false]; // Match the number of initial controllers
  }

  void _addOptionController() {
    setState(() {
      if (_optionControllers.length < 4) {
        // Limit to 4 options
        _optionControllers.add(TextEditingController());
        _showCross.add(false); // Default to not showing the cross button
      }
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers.removeAt(index);
      _showCross.removeAt(index);
    });
  }

  void _createPoll() {
    if (_questionController.text.isNotEmpty &&
        _optionControllers.every((controller) => controller.text.isNotEmpty)) {
      setState(() {
        question = _questionController.text;
        options =
            _optionControllers.map((controller) => controller.text).toList();
        votes = {for (var option in options!) option: 0};
      });

      // Pass poll data to parent
      widget.onPollPosted({
        'profilePic': 'https://via.placeholder.com/50',
        'name': 'You',
        'contentType': 'poll',
        'question': question!,
        'options': options!,
        'votes': votes!,
        "likeCount": 0,
        "isLiked": false,
      });
      setState(() {
        pollSubmitted = true;
      });

      // Close the screen
      //Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Please fill in all fields before posting the poll.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _vote(String option) {
    setState(() {
      votes![option] = (votes![option] ?? 0) + 1;
    });
  }

  double _getPercentage(String option) {
    int totalVotes = votes!.values.fold(0, (sum, count) => sum + count);
    if (totalVotes == 0) return 0.0;
    return (votes![option]! / totalVotes) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return pollSubmitted
        ? const SuccessPost()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          widget.userInfo['profilePic'].toString()),
                      radius: 24,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userInfo['name'].toString(),
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                        Text('New post',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.black)),
                      ],
                    ),
                  ],
                ),
                if (question == null) ...[
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Ask a question',
                      hintStyle: FontManager().getTextStyle(context,
                          lWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(_optionControllers.length, (index) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Option ${index + 1}',
                                  hintStyle: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.normal,
                                      fontSize: 14,
                                      color: Colors.black),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(16))),
                                  fillColor: Colors.grey[300],
                                  filled: true,
                                  suffixIcon: _showCross[index]
                                      ? IconButton(
                                          onPressed: () => _removeOption(index),
                                          icon: const Icon(Icons.close),
                                        )
                                      : null,
                                ),
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    setState(() {
                                      _showCross[index] =
                                          true; // Show the cross icon for this field
                                    });
                                  }
                                },
                              ),
                            ),
                            //const SizedBox(width: 8),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),
                  TextButton.icon(
                    onPressed: _addOptionController,
                    icon: _optionControllers.length < 4
                        ? const Icon(Icons.add)
                        : const SizedBox(),
                    label: _optionControllers.length < 4
                        ? Text(
                            'Add Option',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.normal,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          )
                        : const SizedBox(),
                  ),
                  const SizedBox(height: 20),
                  DecoratedContainer(
                      borderRadius: 24,
                      backgroundColor: _questionController.text.isNotEmpty &&
                              _optionControllers.every(
                                  (controller) => controller.text.isNotEmpty)
                          ? Colors.blue
                          : Colors.grey,
                      child: TextButton(
                        onPressed: _createPoll,
                        child: Text('Continue',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: 18,
                                color: Colors.black)),
                      )),
                ] else ...[
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question!,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          for (var option in options!)
                            GestureDetector(
                              onTap: () => _vote(option),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option,
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.normal,
                                        fontSize: 18,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(height: 5),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      Container(
                                        height: 10,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8 *
                                                (_getPercentage(option) / 100),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${_getPercentage(option).toStringAsFixed(1)}%',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
  }
}
