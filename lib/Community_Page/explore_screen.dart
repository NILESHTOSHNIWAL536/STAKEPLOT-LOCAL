// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import './success_post.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';

// class ExploreModal extends StatefulWidget {
//   final Function(Map<String, dynamic>) onPostCreated;

//   const ExploreModal({Key? key, required this.onPostCreated}) : super(key: key);

//   @override
//   _ExploreModalState createState() => _ExploreModalState();
// }

// class _ExploreModalState extends State<ExploreModal> {
//   final TextEditingController locationNameController = TextEditingController();
//   final TextEditingController locationAddressController =
//       TextEditingController();
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController contentController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   File? selectedImage;

//   final List<TextEditingController> _textControllers = [];
//   final List<TextEditingController> _amountControllers = [];
//   bool exploreSubmitted = false;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize with two default controllers
//     _textControllers.add(TextEditingController());
//     _amountControllers.add(TextEditingController());
//   }

//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         selectedImage = File(image.path);
//       });
//     }
//   }

//   void _addTextFields() {
//     setState(() {
//       _textControllers.add(TextEditingController());
//       _amountControllers.add(TextEditingController());
//     });
//   }

 

//   @override
//   void dispose() {
//     locationNameController.dispose();
//     locationAddressController.dispose();
//     titleController.dispose();
//     contentController.dispose();

//     for (var controller in _textControllers) {
//       controller.dispose();
//     }
//     for (var controller in _amountControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return exploreSubmitted
//         ? const SuccessPost()
//         : AnimatedPadding(

//            padding:
//               EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//           duration: const Duration(milliseconds: 100),
//           child: SingleChildScrollView(
//             child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.explore_sharp, size: 24, color: Colors.green),
//                           SizedBox(width: 8),
//                           Text('Explore',
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                   color: Colors.black)),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       GestureDetector(
//                         onTap: _pickImage,
//                         child: Container(
//                           height: 200,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: selectedImage != null
//                               ? Image.file(
//                                   selectedImage!,
//                                   fit: BoxFit.cover,
//                                 )
//                               : const Icon(
//                                   Icons.add_photo_alternate,
//                                   size: 50,
//                                   color: Colors.grey,
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text('About Place',
//                           style: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.normal,
//                               fontSize: 16,
//                               color: Colors.black)),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: locationNameController,
//                         decoration: InputDecoration(
//                           hintText: 'Location Name',
//                           hintStyle: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.normal,
//                               fontSize: 16,
//                               color: Colors.black),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                           ),
//                           prefixIcon: Icon(Icons.place_outlined),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: locationAddressController,
//                         decoration: InputDecoration(
//                           hintText: 'Location Address',
//                           hintStyle: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.normal,
//                               fontSize: 16,
//                               color: Colors.black),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                           ),
//                           prefixIcon: Icon(Icons.place_sharp),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Text('Budget',
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.normal,
//                                   fontSize: 16,
//                                   color: Colors.black)),
//                           IconButton(
//                             onPressed: _addTextFields,
//                             icon: const Icon(Icons.add),
//                           ),
//                         ],
//                       ),
//                       ...List.generate(_textControllers.length, (index) {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   controller: _textControllers[index],
//                                   decoration: InputDecoration(
//                                     hintText: 'Add Category',
//                                     hintStyle: FontManager().getTextStyle(context,
//                                         lWeight: FontWeight.normal,
//                                         fontSize: 16,
//                                         color: Colors.black),
//                                     prefixIcon: Icon(Icons.description),
//                                     border: OutlineInputBorder(
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(16.0)),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: TextField(
//                                   controller: _amountControllers[index],
//                                   keyboardType: TextInputType.number,
//                                   decoration: InputDecoration(
//                                     hintText: 'Add Budget',
//                                     hintStyle: FontManager().getTextStyle(context,
//                                         lWeight: FontWeight.normal,
//                                         fontSize: 16,
//                                         color: Colors.black),
//                                     prefixIcon: Icon(Icons.currency_rupee),
//                                     border: OutlineInputBorder(
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(16.0)),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                       const SizedBox(height: 20),
//                       Text('Trip Highlights',
//                           style: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.normal,
//                               fontSize: 16,
//                               color: Colors.black)),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: titleController,
//                         decoration: const InputDecoration(
//                           hintText: 'Enter title',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: contentController,
//                         decoration: InputDecoration(
//                           hintText: 'Add your thoughts',
//                           hintStyle: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.normal,
//                               fontSize: 16,
//                               color: Colors.black),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       DecoratedContainer(
//                         borderRadius: 24,
//                         backgroundColor: locationNameController.text.isNotEmpty &&
//                                 locationAddressController.text.isNotEmpty
//                             ? Colors.blue
//                             : Colors.grey,
//                         child: Center(
//                           child: TextButton(
//                             onPressed:(){},
//                             child: Text('Continue',
//                                 style: FontManager().getTextStyle(context,
//                                     lWeight: FontWeight.normal,
//                                     fontSize: 18,
//                                     color: Colors.black)),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//           ),
//         );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;

  const ExploreModal({Key? key, required this.onPostCreated}) : super(key: key);

  @override
  _ExploreModalState createState() => _ExploreModalState();
}

class _ExploreModalState extends State<ExploreModal> {
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController locationAddressController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  final List<TextEditingController> _textControllers = [];
  final List<TextEditingController> _amountControllers = [];
  bool exploreSubmitted = false;

  @override
  void initState() {
    super.initState();
    print('initState: Initializing ExploreModal state');
    _textControllers.add(TextEditingController());
    _amountControllers.add(TextEditingController());
  }

  Future<void> _pickImage() async {
    print('Picking image from gallery');
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        print('Image picked: ${selectedImage!.path}');
      });
    } else {
      print('No image selected');
    }
  }

  void _addTextFields() {
    setState(() {
      _textControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());
      print('Added new text fields. Total count: ${_textControllers.length}');
    });
  }
static Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var accessToken = pref.getString("accessToken");

    if (accessToken == null) {
      // print("No access token found in SharedPreferences");
      return null;
    } else {
      //  print("Token: $accessToken");
      return accessToken;
    }
  }
  Future<void> _submitPost() async {

    if (locationNameController.text.isEmpty || locationAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    List<Map<String, dynamic>> budget = [];
    for (int i = 0; i < _textControllers.length; i++) {
      if (_textControllers[i].text.isNotEmpty && _amountControllers[i].text.isNotEmpty) {
        budget.add({
          "category": _textControllers[i].text,
          "amount": int.tryParse(_amountControllers[i].text) ?? 0,
        });
      } else {
      }
    }
 
    String getImage =await postImageToCloud(selectedImage!,context);

    print('Constructing request body');
    Map<String, dynamic> requestBody ={
      "pictures":getImage ?? "",
      // "pictures": selectedImage != null ? [selectedImage!.path] : [],
      //"backGroundPicture": selectedImage != null ? selectedImage!.path : "",
      "place": {
        "name": locationNameController.text,
        "location": locationAddressController.text,
      },
      "budget": budget,
      "rating": 4.5,
      "tripHighlight": titleController.text,
      "description": contentController.text,
      "comments": 0,
      "shares": 0,
      "upvotes": 0,
      
    };

    var body = {
      'title':  titleController.text,
      'description': {'message': requestBody},
      'image': getImage,
      'fileName': '',
      'type':'explore'
    };

    try {
      var accessToken = await getToken();
      final response = await http.post(
        Uri.parse('${url}/post/'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "$accessToken",
        },
        body: jsonEncode(body),
      );

      print('Response received. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Post submitted successfully');
        setState(() {
          exploreSubmitted = true;
          print('State updated: exploreSubmitted = true');
        });
        widget.onPostCreated(jsonDecode(response.body));
        print('onPostCreated callback triggered');
      } else {
        print('Failed to submit post. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit post: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error during POST request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    print('Disposing ExploreModal state');
    locationNameController.dispose();
    locationAddressController.dispose();
    titleController.dispose();
    contentController.dispose();
    for (var controller in _textControllers) {
      controller.dispose();
    }
    for (var controller in _amountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building ExploreModal widget. exploreSubmitted: $exploreSubmitted');
    return exploreSubmitted
        ? const SuccessPost()
        : AnimatedPadding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            duration: const Duration(milliseconds: 100),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.explore_sharp, size: 24, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Explore',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: selectedImage != null
                              ? Image.file(selectedImage!, fit: BoxFit.cover)
                              : const Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('About Place',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal, fontSize: 16, color: Colors.black)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: locationNameController,
                        decoration: InputDecoration(
                          hintText: 'Location Name',
                          hintStyle: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          ),
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: locationAddressController,
                        decoration: InputDecoration(
                          hintText: 'Location Address',
                          hintStyle: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          ),
                          prefixIcon: Icon(Icons.place_sharp),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Budget',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.normal, fontSize: 16, color: Colors.black)),
                          IconButton(
                            onPressed: _addTextFields,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      ...List.generate(_textControllers.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textControllers[index],
                                  decoration: InputDecoration(
                                    hintText: 'Add Category',
                                    hintStyle: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
                                    prefixIcon: Icon(Icons.description),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _amountControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Add Budget',
                                    hintStyle: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
                                    prefixIcon: Icon(Icons.currency_rupee),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      Text('Trip Highlights',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal, fontSize: 16, color: Colors.black)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Enter title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: contentController,
                        decoration: InputDecoration(
                          hintText: 'Add your thoughts',
                          hintStyle: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DecoratedContainer(
                        borderRadius: 24,
                        backgroundColor: locationNameController.text.isNotEmpty &&
                                locationAddressController.text.isNotEmpty
                            ? Colors.blue
                            : Colors.grey,
                        child: Center(
                          child: TextButton(
                            onPressed: _submitPost,
                            child: Text('Continue',
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.normal, fontSize: 18, color: Colors.black)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}