import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/opt_email.dart';
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
            
                                       InputDate("email/phone number",TextInputType.number,_controllers[0],0),
                                       InputDate("username",TextInputType.number,_controllers[1],1),
                                       InputDate("Date of birth",TextInputType.number,_controllers[2],2),
                                       InputDate("password",TextInputType.number,_controllers[3],3),
                                       InputDate("password",TextInputType.number,_controllers[4],4),
                                       InputDate("password",TextInputType.number,_controllers[5],5),
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
  }


    void _handleTextChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }


}


