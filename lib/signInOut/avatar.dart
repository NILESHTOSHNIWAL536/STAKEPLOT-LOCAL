
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/signInOut/confirm.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';








class Avatar extends StatefulWidget {
   var data;
   Avatar({ Key? key,required this.data }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Avatar> {

 int index = 0;
  
  PageController _pageController = PageController(
  initialPage: 0,
);


 List<String> images=[
        "assets/avatar/menp1.svg",
        "assets/avatar/menp2.svg",
        "assets/avatar/menp3.svg",
        "assets/avatar/menp4.svg",
        "assets/avatar/womenp1.svg",
        "assets/avatar/womenp2.svg",
        "assets/avatar/womenp3.svg",
        "assets/avatar/womenp4.svg",
  ];

  int activePage = 3;
 

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colorcodes.budgetDarkGreen,
      body: Container(
             height: MediaQuery.of(context).size.height*2,
            //  padding:const EdgeInsets.only(bottom: 20),
             child: SingleChildScrollView(
               child: Column(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                      
                       
                          const SizedBox(height: 20,),
                           Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(("Choose Avatar...!"), // email already exists..! or other errors
                                      style: FontManager().getTextStyle(context,
                                                                 fontSize: 18,
                                                                 letterSpacing: 1.2,
                                                                lWeight: FontWeight.bold,
                                                                color: Colors.black)),
                                ),
                          ),
               
                         Container(
                            height: MediaQuery.of(context).size.height/4,
                            // width: 200,
                            child: SvgPicture.asset(
                                   images[activePage],
                                                     ),
                          ),
                          const SizedBox(height: 10,),
                           Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: Text((!widget.data['name'].toString().isEmpty?widget.data['name']:"Nilesh Toshniwal"), // email already exists..! or other errors
                                      style: FontManager().getTextStyle(context,
                                                                fontSize: 18,
                                                                   letterSpacing: 1.2,
                                                                lWeight: FontWeight.w400,
                                                                color: Colors.black)),
                                ),
                          ),
               
                          avatarSlider(),
                          // avatarSlider2(),

                          const SizedBox(height: 20,),
               
                          GestureDetector(
                            onTap: () {
                                //  storeData(context);
                                snackBarCalled(context,"Sended Otp To Email Id...!",Colors.green);
                                getOTP(context, widget.data['name'], widget.data['email']);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => conform(data: widget.data,url: images[activePage],),
                                  ),
                              );
                            },
                            child: Container( 
                                      width: MediaQuery.of(context).size.width/2,
                                        padding:const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                        color:Colorcodes.budgetLightGreen,
                                             borderRadius: BorderRadius.circular(5),
                                             border: Border.all(
                                              color: Colorcodes.budgetLightGreen,
                                              width: .5

                                             )
                                        ),
                                        child: Center(
                                          child: Text(("Sign Up"),
                                          style: FontManager().getTextStyle(context,
                                                                      lWeight: FontWeight.w400,
                                                                      fontSize: 20,
                                                                      color: Colorcodes.iconBackGround)),
                                      ),
                                                   ),
                          ),
               
               
                            
                     
                   ],
               ),
             ),
       ),
    );
  }
  

// Widget avatarSlider2(){
    // return   Container(
    //             width: MediaQuery.of(context).size.width,
    //              height: MediaQuery.of(context).size.height/3,
    //             // color: Colors.red,
    //             // height: MediaQuery.of(context).size.height/2,
    //             padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20),
    //             child: CarouselSlider.builder(
    //             itemCount: images.length,
                
    //             itemBuilder: (context, index, realIndex) {
    //                 return  Container(
    //                                height: MediaQuery.of(context).size.height/4,
                                   
    //                                color: Colorcodes.appBarColor,
    //                                margin: EdgeInsets.symmetric(horizontal: 2),
                                  
    //                               child: SvgPicture.asset(
    //                              images[index],
    //                              width: MediaQuery.of(context).size.width,
    //                      ),
    //                             );
    //             },
    //           options: CarouselOptions(
    //              aspectRatio: 1.3,
    //              height: 400,
    //             //  autoPlay: true,
                 
    //              onPageChanged: (position,reason){
    //             setState(() {
    //                   activePage=position;
    //             });
    //             },
                
    //           )
               
    // ));       

}



Widget avatarSlider(){
  return Text("");
//   return  
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                  height: MediaQuery.of(context).size.height/3,
//                 // color: Colors.red,
//                 // height: MediaQuery.of(context).size.height/2,
//                 padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20),
//                 child: CarouselSlider(

//               options: CarouselOptions(
//                 // aspectRatio: 1.6,
//                  aspectRatio: 2,
//                  enlargeCenterPage:true,
//                 viewportFraction: 0.3,
//                  height: MediaQuery.of(context).size.height/3.5,
//                 // enlargeCenterPage: true,
//                 // autoPlay: true,
//                 initialPage: 3,
//                 onPageChanged: (position,reason){
//                 setState(() {
//                       activePage=position;
//                 });
//                 },
//                 enableInfiniteScroll: false,
                
//               ),
//               items: images.map<Widget>((i) {
//                 return Builder(
//           builder: (BuildContext context) {
//             return SvgPicture.asset(
//                                i,
//                               //  width: 10,
//                               //  height: 10,
//                        );
//           },
//                 );
//               }).toList(),
//             )
               
//               );       

// }


}





 void storeData(context,data,String opt,Avatarurl)async{

   String name=data['name'];
   String email=data['email'];
   String password=data['userpassword'];
   String conform=data['confirmPassword'];
   String phone=data['phone'];
   String dob=data['dob'];


    // if(name=="" || email=="" || password=="" || conform=="" || phone=="" || dob==""){
    //     snackBarCalled(context, "pls enter all feilds",Colors.red);
    //     return;
    // }

    
    // if(password.length<6)
    // {
    //      snackBarCalled(context, "Password must be atleast 6 characters",Colors.red);
    //      return;
    // }

    // if(password!=conform)
    // {
    //      snackBarCalled(context, "Password and Conform password doesn't match",Colors.red);
    //      return;
    // }
     
     final response = await http.post(
      
    Uri.parse('${url}/user/register'),
    // Uri.parse('https://stakeplot-bk4z.onrender.com/api/v1/user/register'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
           'name':name,
            'email': email,
            'userpassword':password,
            'confirmPassword':conform,
            'phone':phone,
            'dob':dob,
            'avatarType':Avatarurl,
            'otp':opt
       }),
    

  );

try{

  
  var data2=jsonDecode(response.body);
 
  bool boolvar=data2['success'];


   acceptReset.value=false;
  if(!boolvar)
  {
                snackBarCalled(context, data2['error']['explanation'],Colors.red);
                return;
  } 
    
   snackBarCalled(context,"User Registered Successfully...!",Colors.green);
  //  Navigator.pushReplacementNamed(context, '/LinkedBackAccount'); 

    

    // Navigator.pushReplacement(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) => LinkedBackAccount(email: email,Password: password,),
    //                   ),
    // );

}catch(e){
       snackBarCalled(context,"InValid Otp...!",Colors.red);
}


}



