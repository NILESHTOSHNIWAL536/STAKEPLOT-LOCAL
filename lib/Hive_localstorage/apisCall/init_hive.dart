import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/user_apis.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../user-data/user_model.dart';

void GetLocalStorage()async
{
        final dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
        Hive.registerAdapter(UserModelAdapter());
        await Hive.openBox<UserModel>('userBox');
        callLocalDataBaseoftheUser(); 
}


void callLocalDataBaseoftheUser()async
{
    loadUserFromHive();     
}