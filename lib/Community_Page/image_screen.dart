// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/loader.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import './success_post.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';

// class ImageScreen extends StatefulWidget {
//   final Function(Map<String, dynamic>) onPostCreated;
//   final Map<String, dynamic> userInfo;

//   const ImageScreen({
//     Key? key,
//     required this.onPostCreated,
//     required this.userInfo,
//   }) : super(key: key);

//   @override
//   State<ImageScreen> createState() => _ImageScreenState();
// }

// class _ImageScreenState extends State<ImageScreen> {
//   final TextEditingController textController = TextEditingController();
//   final TextEditingController titleController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   bool imageSubmitted = false;
//   File? selectedImage;

//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         selectedImage = File(image.path);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return imageSubmitted
//         ? const SuccessPost()
//         : Container(
//          // height: MediaQuery.of(context).size.height/2 ,
//           child: Expanded(
//             child: AnimatedPadding(
//               padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context)
//                       .viewInsets
//                       .bottom), // Adjusts padding when keyboard appears
//               duration: const Duration(milliseconds: 100),
//               child: SingleChildScrollView(
//                 child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 // CircleAvatar(
//                                 //   backgroundImage: NetworkImage(widget.userInfo['profilePic'].toString()),
//                                 //   radius: 24,
//                                 // ),
//                                  AvatarProfileImage(url:  avatar.value, width: 20, height: 20),
//                                 const SizedBox(width: 8),
//                                 Column(
//                                   children: [
//                                     Text(userName.value.toString(),
//                                         style: FontManager().getTextStyle(context,
//                                             lWeight: FontWeight.w600,
//                                             fontSize: 16,
//                                             color: AppColors.bg1)),
//                                     Text('New post',
//                                         style: FontManager().getTextStyle(context,
//                                             lWeight: FontWeight.w400,
//                                             fontSize: 12,
//                                             color: AppColors.bg1)),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         GestureDetector(
//                           onTap: _pickImage,
//                           child: Container(
//                             height: MediaQuery.of(context).size.height/3.5,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: selectedImage != null
//                                 ? Image.file(
//                                     selectedImage!,
//                                     fit: BoxFit.cover,
//                                   )
//                                 : const Icon(
//                                     Icons.add_photo_alternate,
//                                     size:50,
//                                     color: Colors.grey,
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         TextField(
//                           controller: titleController,
//                           decoration: InputDecoration(
//                               hintText: 'Enter title',
//                               hintStyle: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.w600,
//                                   fontSize: 18,
//                                   color: AppColors.bg1),
//                               border: InputBorder.none),
//                         ),
//                         const SizedBox(height: 10),
//                         TextField(
//                           controller: textController,
//                           decoration: InputDecoration(
//                               hintText: 'Add your thoughts',
//                               hintStyle: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.normal,
//                                   fontSize: 14,
//                                   color: AppColors.bg1),
//                               border: InputBorder.none),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                               if(selectedImage==null)
//                               {
//                                    snackBarAllFeilds2(context,"Please Upload Image");
//                                    return;
//                                }

//                             if(titleController.text.toString().trim()=="" || textController.text.toString().trim()==""){
//                                   snackBarAllFeilds(context);
//                                   return ;
//                             }
//                               if( posting.value)return;
//                               posting.value=true;
//                               if(selectedImage!=null)
//                             {
//                                createPost(context,titleController.text,textController.text,selectedImage!);
//                               //  onUploadImage(selectedImage!,context,titleController.text,textController.text);
//                             }
//                             else{
//                                createPostWithOutImage(context,titleController.text,textController.text);
//                             }
//                             Navigator.pop(context);
//                           },
//                           // child: Text('Continue',
//                           //   style: FontManager().getTextStyle(
//                           //     context,
//                           //     lWeight: FontWeight.w600,
//                           //     fontSize: 18,
//                           //     color: titleController.text.isNotEmpty &&
//                           //             textController.text.isNotEmpty
//                           //         ? Colors.white
//                           //         : Colors.black,
//                           //   )),
//                           child:Container(
//                               width: MediaQuery.of(context).size.width / 1.1,
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 14),
//                               decoration: BoxDecoration(
//                                   color: titleController.text.isNotEmpty &&
//                                           textController.text.isNotEmpty
//                                       ? AppColors.primaryColor
//                                       : AppColors.button,
//                                   borderRadius: BorderRadius.circular(24)),
//                               child: Center(
//                                 child:Obx(()=> posting.value? Spinner(size: 30,color: Colorcodes.white,): Text(
//                                   'Continue',
//                                   style: FontManager().getTextStyle(
//                                     context,
//                                     lWeight: FontWeight.bold,
//                                     fontSize: 15,
//                                     color: titleController.text.isNotEmpty &&
//                                             textController.text.isNotEmpty
//                                         ? Colors.white
//                                         : Colors.black,
//                                   ),
//                                 )),
//                               ),
//                             )
//                         )
//                       ],
//                     ),
//                   ),
//               ),
//             ),
//           ),
//         );
//   }

//   @override
//   void dispose() {
//     textController.dispose();
//     titleController.dispose();
//     super.dispose();
//   }
//  }

import 'dart:async';
import 'dart:ui';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application_code_stakeplot/Community_Page/success_post.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

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
  final CustomImageCropController _cropController = CustomImageCropController();
  File? selectedImage;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      snackBarAllFeilds2(context, 'Error picking image: $e');
    }
  }

  Future<File?> _cropAndSaveImage() async {
    try {
      if (selectedImage == null) {
        return null; // Silently fail instead of showing snackbar
      }

      final croppedImage = await _cropController.onCropImage();
      if (croppedImage == null) {
        return null; // Silently fail instead of showing snackbar
      }

      final byteData = await _imageProviderToByteData(croppedImage);
      if (byteData == null) {
        return null; // Silently fail instead of showing snackbar
      }

      final Uint8List bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png')
          .writeAsBytes(bytes);
      
      return file;
    } catch (e) {
      print('Error cropping image: $e'); // Log error instead of showing snackbar
      return null;
    }
  }

  Future<ByteData?> _imageProviderToByteData(ImageProvider imageProvider) async {
    final completer = Completer<ByteData?>();
    final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
    
    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        final image = info.image;
        image.toByteData(format: ImageByteFormat.png).then((byteData) {
          completer.complete(byteData);
          stream.removeListener(listener!);
        });
      },
      onError: (exception, stackTrace) {
        completer.completeError(exception, stackTrace);
        stream.removeListener(listener!);
      },
    );
    
    stream.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: AnimatedPadding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
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
                          AvatarProfileImage(url: avatar.value, width: 20, height: 20),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              Text(
                                userName.value.toString(),
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.bg1
                                ),
                              ),
                              Text(
                                'New post',
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: AppColors.bg1
                                ),
                              ),
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
                      height: MediaQuery.of(context).size.height / 3.1,
                      width: MediaQuery.of(context).size.width / 0.5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: selectedImage != null
                          ? CustomImageCrop(
                              image: FileImage(selectedImage!),
                              cropController: _cropController,
                              shape: CustomCropShape.Square,
                              overlayColor: Colors.black.withOpacity(0.5),
                              cropPercentage: 0.92, // Increased crop size
                              
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
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter title',
                      hintStyle: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w600,
                        fontSize: 18,
                        color: AppColors.bg1
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Add your thoughts',
                      hintStyle: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.bg1
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (selectedImage == null) {
                        snackBarAllFeilds2(context, "Please Upload Image");
                        return;
                      }

                      if (titleController.text.trim().isEmpty || 
                          textController.text.trim().isEmpty) {
                        snackBarAllFeilds(context);
                        return;
                      }

                      if (posting.value) return;

                      try {
                        posting.value = true;
                        
                        final croppedImageFile = await _cropAndSaveImage();
                        if (croppedImageFile == null) {
                          posting.value = false;
                          return; // Silently fail instead of showing snackbar
                        }

                        await createPost(
                          context,
                          titleController.text,
                          textController.text,
                          croppedImageFile,
                        );
                        
                        if (mounted) {
                          Navigator.pop(context);
                          Get.to(() => const SuccessPost());
                        }
                      } catch (e) {
                        print('Error posting: $e'); // Log error instead of showing snackbar
                      } finally {
                        if (mounted) {
                          posting.value = false;
                        }
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      decoration: BoxDecoration(
                        color: titleController.text.isNotEmpty &&
                                textController.text.isNotEmpty
                            ? AppColors.primaryColor
                            : AppColors.button,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Obx(() => posting.value
                            ? Spinner(size: 30, color: Colorcodes.white)
                            : Text(
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
                              )),
                      ),
                    ),
                  ),
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
    _cropController.dispose();
    super.dispose();
  }
}
