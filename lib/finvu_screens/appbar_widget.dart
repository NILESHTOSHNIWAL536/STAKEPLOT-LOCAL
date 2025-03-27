



import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';

AppBar getAppBar(context) {
  return AppBar(
     toolbarHeight: 40,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_sharp),
      color: Colorcodes.black,
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  );
}