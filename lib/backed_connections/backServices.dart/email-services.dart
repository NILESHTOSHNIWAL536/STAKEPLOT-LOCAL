import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';

import '../apiAutomations/curd.dart';

Future<void> revokeEmailAccess(BuildContext context)async 
{
  // implement the function to delete email access
   try {
    var res = await deleteDataApiCall(AuthApiRoutes.revokeAccessToken);
    printData(res);
    if (getFlagOfResponse(res))
    {
      snackBarCalled(context, "Email access deleted successfully");
    }else 
    {
      snackBarCalledfail(context, "Failed to delete email access");
    }
   } catch (e)
    {
     snackBarCalledfail(context, "Error in deleting email access");
   }
}