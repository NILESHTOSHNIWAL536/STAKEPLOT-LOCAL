import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void verify(String otp, context) async {
  print(otp);
  print(otpReference);
  print(finvuManager.isConnected());

  
  try {
    print(1);
    var login = await finvuManager.verifyLoginOtp(
      otp,
      otpReference,
    );
    print(2);
    print(login);
    print(login.userId);

    final SharedPreferences _pref = await SharedPreferences.getInstance();
    String? token = await _pref.getString("token");
    print("token 1");
    clearStackLocalInfo();
    getLinkedAccountInfo();
    print("token 2");

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiscoverAccount(),
                      ),
                  );
                  
  } catch (e) {
    print("error====");
    print(e);
    snackBarCalled(context, "Invalid Otp/Number...");
  }
}

class FinvuAccount extends StatefulWidget {
  const FinvuAccount({Key? key}) : super(key: key);

  @override
  _FinvuAccountState createState() => _FinvuAccountState();
}

class _FinvuAccountState extends State<FinvuAccount> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _initFinvuManager();
  }

  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _initFinvuManager() async {
    finvuManager.initialize(
      FinvuConfig(
        finvuEndpoint: 'wss://webvwdev.finvu.in/consentapi',
        certificatePins: [
          // "3RbasfbYK4UP0GTgGKLV9ggrHbdiwzNDJ4s73Mx8AQM=",
          // "bdrBhpj38ffhxpubzkINl0rG+UyossdhcBYj+Zx2fcc="
        ],
      ),
    );

    await finvuManager.connect();
    var isConnected = await finvuManager.isConnected();
    print(isConnected);
    if (!isConnected) {
      isConnected = await finvuManager.isConnected();
      print(isConnected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {_initFinvuManager()},
              child: Text('Init'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                // login()
                loginToAutoTractions(context)
              },
              child: Text('Login'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                // verify(_controller.text)
                getConsentHandleStatus()
              },
              child: Text('getConsentHandleStatus'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                // verify(_controller.text)
                fetchLinkedAccounts()
              },
              child: Text('fetchLinkedAccounts()'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                // verify(_controller.text)
                completeMobileVerification()
              },
              child: Text('completeMobileVerification()'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                // verify(_controller.text)
                initiateMobileVerification()
              },
              child: Text('initiateMobileVerification()'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                // verify(_controller.text)
                getConsentRequestDetails()
              },
              child: Text('getConsentRequestDetails'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                // verify(_controller.text)
                // discoverAccounts()
                Navigator.pushNamed(context, "/discover")
              },
              child: Text('discoverAccounts'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                verify(_controller.text, context)
                // getConsentHandleStatus()
              },
              child: Text('Verify'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                approveConsentRequest()
                // getConsentHandleStatus()
              },
              child: Text('approveConsentRequest'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                fetch()
                // getConsentHandleStatus()
              },
              child: Text('FetchData'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {
                LOGOUT()
                // getConsentHandleStatus()
              },
              child: Text('LOGOUT'),
            ),
          ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter text',
            ),
          ),
        ],
      ),
    );
  }

  void login() async {
    var login =
        await finvuManager.loginWithUsernameOrMobileNumberAndConsentHandle(
      custId,
      number.value,
      handleId.value,
    );

    otpReference = login.reference;
    debugPrint('LoggedIn');
  }

  void fetch() async {
    try {
      final SharedPreferences _pref = await SharedPreferences.getInstance();
      String? token = await _pref.getString("token");
      ConsentStatus(context, token, handleId.value, custId);
    } catch (e) {
      //  print(e);
    }
  }

  // void verify(String otp,context) async {

  //   try{
  //   var login = await finvuManager.verifyLoginOtp(otp,otpReference,);
  //   //  print("verifyLoginOtp");
  //   //  print(login.userId);
  //   final SharedPreferences _pref = await SharedPreferences.getInstance();
  //   String? token=await _pref.getString("token");

  //    Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ShareAccountLogin(flag: true,),
  //     ),
  //   );
  //   // Navigator.pushNamed(context, "/discover");

  //   //  getConsentRequestDetails();
  //   //  fetchLinkedAccounts();
  //   //  approveConsentRequest();

  //   //  ConsentStatus(context,token,handleId.value,custId);

  //   //  WebSocket message received:

  //   }catch(e){
  //       // print(e);
  //   }

  //   // try{
  //   // List<FinvuLinkedAccountDetailsInfo> data =await  finvuManager.fetchLinkedAccounts();
  //   // print("------------------------------");
  //   // data.forEach((e){
  //   //       print(e.userId);
  //   //       print(e.consentIdList);
  //   //       print(e.fiType);
  //   //       print(e.fipId);
  //   //       print(e);
  //   // });
  //   // }catch(e){
  //   //      print(e);
  //   // }

  // }

  void fetchLinkedAccounts() async {
    try {
      finvuLinkedAccountDetailsInfo = await finvuManager.fetchLinkedAccounts();
      // finvuLinkedAccountDetailsInfo.forEach((e){
      //       print("---------------------------");
      //       print(e.userId);
      //       print(e.consentIdList);
      //       print(e.fiType);
      //       print(e.fipName);
      //       print(e.fipId);
      //       print(e);

      // });
    } catch (e) {
      print(e);
    }

    debugPrint('fetchLinkedAccounts');
  }

  void getConsentHandleStatus() async {
    try {
      var d = await finvuManager.getConsentHandleStatus(handleId.value);
      //  print('d.status-------getConsentHandleStatus-------------getConsentHandleStatus');
      //  print(d.status);
    } catch (e) {
      //  print(e);
    }

    debugPrint('getConsentHandleStatus');
  }

  void LOGOUT() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    try {
      _pref.remove("token");
      _pref.remove("from");
      _pref.remove("to");
      _pref.remove("sessionId");
      _pref.remove("consentId");
      _pref.remove("ConsentHandleId");
      await finvuManager.logout();

      print("Logout user...");
    } catch (e) {
      print(e);
    }

    debugPrint('getConsentHandleStatus');
  }

  void getConsentRequestDetails() async {
    try {
      finvuConsentRequestDetailInfo =
          await finvuManager.getConsentRequestDetails(handleId.value);
    } catch (e) {
      print(e);
    }

    debugPrint('getConsentRequestDetails');
  }

  // void discoverAccounts() async {
  //   try {
  //     List<FinvuFIPInfo> data = await finvuManager.fipsAllFIPOptions();

  //     data = [data[0]];
  //     FinvuFIPInfo finvuFIPInfo = data[0];

  //     var fetchFIPDetails = await finvuManager.fetchFIPDetails("dhanagarbank");
  //     var typeIdentifiers = fetchFIPDetails.typeIdentifiers;

  //     List<FinvuTypeIdentifierInfo> finvuTypeIdentifierInfo = [];

  //     typeIdentifiers.forEach((e) {
  //       e.identifiers.forEach((ele) {
  //         FinvuTypeIdentifierInfo obj = FinvuTypeIdentifierInfo(
  //           category: ele.category,
  //           type: ele.type,
  //           value: number.value, // dou
  //         );
  //         finvuTypeIdentifierInfo.add(obj);
  //       });
  //     });

  //     FinvuFIPDetails fipDetails = FinvuFIPDetails(
  //         fipId: "dhanagarbank",
  //         typeIdentifiers: fetchFIPDetails.typeIdentifiers);

  //     List<FinvuDiscoveredAccountInfo> info =
  //         await finvuManager.discoverAccounts(
  //             fipDetails.fipId, finvuFIPInfo.fipFitypes, finvuTypeIdentifierInfo);

  //     //  info.forEach((e){
  //     //     print('e.accountType');
  //     //     print(e.accountType);
  //     //     print(e.fiType);
  //     //  });
  //   } catch (e) {
  //     print(e);
  //   }

  //   debugPrint('getConsentRequestDetails');
  // }

  void completeMobileVerification() async {
    var sa = await finvuManager.completeMobileVerification(
        number.value, _controller.text);
  }

  void initiateMobileVerification() async {
    var d = await finvuManager.initiateMobileVerification(number.value);
  }

  void approveConsentRequest() async {
    try {
      var d = await finvuManager.approveConsentRequest(
          finvuConsentRequestDetailInfo, finvuLinkedAccountDetailsInfo);
      // print('d.consentIntentId');
      // print(d.consentIntentId);
      // consentUserId.value=d.consentIntentId.toString();
      // print(finvuConsentRequestDetailInfo.consentHandle);
      // print(finvuConsentRequestDetailInfo.consentId);
      // print(finvuConsentRequestDetailInfo.consentDateTimeRange.from);
      // print(finvuConsentRequestDetailInfo.consentDateTimeRange.to);
      // var boolValue=await finvuManager.hasSession();
      print("boolValue approveConsentRequest==========approveConsentRequest");
      // print(boolValue);
      // final SharedPreferences _pref = await SharedPreferences.getInstance();
      // String? token=await _pref.getString("token");

      // FIRequest(context, _pref.getString("token"),
      // finvuConsentRequestDetailInfo.consentHandle,"8978958221@finvu",
      // finvuConsentRequestDetailInfo.consentDateTimeRange.from,
      // finvuConsentRequestDetailInfo.consentDateTimeRange.to,
      // finvuConsentRequestDetailInfo.consentId);

      //  ConsentFromAndToRequest(context,token.toString(),finvuConsentRequestDetailInfo.consentHandle
      //  ,"8978958221@finvu",finvuConsentRequestDetailInfo.consentId
      // );

      // d.consentInfo?.forEach((element) {
      //      print(element.consentId);
      //      print(element.fipId);
      // });
    } catch (e) {
      print("d.consentIntentId error");
      print(e);
    }

    debugPrint('approveConsentRequest');
  }
}
