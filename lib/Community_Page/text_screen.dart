import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
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
  bool showImage = false;
  bool postSubmitted = false;
  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    titleController.addListener(_updateButtonState);
    contentController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {});
  }

  @override
  void dispose() {
    titleController.removeListener(_updateButtonState);
    contentController.removeListener(_updateButtonState);
    titleController.dispose();
    contentController.dispose();
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
    return postSubmitted
        ? const SuccessPost()
        : SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AvatarProfileImage(
                                url: avatar.value, width: 5, height: 10),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userName.value.toString(),
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: AppColors.bg1)),
                                Text('New post',
                                    style: FontManager().getTextStyle(context,
                                        lWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: AppColors.bg1)),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            DecoratedContainer(
                              borderRadius: 30,
                              // height: 50,
                              // width: 50,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showImage = !showImage;
                                  });
                                },
                                icon: const Icon(Icons.photo),
                              ),
                            ),
                            const Positioned(
                              top: 0,
                              right: 0,
                              // child: Text(
                              //   '+',
                              //   style: TextStyle(
                              //     fontSize: 22,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.black,
                              //   ),
                              // ),
                              child: Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                          hintText: 'Enter title',
                          hintStyle: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.bg1),
                          border: InputBorder.none),
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
                    TextField(
                      controller: contentController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Add your thoughts',
                        border: InputBorder.none,
                        hintStyle: FontManager().getTextStyle(context,
                            lWeight: FontWeight.normal,
                            fontSize: 14,
                            color: AppColors.bg1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DecoratedContainer(
                      borderRadius: 24,
                      backgroundColor: titleController.text.isNotEmpty &&
                              contentController.text.isNotEmpty
                          ? AppColors.primaryColor
                          : AppColors.button,
                      child: TextButton(
                        onPressed: () {
                          if (contentController.text.isNotEmpty) {
                            // widget.onPostCreated({
                            //   'profilePic':
                            //       widget.userInfo['profilePic'].toString(),
                            //   'name': widget.userInfo['name'].toString(),
                            //   'contentType': 'textImage',
                            //   'title': titleController.text,
                            //   'content': contentController.text,
                            //   'imageContent': selectedImage != null
                            //       ? selectedImage!.path
                            //       : '',
                            //   'likeCount': 0,
                            //   'isLiked': false,
                            // });
                            // setState(() {
                            //   postSubmitted = true;
                            // });

                            if (showImage && selectedImage == null) {
                              snackBarAllFeilds2(
                                  context, "Please Upload Image...");
                              return;
                            }

                            if (titleController.text.toString().trim() == "" ||
                                contentController.text.toString().trim() ==
                                    "") {
                              snackBarAllFeilds(context);
                              return;
                            }

                            if (selectedImage != null && showImage) {
                              // createPost(context,titleController.text,descriptionsController.text,url!);
                              onUploadImage(selectedImage!, context,
                                  titleController.text, contentController.text);
                            } else {
                              createPostWithOutImage(context,
                                  titleController.text, contentController.text);
                            }
                          }
                        },
                        child: Text('Continue',
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w600,
                              fontSize: 18,
                              color: titleController.text.isNotEmpty &&
                                      contentController.text.isNotEmpty
                                  ? Colors.white
                                  : Colors.black,
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
