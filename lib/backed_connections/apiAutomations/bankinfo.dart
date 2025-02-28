


import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

void getBankAccounts()async
{
    var response=await getDataApiCall("${url}/transactionauto/get-banks-linked/");

        printData(response);
    if(getFlagOfResponse(response)){
            var his = jsonDecode(response.body);
            print(his);
    }

}