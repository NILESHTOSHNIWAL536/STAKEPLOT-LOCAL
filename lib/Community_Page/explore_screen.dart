import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';

class ExploreModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;

  const ExploreModal({Key? key, required this.onPostCreated}) : super(key: key);

  @override
  _ExploreModalState createState() => _ExploreModalState();
}

class _ExploreModalState extends State<ExploreModal> {
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController locationAddressController =
      TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  List<TextEditingController> _textControllers = [];
  List<TextEditingController> _amountControllers = [];
  bool exploreSubmitted = false;

  @override
  void initState() {
    super.initState();
    // Initialize with two default controllers
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

  void _submitData() {
    List<Map<String, String>> budgetItems = [];

    for (int i = 0; i < _textControllers.length; i++) {
      String description = _textControllers[i].text.trim();
      String amount = _amountControllers[i].text.trim();

      if (description.isNotEmpty && amount.isNotEmpty) {
        budgetItems.add({
          'description': description,
          'amount': amount,
        });
      }
    }
    if (budgetItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in budget details')),
      );
      return;
    }

    String locationName = locationNameController.text.trim();
    String locationAddress = locationAddressController.text.trim();
    String title = titleController.text.trim();
    String content = contentController.text.trim();

    if (locationName.isEmpty ||
        locationAddress.isEmpty ||
        title.isEmpty ||
        content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    widget.onPostCreated({
      'profilePic': 'https://via.placeholder.com/50',
      'name': 'You',
      'contentType': 'Exploria',
      'locationName': locationName,
      'locationAddress': locationAddress,
      'budgetItems': budgetItems,
      'likeCount': 0,
      'isLiked': false,
      'title': title,
      'content': content,
    });
    setState(() {
      exploreSubmitted = true;
    });

    //Navigator.of(context).pop();
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
        : Padding(
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
                              lWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black)),
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
                          ? Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('About Place',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: locationNameController,
                    decoration: InputDecoration(
                      hintText: 'Location Name',
                      hintStyle: FontManager().getTextStyle(context,
                          lWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black),
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
                          lWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black),
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
                              lWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.black)),
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
                                    lWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: Colors.black),
                                prefixIcon: Icon(Icons.description),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
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
                                    lWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: Colors.black),
                                prefixIcon: Icon(Icons.currency_rupee),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
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
                          lWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black)),
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
                          lWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black),
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
                        onPressed: _submitData,
                        child: Text('Continue',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: 18,
                                color: Colors.black)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
