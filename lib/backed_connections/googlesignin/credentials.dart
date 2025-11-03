// ignore_for_file: non_constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Credentials
{
    static  String androidClientId = dotenv.env['GOOGLE_CLIENT_ID_ANDROID']??"";
    static  String iosClientId = dotenv.env['GOOGLE_CLIENT_ID_IOS']??""; 
    static  String  serverClientId= dotenv.env['GOOGLE_CLIENT_ID_SERVER']??""; 
    static  String  oneSignal= dotenv.env['One_Signal_AppId']??""; 
    static  String  LIVE_API= dotenv.env['API_URL'] ??""; 
    static  String  LIVE_API_TEST= dotenv.env['API_URL_Local'] ?? dotenv.env['API_URL'] ?? ""; 
    static  String  LIVE_API2= dotenv.env['EMAIL_API_URL'] ??""; 
    static  String  LIVE_API_TEST2= dotenv.env['EMAIL_API_URL_Local'] ?? dotenv.env['EMAIL_API_URL'] ?? ""; 
    static  String  FINVU_LIVE= dotenv.env['Finvu_API_URL'] ??""; 
    static  String  FINVU_TEST= dotenv.env['Finvu_API_URL_Local'] ?? dotenv.env['Finvu_API_URL'] ?? ""; 
    static  String  TestUser= dotenv.env['TESTUSER'] ??""; 
    static  String  FinvuUrl= dotenv.env['FinvuUrl'] ??""; 
    static  String  Live_finvu_api= dotenv.env['Live_finvu_api'] ?? ""; 
    static  String  Dev_finvu_api= dotenv.env['Dev_finvu_api'] ?? ""; 
    static  String  Sign_Up_Key= dotenv.env['Sign_Up_Key'] ?? ""; 
}