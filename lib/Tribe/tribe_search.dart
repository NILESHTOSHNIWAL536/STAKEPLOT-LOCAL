import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_application_code_stakeplot/Community_Page/maskedNameDialogbox.dart";
import "package:flutter_application_code_stakeplot/Constants/colors.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/helper.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/room_poll_chart.dart";
import "package:flutter_application_code_stakeplot/bottomNavigations.dart";
import "package:flutter_application_code_stakeplot/controllers/controllerManagement.dart";
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import "package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart";
import "package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart";
import "package:flutter_application_code_stakeplot/loader.dart";
import "package:flutter_application_code_stakeplot/profile_screen/communityProfileScreen.dart";
import "package:flutter_application_code_stakeplot/profile_screen/usercommunityProfile.dart";
import "package:flutter_application_code_stakeplot/user_chat/chat.dart";
import "package:flutter_application_code_stakeplot/user_chat/tribe_chart.dart";
import "package:get/get.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:http/http.dart' as http;
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import 'package:flutter_application_code_stakeplot/Constants/search.dart';

import "../routes/route_user_login.dart";
import "../routes/route_post.dart";


List ids = [];

class TribeSearch extends StatefulWidget {
  bool isMasked=false;
   TribeSearch({Key? key,this.isMasked=false}) : super(key: key);

  @override
  _TribeSearchState createState() => _TribeSearchState();
}

class _TribeSearchState extends State<TribeSearch> {
  TextEditingController search = TextEditingController();

  List frdsList = [];
  List frdsListOrigin = [];
  bool frdsThere = false;
  
  TextEditingController about = TextEditingController();
  String dataReport = "";
  List getTrendingData = [];
  RxList getuerPost = [].obs;
  List frds = [];
  bool findData = true;
  RxBool finduserPost = true.obs;
  bool already = false;
  RxInt count = 0.obs;
  RxInt score = 0.obs;
  RxBool fl = false.obs;
  RxBool reload = false.obs;
  RxString buttonValue="Add".obs;
  RxString frdRequest="Friend Request not sent before".obs;
  RxString frdRequestCheck="Friend Request not sent before".obs;

  @override
  void initState() {
    super.initState();
    getTransaction();
  }


  void getDis(data) async {
    
    final response = await getDataApiCall(
        "${PostRoutes.userDiscussions}/${data['_id']}");
    
    if (getFlagOfResponse(response)) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
       
       setState(() {
        getTrendingData = obj;

       });
   
    } else {}
  }

  void getConnections(data) async {
    
    final response = await getDataApiCall(
        "${UserRoutes.connections}/${data['_id']}/${widget.isMasked}");
   

    if (getFlagOfResponse(response)) {
      var his = jsonDecode(response.body);
      
      setState(() {
       count.value = his['data']['connections'];
      });
      // fl.value = !fl.value;
    
    } else {}
  }
  
  void getStatus(data) async {
   
    UserController userController =ControllerManagement.userController;
    if(widget.isMasked){
         bool isMasked = userController.maskedConnections.any((friend) => friend['_id'] == data['_id']);
          if(!isMasked) buttonValue.value="Add";
          else  buttonValue.value="Remove";

      return;
    }
    
    final response = await postDataApiCall(UserRoutes.acceptRequestStatus,{
        'friendUserId':data['_id'],
     }
    );
   

    if (getFlagOfResponse(response)) {
      var his = jsonDecode(response.body);
       frdRequestCheck.value=his['data'];
        if(frdRequestCheck.value=="Friend Request already sent"){
                    buttonValue.value="Requested";
        }
        else if(frdRequestCheck.value=="Friend Request not sent before"){
                    buttonValue.value="Add";
        }
        else if(frdRequestCheck.value=="User is already your friend")
        {
                    buttonValue.value="Remove";
        }else{
             buttonValue.value="Accept";
        }
      
    } else {}
  }


 
  void getTransaction() async {   
    var response=await getDataApiCall("${UserRoutes.findFriend}/${widget.isMasked}");
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
      setState(() {
        // frdsList = obj;
        frdsListOrigin = obj;
        frdsThere = true;
        frdsList =[]; 
      });
    } else {}
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(child: BottomNavigations(data: widget.isMasked ? 2 : 1)),
      extendBody: true,
      body: SafeArea(
        child: Container(
          color: AppColors.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: ListView(
           
            children: [
              Hero(
                  tag: "TribeSearc",
                  child: InputDate("Search", TextInputType.name, search)),
              const SizedBox(
                height: 20,
              ),
              !frdsThere
                  ? Loader()
                  : frdsList.isEmpty
                      ? Text(search.text.isEmpty?"":"No Users Found!")
                      : Column(
                          children: frdsList
                              .map((data) => profileContainer(data))
                              .toList(),
                        )
            ],
          ),
        ),
      ),
    );
  }

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
       
         width: MediaQuery.sizeOf(context).width/1.07,
                height: MediaQuery.sizeOf(context).width *(32/348),
        child: Center(
          child: TextFormField(
            keyboardType: keyBoard,
            controller: Textcontroller,
            onChanged: (value) 
            {
              setState(() {
                if(value=="")frdsList=[];
                else frdsList = getLastTenUsers(getSearchData(value, frdsListOrigin,widget.isMasked));
              });
              
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
              hintText: lableText,
              
              fillColor: AppColors.backgroundColor,
              border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
            ),
          ),
        ),
      ),
    );
  }
Widget profileContainer(data) {
  // Early return if critical fields are null
  if (data['name'] == null || data['avatarType'] == null) {
    return SizedBox.shrink(); // or return a placeholder widget
  }

  // Ensure non-null values with defaults
  String name =widget.isMasked? (data['maskedName'] ?? ""):(data['name'] ?? "Unknown User");
  String background = data['avatarBackGround'] ?? defaultBackGround.value ?? "#FFFFFF"; // Fallback to a default color
  if(name=="")return SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
    child: Center(
      child: InkWell(
        onTap: () {
          //************Dont remove this lines....
          if(!widget.isMasked)
          {
              getDis(data);
              getStatus(data);
              getConnections(data);
              showmodalWidget(data);
          }else{
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityUserProfile(data: data,ids:[],flag: true,isMasked: widget.isMasked,),
                      ),
                  );
          }

            },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                children: [
             widget.isMasked?  AvatarProfile2(url: data['avatarType'], width: 20, height: 20)
                   :   AvatarProfile(
                    name: name,
                    width: 30,
                    height: 13,
                    background: background,
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Text(
                      name,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.accentColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Divider(),
            ],
          ),
        ),
      ),
    ),
  );
}
  // Widget profileContainer(data) {
  //   if (data['name'] == null || data['avatarType'] == null) {}
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
  //     child: Center(
  //         child: InkWell(
  //       onTap: ()
  //       {
          
  //         getDis(data);
  //         getStatus(data);
  //         getConnections(data);
  //         showmodalWidget(data);

  //       },
  //       child: Container(
  //         padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
  //         width: MediaQuery.of(context).size.width,
  //         child: Column(
  //           children: [
  //             Row(
  //               children: [
                 
  //                 AvatarProfile(name: data['name'], width: 30, height: 13,background:data['avatarBackGround'] ?? defaultBackGround.value,),

  //                 const SizedBox(
  //                   width: 5,
  //                 ),

  //                 Container(
  //                   width: MediaQuery.of(context).size.width / 1.5,
  //                   //  color: Colorcodes.black,
  //                   child: Text(
  //                     (data['name'] ?? "name"),
  //                     style: FontManager().getTextStyle(context,
  //                         lWeight: FontWeight.bold,
  //                         fontSize: 18,
  //                         color: AppColors.accentColor),
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Divider(),
  //           ],
  //         ),
  //       ),
  //     )),
  //   );
  // }


void showmodalWidget(data){
       showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return getScreen(data);
                            },
   );

}


  Widget getScreen(data){
     String avatar= data['avatarType'] !=null ? data['avatarType']
    :data['avatar']!=null?data['avatar']:ControllerManagement.userController.avatar;

      String name =widget.isMasked? (data['maskedName'] ?? ""):(data['name'] ?? "Unknown User");


      return Container(
         width: MediaQuery.of(context).size.width,
         height: MediaQuery.of(context).size.height/3,
         decoration: const BoxDecoration(
        //  color: Colorcodes.white,
         borderRadius: BorderRadius.only(
          topLeft: Radius.circular(70),
          topRight: Radius.circular(70)
         )

         ),
         child: Column(
           children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  width: MediaQuery.of(context).size.width/6,
                  height: 3,
                  decoration: BoxDecoration(
                     color: AppColors.primaryColor,
                     borderRadius: BorderRadius.circular(10)
                     
                  ),
                
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   networkFriends("Network",count.toString(),Icons.person_2_outlined),
                    AvatarProfile(name: name, width: 5, height: 10,background:data['avatarBackGround'] ?? defaultBackGround.value,flag: true,),
                    networkFriends("Posts",getTrendingData.length.toString(),Icons.post_add),
                  ],
                ),
                const SizedBox(height: 5,),     
                Text(name.toString(),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w600,
                       color: AppColors.bg1)),
               
                const SizedBox(height:10),

                 InkWell(
                  onTap: (){
          if (buttonValue.value=="Remove") {
                getRemoveFrds(context, data['_id']);
                 buttonValue.value="Add";
            } else if (buttonValue.value=="Add"){
                if(widget.isMasked){
                   if(ControllerManagement.userController.maskedName.value.trim().isEmpty)MaskedNameDialogBox.showMaskedNameDialog(context);
                   else{
                      buttonValue.value="Remove";
                      addUserAsFrd(data['_id'], context,"Masked");
                   }
                }
                else{
                buttonValue.value="Requested";
                addUsersendRequest(data['_id'], data['name'], context);
                }
            }
              else if(buttonValue.value=="Requested")
              {
                      buttonValue.value="Add";
                      removeRequest(data['_id'], data['name'], context);
              }
            else {
               buttonValue.value="Remove";
               addUserAsFrd(data['_id'], context);
            }
                  },
                   child: Padding(
                     padding: const EdgeInsets.symmetric(vertical: 10),
                     child:Obx(()=> getButton(context, buttonValue.value =="Add" ?  widget.isMasked? "Connect":buttonValue.value:buttonValue.value)),
                   ),
                 ),

                //  Row(
                //    children: [
                //      GestureDetector(
                //   onTap: (){
                //           messages.clear();
                //           var item={
                //             '_id': data['_id'],
                //             'name': data['name'],
                //             'avatar': avatar,
                //             'avatarBackGround': data['avatarBackGround'] ?? defaultBackGround.value,
                //           };
                //           unSeenChat(context, item['_id']);
                //           getChatLoader(ismaskedUsers.value);
                //           getChats(item);
                //           clear(item);
                //           ismaskedUsers.value = true;
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) =>
                //                   Chat(data: item, myId: currentId.value, myprofile: {}),
                //             ),
                //           );
                //   },
                //   child: getButton(context, "chat",AppColors.bg5,AppColors.primaryColor)
                // ),
                    //  GestureDetector(
                    //   onTap: (){
                    //      Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => CommunityUserProfile(data: data,ids:[],flag: true,),
                    //       ),
                    //     );
                    //   },
                    //   child: getButton(context, "View Profile",AppColors.bg5,AppColors.primaryColor)),
                  //  ],
                //  ),
                 

                     


           ],
         ),
      );
   }


   Widget networkFriends(String network,String count,IconData icon){
      return Column(
        children: [
          Container(
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 14),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primaryColor,
                      width: .5
                  ),
              ),
              child:Row(
                children: [
                   Icon(icon,size: 20,),
                   textStyle(context: context,text: count.toString(),fontWeight: FontWeight.bold,fontsize: 12),
                ],
              )  
          ),
          const SizedBox(height: 5,),
          textStyle(context: context,text: network.toString(),fontWeight: FontWeight.w400,fontsize: 12),
        ],
      );
  }

}
