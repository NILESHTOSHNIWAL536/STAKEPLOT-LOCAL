import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';


class FetchTransaction extends StatelessWidget {
const FetchTransaction({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Fetch Trsaction Data..."),
        backgroundColor: Colors.cyanAccent,
      ),
      body: Container(
           width: MediaQuery.of(context).size.width,
           height: MediaQuery.of(context).size.height,
           child: Expanded(
             child: SingleChildScrollView(
               child: InkWell(
                onTap: (){
                   fetch(context);
                },
                child: Text("FetchData"))
             ),
           ),
      ),
    );
  }

  // fetch(context);
}