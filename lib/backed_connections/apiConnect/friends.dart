
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';





void   addUserAsFrd(id,context)async
{
     //print(id);
      final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
     
    final response = await http.post(
    Uri.parse('${url}/user/friend/add/${id}'),
        headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Authorization": "$accessToken",
        },
      //   body: jsonEncode({
      //        'friendId':id,
      //  }),

  );
      
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            snackBarCalled(context,"Adding user As Friend...!",Colors.black);
            
      }else{
          //  snackBarCalled(context,"can't Add Friend!",Colors.red);
}
}

void  rejectFrdRequest(body,context)async
{
    
      final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
   
    final response = await http.post(
    Uri.parse('${url}/user/friend/rejectRequest'),
        headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken",
        },
        body: jsonEncode(body),

  );
      //printData(response,context);
       //print("rejectRequest ");
      //print(response.statusCode);
      //print(response.body);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            // snackBarCalled(context,"Rem user As Friend...!",Colors.black);
            
      }else{
          snackBarCalled(context,"can't Reject error Friend!",Colors.red);
}

}


void   addUsersendRequest(id,name,context)async
{
   
      final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
     
    final response = await http.post(
    Uri.parse('${url}/user/friend/sendRequest'),
    headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
             'userName':name,
             'friendUserId':id,
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            snackBarCalled(context,"Sending Friend Request...!",Colors.black);

            //  Navigator.pop(context); 
            //  Navigator.pushNamed(context, '/TribeHome'); 
            
      }else{

           snackBarCalled(context,"can't Add Request!",Colors.red);
}
}

void  removeRequest(id,name,context)async
{
   
      final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
     
    final response = await http.post(
    Uri.parse('${url}/user/friend/unsendRequest'),
    headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
             'userName':name,
             'friendUserId':id,
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            snackBarCalled(context,"Removed Friend Request...!",Colors.black);

            //  Navigator.pop(context); 
            //  Navigator.pushNamed(context, '/TribeHome'); 
            
      }else{

           snackBarCalled(context,"can't remove Request!",Colors.red);
}
}



  void  getRemoveFrds(context,id)async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
     
     final response = await http.post(
    Uri.parse('${url}/user/friend/remove/${id}'),
    headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
  );

      if(response.statusCode==200 || response.statusCode==201)
      {
                  snackBarCalled(context,"Removed Friend...!",Colors.black);
                  getUserInfomations();  
      }
      else{
          
      }
}


