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
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:http/http.dart' as http; // Add this for HTTP requests
import 'dart:convert'; // For JSON encoding

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
    _textControllers.add(TextEditingController());
    _amountControllers.add(TextEditingController());
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void _addTextFields() {
    setState(() {
      _textControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());
    });
  }

  // Function to handle the API POST request
  Future<void> _submitPost() async {
    if (locationNameController.text.isEmpty || locationAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Prepare the budget list
    List<Map<String, dynamic>> budget = [];
    for (int i = 0; i < _textControllers.length; i++) {
      if (_textControllers[i].text.isNotEmpty && _amountControllers[i].text.isNotEmpty) {
        budget.add({
          "category": _textControllers[i].text,
          "amount": int.tryParse(_amountControllers[i].text) ?? 0,
        });
      }
    }

    // Prepare the body
    Map<String, dynamic> requestBody = {
      "pictures": selectedImage != null ? [selectedImage!.path] : [], // Replace with actual URL if uploaded
      "backGroundPicture": selectedImage != null ? selectedImage!.path : "", // Replace with actual URL if uploaded
      "place": {
        "name": locationNameController.text,
        "location": locationAddressController.text,
      },
      "budget": budget,
      "rating": 4.5, // Hardcoded for now; adjust as needed
      "tripHighlight": titleController.text,
      "description": contentController.text,
      "comments": 0, // Default value
      "shares": 0, // Default value
      "upvotes": 0, // Default value
      "userId": "60d0fe4f5311236168a109ca", // Replace with actual user ID
    };

    try {
      final response = await http.post(
        Uri.parse('${url}/exploria/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          exploreSubmitted = true;
        });
        widget.onPostCreated(jsonDecode(response.body)); // Notify parent widget
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit post: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
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
                            onPressed: _submitPost, // Call the submit function
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
