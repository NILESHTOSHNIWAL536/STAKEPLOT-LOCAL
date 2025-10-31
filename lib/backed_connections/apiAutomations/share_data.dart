import 'package:share_plus/share_plus.dart';

void shareBankData(Map<String, dynamic> data) {
  // Format the bank info
  final String bankInfo = """
Bank Details:
---------------------
Bank ID: ${data['bankId']}
Bank Name: ${data['bankName']}
Bank Logo: ${data['bankLogo']}
FIP ID: ${data['fipId']}
Account ID: ${data['accountId']}
Account Number: ${data['maskedAccNumber']}
Type: ${data['type']}
Current Balance: ₹${data['currentBalance']}
Last Fetch: ${data['lastFetch']}
Next Fetch: ${data['nextFetch']}
Fetch Count: ${data['fetchCount']}

User Info:
---------------------
Name: ${data['name']}
PAN: ${data['pan']}
DOB: ${data['dob']}
Mobile: ${data['mobile']}
${(data['address'] != null && !data['address'].toString().toLowerCase().contains("encrypted")) ? "User Address: ${data['address']}" : ""}
Branch Address:  ${data['branchAddress']}
ifscCode:  ${data['ifscCode']}
""";

  final String bankInfo2 = """
Bank Details:
---------------------
Name: ${data['name']}
Bank Name: ${data['bankName']}
Account Number: ${data['maskedAccNumber']}
IFSC Code: ${data['ifscCode']}
${(data['address'] != null && !data['address'].toString().toLowerCase().contains("encrypted")) ? "User Address: ${data['address']}" : ""}
Branch Address:  ${data['branchAddress']}
""";

  // Share outside the app
  try {
    Share.share(bankInfo2, subject: "My Bank Account Info");
  } catch (e) {
  }
}
