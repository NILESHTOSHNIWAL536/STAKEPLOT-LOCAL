import 'package:get/get.dart';

RxBool fetchNow = false.obs;
RxBool cashInAndOut = false.obs;
RxBool splitBill = false.obs;
RxBool createDebt = false.obs;
RxBool createBudget = false.obs;
RxBool createDebtBool = false.obs;
RxBool tagBool = false.obs;
RxBool googleSignInBool = false.obs;
RxBool appleSignInBool = false.obs;

void clearAllFlags() {
  fetchNow.value = false;
  cashInAndOut.value = false;
  splitBill.value = false;
  createDebt.value = false;
  createBudget.value = false;
  createDebtBool.value = false;
  tagBool.value = false;
  googleSignInBool.value = false;
  appleSignInBool.value = false;
}
