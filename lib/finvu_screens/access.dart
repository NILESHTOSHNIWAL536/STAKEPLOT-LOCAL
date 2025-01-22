import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchLinkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Access extends StatefulWidget {
  const Access({super.key});

  @override
  State<Access> createState() => _AccessState();
}

class _AccessState extends State<Access> {
  late FinvuConsentRequestDetailInfo finvuConsentRequestDetailInfo;

  RxBool flag = false.obs;
  @override
  void initState() {
    super.initState();
    flag.value = false;
    getInfomationsAboutUser();
  }

  void getInfomationsAboutUser() async {
    fetchAccountData = await finvuManager.fetchLinkedAccounts();
    finvuConsentRequestDetailInfo =
        await finvuManager.getConsentRequestDetails(handleId.value);
    flag.value = true;
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMM yyyy').format(date); // Format as Aug 2024
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10.0, 16, 16, 0),
            child: Obx(
              () => !flag.value
                  ? Loader()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.bg1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 25, 10, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                "Give Permission",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppColors.bg1,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "To share your accounts with Stakeplot for processing your loan application.",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: AppColors.bg1,
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                // height: MediaQuery.of(context).size.height / 2.7,
                                // width: MediaQuery.of(context).size.width ,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section 1: Accounts Shared
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                                Icons
                                                    .account_balance_wallet_outlined,
                                                color: Colors.blue),
                                            SizedBox(width: 10),
                                            Text(
                                              "Accounts Shared",
                                              style: FontManager().getTextStyle(
                                                context,
                                                lWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: AppColors.bg1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 35),
                                          child: Text(
                                            "${fetchAccountData.length} Account Are Linked..",
                                            style: FontManager().getTextStyle(
                                              context,
                                              lWeight: FontWeight.w400,
                                              fontSize: 15,
                                              color: AppColors.bg1,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: fetchAccountData.map((e) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(e.accountType),
                                                SizedBox(width: 5),
                                                Text(e.accountReferenceNumber),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),

                                    // Section 2: Permission Validity
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.date_range_outlined,
                                                color: Colors.blue),
                                            SizedBox(width: 10),
                                            Text(
                                              "Permission Validity",
                                              style: FontManager().getTextStyle(
                                                context,
                                                lWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: AppColors.bg1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 35),
                                          child: Text(
                                            formatDate(
                                                    finvuConsentRequestDetailInfo
                                                        .consentDateTimeRange
                                                        .from
                                                        .toString()) +
                                                " to " +
                                                formatDate(
                                                    finvuConsentRequestDetailInfo
                                                        .consentDateTimeRange.to
                                                        .toString()),
                                            // "From 17 Aug 2024 to 18 Sept 2024",
                                            style: FontManager().getTextStyle(
                                              context,
                                              lWeight: FontWeight.w400,
                                              fontSize: 15,
                                              color: AppColors.bg1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),

                                    // Section 3: Frequency of Access
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.access_time_outlined,
                                                color: Colors.blue),
                                            SizedBox(width: 10),
                                            Text(
                                              "Frequency of Access",
                                              style: FontManager().getTextStyle(
                                                context,
                                                lWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: AppColors.bg1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 35),
                                          child: Text(
                                            "We can access your information one-time Per Week.",
                                            style: FontManager().getTextStyle(
                                              context,
                                              lWeight: FontWeight.w400,
                                              fontSize: 15,
                                              color: AppColors.bg1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),

                                    // Section 4: View More Details
                                    GestureDetector(
                                      onTap: () {
                                        // Add navigation or functionality here
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1,
                                                child: SingleChildScrollView(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20.0, 40, 16, 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Details of your approval',
                                                        style: FontManager()
                                                            .getTextStyle(
                                                          context,
                                                          lWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          color: AppColors.bg1,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(20.0,
                                                                25, 20, 0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                                height:
                                                                    Colorcodes
                                                                        .space),
                                                            Text(
                                                              "Approval Requested on",
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              formatDate(finvuConsentRequestDetailInfo
                                                                  .consentDateTimeRange
                                                                  .from
                                                                  .toString()),
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    Colorcodes
                                                                        .space),
                                                            Text(
                                                              "Purpose",
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              "To process your  loan application",
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    Colorcodes
                                                                        .space),
                                                            Text(
                                                              "Account Details",
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              "Profile,Summary Transactions",
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    Colorcodes
                                                                        .space),
                                                            Text(
                                                              "Data life",
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              finvuConsentRequestDetailInfo
                                                                      .consentDataLifePeriod
                                                                      .value
                                                                      .toString() +
                                                                  finvuConsentRequestDetailInfo
                                                                      .consentDataLifePeriod
                                                                      .unit
                                                                      .toString(),
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    Colorcodes
                                                                        .space),
                                                            Text(
                                                              "Approval Expiry",
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              formatDate(finvuConsentRequestDetailInfo
                                                                  .consentDateTimeRange
                                                                  .to
                                                                  .toString()),
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    Colorcodes
                                                                        .space),
                                                            Text(
                                                              "Account Types",
                                                              style: FontManager()
                                                                  .getTextStyle(
                                                                context,
                                                                lWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .bg1,
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Wrap(
                                                                children: finvuConsentRequestDetailInfo
                                                                    .fiTypes!
                                                                    .map((e) =>
                                                                        Text(
                                                                          e + ",",
                                                                          style:
                                                                              FontManager().getTextStyle(
                                                                            context,
                                                                            lWeight:
                                                                                FontWeight.w600,
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                AppColors.bg1,
                                                                          ),
                                                                        ))
                                                                    .toList()),
                                                            SizedBox(
                                                                height: 20),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    1.1,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppColors
                                                                      .accentColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Understand",
                                                                    style: FontManager()
                                                                        .getTextStyle(
                                                                      context,
                                                                      lWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                      color: AppColors
                                                                          .bg5,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: Center(
                                        child: Text(
                                          "View More Details",
                                          style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Footer: Pause or Cancel Sharing
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline, color: Colors.grey),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "You can pause or cancel sharing anytime via your Finvu app.",
                                      style: FontManager().getTextStyle(
                                        context,
                                        lWeight: FontWeight.w400,
                                        fontSize: 15,
                                        color: AppColors.bg3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 7,
                              ),
                              InkWell(
                                onTap: () {
                                  approveConsentRequest();
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Give permission",
                                      style: FontManager().getTextStyle(
                                        context,
                                        lWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.bg5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 1.1,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                decoration: BoxDecoration(
                                  //color: AppColors.accentColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "Decline",
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.bg1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          )),
    );
  }

  void approveConsentRequest() async {
    try {
      FinvuConsentRequestDetailInfo finvuConsentRequestDetailInfo =
          await finvuManager.getConsentRequestDetails(handleId.value);
      //  print('handleId.value');
      FinvuProcessConsentRequestResponse response =
          await finvuManager.approveConsentRequest(
              finvuConsentRequestDetailInfo, fetchAccountData);
      //  print(handleId.value);
      //  print(response.consentIntentId);
      response.consentInfo!.forEach((e) {
        // print("e.consentId----------------");
        // print(e.consentId);
        // print(e.fipId);
      });

      snackBarCalled(context, "approved ConsentRequest");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FetchTransaction(),
        ),
      );
    } catch (e) {
      snackBarCalled(context, "Error while approving ConsentRequest");
      print("d.consentIntentId error");
    }
    debugPrint('approveConsentRequest');
  }
}
