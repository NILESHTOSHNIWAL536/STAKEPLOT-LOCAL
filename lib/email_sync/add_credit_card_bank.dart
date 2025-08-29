import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/email_sync/credit_cards.dart';
import 'package:get/get.dart';

import '../animated/booleanFlag.dart';
import 'custom_steps.dart';
import 'sign_in.dart';

RxString selectedBankName = ''.obs;

class AddCreditCardBankScreen extends StatelessWidget {
  final List<String> banks = [
    'Axis Bank',
    'Canara Bank',
    'HDFC Bank',
    'hsbc bank',
    'icici bank',
    'idfc bank',
    'indusind bank',
    'kotak bank',
    'rbl bank',
    'state bank of india',
    'standard chartered bank',
    'yes bank',
  ];

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: leadIcon(context),
          title: Text(
            "Add Credit Card Bank Name",
            style: TextStyle(
                color: Color(0xFF37344F),
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          centerTitle: false,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: h * 0.012),
            CustomStepper(activeStep: 0),
            SizedBox(height: h * 0.039),
            TextField(
              controller:controller ,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                hintText: 'Axis Bank',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Color(0xFFACA8A8)),
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: banks.length,
                itemBuilder: (_, i) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFF1EFEF),
                      ),
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    title: Text(
                      banks[i],
                      style: TextStyle(
                        color: Color(0xFF37344F),
                        fontSize: 16,
                      ),
                    ),
                    onTap: ()
                     {
                          controller.text=banks[i];
                          selectedBankName.value=banks[i];
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 14),
            Center(
              child: SizedBox(
                width: w * .45,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    if(selectedBankName.value.isEmpty)
                    {
                          snackBarCalledfail(context, "Please select bank name");
                    }else {
                      googleSignInBool.value = false; // Set loading state
                      pushnameToRoute(context,SignInScreen());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF37344F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Done",
                      style: TextStyle(fontSize: 17, color: Colors.white)),
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}





void pushnameToRoute(BuildContext context,Widget  CreditCardsScreen,[bool replace = true])
{
  if(replace) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>CreditCardsScreen));
  else Navigator.push(context, MaterialPageRoute(builder: (context) =>CreditCardsScreen));
}