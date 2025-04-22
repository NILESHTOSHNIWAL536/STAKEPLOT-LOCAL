import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/helper.dart";
import "package:flutter_application_code_stakeplot/Tribe/userDetails.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/friends.dart";
import "package:flutter_application_code_stakeplot/bottomNavigations.dart";
import "package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart";
import "package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart";
import "package:flutter_application_code_stakeplot/loader.dart";
import "package:flutter_application_code_stakeplot/profile.dart";
import "package:flutter_application_code_stakeplot/profile_screen/usercommunityProfile.dart";
import "package:flutter_svg/svg.dart";
import "package:get/get.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:http/http.dart' as http;
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import "package:flutter_application_code_stakeplot/colorcodes.dart";

List ids = [];

class TribeSearch extends StatefulWidget {
  const TribeSearch({Key? key}) : super(key: key);

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
      // getDis();
      // getStatus();
      // getConnections();
  }


  void getDis(data) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/post/userDiscussions/${data['_id']}'),
      // Uri.parse('https://stakeplot.in/api/v1/post/all'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
   
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];
       
       setState(() {
        getTrendingData = obj;

       });
   
    } else {}
  }

  void getConnections(data) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    
    final response = await http.get(
      Uri.parse(
          '${url}/user/connections/${data['_id']}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );

    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      
      setState(() {
       count.value = his['data']['connections'];
      });
      // fl.value = !fl.value;
    
    } else {}
  }
  void getStatus(data) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    
    final response = await http.post(
      Uri.parse("${url}/user/friend/acceptRequestStatus"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
       body: jsonEncode({
          'userName':data['name'],
          'friendUserId':data['_id'],
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


 
  void getTransaction() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/user/friends/find'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);

      var obj = his['data'];

      setState(() {
        frdsList = obj;
        frdsListOrigin = obj;
        // frdsList = getLastTenUsers(frdsListOrigin);
        frdsThere = true;
        frdsList =[]; //getLastTenUsers(getSearchData("", frdsListOrigin));
      });
    } else {}
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigations(data: sizeRoom ? 3 : 2),
      extendBody: true,
      body: Container(
        // height: MediaQuery.of(context).size.height+400,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //  const SizedBox(height: 20,),
            Hero(
                tag: "TribeSearc",
                child: InputDate("Search", TextInputType.name, search)),
            const SizedBox(
              height: 20,
            ),
            !frdsThere
                ? Loader()
                : frdsList.isEmpty
                    ? Text(search.text.isEmpty?"":"No Users Found...!")
                    : Column(
                        children: frdsList
                            .map((data) => profileContainer(data))
                            .toList(),
                      )
          ],
        ),
      ),
    );
  }

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        // margin: EdgeInsets.symmetric(vertical: 5),
        // color:  Color.fromRGBO(246, 246, 246, 1),
        // height: 50,
        width: MediaQuery.of(context).size.width / 1.1,
        child: Center(
          child: TextFormField(
            keyboardType: keyBoard,
            controller: Textcontroller,
            onChanged: (value) {
              setState(() {
                if(value=="")frdsList=[];
                else frdsList = getLastTenUsers(getSearchData(value, frdsListOrigin));
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              //prefixIconColor: Colorcodes.budgetDarkGreen,
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
              hintText: lableText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                // borderSide: BorderSide(color: Colorcodes.budgetDarkGreen
                //     // color: Color.fromRGBO(249, 246, 238, 1)
                //     )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                //borderSide: BorderSide(color: Colorcodes.budgetDarkGreen)
              ),
              fillColor: AppColors.button,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget profileContainer(data) {
    if (data['name'] == null || data['avatarType'] == null) {}
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Center(
          child: InkWell(
        onTap: ()
        {
          
          getDis(data);
          getStatus(data);
          getConnections(data);
          showmodalWidget(data);

        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                children: [
                  //  const Icon(
                  //         Icons.person_pin_sharp,
                  //         size: 35,
                  //         color: Colors.black,
                  //       ),

                  Container(

                      // width: MediaQuery.of(context).size.width/8,
                      // height: MediaQuery.of(context).size.height/18,
                      child: AvatarProfileImage(
                          url:avaterUrlPath( data['name'] ?? userAvatar) ,
                          width: 20,
                          height: 20)),
                  const SizedBox(
                    width: 5,
                  ),

                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    //  color: Colorcodes.black,
                    child: Text(
                      (data['name'] ?? "name"),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.accentColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Divider(),
            ],
          ),
        ),
      )),
    );
  }


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
    :data['avatar']!=null?data['avatar']:userAvatar;

      return Container(
         width: MediaQuery.of(context).size.width,
         height: MediaQuery.of(context).size.height/2.7,
         decoration: BoxDecoration(
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
                    CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: SvgPicture.asset(
                      avaterUrlPath(data['name']),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                    networkFriends("Posts",getTrendingData.length.toString(),Icons.post_add),
                  ],
                ),
                const SizedBox(height: 5,),     
                Text(data['name'].toString(),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w600,
                        //fontSize: MediaQuery.of(context).size.width * 0.04,
                        //fontSize: 12,
                        color: AppColors.bg1)),
                // Text((data['email'] ?? "").toString(),
                //     style: FontManager().getTextStyle(context,
                //         lWeight: FontWeight.w400,
                //         //fontSize: MediaQuery.of(context).size.width * 0.04,
                //         //fontSize: 12,
                //         color: AppColors.userName)),
                const SizedBox(height:10),

                 InkWell(
                  onTap: (){
                       if (buttonValue.value=="Remove") {
                getRemoveFrds(context, data['_id']);
                 buttonValue.value="Add";
            } else if (buttonValue.value=="Add"){
                buttonValue.value="Requested";
                addUsersendRequest(data['_id'], data['name'], context);
            }
              else if(buttonValue.value=="Requested"){
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
                     child:Obx(()=> getButton(context, buttonValue.value =="Add" ? "Connect":buttonValue.value)),
                   ),
                 ),

                 GestureDetector(
                  onTap: (){
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityUserProfile(data: data,ids:[],flag: true,),
                      ),
                    );
                  },
                  child: getButton(context, "View Profile",AppColors.bg5,AppColors.primaryColor)),

                     


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
