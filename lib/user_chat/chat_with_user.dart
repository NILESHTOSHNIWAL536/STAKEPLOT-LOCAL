import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/bottomNavigations.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class TribeChatsUser extends StatefulWidget {
  final data;
  const TribeChatsUser({ Key? key ,required this.data}) : super(key: key);

  @override
  _TribeSearchState createState() => _TribeSearchState();
}

class _TribeSearchState extends State<TribeChatsUser> {
  TextEditingController search= TextEditingController();


    List frdsList=[];
    bool frdsThere=true;


    @override
  void initState() {
    super.initState();
    getTransactions();
  }


  void  getTransactions()async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
    final response = await http.get(
    Uri.parse('https://stakeplot.in/api/v1/user/info'),
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
                    frdsThere=false;
                  });
      }
      else{
      }
 
}


  @override
  Widget build(BuildContext context) {
    List data=["Nilesh","Sai Teja","Manaish","Kamlesh","Krishna"];




    return Scaffold(
      bottomNavigationBar:  BottomNavigations(data: 3),
       extendBody: true,
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(("chats"),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w500,
                            fontSize: 22,
                            color: Colors.black)),
                                        Container(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: ()
                            {
                                    Navigator.pushNamed(context, '/Poll');  
                            },
                            child: imageurl("assets/images/Add_round.svg")),
                        ],
                      ),
                                        )
                                      ],
                                    ),
                    ),

              Divider(),

              const SizedBox(height: 16,),

                     InputDate("Search",TextInputType.name,search),

                     Column(
                          children: data.map((d) => profileContainer(d)).toList(),
                     )



            ],
          ),
        ),
      ),
    );
  }




  Widget InputDate(lableText,keyBoard,Textcontroller){

    return Center(
        child: Container(
          // padding: EdgeInsets.symmetric(vertical: 5),
          // color:  Color.fromRGBO(246, 246, 246, 1),
          width: MediaQuery.of(context).size.width/1.1,
          height: 40,
          child: Center(
            child: TextFormField(
                 keyboardType: keyBoard,
                  controller: Textcontroller,
                   
                   decoration: InputDecoration(
                        filled: true,
                         suffixIcon: Icon(Icons.search),
                        hintText: lableText,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color:Colors.white
                              // color: Color.fromRGBO(249, 246, 238, 1)
                          )
                        ),
                         focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Color.fromRGBO(246, 246, 246, 1)
                          )
                        ),
                        fillColor: Color.fromRGBO(246, 246, 246, 1),
                        border: InputBorder.none,
                      ),
            
                    
              ),
          ),
        ),
      );
  }
  
 Widget profileContainer(name) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 20),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 10),
             decoration: BoxDecoration(
             color:const Color.fromRGBO(249, 246, 238, 1),
                 borderRadius: BorderRadius.circular(10)
             ),
            width: MediaQuery.of(context).size.width/1.1,
            child: Row(
                 children: [
                         const Icon(
                                Icons.person_pin_sharp,
                                size: 35,
                                color: Colors.black,
                              ), 
        
                        const SizedBox(width: 20,),
        
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((name),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Colors.black)),
                          Text(("message.."),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w300,
                                fontSize: 13,
                                color: Colors.black)),
                        ],
                      ),
                      const Spacer(),

                       Container(
                    child: Row(
                      children: [
                        InkWell(
                            onTap: (){
                                    Navigator.pushNamed(context, '/TribeSearch');  
                            },
                            child: imageurl("assets/images/Chat.svg")
                          ),
                       const SizedBox(
                          width: 3,
                        ),
                        InkWell(
                          onTap: (){
                                    
                                    Navigator.pushNamed(context, '/TribeChats');  
                            },
                          child: imageurl("assets/images/Chat.svg")),
                      ],
                    ),
                  )

                       
        
                 ],
            ),
          )
          ),
      );
 }



  Widget imageurl(url) {
    return SvgPicture.asset(
      url,
      height: 25,
    );
  }


}