import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import '../Home_Screen/helper.dart';
import '../animated/booleanFlag.dart';
import '../finance_screen/Budgets/Budget.dart';
import '../model/credit-card-bank.dart';
import 'custom_steps.dart';
import 'email_signin.dart';

RxString selectedBankName = "".obs;
RxString selectedBankId = "".obs;
RxList<CreditCardBank> creditCardBankList = <CreditCardBank>[].obs;

class AddCreditCardBankScreen extends StatefulWidget {
  @override
  State<AddCreditCardBankScreen> createState() =>
      _AddCreditCardBankScreenState();
}

class _AddCreditCardBankScreenState extends State<AddCreditCardBankScreen> {
  RxList<CreditCardBank> filteredBanks = <CreditCardBank>[].obs;

  TextEditingController controller = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    filteredBanks.clear();
    filteredBanks.addAll(creditCardBankList);
    // controller.text = selectedBankName.value;
  }

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
          title: textStyle(
              context: context,
              text: "Add Credit Card Bank Name",
              c: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontsize: 18),
          //  Text(
          //   "Add Credit Card Bank Name",
          //   style: TextStyle(
          //       color: Color(0xFF37344F),
          //       fontWeight: FontWeight.w600,
          //       fontSize: 18),
          // ),
          centerTitle: false,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomStepper(activeStep: 0),
            TextField(
              controller: controller,
              onChanged: (v) {
                RxList<CreditCardBank> filteredBanksList =
                    <CreditCardBank>[].obs;
                creditCardBankList.forEach((element) {
                  if (element.name.toLowerCase().contains(v.toLowerCase()))
                    filteredBanksList.add(element);
                });

                setState(() {
                  filteredBanks.clear();
                  filteredBanks.addAll(filteredBanksList);
                });
              },
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                hintText: 'Select bank',
                hintStyle: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                      color: AppColors.primaryColor.withOpacity(0.4)),
                ),
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey.withOpacity(0.5), // Set your divider color
                  height: 1, // Space the divider consumes
                  thickness: 1, // Divider line thickness    // End margin
                ),
                itemCount: filteredBanks.length,
                itemBuilder: (_, i) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: i == 0 ? Radius.circular(10) : Radius.zero,
                        topRight: i == 0 ? Radius.circular(10) : Radius.zero,
                        bottomLeft: i == filteredBanks.length - 1
                            ? Radius.circular(10)
                            : Radius.zero,
                        bottomRight: i == filteredBanks.length - 1
                            ? Radius.circular(10)
                            : Radius.zero,
                      )),
                  child: ListTile(
                    dense: true,

                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    leading: Image.network(
                      filteredBanks[i].logo,
                      width: 30,
                      height: 30,
                      fit: BoxFit.fitWidth,
                      errorBuilder: getErrorBankLogo(),
                    ),
                    title: textStyle(
                        context: context,
                        text: filteredBanks[i].name,
                        c: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontsize: 18),
                    // Text(
                    //   filteredBanks[i].name,
                    //   style: TextStyle(
                    //     color: Color(0xFF37344F),
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    onTap: () {
                      controller.text = filteredBanks[i].name;
                      selectedBankName.value = filteredBanks[i].name;
                      selectedBankId.value = filteredBanks[i].id;
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
                    if (selectedBankName.value.isEmpty ||
                        selectedBankId.value.isEmpty) {
                      snackBarCalledfail(context, "Please select bank name");
                    } else {
                      googleSignInBool.value = false; // Set loading state
                      pushnameToRoute(context, SignInScreen());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF37344F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: textStyleImage(
                      context: context,
                      text: "Done",
                      c: AppColors.white,
                      fontWeight: FontWeight.w500,
                      fontsize: 18),
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

void pushnameToRoute(BuildContext context, Widget CreditCardsScreen,
    [bool replace = true]) {
  if (replace)
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => CreditCardsScreen));
  else
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreditCardsScreen));
}



// List banks =
//    [
//        { 
//         'name':"HDFC Bank",
//         'logo':'https://cdn.finvu.in/finvulogos/hdfcbank_logo.jpg',
//          'bankId':'HDFCLtd-FIP'
//        },
//        { 
//         'name':"ICICI Bank",
//         'logo':'https://cdn.finvu.in/finvulogos/icicibank_icon.jpg',
//          'bankId':'ICICI-FIP'
//        },
//        { 
//         'name': "SBI Card",
//         'logo':'https://cdn.finvu.in/finvulogos/sbi_logo.png',
//          'bankId':'sbi-fip'
//        },
//        { 
//         'name':  "Axis Bank",
//         'logo':'https://cdn.finvu.in/finvulogos/axisbank_icon.jpg',
//          'bankId':'AXIS001'
//        },
//        { 
//         'name':  "Kotak Mahindra Bank",
//         'logo':'https://cdn.finvu.in/finvulogos/kotakbank_app_logo.png',
//          'bankId':'KotakMahindraBank-FIP'
//        },
//        { 
//         'name':   "Bank of Baroda",
//         'logo':'https://cdn.finvu.in/finvulogos/bank_of_baroda_logo_bob.png',
//          'bankId':'BARBFIP'
//        },
//        { 
//         'name': "Yes Bank",
//         'logo':'https://cdn.finvu.in/finvulogos/yes_bank_logo.png',
//          'bankId':'YESB-FIP'
//        },
//     ];


     //  { 
      //   'name': "IndusInd Bank",
      //   'logo':'',
      //    'id':''
      //  },
      //  { 
      //   'name': "IDFC First Bank",
      //   'logo':'',
      //    'id':''
      //  },
      //  { 
      //   'name':  "Punjab National Bank",
      //   'logo':'',
      //    'id':''
      //  },
      //  { 
      //   'name': "IDBI Bank",
      //   'logo':'',
      //    'id':''
      //  },
      //  { 
      //   'name':  "Canara Bank",
      //   'logo':'',
      //    'id':''
      //  },   
      //  { 
      //   'name':  "Federal Bank",
      //   'logo':'',
      //    'id':''
      //  },   
      //  { 
      //   'name':  "RBL Bank",
      //   'logo':'',
      //    'id':''
      //  },   
      //  { 
      //   'name': "Union Bank of India",
      //   'logo':'',
      //    'id':''
      //  },   
       
