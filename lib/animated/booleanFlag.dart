import 'package:get/get.dart';


RxBool fetchNow= false.obs;
RxBool cashInAndOut = false.obs;
RxBool splitBill = false.obs;
RxBool createDebt = false.obs;
RxBool createBudget = false.obs;


void clearAllFlags() {
  fetchNow.value = false;
  cashInAndOut.value = false;
  splitBill.value = false;
  createDebt.value = false;
  createBudget.value = false;
}