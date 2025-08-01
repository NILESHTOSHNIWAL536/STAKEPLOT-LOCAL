import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/post_interest.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import './success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

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
  double modalHeight = 300;
  String? question;
  bool pollSubmitted = false;
  List<String>? options;
  Map<String, int>? votes;
  List<bool> _showCross = [];
  final CommunityScreenStrings strings = CommunityScreenStrings();
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
      question = _questionController.text;
      // List<String>  options = _optionControllers.map((controller) => controller.text).toList();
      List options = [];

      _optionControllers.map((controller) {
        String op = controller.text;
        options.add({
          "option": op,
        });
      }).toList();

      if (postController.posting.value) return;
     postController.posting.value = true;
      // clearInterest();
      createPollOfCommunityPost(context, question.toString(), options, {}, [], "casual");
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
    return Scaffold(
 appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.bg1,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          strings.createPoll,
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.bg1,
          ),
        ),
      ),
      body: SafeArea(
        child: pollSubmitted
            ?SuccessPost(celebrationText: strings.postedSuccess)
            : Container(
              
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        if (question == null) ...[
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.1,
                              child: TextField(
                                controller: _questionController,
                                maxLines: null,
                                maxLength: 150,
                                 textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.textBgColor,
                                 hintText: strings.askQuestion,
                                  hintStyle: FontManager().getTextStyle(context,
                                      lWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: AppColors.bg1),
                                    focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: AppColors.textBgColor),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: AppColors.textBgColor),
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(8))),
                                  contentPadding: const EdgeInsets.all(16),
                                // counterText: '',
                                ),
                                
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(_optionControllers.length, (index) {
                            return Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                               crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width / 1.1,
                                    child: TextField(
                                      controller: _optionControllers[index],
                                      maxLines: null,
                                      maxLength: 150,
                                      
                                      decoration: InputDecoration(
                                        hintText: "${strings.optionPrefix} ${index + 1}", 
                                        filled: true,
                                                                fillColor: AppColors.textBgColor,
                                        hintStyle: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.normal,
                                            fontSize: 14,
                                            color: AppColors.bg1),
                                                  
                                            focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.textBgColor),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.textBgColor),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        // fillColor: AppColors.button,
                                        // filled: true,
                                         contentPadding: const EdgeInsets.all(12),
                                    // counterText: '',
                                        suffixIcon: _showCross[index]
                                            ? IconButton(
                                                onPressed: () =>
                                                    _removeOption(index),
                                                 icon: Icon(Icons.delete, color: Colors.red),
                                              )
                                            : null,
                                      ),
                                      onChanged: (value) {
                                    setState(() {
                                      _showCross[index] = value.isNotEmpty;
                                      // Ensure cursor stays at the end
                                      if (value.length == 80) {
                                        _optionControllers[index].selection =
                                            TextSelection.fromPosition(
                                          TextPosition(offset: value.length),
                                        );
                                      }
                                    });
                                  },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }),
                          if (_optionControllers.length < 4)
                            TextButton.icon(
                                onPressed: _addOptionController,
                                icon: const Icon(Icons.add),
                                label: Text(
                                  strings.addOption,
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: AppColors.bg1,
                                  ),
                                )),
                          Center(
                            child: GestureDetector(
                                onTap: (){
                                   int count = 0;

                                  _optionControllers.forEach((e) {
                                    if (e.text.length
                                        .toString()
                                        .trim()
                                        .isNotEmpty) {
                                      count++;
                                    }
                                  });
                                  if (count < 2) {
                                    snackBarCalledfail(context, "Atleast two options must be there");
                                    return;
                                  }

                                  _questionController.text.isNotEmpty &&
                                          _optionControllers.every(
                                              (controller) =>
                                                  controller.text.isNotEmpty)
                                      ? showTagListOfInterestModal(
                                          context: context, onConfirm: callBack)
                                      : null;
                                  //  showTagListOfInterestModal(context:  context,onConfirm: callBack);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 1.1,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 14),
                                  decoration: BoxDecoration(
                                      color: _questionController.text.isNotEmpty &&
                                              _optionControllers.every(
                                                  (controller) =>
                                                      controller.text.isNotEmpty)
                                          ? AppColors.finSpaceColor
                                          : AppColors.button,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                    child: Obx(() => postController.posting.value
                                        ? Spinner(
                                            size: 30,
                                            color: Colorcodes.white,
                                          )
                                        : Text(
                                             strings.continueButton, 
                                            style: FontManager().getTextStyle(
                                              context,
                                              lWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: _questionController
                                                          .text.isNotEmpty &&
                                                      _optionControllers.every(
                                                          (controller) => controller
                                                              .text.isNotEmpty)
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          )),
                                  ),
                                )),
                          ),
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
                            for (var option in ( options==null? [] : options!))
                                    GestureDetector(
                                      onTap: () => _vote(option),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            option,
                                            style: FontManager().getTextStyle(
                                                context,
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
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8 *
                                                    (_getPercentage(option) /
                                                        100),
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
                                            style: const TextStyle(
                                                color: Colors.grey),
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
                  ),
                ),
              ),
      ),
    );
  }


   void callBack()async
  {
       Navigator.pop(context);
      _createPoll();
  }

}
