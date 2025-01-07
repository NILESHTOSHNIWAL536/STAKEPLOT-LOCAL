
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';







    void  getDebts()async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
   
    final response = await http.get(
    Uri.parse('${url}/debt/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

      if(response.statusCode==200 || response.statusCode==201)
      {
            var  his=jsonDecode(response.body);
            var obj=his['data'];
            debtLength.value=obj.length;
            debtsList.clear();
            debtsList.addAll(obj);
      }
      else{
          //  //print("Error while getting data");
      }
}




     getBudget()async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
    
    final response = await http.get(
    Uri.parse('${url}/budget/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

      if(response.statusCode==200)
      {
            var  his=jsonDecode(response.body);
            var obj=his['data'];
            budgetList.clear();
            budgetList.addAll(obj);
            budgetLength.value=obj.length;
      }
      else{
      }
 
}
    
  getBills()async{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
   
    final response = await http.get(
    Uri.parse('${url}/bill/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

      if(response.statusCode==200 || response.statusCode==201)
      {
            var  his=jsonDecode(response.body);
            var obj=his['data'];
             billLength.value=obj.length;
            //  billAmount.clear();
            //  billAmount.addAll(obj);
      }
      else{
      }
 
}

     getPayments()async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
    
    final response = await http.get(
    Uri.parse('${url}/payment/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

      if(response.statusCode==200 || response.statusCode==201)
      {
            var  his=jsonDecode(response.body);
            var obj=his['data'];
            paymentLength.value=obj.length;
            // payment.clear();
            // payment.addAll(obj);
           
      }
      else{
      }
 
}



void addBudget(context,name,amount,expenseCategory,budgetType,budgetPeriod)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
    
     budgetLength.value++;

    final response = await http.post(
    Uri.parse('${url}/budget/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'name': name.toString(),
            'amount':amount.toString(),
            'expenseCategories':expenseCategory.toString(),
            'budgetType':budgetType.toString(),
            'budgetPeriod':budgetPeriod.toString(),
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);

            snackBarCalled(context,'Added Budget!');
            getBudget();
              // Navigator.pushNamed(context, '/BudgetCheck'); 
                 acceptReset.value=false;
            Navigator.pop(context); 
            // Navigator.pop(context); 
            //  Navigator.pushReplacement(
            //                         context,
            //                         PageTransition(
            //                           type: PageTransitionType.bottomToTop,
            //                           alignment: Alignment.bottomRight,
            //                           duration: Durations.long1,

            //                           child:const BudgetCheck(),
            //                           isIos: true,
            //                         ),
            // );
            
      }else{
              snackBarCalled(context,"can't add bedget!",Colors.red);
      }

      acceptReset.value=false;

}


void budgetUpdate(context,name,amount,expenseCategory,budgetType,budgetPeriod,id)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
     
    final response = await http.post(
    Uri.parse('${url}/budget/edit/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'name': name.toString(),
            'amount':amount.toString(),
            'expenseCategories':expenseCategory,
            'budgetType':budgetType.toString(),
            'budgetPeriod':budgetPeriod.toString(),
       }),
  );
      // printData(response,context);
      // //print(object)
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);

            snackBarCalled(context,'Updated Budget successfully!!');
              // Navigator.pushNamed(context, '/BudgetCheck'); 
            Navigator.pop(context); 
            Navigator.pop(context); 
            
            //  Navigator.push(
            //                         context,
            //                         PageTransition(
            //                           type: PageTransitionType.fade,
            //                           alignment: Alignment.bottomRight,
            //                           duration: Durations.long1,

            //                           child:const BudgetCheck(),
            //                           isIos: true,
            //                         ),
            // );
            
      }else{
              snackBarCalled(context,"can't Update bedget!",Colors.red);
      }

}

void  addDebts(context,name,amount,interest,startDate,durations)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
     debtLength.value = 1 + debtLength.value ;
    final response = await http.post(
    Uri.parse('${url}/debt/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'name': name.toString(),
            'amount':amount,
            'interest':interest.toString(),
            'startDate':startDate.toString(),
            'duration':durations,
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);

               snackBarCalled(context,'Added Debt!');
                 acceptReset.value=false;
            //  Navigator.pushNamed(context, '/DebtsBillAmoutDisplay'); 

            //  SchedulePaymentsDisplay

            //   Navigator.pop(context); 
            getDebts();
             Navigator.pop(context); 

            //    Navigator.pushReplacement(
            //                         context,
            //                         PageTransition(
            //                           type: PageTransitionType.bottomToTop,
            //                           alignment: Alignment.bottomRight,
            //                           duration: Durations.long1,

            //                           child:const Budget(),
            //                           isIos: true,
            //  ));
           
            //  Navigator.push(
            //                         context,
            //                         PageTransition(
            //                           type: PageTransitionType.bottomToTop,
            //                           alignment: Alignment.bottomRight,
            //                           duration: Durations.long1,

            //                           child:DebtsBillAmoutDisplay(),
            //                           isIos: true,
            //  ));
            
      }else{
              snackBarCalled(context,"can't add Debt!",Colors.red);
      }
        acceptReset.value=false;

}




void addBillTranscations(List<TextEditingController> controller,context)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
    // //print("bills called");
    int end=controller.length;

    // //print("bills called2");
     for(int i=0;i<end;i+=3)
     {
                billLength.value += 1;
                String name=controller[i].text;
                String amount=controller[i+1].text;
                String expenseCategory=controller[i+2].text;
   
    final response = await http.post(
    Uri.parse('${url}/bill/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'name': name.toString(),
            'amount':amount,
            'dueDate':expenseCategory.toString(),
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
         

              acceptReset.value=false;
            snackBarCalled(context,"Add Bill!",Colors.black);
            getBills();
            Navigator.pop(context); 
            //  Navigator.pop(context); 
              
            //   Navigator.pushReplacement(
            //                         context,
            //                         PageTransition(
            //                           type: PageTransitionType.bottomToTop,
            //                           alignment: Alignment.bottomRight,
            //                           duration: Durations.long1,

            //                           child:const Budget(),
            //                           isIos: true,
            //  ));
           
            //  Navigator.push(
            //                         context,
            //                         PageTransition(
            //                           type: PageTransitionType.bottomToTop,
            //                           alignment: Alignment.bottomRight,
            //                           duration: Durations.long1,

                                      // child:const AddBillAmoutDisplay(),
            //                           isIos: true,
            //  ));
            // // Navigator.pushNamed(context, '/AddBillAmoutDisplay'); 
            // // Navigator.pop(context); 
            
      }else{
          snackBarCalled(context,"can't add Bill!",Colors.red);
      }
      acceptReset.value=false;
    }

}

void addPaymentTranscations(List<TextEditingController> controller,context)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
    
    int end=controller.length;

    // paymentLength.value += (end/3) as int;

     for(int i=0;i<end;i+=3)
     {
                paymentLength.value += 1;
                String name=controller[i].text;
                String amount=controller[i+1].text;
                String expenseCategory=controller[i+2].text;
              
   
    final response = await http.post(
    Uri.parse('${url}/payment/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'name': name.toString(),
            'amount':amount,
            'date': expenseCategory.toString(),
       }),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);     
              acceptReset.value=false;
            snackBarCalled(context,"Add payment!",Colors.black); 
            
                getPayments();
            //  Navigator.pushNamed(context, '/bsDisplay'); 
             Navigator.pop(context);         

      }else{
           snackBarCalled(context,"can't Add Payment!",Colors.red);
      }
        acceptReset.value=false;
      // Navigator.pushNamed(context, '/SchedulePaymentsDisplay');
    } 

  
    // Navigator.pop(context); 

}





void deleteDebts(context,String id,[flag=false])async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
    final response = await http.delete(
    Uri.parse('${url}/debt/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({}),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
             snackBarCalled(context,"Closed Debts...!",Colors.black);
             debtLength.value--;
             getDebts();
             if(flag)return;
            // Navigator.pushReplacement(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => Budget(),
            //           ),
            //       );  
      }else{
           snackBarCalled(context,"error while Closing Debts...!",Colors.red);
      }

}


void deleteAmount(context,String id,String am)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
    final response = await http.patch(
    Uri.parse('${url}/debt/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({}),
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            
      }else{
           snackBarCalled(context,"error while Closing Debts...!",Colors.red);
      }

}




void updateBill(context,String path,String objectId)async{
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");
     String pathUrl='${url}/${path}/${objectId}';
   
    final response = await http.patch(
    Uri.parse(pathUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
    body: jsonEncode({
            'markAsComplete':true,
       }),
  );

      // printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            final body = json.decode(response.body);
            getBills();
            getPayments();
             snackBarCalled(context,"${path} is paid!",Colors.black);   
      }else{
           snackBarCalled(context,"error while updating!",Colors.red);
      }

}


void deleteBudget(context,String id)async{
  
    final SharedPreferences _pref = await SharedPreferences.getInstance();
     var  accessToken=_pref.getString("accessToken");

   
    final response = await http.delete(
    Uri.parse('${url}/budget/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
       "Authorization": "$accessToken",
    },
  );
      //printData(response,context);
      if(response.statusCode==200 || response.statusCode==201){
            snackBarCalled(context,"Deleting Budget.....!",Colors.red);

            //  Navigator.pop(context);
          //   Navigator.push(
          //   context,
          //   PageTransition(
          //     type: PageTransitionType.fade,
          //      duration: Durations.long1,
          //     child: BudgetCheck(),
          //     isIos: true,
          //   ),
          // ); 
            
      }else{

           snackBarCalled(context,"Deleted Budget error!",Colors.red);
      }
}


void clearDebts(context,String id,String amount,String value) async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var accessToken = _pref.getString("accessToken");
   
  
    var body =
    {
            'amount': amount,
            'label': "",
            'account': value,
            'category': "",
            'isDebt': true,
            'remainderId': id,
            'merchantId': 'assxx',
    };
    //print(body);
    
    final response = await http.post(
      Uri.parse('${url}/transaction/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode(body),
    );
     printData(response, context);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      snackBarCalled(context, "Cleared Debts OF This Month!", Colors.black);
      //  Navigator.pushReplacementNamed(context, '/home');
    } else {
      snackBarCalled(context, "can't Add Trasactions!", Colors.red);
    }
  }


  void  getNewBudget()async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
    
    final response = await http.get(
    Uri.parse('${url}/budget/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

      if(response.statusCode==200)
      {
            var  his=jsonDecode(response.body);
            var obj=his['data'];
           
               budgetList.clear();
                 budgetLength.value=obj.length;
               budgetList.addAll(obj);
      }
      else{
      }
 
}



    void  getDebts2()async
{
    
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    var  accessToken=_pref.getString("accessToken");
    
    final response = await http.get(
    Uri.parse('${url}/debt/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

      if(response.statusCode==200 || response.statusCode==201)
      {
            var  his=jsonDecode(response.body);
            var obj=his['data'];

          
           
            // // setState(() {
            //    debtsList.clear();
            //    debtsList.addAll(obj);
            //    getdata=false;
            // // });
          
      }
      else{
           
      }
 
}




void getUserLend(context)async
{
    String urlPath ="${url}/bill/lend";
    var responce=await getDataApiCall(urlPath);
    if(getFlagOfResponse(responce))
    {
        var  his=jsonDecode(responce.body);
        var userLend=his['data'];
        lendAmountRemainders.clear();
        lendAmountRemainders.addAll(userLend);
    }
}


