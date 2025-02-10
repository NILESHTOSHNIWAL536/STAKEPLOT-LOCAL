import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';

class ImageScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;
  final Map<String, dynamic> userInfo;

  const ImageScreen({
    Key? key,
    required this.onPostCreated,
    required this.userInfo,
  }) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool imageSubmitted = false;
  File? selectedImage;
  

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return imageSubmitted
        ? const SuccessPost()
        : Container(
          height: MediaQuery.of(context).size.height/2 ,
          child: Expanded(
            child: AnimatedPadding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context)
                      .viewInsets
                      .bottom), // Adjusts padding when keyboard appears
              duration: const Duration(milliseconds: 100),
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // CircleAvatar(
                                //   backgroundImage: NetworkImage(widget.userInfo['profilePic'].toString()),
                                //   radius: 24,
                                // ),
                                 AvatarProfileImage(url:  avatar.value, width: 5, height: 10),
                                const SizedBox(width: 8),
                                Column(
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
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: MediaQuery.of(context).size.height/3.5,
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
                                    size:50,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                              hintText: 'Enter title',
                              hintStyle: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: AppColors.bg1),
                              border: InputBorder.none),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: textController,
                          decoration: InputDecoration(
                              hintText: 'Add your thoughts',
                              hintStyle: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: AppColors.bg1),
                              border: InputBorder.none),
                        ),
                        GestureDetector(
                          onTap: () {
                              if(selectedImage==null)
                              {
                                   snackBarAllFeilds2(context,"Please Upload Image");
                                   return;
                               } 
                           
                            if(titleController.text.toString().trim()=="" || textController.text.toString().trim()==""){
                                  snackBarAllFeilds(context);
                                  return ;
                            }
                        
                              if(selectedImage!=null)
                            {
                              // createPost(context,titleController.text,descriptionsController.text,url!);
                               onUploadImage(selectedImage!,context,titleController.text,textController.text);
                            }
                            else{ 
                               createPostWithOutImage(context,titleController.text,textController.text);
                            }
                          },
                          // child: Text('Continue',
                          //   style: FontManager().getTextStyle(
                          //     context,
                          //     lWeight: FontWeight.w600,
                          //     fontSize: 18,
                          //     color: titleController.text.isNotEmpty &&
                          //             textController.text.isNotEmpty
                          //         ? Colors.white
                          //         : Colors.black,
                          //   )),
                          child:Container(
                              width: MediaQuery.of(context).size.width / 1.1,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 14),
                              decoration: BoxDecoration(
                                  color: titleController.text.isNotEmpty &&
                                          textController.text.isNotEmpty
                                      ? AppColors.primaryColor
                                      : AppColors.button,
                                  borderRadius: BorderRadius.circular(24)),
                              child: Center(
                                child: Text(
                                  'Continue',
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: titleController.text.isNotEmpty &&
                                            textController.text.isNotEmpty
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            )
                        )
                      ],
                    ),
                  ),
              ),
            ),
          ),
        );
  }

  @override
  void dispose() {
    textController.dispose();
    titleController.dispose();
    super.dispose();
  }
}
