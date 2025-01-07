// import 'package:cloudinary_public/cloudinary_public.dart';
// import 'package:flutter/foundation.dart' ;

// import 'package:cloudinary_flutter/cloudinary_object.dart';
// import 'package:cloudinary_public/cloudinary_public.dart';
// import 'package:cloudinary_url_gen/cloudinary.dart';


// class CloudImage with ChangeNotifier{
//  dynamic _response;
//  List<String> _urlList=[];
//  bool _isloading = true ;
//  dynamic get urlList => _urlList;
//  String get response => _response;
//  bool get isloading => _isloading;
// Future<void> upload(List<String> imagesList) async{
//  CloudinaryClient client = new CloudinaryClient(
//  "your apiKey",
//  "your apiSecret",
//  "your cloudName",
//  );
//  List<CloudinaryResponse> response = await client.uploadImages(imagesList,filename: "MawCars");
//  _response = response;
//  notifyListeners();
//  if(_response==null){
//  return null;
//  }
//  else {
//  List<String> urlList= [];
//  _response.forEach((element){
//  urlList.add(element.secure_url);
//  });
//  _urlList = urlList;
//  _isloading = false;
//  notifyListeners();
//  }
//  }
// }