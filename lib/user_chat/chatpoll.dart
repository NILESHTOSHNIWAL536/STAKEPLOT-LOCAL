import "dart:convert";
import "dart:math";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/bottomNavigations.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";
import "package:flutter_application_code_stakeplot/user_chat/chat.dart";
import "package:get/get.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


class chatPoll extends StatefulWidget {
  var data;
  chatPoll({ Key? key,required this.data}) : super(key: key);

  @override
  _PollState createState() => _PollState();
}

class _PollState extends State<chatPoll> {
  TextEditingController question= TextEditingController();
  TextEditingController optionsController1= TextEditingController();
  TextEditingController optionsController2= TextEditingController();
  TextEditingController optionsController3= TextEditingController();
  TextEditingController optionsController4= TextEditingController();
   TextEditingController Textcontroller= TextEditingController();
   int index=1;
  List list=[0];
     TextEditingController titleController= TextEditingController();
     TextEditingController descriptionsController= TextEditingController();
    List<TextEditingController> controllers = [ TextEditingController(), TextEditingController()];

    List frdsList=[];
    List frdsOrigin=[];
  bool frdsThere=true;
  bool showFrds=false;
   List  addedUser=[];
  List addedMembers=[];
  var data={};
  var userDetails=[];



  @override
  void initState() {
    super.initState();
    getTransaction();
  }

    void  getTransaction()async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
    final response = await http.get(
    Uri.parse('${url}/user/info'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
      if(response.statusCode==200)
      {
                  var  his=jsonDecode(response.body);
                  var obj=his['data'];
                  


                 
                   setState(() {
                    frdsList=obj['friendsList'];
                    frdsOrigin=frdsList;
                    frdsThere=false;
                    data={
                      
                                      "name": obj['name'],
                                      "id": obj['_id'],
                    };
                  });
      }
      else{
      }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:  BottomNavigations(data: 3),
       extendBody: true,
      appBar: AppBar(
           backgroundColor: Colorcodes.appBarColor,
           leading: InkWell(
            onTap: (){
                Navigator.pop(context);
            },
             child: Icon(
                Icons.arrow_back_ios_new_rounded
             ),
           ),
           title:  Text(("Create Poll"),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500,
                          fontSize: 22,
                          color: Colors.black)),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              pollOptions(),

            ],
          ),
        ),
      ),
    );
  }




Widget pollOptions(){
    return Container(
          child: Column(
               children: [
                            const SizedBox(height: 20,),
             InputDate("Question",TextInputType.name,question),
             InputDate("Option 1",TextInputType.name,optionsController1),
             InputDate("Option 2",TextInputType.name,optionsController2),
             InputDate("Option 3",TextInputType.name,optionsController3),
             InputDate("Option 4",TextInputType.name,optionsController4),
             const SizedBox(height: 20,),

            InkWell(
                              onTap: (){

                                if( optionsController1.text=="" ||
                                     optionsController2.text =="" ||
                                     optionsController3.text =="" ||
                                     optionsController4.text =="" ||
                                     question.text =="" )
                                     {
                                        snackBarAllFeilds(context);
                                        return;
                                     }


                                  List options=[];
                                options.add({           
                                    "option": optionsController1.text,
                                });
                                options.add({           
                                    "option": optionsController2.text,
                                });
                                options.add({           
                                    "option": optionsController3.text,
                                });
                                options.add({           
                                    "option": optionsController4.text,
                                });

                             

                               var userDetails={
                                   'id':widget.data['_id'],
                                   'name':widget.data['name']
                               };

                               var members=[userDetails,data];
                               
                               
                
                                createPoll(context,question.text,options,{},members,"casual");
                             
                                Get.to(Chat(data: widget.data, myId: widget.data['_id'],myprofile: "",));
                               
                               
                              },
                              child: Container( 
                                width: MediaQuery.of(context).size.width/1.2,
                                padding:const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                color:const Color.fromRGBO(97, 143, 214, 1),
                                     borderRadius: BorderRadius.circular(5)
                                ),
                                child: Center(
                                  child: Text(("Send"),
                                  style: FontManager().getTextStyle(context,
                                                              lWeight: FontWeight.w400,
                                                              fontSize: 20,
                                                              color: Colors.white)),
                                ),
                                                   ),
                            ),  

               ], 
          ),
    );
}


Widget roomCreations(){
     return   Center(
       child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  const SizedBox(height: 40,),
                  
                  Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                                               
                   
                              InputDate("Name",TextInputType.name,titleController),
                              Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: (){
                                          setState(() {
                                            showFrds=!showFrds;
                                          });
                                  },
                                  child: Container(
                                     padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                      width: MediaQuery.of(context).size.width/1.1,
                                      // height: 50,
                                      color: Colorcodes.appBarColor,
                                      child: Text("Add Members",
                                      textAlign:TextAlign.start ,
                                      style:FontManager().getTextStyle(context,
                                          lWeight: FontWeight.w400
                                      ),),
                                  ),
                                ),
                              ),
                              
                            addedMembers.length>0?Container(
                                width: MediaQuery.of(context).size.width,
                                height: 70,
                                child: ListView(
                                      scrollDirection: Axis.horizontal,
                                     children: addedMembers.map((element) {
                                     
                                      return Container(
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                       Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                         children: [
                                                        const  Padding(
                                                            padding:  EdgeInsets.all(0.0),
                                                            child:  Icon(
                                                                 Icons.person,
                                                                 size: 30,
                                                             ),
                                                          ),
                                                           InkWell(
                                                            onTap: (){
                                                       List me=[];
                                                              addedMembers.forEach((ele) {
                                                                     if(element['id']!=ele['id']){
                                                                        me.add(ele);
                                                                     }
                                                              });

                                                              setState(() {
                                                                   addedMembers=me;
                                                                   addedUser.remove(element['id']);
                                                              });
                                                             
                                                            },
                                                             child:const Icon(
                                                                 Icons.close,
                                                             ),
                                                           ),
                                                         ],
                                                       ),
                                                       Text(element['name'])

                                               ],
                                          ),
                                     
                                     );}).toList(),
                                ),
                              ):SizedBox.shrink(),


                            showFrds?  commentedData():SizedBox.shrink(),
                              

                              Padding(
                               padding:const EdgeInsets.only(right: 10),
                               child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                           InkWell(
                                            onTap: () {
                                                  setState(() {
                                                     int x=list.last;
                                                     list.add(x+2);
                                                     controllers.add( TextEditingController());
                                                     controllers.add( TextEditingController());
                                                    
                                                 }); 
                                            },
                                             child:const Icon(
                                                Icons.add_circle_outline_rounded,
                                                color: Colors.black,
                                                size: 35,
                                             ),
                                           ),
                                    ],
                                ),
                             ),


                               
                                    
                         Column(
                            children: list.map((e) {
                                return Row(
                                     children: [
                                             InputAmount("Expense",TextInputType.name,controllers[e]),
                                             InputAmount("Amount",TextInputType.number,controllers[e+1]),
                                     ],
                                 );
                                  
                            
                            }).toList(),
                          ),

                            
                            
                             
                            
          
                          SizedBox(height: 30,),              
                                       
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         InkWell(
                             onTap: (){
                              //  Navigator.pushNamed(context, '/TribeHome'); 
                            
                            String name=titleController.text;
                            List members=  [data];
                            members.addAll(addedMembers); 
                           
                            List expenses=[];

                            
                            for(int i=0;i<controllers.length;i+=2){
                                    String name=controllers[i].text.toString();
                                    String amount=controllers[i+1].text.toString();
                                    String date=DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
                                    var item={
                                         "name": name,
                                        "amount": amount,
                                        "date": date,
                                        "users":members
                                    };
                                    expenses.add(item);
                            }


                            
                            createRoom(context, expenses,members, name);


                            },
                           child: Container( 
                             padding:const EdgeInsets.symmetric(horizontal:100,vertical: 12),
                             decoration: BoxDecoration(
                             color:const Color.fromRGBO(97, 143, 214, 1),
                                  borderRadius: BorderRadius.circular(10)
                             ),
                             child: Text(("Create"),
                             style: FontManager().getTextStyle(context,
                                                         lWeight: FontWeight.w400,
                                                         fontSize: 20,
                                                         color: Colors.white)),
                                                ),
                         ),
                       ],
                     ),
                     
                                 
                       ],
                    ),
                  )
                  
              
              
              
            ],
        ),
     );

}



Widget InputDate(lableText,keyBoard,Textcontroller){

    return Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          // color:  Color.fromRGBO(246, 246, 246, 1),
          width: MediaQuery.of(context).size.width/1.1,
          // height: 50,
          child: Center(
            child: TextFormField(
                 keyboardType: keyBoard,
                  controller: Textcontroller,
                   
                   decoration: InputDecoration(
                        filled: true,
                        hintText: lableText,
                        enabledBorder: OutlineInputBorder(
                          // borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                              // color:Colors.white
                              color: Color.fromRGBO(249, 246, 238, 1)
                          )
                        ),
                         focusedBorder: OutlineInputBorder(
                          // borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(
                              color: Color.fromRGBO(246, 246, 246, 1)
                          )
                        ),
                        fillColor:Colorcodes.appBarColor,
                        border: InputBorder.none,
                      ),
            
                    
              ),
          ),
        ),
      );
  }

Widget InputDat(lableText,keyBoard,Textcontroller){

    return Center(
        child: Container(
          // padding: EdgeInsets.symmetric(vertical: 5),
          color:  Color.fromRGBO(246, 246, 246, 1),
          width: MediaQuery.of(context).size.width/1.1,
          height: 50,
          child: Center(
            child: TextFormField(
                 keyboardType: keyBoard,
                  controller: Textcontroller,

                  onChanged: (v){
                       var frdsList2=[];

                       if(v==""){
                           frdsList=frdsOrigin;
                       }

                       frdsList.forEach((element) {

                           if(element['name'].toString().contains(v)){
                              frdsList2.add(element);
                           }
                            
                      });

                      setState(() {
                        frdsList=frdsList2; 
                      });
                  },
                   
                   decoration: InputDecoration(
                        filled: true,
                        hintText: lableText,
                        enabledBorder: OutlineInputBorder(
                          // borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                              // color:Colors.white
                              color: Color.fromRGBO(249, 246, 238, 1)
                          )
                        ),
                         focusedBorder: OutlineInputBorder(
                          // borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(
                              color: Color.fromRGBO(246, 246, 246, 1)
                          )
                        ),
                        fillColor:Colors.white,
                        border: InputBorder.none,
                      ),
            
                    
              ),
          ),
        ),
      );
  }



  
Widget InputAmount(lableText,keyBoard,Textcontroller){

    return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: Container(
            // padding: EdgeInsets.symmetric(vertical: 2),
            width: MediaQuery.of(context).size.width/2.8,
            height: 50,
            child: Center(
              child: TextFormField(
                   keyboardType: keyBoard,
                    controller: Textcontroller,
                     
                     decoration: InputDecoration(
                          filled: true,
                          hintText: lableText,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(250, 249, 246, 1)
                            )
                          ),
                           focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(250, 249, 246, 1)
                            )
                          ),
                         fillColor:Colorcodes.appBarColor,
                          border: InputBorder.none,
                        ),
                        
                        
                ),
            ),
          ),
        ),
      );

  }




   Widget commentedData() {
    
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
       child: Container(
             padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(249, 246, 238, 1),
                    borderRadius: BorderRadius.circular(4)),
             child: Column(
                  children: [
                        InputDat('Search',TextInputType.name,Textcontroller),
                        
                      Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                height: 150,
                                child: GridView.builder(
                                  itemCount: frdsList.length, // +1 for loading more indicator
                                  itemBuilder: (context, index) {
                                    String  values=frdsList[index]['_id'];
                                    return InkWell(
                                      onTap: (){},
                                      child: Column(
                                        children: [
                                           GestureDetector(
                                            onTap: (){
                                              
                                                setState(() {
                                                       addedUser.contains(values) ?addedUser.remove(values) :addedUser.add(values);
                                          if(addedUser.contains(values)){
                                           addedMembers.add(
                                              {
                                                  "name": frdsList[index]['name'],
                                                  "id": values,
                                                  "balance": 200
                                              },
                                           );
                                          }else{
                                                List f=[];
                                               addedMembers.forEach((element) {
                                                       if(element['id']!=values){
                                                              f.add(element);
                                                       }
                                                }); 

                                                setState(() {
                                                     addedMembers=f;
                                                });
                                          }
                                                });
                                            },
                                             child: Container(
                                                    // color:Colors.deepOrangeAccent, 
                                                     width: MediaQuery.of(context).size.width/5,
                                                     height: 50,
                                                    // backgroundColor:const Color.fromRGBO(249, 246, 238, 1), 
                                                     child:  Stack(
                                                       children: [
                                                     
                                                      const  Center(
                                                           child: Icon(
                                                                Icons.person_outline_sharp,
                                                                size: 40,
                                                                color: Colors.black,
                                                              ),
                                                         ),
                                                      addedUser.contains(values) ?const Positioned(
                                                              right: 0,
                                                              top: 0,
                                                             child: Icon(
                                                              Icons.check,
                                                              size: 30,
                                                              color: Colors.green,
                                                                                                                   ),
                                                           ):const SizedBox.shrink(),
                                                       ],
                                                     ),
                                                     ),
                                           ),
                                                    Text((frdsList[index]['name']),
                                                        style: FontManager().getTextStyle(context,
                                                              lWeight: FontWeight.w400,
                                                              fontSize: 14,
                                                              color: Colors.black))
                                        ],
                                      ),
                                    );
                                  },
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // Number of columns
                                    crossAxisSpacing: 0.0, // Spacing between columns
                                    mainAxisSpacing: 0.0, // Spacing between rows
                                  ),
                                ),
                                ),
                              ),     
                  ],
             ),
       ),
     );
  }



}