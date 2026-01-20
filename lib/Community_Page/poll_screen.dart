import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/post_interest.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/dotted_Border.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/user_chat/room_poll_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:get/get.dart';
import '../Constants/core/app_padding_sizes.dart';
import './success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class PollScreen extends StatefulWidget {
 

  PollScreen();

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

  void createPoll(String finalQuestion, List finalOptions) {
{
    // if (_questionController.text.isNotEmpty &&
    //     _optionControllers.every((controller) => controller.text.isNotEmpty)) {
    //   question = _questionController.text;
    //   // List<String>  options = _optionControllers.map((controller) => controller.text).toList();
    //   List options = [];

    //   _optionControllers.map((controller) {
    //     String op = controller.text;
    //     options.add({
    //       "option": op,
    //     });
    //   }).toList();

    //   if (postController.posting.value) return;
    //  postController.posting.value = true;
    //   // clearInterest();
    //   createPollOfCommunityPost(context, question.toString(), options, {}, [], "casual");
    // } else {
    //   snackBarCalledfail(context, 'Please fill in all fields before posting the poll.');
     
    // }
    if (postController.posting.value) return;
postController.posting.value = true;

createPollOfCommunityPost(
  context,
  finalQuestion,
  finalOptions,
  {},
  [],
  "casual",
);

  }}

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
      backgroundColor: AppColors.border,
  resizeToAvoidBottomInset: true,
      body: pollSubmitted
          ?SuccessPost(celebrationText: strings.postedSuccess)
          : Column(
            children: [
             PollStepHeader(
  title: strings.createPoll,
  step: 1,
),

              Container(
                height: MediaQuery.sizeOf(context).height/1.4,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        if (question == null) ...[
                          Container(
                            width: MediaQuery.of(context).size.width / 1.1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               Text(
                            "Your Question *",
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 15,
                              lWeight: FontWeight.w700,
                              color: AppColors.accentColor
                            ),
                          ),
                           SizedBox(height: AppSizes.h8),
                          
                          TextField(
                            controller: _questionController,
                            maxLength: 200,
                            maxLines: 3,
                                buildCounter: (
                      BuildContext context, {
                      required int currentLength,
                      required bool isFocused,
                      required int? maxLength,
                    }) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "$currentLength / $maxLength characters",
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 12,
                            lWeight: FontWeight.w400,
                            color: AppColors.grey,
                          ),
                        ),
                      );
                    },
                            decoration: InputDecoration(
                              hintText: strings.askQuestion,
                              filled: true,
                              fillColor: AppColors.backgroundColor,
                              
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          
                              ],
                            ),
                          ),
                           SizedBox(height: AppSizes.h30),
                           Text(
                            "Answer Options * (2-4 options)",
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 15,
                              lWeight: FontWeight.w700,
                            ),
                          ),
                           SizedBox(height: AppSizes.h10),
                
                          ...List.generate(_optionControllers.length, (index) {
                            return Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                               crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child:
                                  Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFE0E0E0),
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(fontSize: 15, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: AppSizes.w12),
                    Container(
                      width: MediaQuery.sizeOf(context).width/1.38,
                      child: TextField(
                        controller: _optionControllers[index],
                        decoration: InputDecoration(
                          hintText: "Option ${index + 1}",
                          hintStyle: FontManager().getTextStyle(context, color: AppColors.grey, fontSize: 14),
                          filled: true,
                          fillColor: AppColors.backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                
                                  //  Container(
                                  //   width: MediaQuery.of(context).size.width / 1.1,
                                  //   child: TextField(
                                  //     controller: _optionControllers[index],
                                  //     maxLines: null,
                                  //     maxLength: 150,
                                      
                                  //     decoration: InputDecoration(
                                  //       hintText: "${strings.optionPrefix} ${index + 1}", 
                                  //       filled: true,
                                  //                               fillColor: AppColors.textBgColor,
                                  //       hintStyle: FontManager().getTextStyle(
                                  //           context,
                                  //           lWeight: FontWeight.normal,
                                  //           fontSize: 14,
                                  //           color: AppColors.bg1),
                                                  
                                  //           focusedBorder: OutlineInputBorder(
                                  //         borderSide: BorderSide(color: AppColors.textBgColor),
                                  //         borderRadius: BorderRadius.circular(8),
                                  //       ),
                                  //       enabledBorder: OutlineInputBorder(
                                  //         borderSide: BorderSide(color: AppColors.textBgColor),
                                  //           borderRadius: BorderRadius.all(
                                  //               Radius.circular(8))),
                                  //       // fillColor: AppColors.button,
                                  //       // filled: true,
                                  //        contentPadding: const EdgeInsets.all(12),
                                  //   // counterText: '',
                                  //       suffixIcon: _showCross[index]
                                  //           ? IconButton(
                                  //               onPressed: () =>
                                  //                   _removeOption(index),
                                  //                icon: Icon(Icons.delete, color: Colors.red),
                                  //             )
                                  //           : null,
                                  //     ),
                                  //     onChanged: (value) {
                                  //   setState(() {
                                  //     _showCross[index] = value.isNotEmpty;
                                  //     // Ensure cursor stays at the end
                                  //     if (value.length == 80) {
                                  //       _optionControllers[index].selection =
                                  //           TextSelection.fromPosition(
                                  //         TextPosition(offset: value.length),
                                  //       );
                                  //     }
                                  //   });
                                  // },
                                  //   ),
                                  // ),
                               
                                ),
                                SizedBox(height: AppSizes.h10),
                              ],
                            );
                          }),
                          SizedBox(height: AppSizes.h12),
                          if (_optionControllers.length < 4)
                            GestureDetector
                            
                            (
                              onTap:_addOptionController,
                              child: DottedBorderBox(
                
                                color: AppColors.primaryColor,
                                dashWidth: 1.0,
                                dashHeight: 1.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add, color: AppColors.primaryColor,size: 26,),
                                    SizedBox(width: AppSizes.w10),
                                    Text(
                                    strings.addOption,
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.primaryColor,
                                    ),
                                  )
                                  ],
                                ),
                              ),
                            ),
                             SizedBox(height: AppSizes.h12),
                         
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
                                        color: AppColors.accentColor),
                                  ),
                                  SizedBox(height: AppSizes.h10),
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
                                                color: AppColors.accentColor),
                                          ),
                                          SizedBox(height: AppSizes.h5),
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
                                          SizedBox(height: AppSizes.h5),
                                          Text(
                                            '${_getPercentage(option).toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                          SizedBox(height: AppSizes.h10),
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
  final List<Map<String, dynamic>> pollOptions =
      _optionControllers.map((c) {
    return {"option": c.text.trim()};
  }).toList();
                                    _questionController.text.isNotEmpty &&
                                            _optionControllers.every(
                                                (controller) =>
                                                    controller.text.isNotEmpty)
                                        ?
                                    

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => InterestSelectionPage(
        question: _questionController.text.trim(),
        options: pollOptions,
       onConfirm: (String q, List<Map<String, dynamic>> opts) {
  Navigator.pop(context);
  createPoll(q, opts);
},

      ),
    ),
  )
 
                                        // showTagListOfInterestModal(
                                        //     context: context, onConfirm: callBack)
                                        : null;
                                    //  showTagListOfInterestModal(context:  context,onConfirm: callBack);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width / 1.1,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 20),
                                    decoration: BoxDecoration(
                                        color: _questionController.text.isNotEmpty &&
                                                _optionControllers.every(
                                                    (controller) =>
                                                        controller.text.isNotEmpty)
                                            ? AppColors.primaryColor
                                            : AppColors.backgroundColor,
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
                                                lWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: _questionController
                                                            .text.isNotEmpty &&
                                                        _optionControllers.every(
                                                            (controller) => controller
                                                                .text.isNotEmpty)
                                                    ? AppColors.backgroundColor
                                                    : AppColors.accentColor,
                                              ),
                                            )),
                                    ),
                                  )),
                            ),
                          
            ],
          ),
    );
  }


  //  void callBack()async
  // {
  //      Navigator.pop(context);
  //     createPoll();
  // }

}


