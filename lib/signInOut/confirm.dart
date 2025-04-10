// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
// import 'package:flutter_application_code_stakeplot/loader.dart';
// import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
// import 'package:get/get.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';


// class conform extends StatefulWidget {
//   var data;
//   String url;
//   conform({ Key? key,required this.data,required this.url }) : super(key: key);

//   @override
//   // ignore: library_private_types_in_public_api
//   _SigninState createState() => _SigninState();
// }

// class _SigninState extends State<conform> {
  

//   Widget InputDate(lableText,keyBoard,Textcontroller,index){
//     double width = MediaQuery.of(context).size.width;
//     return Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 3),
//             // color: Color.fromRGBO(249, 246, 238, 1),
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: 1,horizontal: 5),
//             width:  width <=350 ? width/6: width <=500 ? width/7:width/8,
//             alignment: Alignment.center,
//             child: Center(
//               child: TextFormField(
//                     keyboardType: keyBoard,
//                     maxLength: 1,
//                     controller: _controllers[index],
//                     focusNode: _focusNodes[index],
//                     // controller: Textcontroller,
          
//                       decoration: InputDecoration(
//                   counterText: '',  // Hide the counter
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(100),
//                     borderSide: BorderSide(
//                       color: Colorcodes.budgetDarkGreen
//                     )
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(100),
//                     borderSide: BorderSide(
//                       color: Colorcodes.budgetDarkGreen
//                     )
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(100),
//                     borderSide: BorderSide(
//                       color: Colorcodes.budgetDarkGreen
//                     )
//                   ),
//                 ),
                
//                     onChanged: (value) => _handleTextChanged(value, index),
                    
//                 ),
//             ),
//           ),
//         ),
//       );


//   }

//    final int _otpLength = 6;
//   late List<TextEditingController> _controllers= List.generate(_otpLength, (_) => TextEditingController());
//   late List<FocusNode> _focusNodes=List.generate(_otpLength, (_) => FocusNode());
//   final int _otpCodeLength = 6; // OTP length
//   RxString _otpCode = "".obs; // Captured OTP code
//   RxBool _isOtpValid = false.obs; // Validate OTP length
//   TextEditingController otpController = TextEditingController();

  
//   @override
//   void initState() {
//     super.initState();
//     if(acceptReset.value)acceptReset.value=false;
//   }
 

 
//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }


//   @override
//   Widget build(BuildContext context) {
//      TextEditingController emailController= TextEditingController();
//      TextEditingController passwordController= TextEditingController();

//        return   SafeArea(
//          child: Scaffold(
//                backgroundColor: Colorcodes.white,
//                body: Container(
//                  padding: const EdgeInsets.symmetric(horizontal: 20),
//                  height: MediaQuery.of(context).size.height/1.3,
//                  width: MediaQuery.of(context).size.width,
//                  child: Column(
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: [
//                              const SizedBox(height: 20,),
//                              topHeader(),
//                              textStyle(context: context,text:StringConstant.otpText,fontWeight: FontWeight.w400,fontsize: 10 ),
                     
//                             const SizedBox(height: 40,),
                 
                                   
//                           verifyOpt(),
                   
                   
                  
//                           acceptButton(),  
                         
                            
//                             SizedBox(height: Colorcodes.paddingSize*2,),
                   
                 
                 
                 
//                                InkWell(
//                                  onTap: (){
                 
//                   //  resendOptUser(context,widget.data['email'],widget.data['name']);
                 
//                                  },
//                                  child: resendOtp()
//                                ),
                   
                   
                                 
//                            ],
//                  ),
//                ),
//              ),
//        );
//   }

//   Widget topHeader(){
//       return   Padding(
//             padding:  EdgeInsets.symmetric(vertical: 20),
//             child: Text(("Security Pin"),
//                                 style: FontManager().getTextStyle(context,
//                                     lWeight: FontWeight.bold,
//                                     fontSize: 22,
//                                     color: Colors.black)),
//           );
//   }


//     void _handleTextChanged(String value, int index) {
//     if (value.length == 1 && index < _otpLength - 1) {
//       FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
//     } else if (value.isEmpty && index > 0) {
//       FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
//     }
//   }


// Widget acceptButton(){
//     return 
//                                Center(
//                   child: Container(
//                     width: MediaQuery.of(context).size.width/1.1,
//                     margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
//                     padding:const EdgeInsets.symmetric(vertical: 10),
//                     decoration: BoxDecoration(
//                                  color: AppColors.primaryColor,
//                                       borderRadius: BorderRadius.circular(Colorcodes.borderRadius10)
//                                  ),
//                     child: InkWell(
//                                                onTap: (){
                       
//                         //  Navigator.pushReplacementNamed(context, '/ShareAccountLogin'); 
//                             acceptReset.value=true;
//                             storeData(context,widget.data, _otpCode.value, widget.url);
//                        },
//                       child:Obx(() =>  Center(
//                                      child:  acceptReset.value? Verify(): 
//                                    Text(("Accept"),
//                                      style: FontManager().getTextStyle(context,
//                                                                  lWeight: FontWeight.bold,
//                                                                  fontSize: 20,
//                                                                  color: Colorcodes.white)),
//                       )),
//                     ),
//                   ),
//               );
// }



// Widget resendOtp(){
//   return Center(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                           vertical: Colorcodes.paddingSize / 3),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(("Didn’t you receive the OTP ? "),
//                               style: FontManager().getTextStyle(
//                                 context,
//                                 lWeight: FontWeight.w400,
//                                 fontSize: 13,
//                                 color: Colorcodes.iconBackGround,
//                                 // decoration: TextDecoration.underline
//                               )),
//                           // InkWell(
//                           //   onTap: () {
//                           //      resendOptUser(context,widget.data['email'],widget.data['name']);
//                           //   },
//                           //   child: Text(("Resend OTP"),
//                           //       style: FontManager().getTextStyle(
//                           //         context,
//                           //         lWeight: FontWeight.bold,
//                           //         fontSize: 16,
//                           //         color: Colorcodes.cardShade5,
//                           //         // decoration: TextDecoration.underline
//                           //       )
//                           //       ),
//                           // ),
//                            Obx(
//                     () => GestureDetector(
//                       onTap: canResendOtp.value
//                           ? () {
//                               resendOptUser(context,widget.data['email'],widget.data['name']);
//                               startOtpTimer();
//                               isOtpWrong.value = false;
//                               // Restart the timer on resend
//                             }
//                           : null,
//                       child: Text(
//                         canResendOtp.value
//                             ? "Resend OTP"
//                             : "Resend in ${otpCountdown.value} seconds",
//                         style: FontManager().getTextStyle(
//                           context,
//                           lWeight: FontWeight.w400,
//                           fontSize: 12,
//                           color: canResendOtp.value
//                               ? AppColors.primaryColor
//                               : Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ),
//                         ],
//                       ),
//                     ),
      
//                   );
// }




// Widget verifyOpt(){
//     return  Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: PinCodeTextField(
//                 appContext: context,
//                 length: _otpCodeLength,
//                 controller: otpController,
//                 keyboardType: TextInputType.number,
//                 autoFocus: true,
//                 animationType: AnimationType.fade,
//                 pinTheme: PinTheme(
//                   shape: PinCodeFieldShape.box,
//                   borderRadius: BorderRadius.circular(10),
//                   fieldHeight: MediaQuery.of(context).size.width * 0.13,
//                   fieldWidth: MediaQuery.of(context).size.width * 0.13,
//                   activeFillColor: Colors.white,
//                   activeColor: Colors.blue,
//                   selectedFillColor: Colors.white,
//                   selectedColor: Colors.blue,
//                   inactiveFillColor: Colors.grey[200],
//                   inactiveColor: Colors.grey,
//                 ),
//                 enableActiveFill: true,
//                 textStyle: TextStyle(fontSize: 20, color: Colors.black),
//                 onChanged: (value) {
//                   _otpCode.value = value;
//                   _isOtpValid.value = value.length == _otpCodeLength;
//                   if(_isOtpValid.value){
//                        acceptReset.value=true;
//                       storeData(context,widget.data, _otpCode.value, widget.url);
//                   }
//                 },
//               ),
//           );
// }

// }



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/opt_email.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class conform extends StatefulWidget {
  var data;
  String url;
  conform({Key? key, required this.data, required this.url}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<conform> {
  final int _otpLength = 6;
  late List<TextEditingController> _controllers = List.generate(_otpLength, (_) => TextEditingController());
  late List<FocusNode> _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  final int _otpCodeLength = 6;
  RxString _otpCode = "".obs;
  RxBool _isOtpValid = false.obs;
  TextEditingController otpController = TextEditingController();

  // Timer-related variables
  RxInt otpCountdown2 = 30.obs;
  RxBool canResendOtp2 = false.obs;
  RxBool isOtpWrong2 = false.obs;
  Timer? otpTimer2;

  @override
  void initState() {
    super.initState();
    if (acceptReset.value) acceptReset.value = false;
    startOtpTimer2(); // Start the timer on init
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    otpTimer2?.cancel();
    super.dispose();
  }

  void startOtpTimer2() {
    canResendOtp2.value = false;
    otpCountdown2.value = 30;
    otpTimer2?.cancel(); // Cancel any existing timer
    otpTimer2 = Timer.periodic(Duration(seconds: 1), (timer) {
      if (otpCountdown2.value > 0) {
        otpCountdown2.value--; // Decrement the countdown
      } else {
        canResendOtp2.value = true;
        timer.cancel(); // Stop the timer when it reaches 0
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colorcodes.white,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height / 1.3,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              topHeader(),
              textStyleOnly2(
                  context: context,
                  text: "Enter the 6-digit OTP sent to your email",
                  fontWeight: FontWeight.w400,
                  fontsize: 14,
                  color:AppColors.bg1
                ),
              const SizedBox(height: 40),
              verifyOpt(),
              acceptButton(),
              SizedBox(height: Colorcodes.paddingSize * 2),
              resendOtp(), // Simplified structure
            ],
          ),
        ),
      ),
    );
  }

  Widget topHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "Verify OTP",
        style: FontManager().getTextStyle(context, lWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
      ),
    );
  }

  void _handleTextChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Widget acceptButton() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(Colorcodes.borderRadius10),
        ),
        child: InkWell(
          onTap: () {
            acceptReset.value = true;
            storeData(context, widget.data, _otpCode.value, widget.url);
          },
          child: Obx(
            () => Center(
              child: acceptReset.value
                  ? Verify()
                  : Text(
                      "Verify & Accept",
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500, fontSize: 16, color: Colorcodes.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget resendOtp() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Colorcodes.paddingSize / 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Didn’t you receive the OTP? ",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w400,
                fontSize: 14,
                color: Colorcodes.iconBackGround,
              ),
            ),
            Obx(
              () => GestureDetector(
                onTap: canResendOtp2.value
                    ? () {
                        resendOptUser(context, widget.data['email'], widget.data['name']);
                        startOtpTimer2();
                        isOtpWrong2.value = false;
                        otpController.clear(); // Clear OTP field on resend
                        _otpCode.value = ""; // Reset OTP code
                        _isOtpValid.value = false; // Reset validity
                      }
                    : null,
                child: Text(
                  canResendOtp2.value ? "Resend OTP" : "Resend in ${otpCountdown2.value} seconds",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 12,
                    color: canResendOtp2.value ? AppColors.primaryColor : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget verifyOpt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: PinCodeTextField(
        appContext: context,
        length: _otpCodeLength,
        controller: otpController,
        keyboardType: TextInputType.number,
        autoFocus: true,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          fieldHeight: MediaQuery.of(context).size.width * 0.13,
          fieldWidth: MediaQuery.of(context).size.width * 0.13,
          activeFillColor: Colors.white,
          activeColor: Colors.blue,
          selectedFillColor: Colors.white,
          selectedColor: Colors.blue,
          inactiveFillColor: Colors.grey[200],
          inactiveColor: Colors.grey,
        ),
        enableActiveFill: true,
        textStyle: TextStyle(fontSize: 20, color: Colors.black),
        onChanged: (value) {
          _otpCode.value = value;
          _isOtpValid.value = value.length == _otpCodeLength;
          if (_isOtpValid.value) {
            acceptReset.value = true;
            storeData(context, widget.data, _otpCode.value, widget.url);
          }
        },
      ),
    );
  }
}