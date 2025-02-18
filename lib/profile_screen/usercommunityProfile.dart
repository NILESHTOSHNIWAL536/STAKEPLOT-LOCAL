import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CommunityUserProfile extends StatefulWidget {
   final data;
  final List ids;
  bool flag = false;
  CommunityUserProfile(
      {Key? key, required this.data, required this.ids, this.flag = false})
      : super(key: key);


  @override
  State<CommunityUserProfile> createState() => _CommunityProfileScreenState();
}

class _CommunityProfileScreenState extends State<CommunityUserProfile> {

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
   File? _profileImage;
  File? _coverImage;

  final dummyData = {
    "name": "Rohit Sharma",
    "username": "@rohit45_",
    "posts": "Posts Content",
    "polls": "Polls Content",
    "exploria": "Exploria Content"
  };
  String _networkImageUrl =
      "https://static.vecteezy.com/system/resources/thumbnails/045/713/367/small_2x/aesthetic-leaves-on-a-dark-background-free-photo.jpg"; // This can be dynamically set



  @override
  void initState() {
      getDis();
      getStatus();
      getConnections();
  }

  void getDis() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/post/userDiscussions/${widget.data['_id']}'),
      // Uri.parse('https://stakeplot.in/api/v1/post/all'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    print(widget.data);
    printData(response);
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
       
       setState(() {
        getTrendingData = obj;
        findData = false;
       });
      getuerPost.clear();
      getuerPost.addAll(obj);
      getTrendingData.forEach((element) {
        postCount[element["_id"]] =
            element['upvotes'] < 0 ? 0 : element['upvotes'];
      });
   
    } else {}
  }

  void getConnections() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    
    final response = await http.get(
      Uri.parse(
          '${url}/user/connections/${widget.data['_id']}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );

    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      
       count.value = his['data']['connections'];
       score.value = his['data']['score'];
      // fl.value = !fl.value;
    } else {}
  }
  void getStatus() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    
    final response = await http.post(
      Uri.parse("${url}/user/friend/acceptRequestStatus"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
       body: jsonEncode({
          'userName':widget.data['name'],
          'friendUserId':widget.data['_id'],
       }),
    );

    if (response.statusCode == 200) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg5,
      // bottomNavigationBar: BottomNavigations(data: 4),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            // Top Cover and Profile Picture
            topUserProfile(widget.data),
           
            const SizedBox(height: 60),
            
            Column(
              children: [
                Text(widget.data['name'].toString(),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w600,
                        //fontSize: MediaQuery.of(context).size.width * 0.04,
                        //fontSize: 12,
                        color: AppColors.bg1)),
                Text((widget.data['email'] ?? "").toString(),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w400,
                        //fontSize: MediaQuery.of(context).size.width * 0.04,
                        //fontSize: 12,
                        color: AppColors.userName)),
        
                DefaultTabController(
                  length: 3, // Number of tabs
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: DecoratedBox(
                          decoration: const BoxDecoration(),
                          child: TabBar(
                            indicator: BoxDecoration(
                              // Rounded corners
        
                              color: AppColors.tab,
        
                              borderRadius: BorderRadius.circular(16),
                            ),
                            // Padding for labels
                            labelColor: AppColors
                                .primaryColor, // Text color for selected tab
                            unselectedLabelColor: AppColors
                                .bg1, // Text color for unselected tabs
        
                            tabs: const [
                              Tab(child: Text('Posts')),
                              Tab(text: 'Polls'),
                              // Tab(text: 'Exploria'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height/1.609, // Adjust as needed for TabBarView
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 12.0),
                          child: TabBarView(
                            children: [
                              Center(child: feedWidgets("post")),
                              Center(child: pollWidgets("poll")),
                             
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget feedWidgets(String type) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Column(
                children: findData?[Spinner()] : getTrendingData.length == 0
                ? [Center(
                    child: Text("No Post Yet",
                        style: FontManager().getTextStyle(context)))]
                :   getTrendingData.map((item) => (item['isPoll'] ?? false)? const SizedBox.shrink(): PostCard(data: item)).toList(),
              ),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }



  Widget pollWidgets(String type) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Container(
            //     child: Wrap(
            //         children: getTrendingData
            //             .map((item) => (item['isPoll'] ?? false)
            //                 ? PostCard(data: item)
            //                 : SizedBox.shrink())
            //             .toList())),
            Container(
              child: Column(
                children: findData?[Spinner()] : getTrendingData.length == 0
                ? [Center(
                    child: Text("No Post Yet",
                        style: FontManager().getTextStyle(context)))]
                :   getTrendingData.map((item) => !(item['isPoll'] ?? false)? const SizedBox.shrink(): PostCard(data: item)).toList(),
              ),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }




  Widget topUserProfile(data){
     String avatar= data['avatarType'] !=null ? data['avatarType']
    :data['avatar']!=null?data['avatar']:userAvatar;

     return  Stack(
                clipBehavior: Clip.none,
                children: [
                  // Positioned button to edit cover image
                  Positioned(
                    top: 20,
                    right: 16,
                    child: TextButton.icon(
                      onPressed: () {
                        // _pickImage(ImageSource.gallery, "cover");
                      },
                      label: const Text(
                        'Edit cover',
                        style: TextStyle(color: AppColors.bg1),
                      ),
                      icon: const Icon(Icons.edit),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Add the action to be triggered on tap, like picking an image
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height/6,
                      // height: 200,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        image: _coverImage != null
                            ? DecorationImage(
                                image: FileImage(_coverImage!),
                                fit: BoxFit.cover,
                              )
                            : _networkImageUrl != null &&
                                    _networkImageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(_networkImageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: AssetImage(
                                        'assets/cover_placeholder.jpg'), // Default placeholder asset
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 140,
                    left:  MediaQuery.of(context).size.width /6.7,
                    child: networkFriends("Network",count.toString(),Icons.person_2_outlined),
                  ),

                  Positioned(
                    top: 140,
                    left: MediaQuery.of(context).size.width / 1.45,
                    child: networkFriends("Posts",getTrendingData.length.toString(),Icons.post_add),
                  ),
                  
                  Positioned(
                    top: 80,
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: GestureDetector(
                      // onTap: () => _pickImage(ImageSource.gallery, "profile"),
                      child: CircleAvatar(
                        radius: 50,
                        child: ProfileImage(url:avatar  ??""),
                      ),
                    ),
                  ),
                ],
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
