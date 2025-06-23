import 'package:flutter/material.dart';
import 'package:get/get.dart';

List getSearchData(String val, List data,[bool isMasked=false]) {
  List findOne = [];
  data.forEach((element) {
    if (element[isMasked?"maskedName":'name'].toString().toLowerCase().contains(val.toLowerCase())) {
      findOne.add(element);
    }
  });
  return findOne;
}

RxList getSearchDataRx(String val, List data,[bool isMasked=false])
{
  RxList findOne = [].obs;
  data.forEach((element) {
    if (element[isMasked?"maskedName":'name'].toString().toLowerCase().contains(val.toLowerCase())) {
      findOne.add(element);
    }
  });
  return findOne;
}


String currentPage2(context) {
  String modalRoute = ModalRoute.of(context)?.settings.name ?? '';
  return modalRoute;
}

String toUpperCase(String str) {
  if (str.isEmpty) return str;
  return str[0].toUpperCase() + str.substring(1);
}

