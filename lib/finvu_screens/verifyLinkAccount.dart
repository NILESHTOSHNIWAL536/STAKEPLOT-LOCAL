import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchLinkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/main.dart';

class VerifyLinkAccount extends StatefulWidget {
  FinvuAccountLinkingRequestReference linkingReference;
  VerifyLinkAccount({Key? key, required this.linkingReference})
      : super(key: key);

  @override
  _VerifyLinkAccountState createState() => _VerifyLinkAccountState();
}

class _VerifyLinkAccountState extends State<VerifyLinkAccount> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FinvuStrings().linkedAccount),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child:
            Expanded(child: SingleChildScrollView(child: getWidgetTextFeild())),
      ),
    );
  }

  Widget getWidgetTextFeild() {
    return Container(
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: FinvuStrings().enterText
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  // print(_controller.text);
                  var data = await finvuManager.confirmAccountLinking(
                      widget.linkingReference, _controller.text);
                  // print('data.linkedAccounts');
                  // print(data.linkedAccounts);
                  snackBarCalled(context, "Linked account found successfully.");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FetchLinkedAccounts(),
                    ),
                  );
                } catch (e) {
                  snackBarCalled(
                      context,
                      "Error while verifying OTP or the account is already linked.",
                      Colors.red);
                }
              },
              child: Text( FinvuStrings().verifyAndLink),
            ),
          ),
        ],
      ),
    );
  }
}
