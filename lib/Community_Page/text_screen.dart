import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import './success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class TextScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;
  final Map<String, dynamic> userInfo;

  const TextScreen({
    Key? key,
    required this.onPostCreated,
    required this.userInfo,
  }) : super(key: key);

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  bool showImage = false;
  bool postSubmitted = false;
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  double modalHeight = 300; // Initial height

  @override
  void initState() {
    super.initState();
    titleController.addListener(_updateButtonState);
    contentController.addListener(_updateButtonState);
    _titleFocusNode.addListener(_adjustHeight);
    _contentFocusNode.addListener(_adjustHeight);
  }

  void _updateButtonState() {
    setState(() {});
  }

  void _adjustHeight() {
    setState(() {
      if (_titleFocusNode.hasFocus || _contentFocusNode.hasFocus) {
        // Adjust height based on showImage when keyboard appears
        modalHeight = showImage
            ? MediaQuery.of(context).size.height * 0.6 // Larger height with image
            : MediaQuery.of(context).size.height * 0.36; // Smaller height without image
      } else {
        // Return to normal height when keyboard dismisses
        modalHeight = 300;
      }
    });
  }

  @override
  void dispose() {
    titleController.removeListener(_updateButtonState);
    contentController.removeListener(_updateButtonState);
    _titleFocusNode.removeListener(_adjustHeight);
    _contentFocusNode.removeListener(_adjustHeight);
    titleController.dispose();
    contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: modalHeight + MediaQuery.of(context).viewInsets.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: postSubmitted
          ? const SuccessPost()
          : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: modalHeight, // Limit scrollable height
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              AvatarProfileImage(url: avatar.value, width: 20, height: 20),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName.value.toString(),
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w600, fontSize: 18, color: AppColors.bg1),
                                  ),
                                  Text(
                                    'New post',
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w400, fontSize: 12, color: AppColors.bg1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Stack(
                            children: [
                              DecoratedContainer(
                                borderRadius: 10,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showImage = !showImage;
                                      _adjustHeight(); // Adjust height when toggling showImage
                                    });
                                  },
                                  icon: FaIcon(FontAwesomeIcons.images),
                                ),
                              ),
                              const Positioned(
                                top: 10,
                                right: 2,
                                child: Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleController,
                        focusNode: _titleFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Enter title',
                          hintStyle: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w700, fontSize: 18, color: AppColors.bg1),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (showImage)
                        GestureDetector(
                          onTap: pickImage,
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
                      TextField(
                        controller: contentController,
                        focusNode: _contentFocusNode,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Add your thoughts',
                          border: InputBorder.none,
                          hintStyle: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal, fontSize: 14, color: AppColors.bg1),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          if (contentController.text.isNotEmpty) {
                            if (showImage && selectedImage == null) {
                              snackBarAllFeilds2(context, "Please Upload Image...");
                              return;
                            }

                            if (posting.value) return;
                            posting.value = true;

                            if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                              snackBarAllFeilds(context);
                              posting.value = false;
                              return;
                            }

                            if (selectedImage != null && showImage) {
                              createPost(context, titleController.text, contentController.text, selectedImage!);
                            } else {
                              createPostWithOutImage(context, titleController.text, contentController.text);
                            }

                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.1,
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                          decoration: BoxDecoration(
                            color: titleController.text.isNotEmpty && contentController.text.isNotEmpty
                                ? AppColors.primaryColor
                                : AppColors.button,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Obx(
                              () => posting.value
                                  ? Spinner(size: 30, color: Colorcodes.white)
                                  : Text(
                                      'Continue',
                                      style: FontManager().getTextStyle(
                                        context,
                                        lWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: titleController.text.isNotEmpty && contentController.text.isNotEmpty
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}