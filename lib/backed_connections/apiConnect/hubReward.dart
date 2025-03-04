
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



  void  getHub()async
{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
    final response = await http.get(
    Uri.parse('https://stakeplot.in/api/v1/hub/fetch'),
    
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
     
  
      if(response.statusCode==200)
      {
                  var  his=jsonDecode(response.body);
                  var obj=his['data'];
                
                    
                    // hubImage.clear();
                    // hubImageTop.clear();
                    // hubImageBottom.clear();
                    // hubImage.addAll(obj);
                   
                    //  hubImage.forEach((element) { 
                    //          if(element['description']!=null){
                    //                hubImageBottom.add(element);
                    //          }else{
                    //                 hubImageTop.add(element);
                    //          }
                    //  }); 
                  
                //  if(hubImageTop.length>=5 ){
                //        RxList hubImageTop2=[].obs;
                //        hubImageTop2 = hubImageTop.sublist(0,5) as RxList;
                //        hubImageTop.clear();
                //        hubImageTop.addAll(hubImageTop2);
                //  }


      }
      else{
         
      }
 
}





void  getproduct()async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
    try{
    final response = await http.get(
    
    Uri.parse('https://stakeplot.in/api/v1/products/fetch'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
    printData(response, BuildContext);
      if(response.statusCode==200)
      {
                  var  his=jsonDecode(response.body);
                  List obj=his['data'];
                  productList.clear();
                  productList.addAll(obj);
                
      }
      else{
      
      }
    }catch(e){

    }
 
}




void addVoucher(context,var data)async{
    
    var body={ "voucherObj":{
              "code": "FRITH4567",
              "brandName": data['brandName'],
              "companyUrl": data['companyUrl'],
              "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5MJTPdSJ3_soEKVTMdP3C1QAnsLKqINpsCq3wbwCqUA&s",
              "offerExpiry": data['offerExpiry']
       }};

   
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");

    final response = await http.post(
    Uri.parse('https://stakeplot.in/api/v1/products/vouchers/add'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode(body),
  );
      printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
          
            snackBarCalled(context,"Updated users Info!",Colors.black);   
      }else{

           snackBarCalled(context,"can't edit User Info error!",Colors.red);
      }
}

void addLiked(context,String id)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");

    final response = await http.post(
    Uri.parse('https://stakeplot.in/api/v1/products/like/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({}),
  );
      // printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            // likedProducts.add(id);
            snackBarCalled(context,"Liked Product!",Colors.black);   
      }else{

           snackBarCalled(context,"error to add liked!",Colors.red);
      }
}




