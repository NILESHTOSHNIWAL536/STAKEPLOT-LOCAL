
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
import 'package:shared_preferences/shared_preferences.dart';

class ExploreModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;

  const ExploreModal({super.key, required this.onPostCreated});

  @override
  _ExploreModalState createState() => _ExploreModalState();
}

class _ExploreModalState extends State<ExploreModal> {
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController locationAddressController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = []; // Changed to List<File>
  static const int maxImages = 5;

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
    if (selectedImages.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImages.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void _addTextFields() {
    setState(() {
      _textControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());
    });
  }

  static Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("accessToken");
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
      }
    }

    // Upload all images and get their URLs
    List<String> imageUrls = [];
    for (File image in selectedImages) {
      String url = await postImageToCloud(image, context);
      imageUrls.add(url);
    }

    Map<String, dynamic> requestBody = {
      "pictures": imageUrls,
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
      'title': titleController.text,
      'description': {'message': requestBody},
      'image':  '', // First image as main image
      'fileName': '',
      'type': 'explore'
    };

    try {
      var accessToken = await getToken();
      final response = await http.post(
        Uri.parse('$url/post/'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "$accessToken",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() => exploreSubmitted = true);
        widget.onPostCreated(jsonDecode(response.body));
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
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildImageSection(),
                    const SizedBox(height: 10),
                    _buildPlaceSection(),
                    const SizedBox(height: 10),
                    _buildBudgetSection(),
                    const SizedBox(height: 20),
                    _buildHighlightSection(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.explore_sharp, size: 24, color: Colors.green),
        const SizedBox(width: 8),
        Text('Explore',
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: selectedImages.length < maxImages ? _pickImage : null,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: selectedImages.isEmpty
                ? const Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey)
                : null,
          ),
        ),
        if (selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        selectedImages[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: const Icon(Icons.cancel, color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About Place',
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal, fontSize: 16, color: Colors.black)),
        const SizedBox(height: 10),
        TextField(
          controller: locationNameController,
          decoration: _inputDecoration('Location Name', Icons.place_outlined),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: locationAddressController,
          decoration: _inputDecoration('Location Address', Icons.place_sharp),
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    decoration: _inputDecoration('Add Category', Icons.description),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Add Budget', Icons.currency_rupee),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHighlightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trip Highlights',
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal, fontSize: 16, color: Colors.black)),
        const SizedBox(height: 10),
        TextField(
          controller: titleController,
          decoration: _inputDecoration('Enter title', null),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: contentController,
          decoration: _inputDecoration('Add your thoughts', null),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled = locationNameController.text.isNotEmpty && 
                     locationAddressController.text.isNotEmpty;
    return DecoratedContainer(
      borderRadius: 24,
      backgroundColor: isEnabled ? Colors.blue : Colors.grey,
      child: Center(
        child: TextButton(
          onPressed: isEnabled ? _submitPost : null,
          child: Text('Continue',
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal, fontSize: 18, color: Colors.black)),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData? icon) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: FontManager().getTextStyle(context,
          lWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      prefixIcon: icon != null ? Icon(icon) : null,
    );
  }
}