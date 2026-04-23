import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:get/get.dart';

  String otpReference = "";
  String displayText = '';
  RxString number="".obs;
  String custId="${number.value}@finvu";
  RxString mobileNo="".obs;
  RxString handleId="".obs;
  RxString fipIdSeleted="".obs;
  RxString consentUserId="".obs;
  RxBool fetchedData=false.obs;
  RxList fetchedTrsacntionList = [].obs;
  late FinvuConsentRequestDetailInfo finvuConsentRequestDetailInfo;
  late List<FinvuLinkedAccountDetailsInfo> finvuLinkedAccountDetailsInfo;
  List<String> fiTypes=[];
  RxList<String> FipIdsConnected=<String>[].obs;
 