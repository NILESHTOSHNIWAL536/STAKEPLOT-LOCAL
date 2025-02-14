import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';


//  RxBool acceptReset=false.obs;

class ResetOtp extends StatefulWidget {
  String name;
  String email;

  ResetOtp({ Key? key,required this.email,required this.name }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<ResetOtp> {
  

  Widget InputDate(lableText,keyBoard,Textcontroller,index){
    double width = MediaQuery.of(context).size.width;
    return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
            // color: Color.fromRGBO(249, 246, 238, 1),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1,horizontal: 5),
            width:  width <=350 ? width/6: width <=500 ? width/7:width/8,
            alignment: Alignment.center,
            child: Center(
              child: TextFormField(
                    keyboardType: keyBoard,
                    maxLength: 1,
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    // controller: Textcontroller,
           
                    
                      decoration: InputDecoration(
                  counterText: '',  // Hide the counter
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: Colorcodes.budgetDarkGreen
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: Colorcodes.budgetDarkGreen
                    )
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: Colorcodes.budgetDarkGreen
                    )
                  ),
                ),
                
                    onChanged: (value) => _handleTextChanged(value, index),
                    
                ),
            ),
          ),
        ),
      );


  }

   final int _otpLength = 6;
  late List<TextEditingController> _controllers= List.generate(_otpLength, (_) => TextEditingController());
  late List<FocusNode> _focusNodes=List.generate(_otpLength, (_) => FocusNode());


  
  @override
  void initState() {
    super.initState();
    // _controllers = List.generate(_otpLength, (_) => TextEditingController());
    // _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  }
 

 
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     TextEditingController emailController= TextEditingController();
     TextEditingController passwordController= TextEditingController();


       return   Scaffold(
      backgroundColor: Colorcodes.budgetDarkGreen,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [



          Padding(
            padding:  EdgeInsets.symmetric(vertical: Colorcodes.paddingTopDesign/1.4),
            child: Text(("Security Pin"),
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.black)),
          ),
          
          Expanded(
            child: Container(
                 width: MediaQuery.of(context).size.width,
                   height: MediaQuery.of(context).size.height,
                    // margin:  EdgeInsets.only(top: Colorcodes.paddingTopDesign/2),
                    padding:  EdgeInsets.symmetric(vertical: Colorcodes.paddingTopScroll),
                   decoration: BoxDecoration(
                      color: Colorcodes.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Colorcodes.borderCut),
                            topRight: Radius.circular(Colorcodes.borderCut),
                           )
            
                   ),
                    child: ListView(
                          
                          children: [
            
                         const SizedBox(height: 30,),
                         Container(
                          width: MediaQuery.of(context).size.width/1.4,
                          // color: Colorcodes.barGraphOrange,
                           child: Center(
                             child: Text((StringConstant.otpText),
                                                    style: FontManager().getTextStyle(context,
                                                                                lWeight: FontWeight.bold,
                                                                                fontSize: 20,
                                                                                color: Colorcodes.iconBackGround)),
                           ),
                         ),
            
                         const SizedBox(height: 30,),
            
            
                           Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
            
                                       InputDate("email/phone number",TextInputType.number,emailController,0),
                                       InputDate("username",TextInputType.number,passwordController,1),
                                       InputDate("Date of birth",TextInputType.number,passwordController,2),
                                       InputDate("password",TextInputType.number,passwordController,3),
                                       InputDate("password",TextInputType.number,passwordController,4),
                                       InputDate("password",TextInputType.number,passwordController,5),
                                 ],
                             ),
                       
                  
                        
                        SizedBox(height: Colorcodes.paddingSize*2,),
                              
                           Center(
                             child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Container(
                                   width: MediaQuery.of(context).size.width/2,
                                   margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                   padding:const EdgeInsets.symmetric(vertical: 10),
                                   decoration: BoxDecoration(
                                                color: Colorcodes.budgetDarkGreen,
                                                     borderRadius: BorderRadius.circular(Colorcodes.borderRadius30)
                                                ),
                                   child: InkWell(
                                                              onTap: (){
                                       String opt="";
                                             
                                         for(int i=0;i< _controllers.length;i++)
                                          { 
                                                if(_controllers[i].text==""){
                                                  snackBarAllFeilds(context,Colors.red);
                                                  return;
                                                }
                                          }

                                          _controllers.forEach((element) { 
                                               opt += element.text;
                                          });
                                           acceptReset.value=true;
                                           checkEmail(context,widget.email, opt,widget.name);
                                      },
                                     child:Obx(() =>  Center(
                                                    child: acceptReset.value? Spinner(size: 20,color: Colorcodes.white,): Text(("Accept"),
                                                    style: FontManager().getTextStyle(context,
                                                                                lWeight: FontWeight.bold,
                                                                                fontSize: 20,
                                                                                color: Colorcodes.iconBackGround)),
                                                  )),
                                   ),
                                 ),
                               ],
                             ),
                           ),
            
            
                            Center(
                             child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Container(
                                   width: MediaQuery.of(context).size.width/2,
                                   margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                   padding:const EdgeInsets.symmetric(vertical: 10),
                                   decoration: BoxDecoration(
                                                color: Colorcodes.budgetLightGreen,
                                                     borderRadius: BorderRadius.circular(Colorcodes.borderRadius30)
                                                ),
                                   child: InkWell(
                                                              onTap: (){
                                                                //  Navigator.pushNamed(context,'/signup');
                                                                resendOpt(context, widget.email, widget.name);  
                                                              },
                                     child: Center(
                                                    child: Text(("Send Again"),
                                                    style: FontManager().getTextStyle(context,
                                                                                lWeight: FontWeight.bold,
                                                                                fontSize: 20,
                                                                                color: Colorcodes.iconBackGround)),
                                                  ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                              
                          ],
                    ),
            ),
          ),
        ],
      ),
    );

   
    // return SafeArea(
    //   child: Scaffold(
    //     body: Container(
    //            height: MediaQuery.of(context).size.height,
    //           //  padding:const EdgeInsets.only(bottom: 20),
    //            child:   SingleChildScrollView(
    //              child: Column(
    //                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                  crossAxisAlignment: CrossAxisAlignment.center,
    //                  children: [
    //                      ClipRRect(
    //                          borderRadius: BorderRadius.only(
    //                              bottomLeft: Radius.circular(100)
    //                          ),
    //                          child: Container( 
    //                             padding:const EdgeInsets.all(25),
    //                              color: Colorcodes.debtBody,
    //                             // color:  Color.fromRGBO(97, 143, 214, 1),  //rgba(97, 143, 214, 1)
    //                             child: Center(child: Text(("signup"),
    //                             style: FontManager().getTextStyle(context,
    //                           lWeight: FontWeight.w400,
    //                           fontSize: 25,
    //                           color: Colors.white))),
    //                          ),
    //                        ),
      
    //                        const SizedBox(height: 100,),
      
      
    //                        Container(
    //                          padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20),
    //                          decoration: BoxDecoration(
    //                           color: Color.fromRGBO(249, 246, 238, 1),
    //                           borderRadius: BorderRadius.circular(50)
                                 
    //                          ),
    //                          child: Column(
    //                             mainAxisAlignment: MainAxisAlignment.center,
    //                             children: [
    //                               Text(("confirmation code"),
    //                               style: FontManager().getTextStyle(context,
    //                                                         fontSize: 17,
    //                                                         color: Colors.black)),
    //                             ],
    //                           ),
    //                        ),
      
    //                          const SizedBox(height: 40,),
                        
                          //  Row(
                          //      mainAxisAlignment: MainAxisAlignment.center,
                          //      children: [
                          //            InputDate("email/phone number",TextInputType.number,emailController,0),
                          //            InputDate("username",TextInputType.number,passwordController,1),
                          //            InputDate("Date of birth",TextInputType.number,passwordController,2),
                          //            InputDate("password",TextInputType.number,passwordController,3),
                          //            InputDate("password",TextInputType.number,passwordController,4),
                          //            InputDate("password",TextInputType.number,passwordController,5),
                          //      ],
                          //  ),
                                        
                                        
    //                             const SizedBox(height:100,),                       
                                              
                                              
    //                         Row(
    //                           mainAxisAlignment: MainAxisAlignment.center,
    //                           children: [
    //                             GestureDetector(
    //                               onTap: () {
                                    // String opt="";

                                    // _controllers.forEach((element) { 
                                    //      opt += element.text;
                                    // });
                                   
                                    //  storeData(context,widget.data, opt, widget.url);
    //                               },
    //                               child: Container( 
    //                                 padding:const EdgeInsets.symmetric(horizontal:35,vertical: 10),
    //                                 decoration: BoxDecoration(
    //                                 // color:const Color.fromRGBO(97, 143, 214, 1),
    //                                 color: Colorcodes.debtBody,
    //                                      borderRadius: BorderRadius.circular(5)
    //                                 ),
    //                                 child: Text(("Sign Up"),
    //                                 style: FontManager().getTextStyle(context,
    //                                                             lWeight: FontWeight.w400,
    //                                                             fontSize: 20,
    //                                                             color: Colors.white)),
    //                                                    ),
    //                             ),
    //                           ],
    //                         )
                           
                            
                       
                       
    //                  ],
    //              ),
    //            ),
    //      ),
    //   ),
    // );
  }


    void _handleTextChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }


}


