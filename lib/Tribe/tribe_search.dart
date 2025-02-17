import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Tribe/userDetails.dart";
import "package:flutter_application_code_stakeplot/avatarProfile.dart";
import "package:flutter_application_code_stakeplot/bottomNavigations.dart";
import "package:flutter_application_code_stakeplot/loader.dart";
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

  @override
  void initState() {
    super.initState();
    getTransaction();
    // getNotifications();
  }

  void getNotifications() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
    final response = await http.get(
      Uri.parse('${url}/user/myNotifications'),
      // Uri.parse('https://stakeplot.in/api/v1/post/all'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );

    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);
      var obj = his['data'];

      obj.forEach((e) {
        if (e['notificationMessage']['type'] == "friendRequest") {
          e = e['notificationMessage'];
          ids.add(e['from_id']);
        }
      });
      //
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

        frdsList = getLastTenUsers(frdsListOrigin);
        frdsThere = true;
      });
    } else {}
  }

  List getLastTenUsers(List allUsers) {
    // Determine the number of users to take
    int numberOfUsersToTake = allUsers.length < 10 ? allUsers.length : 10;

    // Get the last `numberOfUsersToTake` users
    List lastUsers = allUsers.sublist(allUsers.length - numberOfUsersToTake);

    // Reverse the list
    return lastUsers.reversed.toList();
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
                    ? Text("No Users Found...!")
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
                frdsList =
                    getLastTenUsers(getSearchData(value, frdsListOrigin));
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
        onTap: () {
          //  UserDetails
          // Navigator.pushNamed(context, '/UserDetails');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetails(data: data, ids: ids),
            ),
          );
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
                          url: data['avatarType'] ?? userAvatar,
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
}
