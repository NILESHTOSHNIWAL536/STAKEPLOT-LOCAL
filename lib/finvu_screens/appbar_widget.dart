



import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';

AppBar getAppBar(context) {
  return AppBar(
     toolbarHeight: 40,
     actions: [ 
       Padding(
         padding: const EdgeInsets.symmetric(horizontal: 20),
         child: Icon(
            Icons.login,
            color: Colorcodes.black,
            size: 30,
         ),
       ),
     ],
    leading: IconButton(
      icon: Icon(Icons.arrow_back_sharp),
      color: Colorcodes.black,
      onPressed: () {
        Navigator.pop(context);
      },

    ),
  );
}